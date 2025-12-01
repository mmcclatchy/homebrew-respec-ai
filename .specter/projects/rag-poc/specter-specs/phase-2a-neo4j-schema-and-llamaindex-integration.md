# Technical Specification: phase-2a-neo4j-schema-and-llama-index-integration

## Overview

### Objectives
Implement a concrete Neo4j schema for storing best practices and integrate LlamaIndex to enable natural language querying of the knowledge base. This phase establishes the "read from cache" capability that forms the foundation of the hybrid cache system.

### Scope
**Included:**
- **Concrete Neo4j Schema Design**:
  - `BestPractice` node type with specific properties
  - Example node structure:
    ```cypher
    (:BestPractice {
      title: "Python Error Handling with Context Managers",
      content: "Use context managers for resource cleanup...",
      topic: "error-handling",
      framework: "python",
      language: "python",
      source: "exa-api",
      created_at: "2025-11-29T10:30:00Z",
      id: "uuid-v4-string"
    })
    ```
  - Simple relationship structure (optional): `(:BestPractice)-[:RELATED_TO]->(:BestPractice)`

- LlamaIndex Neo4j integration configuration
- Natural language query translation to Neo4j Cypher via LlamaIndex
- Query execution and result retrieval from Neo4j
- Sample data insertion for testing (2-3 best practices nodes)
- Basic query testing with diverse natural language inputs

**Excluded:**
- Complex Neo4j indexing or performance optimization
- Advanced graph relationships beyond simple RELATED_TO edges
- LlamaIndex fine-tuning or advanced configuration
- Result ranking or relevance scoring
- Query caching or optimization
- Schema migration tooling (manual schema is acceptable for POC)

### Dependencies
**Prerequisites:**
- Phase 1 complete: Neo4j container running and accessible
- Phase 1 complete: Python environment with LlamaIndex installed
- Phase 1 complete: Neo4j Python driver available

**Blocking Relationships:**
- This phase blocks Phase 3A: Agent evaluation cannot assess cached results quality without working Neo4j queries
- This phase blocks Phase 3B: Partial results path cannot combine cached + fresh data without cache reads working
- Phase 2B can proceed in parallel: Exa and Lambda AI integrations are independent

**Technical Dependencies:**
- Neo4j Bolt connection from Phase 1 environment variables
- LlamaIndex Neo4j connector library (installed in Phase 1)
- Understanding of basic Cypher query syntax for debugging

### Deliverables
**Schema Deliverables:**
1. **schema.cypher**: Cypher script defining BestPractice node structure with constraints
   - Unique constraint on BestPractice.id
   - Index on BestPractice.topic for query performance
2. **Sample Data Script**: Cypher or Python script inserting 2-3 example best practices for testing
3. **Schema Documentation**: Comment block in schema.cypher explaining node properties and their purposes

**Integration Deliverables:**
4. **src/neo4j_client.py**: Module encapsulating LlamaIndex Neo4j configuration and query methods
5. **Query Function**: `query_knowledge_base(natural_language_query: str) -> List[BestPractice]`
6. **Result Parsing**: Convert LlamaIndex query results to structured BestPractice objects

**Testing Deliverables:**
7. **Test Queries Script**: Python script running diverse natural language queries
    - Example: "How to handle errors in Python?"
    - Example: "FastAPI async patterns"
    - Example: "React hooks best practices"
8. **Query Results Validation**: Manual verification that results match expected best practices

**Documentation Deliverables:**
9. **README.md Update**: Add section on Neo4j schema structure and LlamaIndex query usage
10. **Inline Documentation**: Docstrings for query_knowledge_base function and BestPractice data structure

**Success Criteria:**
- ✅ Neo4j contains concrete schema with BestPractice nodes including title, content, topic, framework, language properties
- ✅ Sample data queryable via Neo4j browser (<http://localhost:7474>)
- ✅ LlamaIndex successfully translates natural language to Cypher queries
- ✅ Query function returns structured results with all node properties
- ✅ At least 3 diverse test queries execute successfully
- ✅ Results are relevant to query intent (manual validation)
- ✅ Phase 2A completion time: ≤2 hours including buffer

## Metadata

### Iteration
0

### Version
1

### Status
draft
