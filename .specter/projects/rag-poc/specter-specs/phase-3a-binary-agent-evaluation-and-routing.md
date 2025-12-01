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
- Phase 2B complete: Lambda AI evaluation function working
- Phase 2B complete: Exa search function working
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

## Metadata

### Iteration
0

### Version
1

### Status
draft
