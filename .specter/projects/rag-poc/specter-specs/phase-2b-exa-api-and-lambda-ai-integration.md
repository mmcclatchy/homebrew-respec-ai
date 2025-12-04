# Technical Specification: phase-2b-exa-api-and-lambda-ai-integration

## Overview

### Objectives
Integrate Exa API for best practices retrieval via LangChain and Lambda AI API for agent-based result evaluation using PydanticAI framework. This phase establishes the external search capability and evaluation intelligence that enable the hybrid cache decision-making system.

**Note on Execution Sequencing**: While this specification describes both integrations together, the actual execution order (Exa first, then Lambda AI, or parallel development) should be explored and determined during implementation based on developer learning curve and integration complexity. The specification maintains flexibility rather than enforcing strict sequential ordering.

### Scope
**Included:**

**Exa API Integration:**
- LangChain Exa integration configuration with API key authentication
- Best practices search function: `search_best_practices_exa(query: str) -> List[SearchResult]`
- Result parsing and normalization to match BestPractice schema structure
- Basic error handling for API failures (retry logic optional)
- Test queries to verify Exa response quality and relevance

**Lambda AI Integration:**
- PydanticAI agent setup for Lambda AI API (OpenAI-compatible endpoint)
- Evaluation agent with EvaluationResponse Pydantic model as result type
- System prompt design for result completeness classification (sufficient/partial/insufficient)
- Automatic response validation and retry logic via PydanticAI
- Test evaluation calls with diverse query/result combinations

**Data Structures:**
- `SearchResult` Pydantic model for Exa API responses
- `EvaluationResponse` Pydantic model with fields: classification (enum), reasoning (str), identified_gaps (List[str])

**Execution Flexibility:**
- Implementation order determined during phase execution based on:
  - Integration documentation quality and availability
  - Developer familiarity with API patterns
  - Complexity encountered in initial integration attempts
- Options: Sequential (Exa → Lambda AI), Sequential (Lambda AI → Exa), or Parallel development
- Document chosen approach and reasoning in phase notes

**Excluded:**
- Advanced Exa search filters or ranking customization
- Lambda AI model fine-tuning or advanced prompting techniques
- Retry logic with exponential backoff (basic retry acceptable)
- Rate limiting handling (assume POC usage within limits)
- Result caching for API responses
- Integration testing between Exa and Lambda AI (deferred to Phase 3)

### Dependencies
**Prerequisites:**
- Phase 1 complete: Environment variables configured for EXA_API_KEY and LAMBDA_AI_API_KEY
- Phase 1 complete: Python environment with LangChain and PydanticAI installed
- Phase 2A complete (optional): Understanding of BestPractice schema for result normalization helps but not strictly blocking

**Blocking Relationships:**
- This phase blocks Phase 3A: Agent evaluation logic requires working Lambda AI integration
- This phase blocks Phase 3B: Gap-filling logic requires working Exa search capability
- Phase 2A can complete independently: Neo4j + LlamaIndex integration has no dependency on external APIs

**Technical Dependencies:**
- Exa API access with valid API key and sufficient rate limits
- Lambda AI API access with Qwen3-235B-A22B model availability (OpenAI-compatible)
- PydanticAI library with OpenAI provider support
- Internet connectivity for API calls
- LangChain library with Exa integration support

**Execution Sequencing Considerations (Flexible):**
- If Exa documentation is clearer: Start with Exa integration to build confidence
- If Lambda AI prompt design seems simpler: Start with evaluation logic to understand output requirements
- If parallel development preferred: Work on both simultaneously with independent testing
- Decision point: First hour of Phase 2B based on initial exploration

### Deliverables
**Exa API Deliverables:**
1. **src/exa_client.py**: Module with Exa API integration via LangChain
2. **search_best_practices_exa() function**: Accepts query string, returns structured SearchResult list
3. **Result Normalization Function**: Converts Exa SearchResult to BestPractice schema format
4. **Exa Test Script**: Runs sample queries and prints results for manual validation
5. **Error Handling**: Basic try/except for API failures with informative error messages

**Lambda AI Deliverables:**
6. **src/lambda_ai_agent.py**: Module with PydanticAI agent for Lambda AI evaluation
7. **evaluate_results() function**: Accepts query + results, returns EvaluationResponse via PydanticAI agent
8. **Evaluation System Prompt**: System instructions for result completeness assessment
9. **Agent Configuration**: PydanticAI agent configured with Lambda AI endpoint and Qwen3 model
10. **Evaluation Test Script**: Runs sample evaluations with diverse result sets

