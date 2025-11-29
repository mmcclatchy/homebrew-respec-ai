# Technical Specification: Phase 2 - Core Integrations

## Overview

### Objectives
Implement and verify the three core external integrations required for the RAG POC: LlamaIndex connection to Neo4j for knowledge base queries, Exa API integration via LangChain for best practices retrieval, and Lambda AI API client for agent-based evaluation, ensuring each component can be tested independently before combining them in Phase 3.

**Success Criteria:**
- LlamaIndex successfully queries Neo4j and returns results (even from empty database)
- Exa API returns relevant best practices results for test query (e.g., "Python error handling")
- Lambda AI API returns evaluation classification (sufficient/partial/insufficient) with visible reasoning for sample input
- Each integration has basic error handling showing connection failures clearly
- Simple test scripts demonstrate each integration working independently

### Scope
**Included:**
- LlamaIndex Neo4j graph store configuration and connection
- Simple Neo4j schema design for best practices storage (nodes for practices, edges for relationships)
- Exa search client initialization using LangChain integration
- Lambda AI API client setup with Qwen3-235B-A22B model configuration
- Basic query flow: MCP tool receives query → queries Neo4j via LlamaIndex → returns results
- Test scripts for each integration (test_neo4j.py, test_exa.py, test_lambda.py)
- Sample data insertion into Neo4j for query testing

**Excluded:**
- Agent evaluation logic (Phase 3)
- Knowledge gap detection (Phase 3)
- Result storage back to Neo4j (Phase 3)
- Three-path routing logic (Phase 3)
- Production error handling and retries
- Result caching strategies beyond basic Neo4j storage
- Query optimization or performance tuning

### Dependencies
**Prerequisites:**
- Phase 1 complete: Neo4j container running, MCP Server skeleton exists, environment configured
- API keys for Lambda AI and Exa available in .env file
- Neo4j accessible at localhost:7687

**Blocking Relationships:**
- Phase 1 must be complete before Phase 2 can begin
- All three integrations must be functional before Phase 3 agent evaluation can be implemented
- LlamaIndex + Neo4j must work before storage logic in Phase 3 can be added
- Basic query flow must work before adding conditional routing in Phase 3

### Deliverables
1. **src/integrations/neo4j_client.py** - LlamaIndex Neo4j graph store initialization and query methods
2. **src/integrations/exa_client.py** - Exa search client using LangChain integration
3. **src/integrations/lambda_client.py** - Lambda AI API client for evaluation calls
4. **src/schema/best_practices.py** - Pydantic models for best practice data structure
5. **scripts/test_neo4j.py** - Script demonstrating LlamaIndex query of Neo4j
6. **scripts/test_exa.py** - Script demonstrating Exa API search
7. **scripts/test_lambda.py** - Script demonstrating Lambda AI evaluation call
8. **scripts/seed_neo4j.py** - Script to insert sample best practices data for testing
9. **Integration Test Log** - Manual test results showing each integration functional

**Research Focus:**
- LlamaIndex Neo4j PropertyGraphStore documentation and examples
- Exa API search parameters and result structure (via LangChain docs)
- Lambda AI API request/response formats for Qwen3-235B-A22B model
- Neo4j Cypher query patterns for best practices retrieval
- LlamaIndex query engine configuration options

**Visual Deliverable (update to Phase 1 diagram):**
- Sequence diagram showing end-to-end query flow: Claude Code → MCP Server → LlamaIndex → Neo4j → Response, parallel flows for Exa and Lambda AI

## Metadata

### Iteration
0

### Version
1

### Status
draft