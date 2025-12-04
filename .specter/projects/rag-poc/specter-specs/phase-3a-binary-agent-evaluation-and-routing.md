# Technical Specification: phase-3a-binary-agent-evaluation-and-routing

## Overview

### Objectives
Implement agent-based evaluation logic that classifies Neo4j query results as "sufficient" or "insufficient" and routes the query flow accordingly. This phase establishes the core intelligence layer that determines whether cached knowledge meets user needs or requires external search.

### Scope
**Included:**
- Binary classification logic: sufficient vs insufficient (defer "partial" to Phase 3B)
- Integration of Lambda AI evaluation into query flow
- Routing logic based on classification:
  - **Sufficient**: Return cached results directly to MCP Server response
  - **Insufficient**: Trigger Exa search, store results to Neo4j, return fresh data
- Evaluation prompt refinement for binary decision accuracy
- Test scenarios for both evaluation paths
- Logging of evaluation reasoning for debugging and analysis

**Excluded:**
- "Partial" results classification (Phase 3B scope)
- Gap identification logic for partial results (Phase 3B scope)
- Advanced prompt engineering for improved accuracy (best-effort for POC)
- Evaluation confidence scoring (binary decision only)
- Multi-turn evaluation refinement

### Dependencies
**Prerequisites:**
- Phase 2A complete: Neo4j query capability via LlamaIndex functioning
- Phase 2B complete: Lambda AI evaluation function working (using PydanticAI agent)
- Phase 2B complete: Exa search function working (using LangChain Exa integration)
- Phase 1 complete: MCP Server skeleton ready for query routing logic

**Blocking Relationships:**
- This phase blocks Phase 3B: Partial results logic requires binary evaluation working first
- This phase blocks Phase 4: End-to-end testing requires at least binary paths functioning

**Technical Dependencies:**
- `evaluate_results()` function from Phase 2B Lambda AI integration
- `query_knowledge_base()` function from Phase 2A LlamaIndex integration
- `search_best_practices_exa()` function from Phase 2B Exa integration
- Neo4j write operations (Cypher INSERT or Python driver) for storing Exa results

### Deliverables
**Core Logic Deliverables:**
1. **src/agent_evaluator.py**: Module containing evaluation and routing logic
2. **evaluate_and_route() function**: Main orchestration function
   - Input: user_query (str)
   - Output: response (dict with results and metadata)
   - Logic: Query Neo4j → Evaluate → Route based on classification
3. **Routing Implementation**:
   - Sufficient path: Return cached results with source="cache" metadata
   - Insufficient path: Call Exa → Store to Neo4j → Return with source="exa" metadata

**Storage Logic Deliverables:**
4. **src/neo4j_writer.py**: Module for writing Exa results to Neo4j
5. **store_best_practice() function**: Converts SearchResult to BestPractice node and inserts to Neo4j
6. **Duplicate Prevention**: Check if content already exists before insertion (basic title matching)

**Prompt Engineering Deliverables:**
7. **Binary Evaluation Prompt**: Refined prompt template for sufficient/insufficient classification
    - Clear criteria definition for each classification
    - Examples of sufficient vs insufficient scenarios
    - Structured output format for reliable parsing
8. **Prompt Documentation**: Comment explaining evaluation criteria and expected reasoning

**Testing Deliverables:**
9. **Test Scenario Script**: Python script testing both paths
    - Test Case: Empty database query → Should route to insufficient → Exa search
    - Test Case: Well-populated query → Should route to sufficient → Return cache
10. **Evaluation Log Output**: Console logging showing classification reasoning for each test

**Integration Deliverables:**
11. **MCP Server Update**: Integrate evaluate_and_route() into MCP Server tool handler
12. **Response Format**: Standardize MCP Server response with results, source, and evaluation_reasoning fields

**Success Criteria:**
- ✅ Empty database queries consistently classified as "insufficient"
- ✅ Well-matched queries consistently classified as "sufficient"
- ✅ Insufficient path triggers Exa search and stores results to Neo4j
- ✅ Sufficient path returns cached results without Exa call
- ✅ Evaluation reasoning is visible and explains classification decision
- ✅ MCP Server responds with correct source metadata (cache vs exa)
- ✅ New Exa results successfully stored to Neo4j with BestPractice schema
- ✅ Phase 3A completion time: ≤1.5 hours including buffer