**Data Structure Deliverables:**
11. **src/models.py**: Pydantic models for SearchResult, EvaluationResponse, Classification enum
12. **Type Hints**: All functions have complete type annotations using Pydantic models

**Documentation Deliverables:**
13. **README.md Update**: Add sections on Exa search usage and Lambda AI evaluation
14. **API Configuration Docs**: Document required environment variables and API key setup
15. **Execution Notes**: Document chosen integration order and reasoning in phase completion notes

**Success Criteria:**
- ✅ Exa API returns relevant best practices for test queries
- ✅ SearchResult objects successfully normalized to BestPractice format
- ✅ Lambda AI API returns structured evaluation with classification and reasoning
- ✅ Evaluation reasoning is readable and explains classification decision
- ✅ Both integrations tested independently with sample data
- ✅ Error handling prevents crashes on API failures
- ✅ Execution approach documented with reasoning for chosen sequencing
- ✅ Phase 2B completion time: ≤2 hours including buffer

## System Design

### Architecture
**Component Overview:**

This phase introduces two independent external API integration components that will later (Phase 3) be orchestrated together:

```text
┌─────────────────────────────────────────────────────────────────┐
│                     Phase 2B Components                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌────────────────────┐          ┌─────────────────────────┐    │
│  │   Exa Client       │          │  Lambda AI Agent        │    │
│  │  (LangChain-based) │          │  (PydanticAI-based)     │    │
│  └────────┬───────────┘          └───────┬─────────────────┘    │
│           │                              │                      │
│           │ SearchResult[]               │ EvaluationResponse   │
│           ▼                              ▼                      │
│  ┌─────────────────────┐         ┌──────────────────────────┐   │
│  │ Result Normalizer   │         │  Response Parser         │   │
│  │ (Exa → BestPractice)│         │ (JSON → Classification)  │   │
│  └────────┬────────────┘         └───────┬──────────────────┘   │
│           │                              │                      │
│           │ BestPractice[]               │ Classification       │
│           ▼                              ▼                      │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │            Data Models (models.py)                       │   │
│  │  - SearchResult                                          │   │
│  │  - BestPractice (from Phase 2A)                          │   │
│  │  - EvaluationResponse                                    │   │
│  │  - Classification (Enum: SUFFICIENT/PARTIAL/INSUFFICIENT)│   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
         │                                    │
         ▼                                    ▼
    Exa API                             Lambda AI API
  (External)                             (External)
```

**Component Interactions:**

1. **Exa Client Flow**:
   - Accept query string from caller
   - Configure LangChain Exa integration with API key
   - Execute search via LangChain wrapper
   - Parse LangChain response into SearchResult Pydantic models
   - Normalize SearchResult to BestPractice schema
   - Return BestPractice list to caller

2. **Lambda AI Agent Flow**:
   - Accept query string + BestPractice list from caller
   - Format agent context with query and results data
   - Execute PydanticAI agent with EvaluationResponse Pydantic model as result type
   - Agent automatically validates response against Pydantic model schema
   - Built-in retry logic handles validation failures
   - Return validated EvaluationResponse Pydantic model to caller

3. **Independent Testing Flow**:
   - Each component has dedicated test script
   - No inter-component dependencies during Phase 2B
   - Integration testing deferred to Phase 3

**Design Decisions:**

1. **LangChain for Exa vs PydanticAI for Lambda AI**:
   - **Rationale**: LangChain provides Exa integration (reduces code), PydanticAI provides structured output validation for Lambda AI (automatic retries, type safety)
   - **Trade-off**: Two frameworks instead of one, but each is best tool for its job

2. **Synchronous API Calls**:
   - **Rationale**: POC simplicity, no concurrent request requirements yet
   - **Trade-off**: Could use async for future performance, but adds learning curve

3. **Pydantic v2 Models (Not Dataclasses)**:
   - **Rationale**: Type safety, validation, consistency with Phase 2A, seamless PydanticAI integration
   - **Trade-off**: More verbose than plain dataclasses, but prevents runtime errors and enables validation

4. **No Result Caching**:
   - **Rationale**: POC focus, caching adds complexity without clear POC value
   - **Trade-off**: Repeated queries cost API calls, acceptable for testing

5. **Basic Error Handling Only**:
   - **Rationale**: 2-hour time constraint, advanced retry logic deferred
   - **Trade-off**: Less robust, but sufficient for POC validation

