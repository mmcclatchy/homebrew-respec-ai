# Technical Specification: Phase 1 - Foundation and Infrastructure

## Overview

### Objectives
Establish the foundational infrastructure for the RAG POC by setting up local Docker environment for Neo4j, configuring project structure with Python 3.13 and uv package manager, scaffolding basic MCP Server implementation, and ensuring environment configuration is complete with API keys and connection settings.

**Success Criteria:**
- Neo4j container running and accessible on localhost:7474 (HTTP) and localhost:7687 (Bolt)
- Project structure created with pyproject.toml and dependencies installed via uv
- Basic MCP Server responds to test ping/health check
- Environment file configured with Lambda AI and Exa API keys
- Developer can connect to Neo4j browser interface and execute basic Cypher queries

### Scope
**Included:**
- Docker Compose configuration for Neo4j community edition
- Python project initialization with uv (pyproject.toml, .python-version)
- Core dependency installation (mcp, llama-index, langchain, neo4j driver)
- MCP Server skeleton with single placeholder tool
- .env file template with required API keys and Neo4j connection settings
- Basic README with setup instructions

**Excluded:**
- Neo4j schema design (deferred to Phase 2)
- Actual query logic implementation
- Integration with LlamaIndex, Exa, or Lambda AI
- Error handling beyond basic connection validation
- Production-ready configuration (authentication, persistence, backups)
- Automated testing setup

### Dependencies
**Prerequisites:**
- Docker and Docker Compose installed on macOS
- Python 3.13+ available (managed by uv)
- uv package manager installed
- Internet connectivity for Docker image pull and package downloads
- Lambda AI API key obtained
- Exa API key obtained

**Blocking Relationships:**
- No prior phases (this is Phase 1)
- Neo4j container must be operational before Phase 2 LlamaIndex integration
- MCP Server skeleton must exist before Phase 2 query logic implementation
- Environment configuration must be complete before any API integrations

### Deliverables
1. **docker-compose.yml** - Neo4j container configuration with port mappings and basic settings
2. **pyproject.toml** - Python project configuration with all required dependencies
3. **.python-version** - Python 3.13 version specification for uv
4. **src/mcp_server.py** - Basic MCP Server implementation with placeholder tool
5. **.env.example** - Template showing required environment variables
6. **.env** - Actual environment file with API keys (gitignored)
7. **README.md** - Setup and quick start instructions
8. **Verification Log** - Manual test results showing Neo4j accessible and MCP Server responding

**Research Focus:**
- MCP SDK documentation for Python server implementation patterns
- LlamaIndex Neo4j integration requirements (inform dependency versions)
- Docker Compose Neo4j configuration best practices for local development
- Exa LangChain integration package names and versions
- Neo4j Python driver connection string formats

**Visual Deliverable:**
- Architecture diagram showing component relationships (Neo4j ← LlamaIndex ← MCP Server → Claude Code, MCP Server → Lambda AI, MCP Server → Exa API → Neo4j storage loop)

## Metadata

### Iteration
0

### Version
1

### Status
draft