## System Design

### Architecture
#### Component Overview

```text
┌─────────────────────────────────────────────────────────────────┐
│                         MCP Server                              │
│                     (FastMCP Framework)                         │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     │ tool_call("query_best_practices", query)
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Agent Evaluator Module                       │
│                   (evaluate_and_route())                        │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ STEP 1: Query Neo4j Cache                                │   │
│  │ - Call query_knowledge_base(query)                       │   │
│  │ - Get List[BestPractice] results                         │   │
│  └──────────────────────────────────────────────────────────┘   │
│                           │                                     │
│                           ▼                                     │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ STEP 2: Evaluate Results                                 │   │
│  │ - Call evaluate_results(query, results)                  │   │
│  │ - Get Classification: sufficient | insufficient          │   │
│  │ - Get Reasoning: str                                     │   │
│  └──────────────────────────────────────────────────────────┘   │
│                           │                                     │
│              ┌────────────┴────────────┐                        │
│              ▼                         ▼                        │
│  ┌─────────────────────┐   ┌─────────────────────────────────┐  │
│  │ SUFFICIENT PATH     │   │ INSUFFICIENT PATH               │  │
│  │                     │   │                                 │  │
│  │ Return cached       │   │ 1. search_best_practices_exa()  │  │
│  │ results with:       │   │ 2. store_best_practice() to DB  │  │
│  │ - source="cache"    │   │ 3. Return fresh results with:   │  │
│  │ - reasoning         │   │    - source="exa"               │  │
│  │                     │   │    - reasoning                  │  │
│  └─────────────────────┘   └─────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                     │                           │
                     │                           │
         ┌───────────▼────────┐     ┌───────────▼────────────┐
         │  LlamaIndex        │     │  LangChain Exa         │
         │  Neo4j Query       │     │  Search Integration    │
         │  (Phase 2A)        │     │  (Phase 2B)            │
         └────────────────────┘     └────────────────────────┘
                     │                           │
                     │                           │
                     ▼                           ▼
         ┌────────────────────────────────────────────────────┐
         │              Neo4j Knowledge Graph                 │
         │                                                    │
         │  Nodes: BestPractice                               │
         │  Properties: title, content, url, category         │
         └────────────────────────────────────────────────────┘
```

#### Evaluation Logic Flow

```text
evaluate_and_route(user_query: str) → dict
    │
    ├─→ cached_results = query_knowledge_base(user_query)
    │   └─→ Returns List[BestPractice] (potentially empty)
    │
    ├─→ evaluation = evaluate_results(user_query, cached_results)
    │   │
    │   └─→ Lambda AI Agent (PydanticAI + Qwen3-235B-A22B)
    │       ├─→ Analyzes query intent
    │       ├─→ Examines result relevance
    │       ├─→ Returns: {"classification": "sufficient|insufficient", "reasoning": str}
    │
    └─→ Route based on classification:
        │
        ├─→ IF sufficient:
        │   └─→ return {
        │           "results": cached_results,
        │           "source": "cache",
        │           "evaluation_reasoning": reasoning
        │       }
        │
        └─→ IF insufficient:
            ├─→ fresh_results = search_best_practices_exa(user_query)
            ├─→ for result in fresh_results:
            │       store_best_practice(result)  # Write to Neo4j
            └─→ return {
                    "results": fresh_results,
                    "source": "exa",
                    "evaluation_reasoning": reasoning
                }
```

#### Component Interactions

**1. MCP Server → Agent Evaluator**
- Protocol: Function call
- Input: user_query (str)
- Output: dict with results, source, evaluation_reasoning
- Error Handling: Agent evaluator logs errors, returns empty results with error in reasoning

**2. Agent Evaluator → LlamaIndex Neo4j Query**
- Protocol: Function call to `query_knowledge_base()`
- Input: user_query (str)
- Output: List[BestPractice] (Pydantic models)
- Error Handling: Empty list on query failure

