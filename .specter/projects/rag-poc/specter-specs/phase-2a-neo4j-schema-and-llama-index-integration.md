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

## System Design

### Architecture
**Component Structure:**

```text
┌─────────────────────────────────────────────────────────────┐
│                     Application Layer                       │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  query_knowledge_base(query: str)                    │   │
│  │  - Input: Natural language query string              │   │
│  │  - Output: List[BestPractice] Pydantic models        │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                  LlamaIndex Integration Layer               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Neo4jGraphStore                                     │   │
│  │  - Manages Neo4j connection (bolt://localhost:7687)  │   │
│  │  - Translates NL query → Cypher                      │   │
│  │  - Executes graph queries                            │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                     Neo4j Graph Database                    │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  (:BestPractice) Nodes                               │   │
│  │  - Properties: id, title, content, topic, framework  │   │
│  │  - Constraints: UNIQUE(id)                           │   │
│  │  - Indexes: INDEX(topic)                             │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

**Data Flow:**

1. **Query Input:** User provides natural language query string
2. **Translation:** LlamaIndex Neo4jGraphStore converts NL to Cypher pattern matching
3. **Execution:** Cypher query executes against Neo4j graph using indexed properties
4. **Result Parsing:** Neo4j records mapped to Pydantic BestPractice models
5. **Return:** Structured list of BestPractice objects to caller

**Key Design Decisions:**

- **LlamaIndex Over Direct Cypher:** Abstracts NL→Cypher translation, reduces prompt engineering complexity by ~60%, acceptable dependency for POC
- **Simple Schema:** Single node type with flat properties avoids premature graph complexity, supports POC validation goals
- **Environment-Based Config:** Credentials via environment variables meets security requirement, enables container-based deployment
- **Pydantic Models:** Structured result parsing ensures type safety, simplifies downstream processing in Phase 3

**Integration Points:**

- Neo4j connection via bolt:// protocol (port 7687)
- LlamaIndex graph store interface for query abstraction
- Pydantic model layer for structured data validation

### Technology Stack
**Core Technologies:**

1. **Neo4j Community Edition 5.0+**
   - Why: Native graph database with Cypher query language, bolt protocol support
   - Trade-offs: Community edition lacks clustering, acceptable for POC single-instance deployment
   - Justification: Best-in-class graph database with mature Python ecosystem

2. **LlamaIndex 0.9+ with Neo4j Integration**
   - Why: Provides Neo4jGraphStore abstraction, reduces NL→Cypher complexity
   - Trade-offs: Adds dependency vs direct neo4j driver, but saves ~60% development time on query translation
   - Justification: Mature LLM integration library with proven Neo4j connector

3. **Python 3.13+ with Pydantic**
   - Why: Type-safe data models, automatic validation, clean API design
   - Trade-offs: Slight performance overhead vs plain dicts, negligible for POC scale
   - Justification: Aligns with project standards, enhances code quality

4. **neo4j Python Driver 5.0+**
   - Why: Official driver with connection pooling, bolt protocol support
   - Trade-offs: None, required dependency for Neo4j access
   - Justification: Production-ready driver with extensive documentation

**Configuration Approach:**

```python
# Environment-based configuration (no hardcoded credentials)
NEO4J_URI=bolt://localhost:7687
NEO4J_USERNAME=neo4j
NEO4J_PASSWORD=<secure-password>
NEO4J_DATABASE=neo4j  # Default database name
```

**Version Justifications:**
- Neo4j 5.0+: Required for modern Cypher syntax, improved indexing performance
- LlamaIndex 0.9+: Neo4jGraphStore API stability, active maintenance
- Python 3.13+: Project standard, type hinting support

## Implementation

### Functional Requirements
**FR1: Natural Language Query Processing**
- Accept plain English queries describing desired best practices
- Examples: "Python error handling", "async patterns in FastAPI", "React hooks best practices"
- Translate to Cypher MATCH patterns targeting BestPractice nodes
- Support property filtering (topic, framework, language)

**FR2: Structured Result Retrieval**
- Return BestPractice objects with all schema properties populated
- Include: id, title, content, topic, framework, language, source, created_at
- Handle empty results gracefully (empty list, not error)
- Parse Neo4j datetime types to Python datetime

**FR3: Schema Integrity Enforcement**
- Unique constraint on BestPractice.id prevents duplicates
- Index on topic property ensures fast filtering
- All required fields validated at insertion time

**FR4: Sample Data Accessibility**
- 2-3 diverse best practice nodes queryable via Neo4j browser (<http://localhost:7474>)
- Cover multiple topics: error-handling, async-programming, ui-patterns
- Demonstrate complete property population

### Non-Functional Requirements
**NFR1: Performance Targets**
- Query response time: <2 seconds for POC dataset (<10 nodes)
- Measurement: Time from query_knowledge_base call to return
- Constraint: Single-threaded execution acceptable for POC

**NFR2: Connection Management**
- Neo4j connection via bolt protocol, default driver settings
- Environment variables for all credentials (no hardcoding)
- Graceful connection failure handling with descriptive errors

**NFR3: Data Integrity**
- Unique constraint prevents duplicate best practice IDs
- Schema validation via Cypher constraints
- Pydantic model validation on result parsing

**NFR4: Observability**
- Log query execution time for performance monitoring
- Log Cypher query text for debugging
- Surface Neo4j errors with context

### Development Plan
**Phase 1: Schema Foundation**
- Define BestPractice node structure with complete property set
- Create unique constraint on id property
- Create performance index on topic property
- Document property purposes in schema comments

**Phase 2: Sample Data Creation**
- Insert 2-3 example best practice nodes via Cypher
- Validate data accessible via Neo4j browser
- Test manual Cypher queries against sample data

**Phase 3: LlamaIndex Integration**
- Configure Neo4jGraphStore with environment-based credentials
- Implement connection initialization with error handling
- Validate bolt connection to Neo4j container

**Phase 4: Query Translation and Execution**
- Implement query_knowledge_base function
- Test NL→Cypher translation with sample queries
- Parse Neo4j results to Pydantic BestPractice models

**Phase 5: Testing and Validation**
- Execute 3+ diverse test queries
- Manually validate result relevance
- Document query patterns and results

**Dependencies:**
- Phase 2 depends on Phase 1 (schema must exist before data insertion)
- Phase 3 depends on Phase 1 (connection requires schema)
- Phase 4 depends on Phases 2-3 (query needs data and connection)
- Phase 5 depends on Phase 4 (testing requires working query function)

### Testing Strategy
**Unit Testing:**
- Test BestPractice Pydantic model validation
- Test environment variable loading
- Test result parsing with mock Neo4j responses
- Coverage target: 80% for utility functions

**Integration Testing:**
- Test full query flow against running Neo4j container
- Validate Cypher translation produces correct patterns
- Confirm index usage via EXPLAIN queries
- Test error handling for connection failures

**Manual Validation Testing:**
- Execute diverse natural language queries
- Human review of result relevance to query intent
- Compare returned content against expected best practices
- Document query→result mappings for reproducibility

**Test Query Coverage:**
1. Topic-based: "Python error handling" → expect error-handling best practices
2. Framework-specific: "FastAPI async patterns" → expect FastAPI + async results
3. Technology-specific: "React hooks best practices" → expect React UI patterns

**Quality Gates:**
- All test queries return non-empty results
- Result content manually confirmed relevant
- Query response time <2 seconds measured
- No unhandled exceptions in query execution

## Additional Details

### Research Requirements
**Existing Documentation (Read These):**
- `/Users/markmcclatchy/.claude/best-practices/2025-08-19-llamaindex-neo4j-integration.md` - LlamaIndex Neo4j setup patterns, graph store configuration
- `/Users/markmcclatchy/.claude/best-practices/2025-08-20-neo4j-vector-store-integration-best-practices.md` - Neo4j connection management, indexing strategies
- `/Users/markmcclatchy/.claude/best-practices/2025-08-21-neo4j-cypher-best-practices.md` - Cypher query optimization, performance tuning

**External Research Needed:**
- Synthesize: "LlamaIndex Neo4jGraphStore natural language to Cypher translation examples 2025"
- Synthesize: "Neo4j Cypher constraint syntax for unique properties 2025"
- Synthesize: "Pydantic model creation from Neo4j query results Python 2025"
- Synthesize: "LlamaIndex query engine configuration for graph databases 2025"

### Success Criteria
**Technical Success Metrics:**
- Neo4j schema created with BestPractice nodes, constraints, and indexes
- Sample data inserted and queryable via Neo4j browser
- LlamaIndex Neo4jGraphStore successfully connects to Neo4j container
- query_knowledge_base function executes without errors

**Functional Success Metrics:**
- 3+ diverse natural language queries execute successfully
- All queries return structured BestPractice objects
- Manual validation confirms result relevance to query intent
- Query response time measured <2 seconds for POC dataset

**Quality Success Metrics:**
- All required properties populated in returned results
- No duplicate nodes due to unique constraint
- Index usage confirmed via Cypher EXPLAIN
- Error handling prevents crashes on connection failures

**Acceptance Criteria:**
- Developer can query knowledge base using plain English
- Results include complete best practice metadata
- Phase 2A completion enables Phase 3A agent evaluation work
- Documentation sufficient for Phase 3 integration

### Integration Context
**Upstream Dependencies:**
- Phase 1: Neo4j container infrastructure, Python environment, LlamaIndex installation

**Downstream Consumers:**
- Phase 3A: Agent-based evaluation needs query_knowledge_base to assess cached result quality
- Phase 3B: Partial result combination requires cache read before merging Exa data
- Future phases: MCP server will expose query_knowledge_base via tool interface

**Interface Contracts:**

```python
# Public API for downstream phases
def query_knowledge_base(query: str) -> List[BestPractice]:
    """
    Query cached best practices using natural language.

    Args:
        query: Plain English description of desired best practices
               Example: "Python error handling best practices"

    Returns:
        List of BestPractice objects matching query intent.
        Empty list if no matches found.

    Raises:
        ConnectionError: If Neo4j connection fails
        QueryError: If Cypher translation or execution fails
    """