**Partial Failure Recovery Procedures:**

1. **Exa API Failures**:
   - **Detection**: HTTP errors (4xx/5xx), timeout exceptions, network errors
   - **Recovery Steps**:
     - Log full error context (query, error type, timestamp)
     - Return empty BestPractice list to allow Phase 3 to continue with cached results only
     - Set flag in response metadata indicating Exa unavailable
   - **Rationale**: System can function with cached results alone if external search fails

2. **Lambda AI API Failures**:
   - **Detection**: HTTP errors, timeout exceptions, malformed JSON responses
   - **Recovery Steps**:
     - Log full error context (query, results count, error details)
     - Return fallback EvaluationResponse with Classification.INSUFFICIENT
     - Include error message in reasoning field for debugging
   - **Rationale**: Conservative fallback triggers gap-filling search, safer than assuming sufficiency

3. **Partial Data Quality Issues**:
   - **Exa returns no results**: Return empty list (not error), log warning
   - **Lambda AI returns unparseable classification**: Default to INSUFFICIENT with error reasoning
   - **Normalization failures**: Skip malformed results, return valid subset with warning log
   - **Rationale**: Partial success better than complete failure, enables iterative debugging

**Data Flow Architecture:**

```text
┌─────────────────────────────────────────────────────────────┐
│                    Phase 2B Data Flow                       │
└─────────────────────────────────────────────────────────────┘

Exa Search Flow:
Query (str)
  → LangChain Exa Wrapper
    → Exa API
      → Raw JSON Response
        → SearchResult[]
          → Result Normalizer
            → BestPractice[]
              → Caller

Lambda AI Evaluation Flow:
Query (str) + BestPractice[]
  → Agent Context Formatter
    → PydanticAI Agent
      → Lambda AI API (OpenAI-compatible)
        → JSON Response
          → Automatic Validation (PydanticAI)
            → EvaluationResponse
              → Caller

Error Paths:
API Failure → Log Error → Return Safe Default (empty list or INSUFFICIENT)
Timeout → Log Error → Return Safe Default with timeout context
Parse Error → Log Error → Skip malformed data, return valid subset
```

**Key Architecture Properties:**

- **Independence**: Both components function without inter-dependencies
- **Testability**: Each component has isolated test script
- **Extensibility**: Clear interface contracts for Phase 3 integration
- **Simplicity**: Minimal abstraction layers (direct API → Model → Caller)
- **Type Safety**: Complete type hints enable static analysis
- **Resilience**: Failures return safe defaults rather than crashing

### Technology Stack
**Python Core:**
- **Python 3.13+**: Latest language features (match statements, improved type hints)
- **uv**: Package manager for dependency management and virtual environment

**Exa API Integration:**
- **LangChain Community 0.3.0+**: Exa integration wrapper
  - **Why**: Abstracts Exa API complexity, reduces custom HTTP handling
  - **Trade-off**: Adds dependency but saves ~50 lines of HTTP client code
- **Exa Python SDK** (if LangChain insufficient): Direct API access fallback
  - **Why**: LangChain wrapper may lack advanced features
  - **Trade-off**: More control but requires custom error handling

**Lambda AI Integration:**
- **PydanticAI 0.0.14+**: Type-safe LLM agent framework
  - **Why**: Automatic structured output validation, built-in retry logic, cleaner code
  - **Trade-off**: Additional framework dependency, but eliminates manual JSON parsing
- **Lambda AI API**: OpenAI-compatible endpoint at `https://api.lambda.ai/v1`
  - **Model**: Qwen3-235B-A22B (235B parameter model for high-quality reasoning)
  - **Why**: Strong reasoning capabilities for result evaluation task
  - **Compatibility**: OpenAI-compatible API works seamlessly with PydanticAI

**Data Validation:**
- **Pydantic 2.0+**: Data validation and serialization
  - **Why**: Type-safe models with automatic validation, consistent with Phase 2A patterns
  - **Trade-off**: Heavier than dataclasses, but prevents runtime type errors

**Development Tools:**
- **Python Standard Library**:
  - `json`: Response parsing
  - `os`: Environment variable access
  - `logging`: Error and debug logging
  - `typing`: Type hint support

**Environment Configuration:**
- **python-dotenv 1.0.0+**: Environment variable loading from .env file
  - **Why**: Simplifies local development without exposing API keys
  - **Trade-off**: Production would use proper secret management