**3. Agent Evaluator → Lambda AI Evaluation**
- Protocol: Function call to `evaluate_results()`
- Input: user_query (str), results (List[BestPractice])
- Output: dict with classification and reasoning
- Error Handling: Default to "insufficient" on evaluation failure (prefer fetching fresh data)

**4. Agent Evaluator → Exa Search**
- Protocol: Function call to `search_best_practices_exa()`
- Input: user_query (str)
- Output: List[SearchResult] (LangChain models)
- Error Handling: Empty list on search failure, log error

**5. Agent Evaluator → Neo4j Writer**
- Protocol: Function call to `store_best_practice()`
- Input: SearchResult (individual result)
- Output: bool (success/failure)
- Error Handling: Log failures, continue with remaining results

#### Data Flow

**Sufficient Path (Cache Hit):**
```text
User Query → Neo4j → BestPractice[] → Lambda AI → "sufficient" → Return Cache
                                                                   ↓
                                                           MCP Response with
                                                           source="cache"
```

**Insufficient Path (Cache Miss/Inadequate):**
```text
User Query → Neo4j → BestPractice[] → Lambda AI → "insufficient"
                                                        ↓
                                                   Exa Search
                                                        ↓
                                               SearchResult[]
                                                   ↓        ↓
                                           Neo4j Write  Return Fresh
                                           (background)     ↓
                                                    MCP Response with
                                                    source="exa"
```

#### Design Decisions

**1. Binary Classification Only**
- Why: Simplifies POC logic, reduces Lambda AI decision complexity
- Trade-off: Misses optimization opportunity for partial results (addressed in Phase 3B)
- Alternative Considered: Three-way classification (sufficient/partial/insufficient) - deferred for complexity

**2. Sequential Storage (Not Batched)**
- Why: Simpler error handling, easier to debug individual failures
- Trade-off: Slightly slower for multiple results (~50ms overhead per write)
- Alternative Considered: Batch write transactions - overkill for POC with <10 results typically

**3. Default to "Insufficient" on Evaluation Error**
- Why: Prefer fresh data over stale/incorrect cache in error scenarios
- Trade-off: Extra Exa API calls during Lambda AI downtime
- Alternative Considered: Return cached results anyway - risks poor user experience

**4. Title-Based Duplicate Prevention**
- Why: Fast O(1) lookup, good enough for POC with small dataset
- Trade-off: May miss duplicates with slightly different titles
- Alternative Considered: Content hashing or semantic similarity - too complex for POC

**5. Synchronous Write Operations**
- Why: Ensures data written before response returned, simpler to test
- Trade-off: Adds ~50-200ms to insufficient path response time
- Alternative Considered: Async background writes - risks data loss on process failure

### Technology Stack
#### Core Technologies

**Python 3.13+**
- Justification: Project standard, modern async support, performance improvements
- Trade-offs: Bleeding edge, may have library compatibility issues
- Alternative Considered: Python 3.11 (more stable, but missing performance gains)

**PydanticAI 0.0.x (Lambda AI Agent)**
- Justification: Structured output validation, type-safe agent responses, Lambda AI integration
- Trade-offs: Early version may have bugs, limited community support
- Alternative Considered: Direct OpenAI API - more manual prompt engineering required

**LlamaIndex 0.11.x (Neo4j Querying)**
- Justification: Already integrated in Phase 2A, abstracts Cypher generation
- Trade-offs: Adds dependency layer, slightly slower than direct Cypher
- Alternative Considered: Neo4j Python Driver directly - requires manual Cypher writing

**LangChain 0.3.x (Exa Integration)**
- Justification: Already integrated in Phase 2B, provides Exa search abstraction
- Trade-offs: Heavy dependency, potential version conflicts with LlamaIndex
- Alternative Considered: Exa Python SDK directly - more boilerplate code

**Neo4j Python Driver 5.x (Write Operations)**
- Justification: Direct control over write operations, better performance than ORM
- Trade-offs: Manual Cypher writing for inserts, no automatic schema validation
- Alternative Considered: LlamaIndex write operations - less control, potential conflicts

