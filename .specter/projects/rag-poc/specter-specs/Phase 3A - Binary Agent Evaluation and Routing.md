# Technical Specification: Phase 3A - Binary Agent Evaluation and Routing

## Overview

### Objectives
Implement the core intelligence layer with agent-based evaluation of Neo4j query results to determine if cached knowledge is sufficient or insufficient, and implement binary routing logic that returns cached results for sufficient cases or triggers Exa API search for insufficient cases, with storage of new results back to Neo4j.

**Success Criteria:**
- Agent evaluation receives query + Neo4j results and returns classification (sufficient/insufficient) with reasoning
- Evaluation prompt is structured and produces consistent, interpretable results
- Binary routing correctly returns cached results when sufficient
- Binary routing triggers Exa search when insufficient and stores results to Neo4j
- At least 5/7 test queries show correct path selection (sufficient vs insufficient)
- Logging shows evaluation reasoning for debugging

### Scope
**Included:**
- Agent evaluation prompt engineering for result completeness assessment
- Lambda AI API call with structured prompt (query context + results + classification request)
- Binary routing logic: sufficient path vs insufficient path
- Sufficient path: Return Neo4j results directly
- Insufficient path: Query Exa → Parse results → Store to Neo4j → Return
- Result storage logic for Exa search results into Neo4j
- Test cases for both paths (empty database, populated database)
- Evaluation reasoning logging for analysis

**Excluded:**
- Partial path implementation (moved to Phase 3B)
- Gap identification logic for partial results (moved to Phase 3B)
- Hybrid result merging (moved to Phase 3B)
- Production-level prompt optimization
- Evaluation confidence scores or multi-tier classification
- Result deduplication or conflict resolution

### Dependencies
**Prerequisites:**
- Phase 2 complete: All integrations functional (Neo4j, Exa, Lambda AI)
- LlamaIndex can query Neo4j successfully
- Exa API returns search results
- Lambda AI API responds with evaluations

**Blocking Relationships:**
- Phase 2 must be complete before Phase 3A can begin
- Binary routing must work before Phase 3B partial path can be added
- Storage logic must be functional before Phase 3B can merge results

### Deliverables
1. **src/agent/evaluator.py** - Agent evaluation logic with structured prompt for Lambda AI
2. **src/agent/prompts.py** - Evaluation prompt templates (sufficient/insufficient classification)
3. **src/routing/query_router.py** - Binary routing logic based on evaluation results
4. **src/storage/neo4j_storage.py** - Logic to store Exa results into Neo4j graph
5. **src/mcp_server.py (updated)** - MCP tool integrated with evaluation and routing
6. **scripts/test_binary_routing.py** - Test script for both routing paths
7. **Evaluation Test Log** - Results from diverse test queries showing classification accuracy

**Research Focus:**
- Prompt engineering patterns for binary classification tasks
- Lambda AI API best practices for structured output
- LlamaIndex document ingestion from external sources (Exa results)
- Neo4j Cypher patterns for inserting nodes and relationships efficiently
- Logging strategies for agent reasoning visibility

**Visual Deliverable (update sequence diagram):**
- Decision flow diagram showing: Query → Neo4j → Evaluation (Sufficient? Yes: Return | No: Exa → Store → Return)

## Metadata

### Iteration
0

### Version
1

### Status
draft