**Version Pinning Strategy:**
- Pin major versions in pyproject.toml (e.g., `langchain-community = "^0.3.0"`)
- Allow minor/patch updates for bug fixes
- Lock exact versions in uv.lock for reproducibility

**Technology Decision Matrix:**

| Component | Options Considered | Chosen | Rationale |
|-----------|-------------------|--------|--------------|
| Lambda AI Client | httpx, PydanticAI, direct OpenAI SDK | PydanticAI | Automatic validation, retry logic, type safety |
| Exa Integration | Direct HTTP, Exa SDK, LangChain | LangChain | Pre-built integration, reduces boilerplate |
| Data Models | dataclasses, Pydantic v2, attrs | Pydantic v2 | Type safety, validation, works seamlessly with PydanticAI |
| Environment Config | os.environ, dotenv, pydantic-settings | dotenv | Simplest for POC, consistent with Phase 2A |

**Pydantic v2 Model Strategy:**
- All data structures use Pydantic BaseModel (not plain dataclasses)
- Enables automatic validation, serialization, and type safety
- SearchResult: Pydantic model with Exa response fields
- EvaluationResponse: Pydantic model used as PydanticAI result_type
- BestPractice: Pydantic model (shared with Phase 2A)
- Classification: Enum compatible with Pydantic

## Implementation

### Functional Requirements
**FR-1: Exa API Search**
- **Description**: Query Exa API for best practices using natural language queries
- **Input**: Query string (e.g., "Python error handling best practices 2025")
- **Output**: List of SearchResult objects containing title, URL, content snippet, relevance score
- **Validation**: Query length >3 characters, API key present
- **Error Handling**: API failures log error and return empty list

**FR-2: Search Result Normalization**
- **Description**: Convert Exa SearchResult to BestPractice schema format
- **Transformation**:
  - `SearchResult.title` → `BestPractice.title`
  - `SearchResult.url` → `BestPractice.source_url`
  - `SearchResult.content` → `BestPractice.summary` (first 500 chars)
  - `SearchResult.published_date` → `BestPractice.published_date` (if available)
  - Set `BestPractice.source_type = "exa_search"`
- **Validation**: Required fields must be non-empty, URL must be valid format
- **Error Handling**: Skip malformed results, log warnings, return valid results only

**FR-3: Lambda AI Result Evaluation**
- **Description**: Evaluate whether search results sufficiently answer query using PydanticAI agent
- **Input**: Query string + List[BestPractice]
- **Output**: EvaluationResponse with classification and reasoning
- **Classification Logic**:
  - `SUFFICIENT`: Results fully answer query with specific, actionable guidance
  - `PARTIAL`: Results provide some relevant info but miss key aspects
  - `INSUFFICIENT`: Results don't address query or lack actionable content
- **System Prompt Requirements**:
  - Include query text for context
  - Present result titles and summaries for evaluation
  - Request structured response matching EvaluationResponse schema
- **Validation**: Automatic via PydanticAI against EvaluationResponse Pydantic model
- **Error Handling**: PydanticAI retry logic handles validation failures; API failures return INSUFFICIENT with error context

**FR-4: Independent Testing**
- **Description**: Verify each integration works in isolation
- **Exa Test Cases**:
  1. Generic query: "Python best practices"
  2. Specific query: "FastAPI error handling 2025"
  3. Technology query: "Neo4j Cypher query optimization"
  4. Multi-term query: "async await patterns Python"
  5. Edge case: Empty string (should fail validation)
- **Lambda AI Test Cases**:
  1. Sufficient results: 3 relevant BestPractice objects
  2. Partial results: 1 relevant + 2 irrelevant objects
  3. Insufficient results: 0 objects or all irrelevant
- **Validation**: Manual review of printed results, no automated assertions required

### Non-Functional Requirements
**NFR-1: Performance**
- **Exa API Response Time**: <3 seconds per query (95th percentile)
- **Lambda AI Evaluation Time**: <5 seconds per evaluation (95th percentile)
- **Timeout Settings**: 10 seconds for Exa, 15 seconds for Lambda AI
- **Rationale**: POC testing tolerance, production would require <1s targets

**NFR-2: Reliability**
- **Error Recovery**: All API failures logged with full context (query, error type, timestamp)
- **No Silent Failures**: All exceptions propagated to caller with descriptive messages
- **Graceful Degradation**: Empty results or safe defaults preferred over crashes
- **Rationale**: POC needs debuggability over robustness