**FastMCP 0.x (MCP Server Framework)**
- Justification: Simplified MCP server setup, already used in Phase 1
- Trade-offs: Early framework, may lack advanced features
- Alternative Considered: Manual MCP protocol implementation - too much boilerplate

#### Supporting Libraries

**Pydantic 2.x**
- Purpose: Data validation for BestPractice and SearchResult models
- Justification: Industry standard, type-safe, excellent error messages
- Trade-offs: Adds validation overhead (~1-5ms per model)

**Logging (Python stdlib)**
- Purpose: Evaluation reasoning logs, error tracking
- Justification: No external dependencies, sufficient for POC
- Trade-offs: Basic features, no structured logging
- Alternative Considered: structlog - overkill for POC

#### Environment Configuration

**Required Environment Variables:**
```bash
NEO4J_URI=bolt://localhost:7687
NEO4J_USERNAME=neo4j
NEO4J_PASSWORD=<password>
LAMBDA_AI_API_KEY=<key>
EXA_API_KEY=<key>
```

**Configuration Management:**
- Use Pydantic Settings for environment variable loading
- Validation on startup (fail fast if missing credentials)
- No hardcoded secrets in code

#### Version Compatibility Matrix

```text
Python 3.13+ ──┬──→ PydanticAI 0.0.x
               ├──→ LlamaIndex 0.11.x
               ├──→ LangChain 0.3.x
               ├──→ Neo4j Driver 5.x
               ├──→ FastMCP 0.x
               └──→ Pydantic 2.x
```

**Known Conflicts:**
- LlamaIndex and LangChain may share transitive dependencies with version conflicts
- Resolution: Pin specific versions in pyproject.toml, test thoroughly

## Implementation

### Functional Requirements
#### FR-1: Binary Classification Logic

**Requirement:** Agent must classify Neo4j query results as "sufficient" or "insufficient"

**Acceptance Criteria:**
- Lambda AI agent receives user query + cached results
- Agent returns structured response: `{"classification": "sufficient" | "insufficient", "reasoning": str}`
- Classification logic considers:
  - Result count (0 results → insufficient)
  - Result relevance to query intent
  - Result completeness (partial answers → insufficient for Phase 3A)
- Reasoning field explains decision in human-readable format

**Input Contract:**
```python
def evaluate_results(
    query: str,
    results: List[BestPractice]
) -> dict[str, str]:
    """
    Evaluate if cached results meet query needs.

    Returns:
        {"classification": "sufficient" | "insufficient", "reasoning": str}
    """
```

**Example Scenarios:**
- Empty results (0 BestPractice objects) → "insufficient"
- Query: "Python error handling", Results: 3 relevant BestPractice nodes → "sufficient"
- Query: "Python async patterns", Results: 1 BestPractice about sync code → "insufficient"

#### FR-2: Sufficient Path Routing

**Requirement:** When classification is "sufficient", return cached results without external search

**Acceptance Criteria:**
- No Exa API call triggered
- Response includes all cached BestPractice objects
- Response metadata includes source="cache"
- Response includes evaluation reasoning
- Response time <3 seconds

**Output Contract:**
```python
{
    "results": [BestPractice, BestPractice, ...],  # List of Pydantic models
    "source": "cache",
    "evaluation_reasoning": "Found 3 relevant articles on Python error handling..."
}
```

#### FR-3: Insufficient Path Routing

**Requirement:** When classification is "insufficient", trigger Exa search and store results

**Acceptance Criteria:**
- Exa API called with user query
- All Exa SearchResults written to Neo4j (with duplicate checking)
- Response includes fresh Exa results
- Response metadata includes source="exa"
- Response includes evaluation reasoning
- Response time <8 seconds

**Output Contract:**
```python
{
    "results": [SearchResult, SearchResult, ...],  # List of LangChain models
    "source": "exa",
    "evaluation_reasoning": "Cached results did not cover async/await patterns..."
}
```

#### FR-4: Neo4j Write Operations

**Requirement:** Store Exa SearchResults as BestPractice nodes in Neo4j