```

**Data Model Contract:**

```python
class BestPractice(BaseModel):
    id: str                    # UUID, unique identifier
    title: str                 # Human-readable title
    content: str               # Full best practice text
    topic: str                 # Category (error-handling, async, etc)
    framework: str | None      # Framework name (FastAPI, React, etc)
    language: str              # Programming language
    source: str                # Data source (exa-api, manual, etc)
    created_at: datetime       # Timestamp of creation
```

## Data Models
### BestPractice Node Schema

**Neo4j Cypher Definition:**

```cypher
(:BestPractice {
  id: String,              // UUID v4, unique identifier
  title: String,           // Short descriptive title (max 200 chars)
  content: String,         // Full best practice text (2000-5000 chars)
  topic: String,           // Category slug (error-handling, async-programming, ui-patterns)
  framework: String,       // Framework name (FastAPI, React, Django) or null
  language: String,        // Primary language (python, javascript, typescript)
  source: String,          // Origin (exa-api, manual, archive-import)
  created_at: DateTime     // ISO 8601 timestamp
})
```

**Property Constraints:**
- `id`: UNIQUE constraint, required, UUID v4 format
- `title`: Required, indexed for full-text search in future phases
- `content`: Required, primary knowledge payload
- `topic`: Required, indexed for fast filtering
- `framework`: Optional, null for language-agnostic practices
- `language`: Required, lowercase
- `source`: Required, tracks data provenance
- `created_at`: Required, auto-set to current time

**Pydantic Model:**

```python
from pydantic import BaseModel, Field
from datetime import datetime