**NFR-3: Maintainability**
- **Code Readability**: Average function length <30 lines
- **Type Safety**: 100% type hint coverage for public functions
- **Documentation**: Docstrings for all public functions (parameters, return type, example usage)
- **Separation of Concerns**: Client logic, data models, test scripts in separate modules
- **Rationale**: Future developers (or AI agents) can modify without deep context

**NFR-4: Security**
- **API Key Storage**: Environment variables only (no hardcoded keys)
- **Logging Sanitization**: API keys never logged (redact sensitive values)
- **HTTPS Only**: All API calls use secure connections
- **Rationale**: Basic security hygiene for POC with real credentials

**NFR-5: Observability**
- **Logging Levels**: INFO for successful operations, WARNING for degraded responses, ERROR for failures
- **Log Format**: Timestamp + level + component + message + context dict
- **Example**: `2025-12-04 10:30:45 INFO exa_client Search completed query="Python errors" results_count=5`
- **Rationale**: Debugging support without full monitoring infrastructure

**NFR-6: Testability**
- **Test Script Execution Time**: <30 seconds per integration test suite
- **Manual Validation**: Printed output includes query, result count, sample content
- **No External Dependencies**: Test scripts runnable with just API keys configured
- **Rationale**: Fast feedback loop for iterative development

### Development Plan
**Phase 2B-1: Data Models Foundation**
- Define SearchResult Pydantic model (BaseModel) with Exa response fields
- Define EvaluationResponse Pydantic model (BaseModel) with classification + reasoning
- Define Classification enum (SUFFICIENT, PARTIAL, INSUFFICIENT)
- Create models.py module with all Pydantic model definitions
- Write unit test script validating Pydantic model instantiation and validation

**Phase 2B-2: Choose Integration Order**
- Review Exa LangChain documentation (exploration)
- Review Lambda AI API documentation (exploration)
- Decision criteria:
  - Documentation clarity and completeness
  - Example code availability
  - Perceived complexity based on initial review
- Document chosen order in implementation notes with reasoning

**Phase 2B-3A: Exa Integration (If chosen first)**
- Install langchain-community via uv
- Create exa_client module
- Implement search_best_practices_exa(query: str) → List[SearchResult]
- Configure LangChain Exa wrapper with API key from environment
- Implement result normalization: SearchResult → BestPractice
- Create exa_test script with 5 test queries
- Run tests and validate output manually
- Document any Exa-specific quirks or limitations

**Phase 2B-3B: Lambda AI Integration (If chosen first)**
- Install pydantic-ai via uv
- Create lambda_ai_agent module
- Import EvaluationResponse Pydantic model as PydanticAI result type
- Design evaluation system prompt for agent
- Configure PydanticAI agent:
  - Model: OpenAI-compatible provider pointing to Lambda AI endpoint
  - Result type: EvaluationResponse Pydantic model
  - System prompt: Evaluation instructions
- Implement evaluate_results() wrapper around agent.run_sync()
- Create lambda_test script with 3 test scenarios
- Run tests and validate classifications manually
- Document agent configuration and prompt design

**Phase 2B-4: Second Integration**
- Complete remaining integration (Exa if Lambda AI done, vice versa)
- Follow same implementation pattern as first integration
- Ensure consistent error handling and logging patterns
- Ensure consistent test script format

**Phase 2B-5: Documentation and Review**
- Update README.md with:
  - Exa API setup and usage examples
  - Lambda AI evaluation usage examples
  - Environment variable requirements
- Document execution order chosen and reasoning
- Review code for type hint completeness
- Run final test of both integrations end-to-end

**Phase Dependencies:**
- Phase 2B-1 is prerequisite for all other phases
- Phase 2B-2 determines sequence of 2B-3A and 2B-3B
- Phase 2B-4 depends on completion of first chosen integration (2B-3A or 2B-3B)
- Phase 2B-5 requires all implementation phases complete

**Flexibility Notes:**
- If first chosen integration exceeds expected duration, reassess approach
- If both integrations can complete in parallel (different modules), consider concurrent development
- If documentation for chosen integration is inadequate, switch to alternative integration first

### Testing Strategy
**Testing Philosophy:**
- Manual validation acceptable for POC phase
- Focus on integration testing (real API calls) over unit testing
- Verify behavior with diverse inputs rather than comprehensive edge cases
- Test scripts serve as usage examples for Phase 3 integration

**Test Levels:**