**Acceptance Criteria:**
- Each SearchResult converted to BestPractice schema
- Duplicate prevention: Check if title exists before insert
- Cypher INSERT executed via Neo4j Python Driver
- Write failures logged but don't halt execution
- Successful writes confirmed with query verification (optional, for testing)

**Data Mapping:**
```python
SearchResult → BestPractice Node
    .title → :title
    .snippet → :content
    .url → :url
    (inferred) → :category  # Extract from URL domain or default to "general"
```

**Duplicate Prevention Logic:**
```cypher
MATCH (bp:BestPractice {title: $title})
RETURN count(bp) > 0 AS exists
```
- If exists = true → Skip insert, log "Duplicate skipped: {title}"
- If exists = false → Execute insert

#### FR-5: Evaluation Prompt Engineering

**Requirement:** Lambda AI prompt must reliably produce binary classifications

**Acceptance Criteria:**
- Prompt includes clear criteria for "sufficient" vs "insufficient"
- Prompt includes 2-3 examples of each classification
- Prompt specifies structured output format (JSON)
- Prompt emphasizes binary decision (no partial classification)

**Prompt Structure:**
```text
System: You are a knowledge base evaluator. Classify cached results as "sufficient" or "insufficient".

Criteria:
- Sufficient: Results directly answer the query with relevant, complete information
- Insufficient: Results are empty, irrelevant, or incomplete

Examples:
[Example 1: Sufficient case]
[Example 2: Insufficient case]

Output Format: {"classification": "sufficient" | "insufficient", "reasoning": str}

Now evaluate:
Query: {user_query}
Cached Results: {results}
```

#### FR-6: MCP Server Integration

**Requirement:** Integrate evaluate_and_route() into MCP Server tool handler

**Acceptance Criteria:**
- MCP Server exposes `query_best_practices` tool
- Tool handler calls evaluate_and_route() with user query
- Tool response includes results, source, and reasoning
- Error handling returns user-friendly error messages
- Logging captures evaluation metadata for debugging

**Tool Definition:**
```python
@mcp.tool()
async def query_best_practices(query: str) -> dict:
    """
    Query knowledge base with intelligent caching.
    Returns cached results if sufficient, or fetches fresh data from Exa.
    """
    response = evaluate_and_route(query)
    return response
```

### Non-Functional Requirements
#### NFR-1: Performance Targets

**Response Time:**
- Sufficient path (cache only): <3 seconds p95
- Insufficient path (with Exa search): <8 seconds p95
- Neo4j query: <500ms p95
- Lambda AI evaluation: <1 second p95
- Exa search: <5 seconds p95
- Neo4j write (per result): <200ms p95

**Justification:** POC-level targets, not production-grade

#### NFR-2: Reliability

**Error Handling Strategy:**
- Neo4j query failure → Return empty results, log error, continue to evaluation
- Lambda AI evaluation failure → Default to "insufficient" classification (prefer fresh data)
- Exa search failure → Return empty results with error in reasoning field
- Neo4j write failure → Log error, continue with remaining writes

**Retry Logic:** No automatic retries (POC simplicity), manual retry via re-query

#### NFR-3: Observability

**Logging Requirements:**
- Log all evaluation decisions with reasoning
- Log all routing paths taken (sufficient vs insufficient)
- Log all Neo4j write operations (success/failure)
- Log all Exa API calls with query and result count
- Use Python logging module with INFO level for decisions, ERROR for failures

**Log Format:**
```python
logger.info(f"Evaluation: query='{query}', classification='{classification}', reasoning='{reasoning}'")
logger.info(f"Routing: path='{path}', source='{source}', result_count={count}")
logger.error(f"Neo4j write failed: title='{title}', error='{error}'")
```

#### NFR-4: Data Quality

**Duplicate Prevention:**
- Accuracy: 95% (title matching, may miss slight variations)
- Performance: O(1) lookup per result
- False Positives: Acceptable for POC (skip legitimate different content with same title)

**Result Relevance:**
- Lambda AI classification accuracy: >80% for clear-cut cases
- Accept lower accuracy for ambiguous queries (Phase 3B improvement)

#### NFR-5: Scalability Constraints