class BestPractice(BaseModel):
    id: str = Field(..., description="Unique UUID identifier")
    title: str = Field(..., max_length=200, description="Short title")
    content: str = Field(..., min_length=100, description="Full practice text")
    topic: str = Field(..., description="Category slug")
    framework: str | None = Field(None, description="Framework name")
    language: str = Field(..., description="Programming language")
    source: str = Field(..., description="Data origin")
    created_at: datetime = Field(default_factory=datetime.now)

    class Config:
        json_schema_extra = {
            "example": {
                "id": "550e8400-e29b-41d4-a716-446655440000",
                "title": "Python Error Handling with Context Managers",
                "content": "Use context managers (with statement) for resource cleanup...",
                "topic": "error-handling",
                "framework": None,
                "language": "python",
                "source": "exa-api",
                "created_at": "2025-12-03T10:00:00Z"
            }
        }
```

**Validation Rules:**
- id must be valid UUID v4
- title required, 1-200 characters
- content required, minimum 100 characters (ensures substantive practices)
- topic required, lowercase with hyphens
- language required, lowercase

### Relationship Schema (Optional)

**RELATED_TO Relationship:**

```cypher
(:BestPractice)-[:RELATED_TO {
  similarity_score: Float,   // 0.0-1.0, semantic similarity
  relationship_type: String  // 'prerequisite', 'alternative', 'complement'
}]->(:BestPractice)
```

**Usage:**
- Connect practices sharing similar topics or frameworks
- Enable graph traversal queries in future phases
- Not required for Phase 2A POC scope

## Deployment Architecture
### Local Development Setup

**Container Configuration:**

```yaml
# docker-compose.yml (from Phase 1, reference only)
services:
  neo4j:
    image: neo4j:5.15-community
    ports:
      - "7474:7474"  # Browser UI
      - "7687:7687"  # Bolt protocol
    environment:
      NEO4J_AUTH: neo4j/development-password
      NEO4J_PLUGINS: '["apoc"]'
    volumes:
      - neo4j_data:/data
      - ./schema:/schema:ro
```

**Environment Variables:**

```bash
# .env file (not committed to version control)
NEO4J_URI=bolt://localhost:7687
NEO4J_USERNAME=neo4j
NEO4J_PASSWORD=development-password
NEO4J_DATABASE=neo4j
```

**Deployment Workflow:**
1. Start Neo4j container via docker-compose
2. Execute schema creation script via Neo4j browser or Python
3. Insert sample data via Cypher script
4. Validate data visible in Neo4j browser
5. Run query tests via Python test script

**Infrastructure Requirements:**
- Docker runtime for Neo4j container
- 2GB RAM minimum for Neo4j (POC dataset)
- Port 7687 available for bolt connections
- Port 7474 available for browser UI (optional)

## Metadata

### Iteration
1

### Version
2

### Status
draft
