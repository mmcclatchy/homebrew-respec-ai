# Technical Specification: Phase 1 - Foundation and Infrastructure

## Overview

### Objectives
Establish the foundational infrastructure for the RAG Best Practices POC by setting up Neo4j database, project structure, MCP Server skeleton, and environment configuration. This phase creates the technical foundation upon which all integration and intelligence work will be built.

### Scope
**Included:**
- Docker Compose configuration for Neo4j Community Edition container
- Neo4j container deployment with port exposure and basic configuration
- Python project structure using uv package manager
- Core dependency installation (MCP SDK, Neo4j driver, LlamaIndex, LangChain)
- MCP Server skeleton with basic request/response capability
- Environment variable configuration for API keys (Lambda AI, Exa)
- Basic connectivity verification for Neo4j
- Git repository initialization with .gitignore for environment files

**Excluded:**
- Neo4j schema design (deferred to Phase 2A)
- LlamaIndex configuration (deferred to Phase 2A)
- Exa API integration (Phase 2B)
- Lambda AI integration (Phase 2B)
- Query routing logic (Phase 3)
- Testing framework setup (manual testing only)
- Production-ready error handling
- Logging infrastructure (basic print statements acceptable)

### Dependencies
**Prerequisites:**
- Docker Desktop installed and running on macOS
- Python 3.13+ available (will be managed by uv)
- uv package manager installed globally
- API keys obtained for Lambda AI and Exa services
- Internet connectivity for downloading images and dependencies

**Blocking Relationships:**
- This phase blocks ALL subsequent phases - nothing can proceed without working infrastructure
- Neo4j container must be healthy before Phase 2A can begin LlamaIndex integration
- MCP Server skeleton must exist before Phase 2 can add query routing logic
- Environment configuration must be complete before Phase 2B can test API integrations

**External Dependencies:**
- Docker Hub for Neo4j official image
- PyPI for Python package downloads via uv
- No dependency on other project phases (foundation is self-contained)

### Deliverables
**Infrastructure Deliverables:**
1. **docker-compose.yml**: Neo4j container configuration with port mappings (7687, 7474) and health checks
2. **Running Neo4j Container**: Accessible at localhost:7687 (Bolt) and localhost:7474 (HTTP), verified healthy

**Project Structure Deliverables:**
3. **pyproject.toml**: uv project configuration with core dependencies defined
4. **src/ directory**: Main source code directory with **init**.py
5. **src/mcp_server.py**: MCP Server skeleton responding to basic ping/health check requests
6. **.env file**: Environment variables for NEO4J_URI, LAMBDA_AI_API_KEY, EXA_API_KEY
7. **.gitignore**: Excludes .env, .venv, **pycache**, and other generated files

**Verification Deliverables:**
8. **Connectivity Test Script**: Simple Python script verifying Neo4j connection via driver
9. **MCP Server Test**: Manual verification that MCP Server starts and responds to requests

**Documentation Deliverables:**
10. **README.md (Initial)**: Setup instructions including Docker Compose commands and uv sync steps

**Success Criteria:**
- ✅ `docker-compose up -d` successfully starts Neo4j container
- ✅ Neo4j browser accessible at <http://localhost:7474>
- ✅ Python script connects to Neo4j without errors
- ✅ `uv sync` installs all dependencies without conflicts
- ✅ MCP Server starts and responds to health check request
- ✅ Environment variables loaded and accessible from Python code
- ✅ Phase 1 completion time: ≤3 hours including buffer

## Metadata

### Iteration
2

### Version
3

### Status
draft