**POC Limitations:**
- Dataset size: <100 BestPractice nodes (no indexing optimization needed)
- Concurrent queries: 1 (no threading/async complexity)
- Exa results per query: <10 (no batching/pagination)
- Cache size: No limits (no eviction policy needed)

### Development Plan
#### Phase 3A.1: Core Evaluation Logic (30 minutes)

**Goal:** Implement evaluate_and_route() orchestration function

**Tasks:**
1. Create agent_evaluator module with evaluate_and_route() function
2. Integrate query_knowledge_base() call (Phase 2A)
3. Integrate evaluate_results() call (Phase 2B)
4. Implement routing logic (if/else on classification)
5. Return standardized response dict with results, source, reasoning

**Dependencies:** Phase 2A and 2B functions available and working

**Validation:**
- Unit test: Call with mock query, verify routing logic
- Integration test: Call with real Neo4j query, verify evaluation triggered

#### Phase 3A.2: Neo4j Write Operations (25 minutes)

**Goal:** Implement store_best_practice() for writing Exa results to Neo4j

**Tasks:**
1. Create neo4j_writer module
2. Implement store_best_practice() function with Cypher INSERT
3. Add duplicate prevention logic (title matching query)
4. Map SearchResult fields to BestPractice schema
5. Add error handling and logging for write failures

**Dependencies:** Neo4j Python Driver installed and configured

**Validation:**
- Unit test: Mock Neo4j connection, verify Cypher query structure
- Integration test: Write test result, query to confirm storage

#### Phase 3A.3: Prompt Refinement (15 minutes)

**Goal:** Refine Lambda AI evaluation prompt for binary classification accuracy

**Tasks:**
1. Review Phase 2B evaluation prompt
2. Add clear "sufficient" vs "insufficient" criteria
3. Add 2-3 examples of each classification
4. Emphasize structured JSON output format
5. Test with sample queries and results

**Dependencies:** Phase 2B evaluate_results() function accessible

**Validation:**
- Manual testing: Run evaluate_results() with edge cases (empty results, ambiguous results)
- Verify structured output format consistency

#### Phase 3A.4: MCP Server Integration (15 minutes)

**Goal:** Integrate evaluate_and_route() into MCP Server tool handler

**Tasks:**
1. Update MCP Server tool definition to call evaluate_and_route()
2. Add response formatting (results, source, reasoning)
3. Add error handling for agent evaluator failures
4. Add logging for MCP Server tool invocations

**Dependencies:** Phase 3A.1 evaluate_and_route() working

**Validation:**
- MCP Client test: Call query_best_practices tool via MCP protocol
- Verify response structure matches expected format

#### Phase 3A.5: End-to-End Testing (15 minutes)

**Goal:** Validate both routing paths with real queries

**Tasks:**
1. Create test scenario script with 2+ test cases
2. Test Case 1: Empty database query (expect insufficient path)
3. Test Case 2: Well-populated query (expect sufficient path)
4. Verify Exa results stored to Neo4j in insufficient path
5. Verify evaluation reasoning logged for both paths

**Dependencies:** All previous phases complete

**Validation:**
- Both test cases pass
- Logs show correct routing and reasoning
- Neo4j contains stored Exa results after insufficient test

### Testing Strategy
#### Test Levels

**1. Unit Tests**
- Component: evaluate_and_route() routing logic
  - Mock query_knowledge_base, evaluate_results, search_best_practices_exa
  - Verify routing decision based on classification
  - Verify response structure for both paths
- Component: store_best_practice() write logic
  - Mock Neo4j driver
  - Verify Cypher query structure
  - Verify duplicate prevention logic
- Component: Evaluation prompt structure
  - Verify prompt template contains required criteria and examples
  - Manual inspection (not automated)

**2. Integration Tests**
- Test: Neo4j query → evaluation → sufficient path
  - Setup: Populate Neo4j with 3 relevant BestPractice nodes
  - Execute: Call evaluate_and_route() with matching query
  - Assert: Classification = "sufficient", source = "cache", results returned