**Level 1: Data Model Validation**
- **Scope**: Pydantic model instantiation and validation
- **Approach**: Create test script that instantiates all models with valid/invalid data
- **Validation**: Models accept valid data, reject invalid data with clear errors
- **Manual Check**: Review validation error messages for clarity and usefulness

**Level 2: Exa Integration Testing**
- **Scope**: search_best_practices_exa() function with real API calls
- **Test Cases**:
  1. **Generic Query**: "Python best practices" → Expect 3-5 results
  2. **Specific Query**: "FastAPI error handling 2025" → Expect focused results
  3. **Technology Query**: "Neo4j Cypher optimization" → Expect database-specific results
  4. **Multi-term Query**: "async await patterns Python" → Expect async-focused results
  5. **Edge Case**: Empty string → Expect validation error
- **Manual Validation Criteria**:
  - Review printed results: Are titles relevant to query?
  - Check URLs: Do they point to credible sources (official docs, well-known blogs)?
  - Read content snippets: Are they on-topic and informative?
  - Verify normalization: Are all required BestPractice fields populated correctly?
- **Execution**: Run exa_test script, manually review printed output, document observations

**Level 3: Lambda AI Integration Testing**
- **Scope**: evaluate_results() function with real API calls
- **Test Scenarios**:
  1. **Sufficient Results**:
     - Query: "Python error handling"
     - Results: 3 BestPractice objects with comprehensive error handling content
     - Expected: Classification.SUFFICIENT
  2. **Partial Results**:
     - Query: "FastAPI async error handling middleware"
     - Results: 1 FastAPI object, 1 async object, 1 unrelated object
     - Expected: Classification.PARTIAL
  3. **Insufficient Results**:
     - Query: "Neo4j LangChain integration"
     - Results: Empty list or unrelated results
     - Expected: Classification.INSUFFICIENT
- **Manual Validation Criteria**:
  - Does classification match expectation? (SUFFICIENT/PARTIAL/INSUFFICIENT)
  - Is reasoning clear and human-readable?
  - Does reasoning explain the classification decision?
  - Are identified gaps specific and actionable?
- **Execution**: Run lambda_test script, manually review classifications and reasoning, document accuracy

**Level 4: Error Handling Testing**
- **Scope**: API failure scenarios
- **Test Cases**:
  1. **Invalid API Key**: Set EXA_API_KEY="" → Expect authentication error logged, empty list returned
  2. **Network Timeout**: Mock slow API response → Expect timeout exception logged, safe default returned
  3. **Malformed Response**: Mock invalid JSON → Expect parse error logged, safe handling
- **Manual Validation Criteria**:
  - Does system crash? (Should NOT crash)
  - Are error messages actionable and include context?
  - Do logs capture full error details (query, error type, timestamp)?
  - Does system return safe defaults rather than propagating exceptions?
- **Execution**: Modify test scripts to inject failures, verify error handling behavior

**Test Execution Workflow:**
1. Set environment variables (EXA_API_KEY, LAMBDA_AI_API_KEY)
2. Run model validation test: `uv run python tests/test_models.py`
3. Run Exa integration test: `uv run python tests/exa_test.py`
4. Review Exa output: Check result relevance, URL quality, normalization correctness
5. Run Lambda AI integration test: `uv run python tests/lambda_test.py`
6. Review Lambda AI output: Check classification accuracy, reasoning quality, gap identification
7. Run error handling tests: Inject failures, verify graceful degradation
8. Document any unexpected behaviors or API quirks

**Success Criteria:**
- All test scripts execute without crashes
- Exa returns relevant results for ≥4/5 test queries (manual assessment)
- Lambda AI classifications are reasonable for all 3 scenarios (manual assessment)
- Error handling prevents crashes in failure scenarios (manual verification)
- Test execution completes in <5 minutes total

**Limitations:**
- No automated assertions (manual validation only)
- No test coverage metrics
- No CI/CD integration
- Real API calls may have variable results (acceptable for POC)

## Additional Details

### Research Requirements
**Existing Documentation:**
- **Archive Scan Result**: No relevant archives found in best-practices collection
- **Local Documentation**: Phase 1 environment setup notes (if available) for API key configuration patterns

**External Research Needed:**

**Priority 1: Exa API + LangChain Integration (Critical)**
- **Topic**: "Exa API LangChain integration Python 2025"
- **Focus**: LangChain Exa wrapper configuration, authentication, result parsing
- **Specific Questions**:
  - How to configure LangChain Exa integration with API key?
  - What is the response format from LangChain Exa wrapper?
  - How to handle pagination or result limits?
  - Are there any known issues with LangChain Exa integration?