- Test: Neo4j query → evaluation → insufficient path → Exa search → storage
  - Setup: Empty Neo4j database
  - Execute: Call evaluate_and_route() with test query
  - Assert: Classification = "insufficient", source = "exa", results stored in Neo4j
- Test: Duplicate prevention
  - Setup: Neo4j contains BestPractice with title "Test Article"
  - Execute: Call store_best_practice() with SearchResult having same title
  - Assert: No duplicate created, log shows "Duplicate skipped"

**3. Manual Testing**
- Test: MCP Client tool invocation
  - Use MCP Inspector or Python client to call query_best_practices
  - Verify response structure and content
  - Verify logs show evaluation reasoning
- Test: Lambda AI evaluation accuracy
  - Run 10+ diverse queries with known expected classifications
  - Calculate accuracy: (correct_classifications / total_queries) > 0.8

#### Test Data Requirements

**Minimal Test Dataset:**
- 5 BestPractice nodes in Neo4j covering different topics:
  - Python error handling
  - Python async patterns
  - Neo4j Cypher queries
  - FastAPI best practices
  - Pydantic validation

**Test Query Set:**
- "How to handle Python errors?" (expect sufficient if populated)
- "What are obscure Python metaclass patterns?" (expect insufficient even if populated)
- "React hooks best practices" (expect insufficient if no React content)

#### Coverage Goals

**Code Coverage:** 70%+ (unit tests)
- Focus on routing logic, write operations, duplicate prevention
- Mock external dependencies (Lambda AI, Exa, Neo4j)

**Functional Coverage:** 100% (integration tests)
- Both routing paths validated
- Write operations validated
- Duplicate prevention validated

**Edge Case Coverage:**
- Empty database
- Empty evaluation results
- Lambda AI evaluation failure (default to insufficient)
- Neo4j write failure (log and continue)
- Exa search failure (return error in reasoning)

#### Quality Gates

**Pre-Commit:**
- All unit tests passing
- No syntax errors or import issues

**Pre-Integration:**
- Integration tests passing with real Neo4j instance
- Manual MCP Client test successful

**Phase Completion:**
- Both routing paths demonstrated working
- Test scenarios documented and reproducible
- Evaluation reasoning visible in logs

## Additional Details

### Research Requirements
#### Existing Documentation to Read

**Required Archives:**
1. `/Users/markmcclatchy/.claude/best-practices/2025-08-19-llamaindex-neo4j-integration.md`
    - Purpose: Understand LlamaIndex Neo4j query patterns for integration
    - Focus Areas: Query response handling, error handling patterns

2. `/Users/markmcclatchy/.claude/best-practices/pydantic-ai-production.md` (if exists)
    - Purpose: PydanticAI best practices for agent implementation
    - Focus Areas: Structured outputs, error handling, prompt engineering

**Optional Archives:**
3. `/Users/markmcclatchy/.claude/best-practices/mcp-server-development.md` (if exists)
    - Purpose: MCP Server integration patterns
    - Focus Areas: Tool definition, response formatting

#### External Research Needed

**High Priority:**
1. "PydanticAI binary classification prompt patterns 2025"
    - Need: Effective prompt structure for reliable binary decisions
    - Context: Lambda AI agent using Qwen3-235B-A22B model

2. "Neo4j Python Driver write operations best practices 2025"
    - Need: Efficient Cypher INSERT patterns, duplicate handling
    - Context: Writing Exa results to Neo4j graph

3. "LangChain Exa integration result mapping 2025"
    - Need: Understanding SearchResult model structure for conversion to BestPractice
    - Context: Data mapping from Exa to Neo4j schema

**Medium Priority:**
1. "Agent routing patterns for cache vs API decisions 2025"
    - Need: Industry patterns for intelligent cache evaluation
    - Context: Deciding when cached data is sufficient vs fetching fresh data

2. "Neo4j duplicate prevention strategies 2025"
    - Need: Efficient duplicate checking techniques beyond title matching
    - Context: Future improvement for Phase 3B (semantic similarity, content hashing)

### Success Criteria
#### Functional Success

**Binary Classification Accuracy:**
- Empty database queries: 100% classified as "insufficient"
- Well-populated relevant queries: >80% classified as "sufficient"
- Edge cases documented with reasoning even if misclassified

**Routing Correctness:**
- Sufficient classification: 0 Exa API calls triggered (verified via logs)
- Insufficient classification: 100% trigger Exa API calls
- Response metadata always matches routing path (source="cache" or source="exa")

**Data Persistence:**
- Exa results successfully stored to Neo4j: 100% success rate (excluding deliberate duplicates)
- Duplicate prevention: 95% accuracy (title matching)
- Neo4j query after storage returns newly written nodes

#### Non-Functional Success

**Performance:**
- Sufficient path response time: <3 seconds p95
- Insufficient path response time: <8 seconds p95 (including Exa search and storage)

**Observability:**
- All evaluation decisions logged with classification and reasoning
- All routing paths logged with source and result count
- All errors logged with context (query, operation, error message)

**Reliability:**
- Evaluation failures default to "insufficient" (safe fallback)
- Write failures don't halt execution (logged and skipped)
- MCP Server returns user-friendly errors on critical failures

#### Verification Methods

**Automated Tests:**
- Run test scenario script: Both test cases pass
- Unit tests: 70%+ code coverage
- Integration tests: Both routing paths validated

**Manual Verification:**
- MCP Inspector: Call query_best_practices tool successfully
- Neo4j Browser: Verify stored Exa results exist with correct schema
- Log Review: Evaluation reasoning is clear and explains decisions

**Phase Completion Checklist:**
- [ ] evaluate_and_route() function working for both paths
- [ ] Neo4j write operations storing Exa results correctly
- [ ] Duplicate prevention skipping existing titles
- [ ] MCP Server tool integration complete
- [ ] Test scenario script passes both test cases
- [ ] Logs show evaluation reasoning for all queries
- [ ] Phase completion time ≤1.5 hours

### Integration Context
#### Upstream Dependencies (Phase 2)

**Phase 2A: LlamaIndex Neo4j Querying**
- Interface: `query_knowledge_base(query: str) -> List[BestPractice]`
- Expected Behavior: Returns list of Pydantic BestPractice models from Neo4j
- Error Handling: Returns empty list on query failure
- Integration Point: Called in STEP 1 of evaluate_and_route()

**Phase 2B: Lambda AI Evaluation**
- Interface: `evaluate_results(query: str, results: List[BestPractice]) -> dict[str, str]`
- Expected Behavior: Returns dict with "classification" and "reasoning" keys
- Error Handling: This phase adds default to "insufficient" on failure
- Integration Point: Called in STEP 2 of evaluate_and_route()

**Phase 2B: Exa Search**
- Interface: `search_best_practices_exa(query: str) -> List[SearchResult]`
- Expected Behavior: Returns list of LangChain SearchResult models
- Error Handling: Returns empty list on search failure
- Integration Point: Called in STEP 3 (insufficient path) of evaluate_and_route()

#### Downstream Dependencies (Phase 3B, Phase 4)

**Phase 3B: Partial Results Logic**
- Will extend: evaluate_and_route() to handle "partial" classification
- Will add: Gap identification logic for partial results
- Will reuse: Neo4j write operations from this phase

**Phase 4: End-to-End Testing**
- Will validate: Full query flow including routing logic
- Will stress test: Performance targets defined in this phase
- Will benchmark: Evaluation accuracy across diverse queries

#### Cross-Cutting Concerns

**Configuration Management:**
- All credentials loaded via Pydantic Settings (Phase 2 pattern)
- Environment variables: NEO4J_URI, NEO4J_USERNAME, NEO4J_PASSWORD, LAMBDA_AI_API_KEY, EXA_API_KEY

**Logging:**
- Use Python logging module consistently across all phases
- Log level: INFO for decisions, ERROR for failures
- Log format: Structured messages with query context

**Error Propagation:**
- Phase 3A handles all downstream errors (Phase 2A, 2B functions)
- MCP Server handles Phase 3A errors (evaluate_and_route failures)
- User receives friendly error messages, not stack traces

## Metadata

### Iteration
1

### Version
2

### Status
draft