- **Deliverable**: Working search_best_practices_exa() implementation

**Priority 2: PydanticAI + Lambda AI Integration (Critical)**
- **Topic**: "PydanticAI OpenAI-compatible provider Lambda AI 2025"
- **Focus**: PydanticAI agent configuration for OpenAI-compatible APIs
- **Specific Questions**:
  - How to configure PydanticAI with custom OpenAI-compatible endpoint?
  - What is the correct provider format for Lambda AI base URL?
  - How to specify custom model name (Qwen3-235B-A22B) in PydanticAI?
  - How to use EvaluationResponse Pydantic model as result_type?
  - What happens when PydanticAI validation fails?
- **Deliverable**: Working PydanticAI agent configured for Lambda AI

**Priority 3: Lambda AI Prompt Engineering (Important)**
- **Topic**: "Lambda AI Qwen3 prompt engineering for result evaluation 2025"
- **Focus**: Effective prompt design for classification tasks
- **Specific Questions**:
  - What prompt structure works best for Qwen3 models?
  - How to request structured JSON responses?
  - Should system message or user message be used for instructions?
  - How to handle reasoning chain-of-thought in prompts?
- **Deliverable**: Effective evaluation prompt template

**Priority 4: Exa Search Quality Optimization (Optional)**
- **Topic**: "Exa API search quality best practices 2025"
- **Focus**: Query formatting for best results
- **Specific Questions**:
  - Does Exa perform better with natural language or keyword queries?
  - Are there search filters or ranking parameters to improve relevance?
  - What domains or sources does Exa prioritize?
- **Deliverable**: Improved test query success rate

**Research Execution Strategy:**
1. Start with Priority 1 and 2 (critical blockers)
2. Use official documentation first (Exa docs, Lambda AI docs, LangChain docs)
3. Supplement with recent blog posts or tutorials (2024-2025)
4. Validate findings with initial test implementations
5. Document any deviations from official patterns with reasoning

### Success Criteria
**Primary Criteria (Must Achieve):**
1. **Exa Integration Functional**: search_best_practices_exa() returns relevant results for ≥4/5 test queries
2. **Lambda AI Integration Functional**: evaluate_results() returns correct classifications for ≥2/3 test scenarios
3. **Data Normalization Successful**: Exa SearchResult → BestPractice conversion preserves all required fields
4. **Error Handling Robust**: No crashes on API failures, all errors logged with context
5. **Type Safety Complete**: All public functions have type hints, models validate input data
6. **Documentation Complete**: README includes setup and usage examples for both integrations

**Secondary Criteria (Desirable):**
7. **Test Script Quality**: Test scripts serve as clear usage examples for Phase 3
8. **Code Readability**: Average function length <30 lines, clear variable names
9. **Prompt Effectiveness**: Lambda AI reasoning is detailed and actionable

**Validation Methods:**
- **Functional Validation**: Run test scripts, manually review output
- **Code Validation**: Static analysis with mypy for type checking
- **Documentation Validation**: README walkthrough without external context

**Failure Scenarios:**
- **Exa Integration Fails**: Fallback to direct Exa SDK or Phase 3 continues with mock data
- **Lambda AI Integration Fails**: Fallback to rule-based evaluation or Phase 3 continues with simplified logic
- **Both Integrations Fail**: Escalate to POC planning review (may need different external services)

### Integration Context
**Upstream Dependencies (Phase 1):**
- Environment variables configured: EXA_API_KEY, LAMBDA_AI_API_KEY
- Python 3.13+ environment with uv package manager
- Project structure established (src/, tests/, README.md)

**Parallel Work (Phase 2A):**
- Neo4j + LlamaIndex integration for cached best practices
- BestPractice Pydantic model definition
- No blocking dependencies, but BestPractice schema used for normalization

**Downstream Consumers (Phase 3):**
- **Phase 3A: Agent Evaluation Logic**
  - Consumes: evaluate_results() function
  - Integration: Agent calls Lambda AI evaluation before deciding cache sufficiency
  - Data Flow: Query + Neo4j results → evaluate_results() → EvaluationResponse → Decision logic
- **Phase 3B: Gap-Filling Logic**
  - Consumes: search_best_practices_exa() function
  - Integration: Agent calls Exa search when gaps identified
  - Data Flow: Identified gaps → search_best_practices_exa() → New results → Merge with cached results

**Interface Contracts:**

**Exa Client Interface:**
```python
def search_best_practices_exa(query: str) -> List[BestPractice]:
    """
    Search Exa API for best practices matching query.

    Args:
        query: Natural language query string (min 3 chars)

    Returns:
        List of BestPractice objects with normalized Exa results

    Raises:
        ValueError: If query is empty or too short
        ExaAPIError: If Exa API request fails
        ExaAuthError: If API key is invalid
    """
```

**Lambda AI Agent Interface:**
```python
def evaluate_results(
    query: str,
    results: List[BestPractice]
) -> EvaluationResponse:
    """
    Evaluate whether results sufficiently answer query using PydanticAI agent.

    Args:
        query: Original user query
        results: Best practices returned from cache or search

    Returns:
        EvaluationResponse with validated classification and reasoning

    Raises:
        ValueError: If query is empty or results is None
        ModelRetry: If PydanticAI validation fails after retries
        LambdaAPIError: If Lambda AI API request fails
        LambdaAuthError: If API key is invalid

    Implementation:
        Uses PydanticAI agent with EvaluationResponse result type.
        Automatic validation ensures type safety.
    """
```

**System Boundaries:**
- Phase 2B does NOT implement orchestration logic (that's Phase 3)
- Phase 2B does NOT integrate with Neo4j (that's Phase 2A)
- Phase 2B does NOT implement MCP Server interface (that's Phase 4)
- Phase 2B provides independent, testable API client functions

## Data Models
### Core Data Structures

**SearchResult (Exa API Response)**

Pydantic model for Exa API search results (inherits from BaseModel):

- **title** (str): Result title, 1-500 characters
- **url** (HttpUrl): Source URL, validated HTTP/HTTPS format
- **content** (str): Content snippet or full text, 1-5000 characters
- **score** (float): Relevance score from Exa, range 0.0-1.0
- **published_date** (Optional[str]): Publication date if available, ISO 8601 format

Validation requirements:
- Title must be non-empty
- URL must be valid HTTP/HTTPS format
- Content must be non-empty
- Score must be between 0.0 and 1.0

**EvaluationResponse (Lambda AI Evaluation Result)**

Pydantic model for Lambda AI evaluation responses (used as PydanticAI result_type):

- **classification** (Classification enum): Sufficiency category
  - SUFFICIENT: Results fully answer query with actionable guidance
  - PARTIAL: Results provide some relevant info but miss key aspects
  - INSUFFICIENT: Results don't address query or lack actionable content
- **reasoning** (str): Human-readable explanation, 10-2000 characters
- **identified_gaps** (List[str]): List of specific topics/aspects missing from results
- **confidence** (Optional[float]): Confidence score, range 0.0-1.0

Validation requirements:
- Classification must be valid enum value
- Reasoning must be at least 10 characters to enforce substance
- Identified gaps can be empty for SUFFICIENT, recommended for PARTIAL/INSUFFICIENT

**BestPractice (Normalized Result Schema)**

Pydantic model for normalized best practice records (shared with Phase 2A):

- **title** (str): Practice title, 1-500 characters
- **summary** (str): Brief description or content snippet, 1-5000 characters
- **source_url** (HttpUrl): Original source URL
- **source_type** (str): Origin identifier (e.g., "exa_search", "neo4j_cache")
- **tags** (List[str]): Optional list of topic tags
- **published_date** (Optional[str]): Optional publication date
- **created_at** (datetime): Timestamp of record creation

Note: This schema matches Phase 2A Neo4j node structure for consistency.

### Data Transformation Rules

**SearchResult → BestPractice Normalization:**

Mapping logic for transforming Exa search results:
- `SearchResult.title` → `BestPractice.title` (direct copy)
- `SearchResult.url` → `BestPractice.source_url` (direct copy)
- `SearchResult.content` → `BestPractice.summary` (truncate to 500 chars if needed)
- `SearchResult.published_date` → `BestPractice.published_date` (direct copy if present)
- `BestPractice.source_type` = "exa_search" (hardcoded)
- `BestPractice.tags` = extracted from title (simple keyword extraction)
- `BestPractice.created_at` = current timestamp

Validation and error handling:
- Skip results with empty title or content
- Validate URL format before assignment
- Log warnings for any data loss during truncation
- Return only successfully normalized results

## Metadata

### Iteration
3

### Version
4

### Status
draft
