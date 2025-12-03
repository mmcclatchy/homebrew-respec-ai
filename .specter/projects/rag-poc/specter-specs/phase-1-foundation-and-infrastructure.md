# Technical Specification: phase-1-foundation-and-infrastructure

## Overview

### Objectives
Establish the foundational infrastructure for the RAG Best Practices POC by setting up Neo4j database, project structure, MCP Server skeleton, and environment configuration. This phase creates the technical foundation upon which all integration and intelligence work will be built.

**Business Value:**
- Validates technical feasibility of the hybrid cache architecture within weekend timeline
- De-risks Phase 2 integration work by proving database and MCP connectivity
- Creates repeatable infrastructure setup for future RAG-based projects
- Enables rapid iteration on knowledge graph design in subsequent phases

**Measurable Goals:**
- Neo4j container operational with <5 minute setup time
- Python project structure follows uv best practices with dependency resolution <2 minutes
- MCP Server skeleton responds to basic requests within 500ms
- All external connectivity (Neo4j, environment variables) verified programmatically

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
- Performance optimization
- Multi-container orchestration beyond Neo4j
- CI/CD pipeline configuration
- Database backup/restore procedures

**Constraints:**
- Weekend project timeline (3 hours allocated for Phase 1)
- Local development environment only (macOS Docker Desktop)
- Community Edition Neo4j (no enterprise features)
- Single developer workflow (no team coordination needed)
- Proof-of-concept quality standards (production hardening deferred)

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
- Docker Hub for Neo4j official image (neo4j:5.15-community or latest 5.x)
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

## System Design

### Architecture
**Component Overview:**

The Phase 1 architecture establishes three foundational layers:

1. **Data Layer**: Neo4j Community Edition running in Docker container
2. **Application Layer**: Python 3.13 project managed by uv with core dependencies
3. **Interface Layer**: MCP Server skeleton enabling Claude Code integration

**Component Interactions:**

```text
┌─────────────────────────────────────────────────────────────┐
│                     Developer Machine (macOS)               │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              Claude Code (Client)                   │    │
│  └────────────────────┬────────────────────────────────┘    │
│                       │ MCP Protocol                        │
│  ┌────────────────────▼────────────────────────────────┐    │
│  │         MCP Server (src/mcp_server.py)              │    │
│  │  - Request handler skeleton                         │    │
│  │  - Health check endpoint                            │    │
│  │  - Environment variable loader                      │    │
│  └────────────────────┬────────────────────────────────┘    │
│                       │ Neo4j Python Driver                 │
│  ┌────────────────────▼────────────────────────────────┐    │
│  │     Docker Container (neo4j:5.15-community)         │    │
│  │  - Bolt Protocol (port 7687)                        │    │
│  │  - HTTP API (port 7474)                             │    │
│  │  - Neo4j Browser UI                                 │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐    │
│  │        Python Environment (uv managed)              │    │
│  │  - neo4j driver                                     │    │
│  │  - mcp SDK                                          │    │
│  │  - LlamaIndex (foundation only, unused in Phase 1)  │    │
│  │  - python-dotenv (environment loading)              │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

**Data Flow:**

Phase 1 establishes connectivity paths without implementing complex workflows:

1. **Docker Startup Flow:**
   - Developer runs `docker-compose up -d`
   - Docker pulls neo4j:5.15-community image (if not cached)
   - Container starts with configured ports and environment variables
   - Health check verifies Neo4j ready state

2. **Python Environment Setup Flow:**
   - Developer runs `uv sync`
   - uv resolves dependencies from pyproject.toml
   - Virtual environment created in .venv/
   - All packages installed with version locking in uv.lock

3. **Connectivity Verification Flow:**
   - Test script loads NEO4J_URI from .env
   - Creates Neo4j driver instance
   - Executes simple Cypher query (e.g., `RETURN 1`)
   - Closes connection and reports success/failure

4. **MCP Server Initialization Flow:**
   - MCP Server process starts
   - Loads environment variables from .env
   - Registers basic request handlers (health check)
   - Listens for Claude Code connections
   - Responds to ping requests with status

**Design Decisions:**

**Decision 1: Docker Compose vs Manual Docker Run**
- **Choice:** Docker Compose
- **Rationale:** Declarative configuration enables reproducible setup. Compose file documents port mappings, environment variables, and health checks in single source of truth.
- **Trade-offs:** Adds docker-compose.yml overhead, but eliminates need for lengthy `docker run` commands and manual container management.

**Decision 2: uv vs pip/poetry**
- **Choice:** uv package manager
- **Rationale:** Project requirement specified in CLAUDE.md. uv provides fastest dependency resolution, built-in virtual environment management, and unified tool for package and version management.
- **Trade-offs:** Less mature ecosystem than pip, but significantly faster and aligns with Python 3.13 modern tooling.

**Decision 3: Neo4j Community Edition vs AuraDB**
- **Choice:** Neo4j Community Edition in Docker
- **Rationale:** Local development avoids cloud service costs, provides full control over startup/shutdown, and enables offline work. POC does not require enterprise features.
- **Trade-offs:** Requires Docker Desktop and local resources, but eliminates network latency and external dependencies.

**Decision 4: MCP Server Skeleton vs Full Implementation**
- **Choice:** Minimal skeleton with health check only
- **Rationale:** Phase 1 validates connectivity, not functionality. Implementing query routing logic before schema design (Phase 2A) would require rework.
- **Trade-offs:** No immediate functional value, but establishes integration point and proves MCP protocol works before investing in complex logic.

**Decision 5: python-dotenv vs Pydantic Settings**
- **Choice:** python-dotenv for Phase 1
- **Rationale:** Simple .env loading without validation overhead. POC environment has 3 variables with straightforward string values.
- **Trade-offs:** No type validation or IDE autocomplete, but reduces initial complexity. Can migrate to Pydantic Settings in Phase 2 if needed.

**Scalability Considerations:**

Phase 1 architecture deliberately avoids premature optimization:
- Neo4j Community Edition supports up to 34 billion nodes (sufficient for POC dataset)
- Single container deployment adequate for weekend project load
- Local development environment limits concurrent users to 1 (acceptable for POC)
- MCP Server runs single-threaded (no concurrency needed in Phase 1)

Future scaling paths (out of Phase 1 scope):
- Migrate to Neo4j AuraDB for cloud deployment
- Add connection pooling for MCP Server concurrent requests
- Implement caching layer for repeated queries
- Consider FastMCP framework for production hardening

### Technology Stack
**Core Technologies:**

| Technology | Version | Purpose | Justification |
|------------|---------|---------|---------------|
| **Neo4j Community Edition** | 5.15+ | Graph database for knowledge storage | Native graph database with Cypher query language. Community Edition sufficient for POC scale. Industry standard for graph-based knowledge systems. |
| **Docker** | 24.0+ | Container runtime for Neo4j | Simplifies Neo4j deployment without local installation. Ensures consistent environment across development machines. Docker Desktop already required prerequisite. |
| **Docker Compose** | 2.20+ | Container orchestration | Declarative infrastructure-as-code for Neo4j container. Single command startup/shutdown. Health check integration. |
| **Python** | 3.13+ | Primary programming language | Latest stable Python version with modern syntax. Required for uv compatibility. Excellent ecosystem for MCP SDK, Neo4j drivers, and LlamaIndex. |
| **uv** | Latest | Package and version manager | Project standard per CLAUDE.md. Fastest dependency resolver in Python ecosystem (10-100x faster than pip). Unified tool for venv + package management. |
| **neo4j Python driver** | 5.15+ | Database connectivity | Official Neo4j driver with Bolt protocol support. Synchronous API suitable for POC simplicity. Mature library with comprehensive documentation. |
| **MCP SDK** | Latest stable | Claude Code integration protocol | Enables Claude Code to interact with custom tools. Official Anthropic SDK with TypeScript reference implementation. Python port available via mcp package. |
| **python-dotenv** | 1.0+ | Environment variable management | Simple .env file loading without validation overhead. Industry standard for local development secrets. No complex configuration needed for POC. |

**Supporting Technologies:**

| Technology | Version | Purpose | Justification |
|------------|---------|---------|---------------|
| **LlamaIndex** | Latest stable | Natural language query framework (foundation only) | Installed in Phase 1 for dependency resolution but unused until Phase 2A. Required for NL→Cypher translation integration. High-level abstraction over LLM interactions. |
| **LangChain** | Latest stable | Agent orchestration (foundation only) | Dependency placeholder for future Phase 2B intelligent routing. Not actively used in Phase 1. |

**Technology Trade-offs:**

**Neo4j Community Edition vs Alternatives:**
- **Alternatives considered:** AuraDB (managed), PostgreSQL with pg_graph extension, Amazon Neptune
- **Why Neo4j Community:** Zero cloud costs, full local control, rich Cypher query language, excellent LlamaIndex integration documented in archive. Community Edition lacks enterprise features (clustering, advanced security) but POC doesn't need them.
- **Trade-off:** Requires Docker Desktop and local resources vs zero-setup cloud solutions, but eliminates network latency and API rate limits.

**uv vs pip/poetry:**
- **Alternatives considered:** pip + venv, Poetry, PDM, Pipenv
- **Why uv:** Project mandate in CLAUDE.md, 10-100x faster than pip, unified interface for package + version management, growing adoption in Python 3.13 ecosystem.
- **Trade-off:** Less mature than pip (fewer StackOverflow answers), but dramatically faster and simpler than Poetry's complex configuration.

**python-dotenv vs Pydantic Settings:**
- **Alternatives considered:** Pydantic Settings, environ-config, dynaconf
- **Why python-dotenv:** Simplest possible .env loading with zero configuration. POC has 3 string environment variables without validation needs.
- **Trade-off:** No type checking or validation vs Pydantic Settings' type safety, but reduces initial complexity and avoids premature abstraction.

**MCP SDK Python vs TypeScript:**
- **Alternatives considered:** TypeScript MCP SDK (reference implementation), REST API custom protocol
- **Why MCP SDK Python:** Matches project language (Python 3.13), official SDK with Anthropic support, avoids inter-process communication complexity.
- **Trade-off:** Python port may lag TypeScript reference implementation in features, but enables single-language codebase and simpler debugging.

**Dependency Versions:**

Critical version constraints for Phase 1:
- Neo4j driver must match container version (5.15.x driver → 5.15.x Neo4j)
- Python 3.13+ required for uv compatibility and modern syntax
- MCP SDK pinned to latest stable to avoid protocol breaking changes
- LlamaIndex and LangChain unpinned (latest stable acceptable for Phase 1 foundation)

Dependency resolution strategy:
- uv.lock file pins exact versions after initial `uv sync`
- pyproject.toml specifies minimum versions with caret (^) notation
- Re-lock dependencies between phases to avoid mid-project breakage
- No upper version bounds (avoid artificial conflicts)

**Archive Best Practices Integration:**

Technologies align with archive-documented patterns:
1. **Neo4j + LlamaIndex:** Archive contains "LlamaIndex Neo4j Integration Best Practices" - validates technology pairing
2. **MCP Server Development:** Archive contains "MCP Server Development Best Practices" and "FastMCP Server Best Practices" - guides server structure
3. **Neo4j Cypher Queries:** Archive contains "Neo4j Cypher Query Best Practices" - will inform Phase 2A schema design
4. **Neo4j Vector Store:** Archive contains "Neo4j Vector Store Integration Best Practices" - relevant for future semantic search (Phase 3+)

Technologies NOT found in archive (external research needed):
- Docker Compose configuration for Neo4j (search: "Neo4j Docker Compose best practices 2025")
- uv package manager usage patterns (search: "uv Python package manager best practices 2025")
- python-dotenv security considerations (search: "python-dotenv environment variable security 2025")

## Implementation

### Functional Requirements
**FR1: Neo4j Container Deployment**
- **Description:** Docker Compose must start Neo4j Community Edition container with accessible ports
- **Acceptance Criteria:**
  - Container starts with `docker-compose up -d` command
  - Bolt protocol available on localhost:7687
  - HTTP API available on localhost:7474
  - Neo4j Browser UI loads in web browser
  - Container health check passes within 30 seconds
  - Container persists data in named Docker volume
- **User Workflow:** Developer runs `docker-compose up -d`, verifies browser access, sees empty database ready for schema

**FR2: Python Project Structure**
- **Description:** uv-managed Python project with organized source directory
- **Acceptance Criteria:**
  - pyproject.toml defines project metadata and dependencies
  - src/ directory contains **init**.py and mcp_server.py
  - uv sync installs all dependencies without errors
  - .venv/ directory created with Python 3.13 interpreter
  - uv.lock file records exact dependency versions
- **User Workflow:** Developer clones repository, runs `uv sync`, sees dependencies installed in <2 minutes

**FR3: Core Dependency Installation**
- **Description:** Required packages available for import in Python code
- **Acceptance Criteria:**
  - neo4j driver imports successfully
  - mcp SDK imports successfully
  - python-dotenv imports successfully
  - LlamaIndex imports successfully (unused but available)
  - No import errors or missing dependency warnings
- **User Workflow:** Developer runs `python -c "import neo4j; import mcp; import dotenv"`, sees no errors

**FR4: MCP Server Skeleton**
- **Description:** Basic MCP Server process that starts and responds to health checks
- **Acceptance Criteria:**
  - Server starts with `uv run src/mcp_server.py` command
  - Registers at least one request handler (health check / ping)
  - Responds to ping request within 500ms
  - Logs startup message indicating ready state
  - Loads environment variables from .env on startup
- **User Workflow:** Developer starts MCP Server, sends test request via Claude Code, receives response confirming connectivity

**FR5: Environment Configuration**
- **Description:** .env file stores API keys and connection strings securely
- **Acceptance Criteria:**
  - .env file contains NEO4J_URI variable (e.g., bolt://localhost:7687)
  - .env file contains LAMBDA_AI_API_KEY placeholder
  - .env file contains EXA_API_KEY placeholder
  - .env file excluded from git via .gitignore
  - python-dotenv loads variables accessible via os.getenv()
- **User Workflow:** Developer copies .env.example, fills in API keys, runs application, sees environment variables loaded

**FR6: Neo4j Connectivity Verification**
- **Description:** Programmatic test confirming Neo4j connection works
- **Acceptance Criteria:**
  - Test script creates Neo4j driver instance
  - Executes simple Cypher query (e.g., RETURN 1 AS result)
  - Query returns expected result without errors
  - Connection closes cleanly
  - Script exits with status code 0 on success
- **User Workflow:** Developer runs `uv run scripts/test_neo4j.py`, sees "Connection successful" message

**FR7: Git Repository Initialization**
- **Description:** Version control setup with appropriate ignore patterns
- **Acceptance Criteria:**
  - .gitignore excludes .env file
  - .gitignore excludes .venv/ directory
  - .gitignore excludes **pycache**/ directories
  - .gitignore excludes *.pyc files
  - .gitignore excludes uv.lock (or includes based on project decision)
  - README.md documents setup steps
- **User Workflow:** Developer runs `git status`, sees no sensitive files staged for commit

### Non-Functional Requirements
**NFR1: Setup Time**
- **Requirement:** Complete Phase 1 setup in ≤3 hours including documentation
- **Target Metrics:**
  - Docker Compose first start: <5 minutes (includes image pull)
  - uv sync dependency install: <2 minutes
  - Manual verification steps: <30 minutes total
- **Rationale:** Weekend project timeline demands rapid infrastructure setup to maximize time for integration work in Phases 2-3

**NFR2: Neo4j Startup Performance**
- **Requirement:** Neo4j container becomes healthy quickly
- **Target Metrics:**
  - Container health check passes within 30 seconds
  - First Cypher query after startup executes within 2 seconds
  - Neo4j Browser UI loads within 5 seconds
- **Rationale:** Fast iteration cycle for Phase 2 schema experimentation requires responsive database

**NFR3: Dependency Resolution Speed**
- **Requirement:** uv sync completes efficiently
- **Target Metrics:**
  - Initial dependency download: <2 minutes on broadband connection
  - Subsequent syncs (cached): <10 seconds
  - Dependency conflict resolution: automatic (no manual intervention)
- **Rationale:** uv chosen specifically for speed advantage over pip/poetry

**NFR4: MCP Server Responsiveness**
- **Requirement:** Health check requests return quickly
- **Target Metrics:**
  - Ping request response time: <500ms
  - Server startup time: <3 seconds
  - Memory footprint: <100MB idle (Python process only)
- **Rationale:** Establishes baseline performance expectations for Phase 2 query routing implementation

**NFR5: Resource Utilization**
- **Requirement:** Infrastructure runs on typical development laptop
- **Target Metrics:**
  - Neo4j container memory: <512MB idle, <2GB under POC load
  - Neo4j container CPU: <5% idle, <50% during queries
  - Total disk space: <500MB (container + dependencies)
- **Rationale:** Local development on macOS laptop without dedicated hardware. Community Edition has lower resource requirements than Enterprise.

**NFR6: Reliability**
- **Requirement:** Infrastructure survives basic failure scenarios
- **Target Metrics:**
  - Docker container restart: Neo4j recovers without data loss
  - Network interruption: Neo4j driver reconnects automatically
  - Invalid environment variable: Application fails fast with clear error message
- **Rationale:** Reduces debugging time during Phase 2-3 development. POC does not require production-level fault tolerance.

**NFR7: Security (POC-level)**
- **Requirement:** Basic security hygiene for local development
- **Target Metrics:**
  - .env file excluded from git (verified by .gitignore)
  - Neo4j default credentials changed (or documented as acceptable for local dev)
  - No hardcoded secrets in source code
  - Docker container not exposed to external network (localhost only)
- **Rationale:** Prevents accidental credential leaks. Production-grade security deferred beyond POC scope.

**NFR8: Maintainability**
- **Requirement:** Infrastructure configuration understandable by future developers
- **Target Metrics:**
  - docker-compose.yml has inline comments explaining configuration choices
  - README.md documents all setup steps with expected outputs
  - pyproject.toml includes dependency justifications in comments
  - No "magic" configuration values without explanation
- **Rationale:** POC may evolve into production system. Clear documentation reduces onboarding friction.

### Development Plan
**Phase 1 Implementation Sequence:**

The development plan follows dependency order to minimize rework and enable incremental verification.

**Stage 1: Docker Infrastructure**

**Step 1.1: Create docker-compose.yml**
- Define Neo4j service with official image (neo4j:5.15-community)
- Configure port mappings: 7687 (Bolt), 7474 (HTTP)
- Set environment variables: NEO4J_AUTH (default neo4j/password or custom)
- Add named volume for data persistence
- Configure health check using Neo4j HTTP API
- Document configuration choices in inline comments

**Step 1.2: Start and Verify Neo4j Container**
- Run `docker-compose up -d`
- Wait for health check to pass (monitor with `docker-compose ps`)
- Open Neo4j Browser at <http://localhost:7474>
- Verify login with configured credentials
- Confirm empty database ready state

**Dependencies:** None (starting point)
**Verification:** Neo4j Browser loads, shows database version, accepts Cypher commands in console

---

**Stage 2: Python Project Foundation**

**Step 2.1: Initialize uv Project**
- Run `uv init` to create pyproject.toml
- Set Python version to 3.13 in pyproject.toml
- Configure project name and description
- Run `uv venv` to create virtual environment

**Step 2.2: Install Core Dependencies**
- Add dependencies via uv: `uv add neo4j mcp python-dotenv`
- Add foundation dependencies: `uv add llama-index langchain`
- Verify uv.lock file created with pinned versions
- Confirm .venv/ directory populated

**Step 2.3: Create Project Structure**
- Create src/ directory
- Add src/**init**.py (empty file for package marker)
- Create placeholder src/mcp_server.py (minimal structure)
- Create scripts/ directory for test utilities

**Dependencies:** Stage 1 complete (Neo4j container running for later verification)
**Verification:** `uv run python -c "import neo4j; import mcp; print('Imports successful')"` succeeds

---

**Stage 3: Environment Configuration**

**Step 3.1: Create Environment Files**
- Create .env file with required variables:
  - NEO4J_URI=bolt://localhost:7687
  - NEO4J_USER=neo4j
  - NEO4J_PASSWORD=password (or custom from Step 1.1)
  - LAMBDA_AI_API_KEY=your_key_here
  - EXA_API_KEY=your_key_here
- Create .env.example with placeholder values for documentation

**Step 3.2: Configure Git Ignore**
- Create .gitignore with entries:
  - .env (exclude secrets)
  - .venv/ (exclude virtual environment)
  - **pycache**/ (exclude bytecode)
  - *.pyc
  - .DS_Store (macOS)
  - uv.lock (project decision - include or exclude based on team preference)

**Dependencies:** Stage 2 complete (project structure exists)
**Verification:** `git status` shows .env excluded, `cat .env.example` shows template

---

**Stage 4: Connectivity Verification**

**Step 4.1: Create Neo4j Test Script**
- Create scripts/test_neo4j.py
- Load environment variables using python-dotenv
- Create Neo4j driver instance with URI from .env
- Execute simple Cypher query: `RETURN 1 AS result`
- Print result and close connection
- Handle connection errors with clear error messages

**Step 4.2: Run Verification**
- Execute `uv run scripts/test_neo4j.py`
- Confirm "Connection successful" output
- Verify query result printed correctly
- Test error handling by stopping Docker container and re-running

**Dependencies:** Stages 1-3 complete (Neo4j running + environment configured)
**Verification:** Script exits with code 0, prints expected result

---

**Stage 5: MCP Server Skeleton**

**Step 5.1: Implement Basic MCP Server**
- Implement src/mcp_server.py using MCP SDK
- Register health check / ping request handler
- Load environment variables on startup
- Add basic logging (print statements acceptable for POC)
- Implement graceful shutdown on SIGINT

**Step 5.2: Test MCP Server Manually**
- Start server: `uv run src/mcp_server.py`
- Verify startup logs indicate server ready
- Use Claude Code or manual MCP client to send ping request
- Confirm response received within 500ms
- Test environment variable loading by printing NEO4J_URI

**Dependencies:** Stages 2-3 complete (dependencies installed + environment configured)
**Verification:** Server responds to health check, loads environment variables correctly

---

**Stage 6: Documentation and Cleanup**

**Step 6.1: Write README.md**
- Document prerequisites (Docker Desktop, uv installed)
- Provide setup instructions (clone, docker-compose up, uv sync)
- Include verification steps (browser check, test script, MCP server start)
- Add troubleshooting section (common errors and solutions)
- Document next steps (Phase 2A preview)

**Step 6.2: Final Verification**
- Run all verification steps from fresh terminal session
- Confirm docker-compose.yml works from cold start
- Test uv sync from scratch (.venv/ deleted)
- Verify all scripts execute successfully
- Confirm git repository clean (no uncommitted sensitive files)

**Dependencies:** Stages 1-5 complete (all components implemented)
**Verification:** Another developer could follow README and complete setup successfully

---

**Stage Dependencies Summary:**
```text
Stage 1 (Docker) → Stage 2 (Python) → Stage 3 (Environment) → Stage 4 (Verification)
                                    ↘ Stage 5 (MCP Server) ↗
                                                ↓
                                          Stage 6 (Documentation)
```

**Critical Path:** Stage 1 → Stage 2 → Stage 3 → Stage 6 (minimum viable infrastructure)
**Parallel Opportunities:** Stages 4 and 5 can be developed concurrently after Stage 3 completes

### Testing Strategy
Phase 1 focuses on **infrastructure validation** rather than functional testing. The strategy emphasizes manual verification and smoke tests to confirm connectivity and basic operations.

**Testing Levels:**

**Level 1: Component Smoke Tests**
- **Scope:** Individual infrastructure components in isolation
- **Approach:** Manual verification that each component starts and responds
- **Coverage:**
  - Docker container health check (automated by Docker Compose)
  - Neo4j Browser UI loads and accepts login
  - Python imports succeed for all core dependencies
  - MCP Server process starts without errors
  - Environment variables load via python-dotenv

**Level 2: Integration Smoke Tests**
- **Scope:** Component interactions (Python → Neo4j, Claude → MCP Server)
- **Approach:** Simple scripts that exercise cross-component communication
- **Coverage:**
  - Neo4j connectivity test (scripts/test_neo4j.py executes Cypher query)
  - MCP Server health check (manual request via Claude Code)
  - Environment variable access from application code

**Level 3: End-to-End Setup Verification**
- **Scope:** Complete infrastructure setup from clean slate
- **Approach:** Follow README.md instructions in fresh environment
- **Coverage:**
  - Docker Compose cold start (no cached images)
  - uv sync from empty .venv/
  - All verification scripts succeed in sequence
  - No manual intervention required beyond documented steps

**Testing Tools:**

Phase 1 uses minimal tooling to match POC simplicity:
- **Docker health checks:** Built-in container monitoring
- **Python scripts:** Simple test utilities in scripts/ directory
- **Manual verification:** Browser checks, log inspection, command output review
- **No testing frameworks:** pytest, unittest deferred to Phase 2+

**Quality Gates:**

Before marking Phase 1 complete, all criteria must pass:

**Infrastructure Quality Gate:**
- [ ] `docker-compose up -d` starts container successfully
- [ ] `docker-compose ps` shows Neo4j container healthy
- [ ] <http://localhost:7474> loads Neo4j Browser
- [ ] Login with configured credentials succeeds
- [ ] Container survives restart (`docker-compose restart`) without data loss

**Python Environment Quality Gate:**
- [ ] `uv sync` completes without errors or warnings
- [ ] `uv run python --version` shows Python 3.13+
- [ ] `uv run python -c "import neo4j; import mcp; import dotenv"` succeeds
- [ ] .venv/ directory contains expected packages (verify with `pip list`)

**Connectivity Quality Gate:**
- [ ] `uv run scripts/test_neo4j.py` prints "Connection successful"
- [ ] Script exits with code 0
- [ ] Script fails gracefully with clear error when Docker container stopped

**MCP Server Quality Gate:**
- [ ] `uv run src/mcp_server.py` starts without errors
- [ ] Server logs indicate environment variables loaded
- [ ] Health check request (via Claude Code or MCP client) returns success response
- [ ] Server shuts down cleanly on Ctrl+C

**Documentation Quality Gate:**
- [ ] README.md setup instructions are accurate (verified by fresh setup)
- [ ] .env.example contains all required variables
- [ ] .gitignore excludes sensitive files (verified by `git status`)
- [ ] No hardcoded secrets in committed code (manual review)

**Test Execution Plan:**

**Initial Development Testing:**
1. Verify each stage completes successfully before proceeding to next
2. Run verification command from Development Plan after each stage
3. Fix issues immediately (fast feedback loop for POC)

**Pre-Completion Testing:**
1. Delete .venv/ directory and run `uv sync` from scratch
2. Stop Docker container and run `docker-compose up -d` cold start
3. Execute all verification scripts in sequence
4. Follow README.md instructions in separate terminal session
5. Confirm all quality gates pass

**Regression Testing (Between Phases):**
- Re-run verification scripts before starting Phase 2 work
- Confirm infrastructure still healthy after laptop restart
- Test environment variables still load correctly
- No regression testing framework needed for Phase 1 (manual re-verification acceptable)

**Known Limitations:**

Phase 1 testing deliberately excludes:
- **No performance testing:** Response time verification limited to "feels fast" manual assessment
- **No load testing:** Single developer workflow, concurrent requests not tested
- **No security testing:** Beyond basic .gitignore verification, no penetration testing or credential scanning
- **No automated test suite:** All verification manual or script-based (pytest framework deferred)
- **No CI/CD integration:** Local development only, no automated build pipelines

These limitations are acceptable for POC scope. Production system would require comprehensive test automation.

## Additional Details

### Research Requirements
**Existing Documentation:**

The archive scan identified relevant best practices documents. Build planner should read these for implementation guidance:

**MCP Server Development:**
- Read: `~/.claude/best-practices/MCP_Server_Development_Best_Practices.md`
  - Guides MCP SDK usage patterns
  - Request handler structure
  - Error handling conventions

- Read: `~/.claude/best-practices/FastMCP_Server_Best_Practices.md`
  - Alternative MCP framework patterns (optional if FastMCP considered over raw MCP SDK)
  - Production hardening techniques (reference for future phases)

**Neo4j Integration:**
- Read: `~/.claude/best-practices/LlamaIndex_Neo4j_Integration_Best_Practices.md`
  - LlamaIndex + Neo4j connection patterns
  - Configuration best practices
  - Query optimization tips (relevant for Phase 2A)

- Read: `~/.claude/best-practices/Neo4j_Vector_Store_Integration_Best_Practices.md`
  - Vector embedding storage (future semantic search)
  - Index configuration (reference for Phase 3+)

- Read: `~/.claude/best-practices/Neo4j_Cypher_Query_Best_Practices.md`
  - Cypher syntax patterns
  - Performance optimization (relevant for Phase 2A schema design)
  - Common pitfalls to avoid

**External Research Needed:**

The following topics were not found in archive documentation. Build planner should synthesize current best practices before implementation:

**Docker Compose Configuration:**
- Synthesize: "Neo4j Docker Compose configuration best practices 2025"
  - Focus: Port mapping conventions, volume mounting strategies, health check patterns
  - Focus: Neo4j-specific environment variables and their security implications
  - Focus: Container restart policies for local development vs production

**uv Package Manager:**
- Synthesize: "uv Python package manager best practices 2025"
  - Focus: pyproject.toml configuration patterns for uv
  - Focus: Virtual environment management (uv venv) workflow
  - Focus: Dependency version pinning strategies (when to use uv.lock)
  - Focus: Migration from pip/poetry to uv

**Environment Variable Security:**
- Synthesize: "python-dotenv environment variable security 2025"
  - Focus: .env file security best practices (permissions, encryption at rest)
  - Focus: When to use .env vs OS environment variables
  - Focus: API key rotation strategies for local development
  - Focus: Preventing accidental .env commits (pre-commit hooks)

**Neo4j Authentication:**
- Synthesize: "Neo4j default credentials management 2025"
  - Focus: Whether to change default neo4j/neo4j password for local development
  - Focus: Docker Compose Neo4j authentication configuration
  - Focus: Neo4j 5.x authentication best practices (APOC, plugins)

**Research Execution Strategy:**

1. **Archive Research First:** Read all identified archive documents before writing code to internalize patterns
2. **External Research On-Demand:** Synthesize external topics as needed during implementation (e.g., research Docker Compose patterns before writing docker-compose.yml)
3. **Document Learnings:** Add inline comments referencing research findings (e.g., "// Based on Neo4j Docker Compose best practices 2025")
4. **Iterate on Findings:** If research reveals better approach than initial plan, adapt specification accordingly

### Success Criteria
**Technical Success Metrics:**

**Infrastructure Operational:**
- ✅ Neo4j container running and healthy (docker-compose ps shows "healthy" status)
- ✅ Neo4j Browser UI accessible at <http://localhost:7474> with successful login
- ✅ Python 3.13 environment created and managed by uv
- ✅ All core dependencies installed (neo4j, mcp, python-dotenv, llama-index, langchain)
- ✅ MCP Server skeleton responds to health check requests within 500ms

**Connectivity Verified:**
- ✅ scripts/test_neo4j.py executes Cypher query successfully
- ✅ Environment variables load from .env file via python-dotenv
- ✅ Neo4j driver connects to container using bolt://localhost:7687
- ✅ No connection errors or timeout issues during verification

**Configuration Complete:**
- ✅ docker-compose.yml defines Neo4j service with correct ports and volumes
- ✅ .env file contains all required variables (NEO4J_URI, API keys)
- ✅ .gitignore excludes sensitive files (.env, .venv, **pycache**)
- ✅ .env.example provides template for other developers

**Documentation Adequate:**
- ✅ README.md documents complete setup process with expected outputs
- ✅ Another developer can follow README and complete setup successfully
- ✅ Troubleshooting section addresses common errors
- ✅ No undocumented "magic" steps required to make infrastructure work

**Timeline Success:**
- ✅ Phase 1 completion time ≤3 hours including all stages and verification
- ✅ No blocking issues requiring external support or complex debugging

**Business Success Metrics:**

**Technical Feasibility Validated:**
- Confirms Neo4j + Python integration works on macOS with Docker
- Proves MCP Server can be implemented in Python (not just TypeScript)
- Validates that required dependencies (MCP SDK, neo4j driver) are installable and compatible
- De-risks Phase 2 integration work by eliminating infrastructure unknowns

**Developer Experience Positive:**
- Setup process simple enough for weekend project constraints
- Infrastructure starts quickly (no lengthy configuration or debugging)
- Clear error messages when something fails (fast troubleshooting)
- Documentation sufficient for revisiting project after breaks

**Foundation Ready for Integration:**
- Phase 2A can immediately begin schema design (Neo4j ready)
- Phase 2B can implement LlamaIndex integration (dependencies installed)
- MCP Server skeleton provides integration point for query routing (Phase 3)
- No anticipated rework needed to proceed to subsequent phases

**Verification Method:**

Demonstrate all success criteria met by executing:
1. Fresh clone of repository
2. `docker-compose up -d` (Neo4j starts)
3. `uv sync` (dependencies install)
4. `uv run scripts/test_neo4j.py` (connectivity verified)
5. `uv run src/mcp_server.py` (MCP Server starts)
6. Manual health check via Claude Code (server responds)
7. Review git status (no sensitive files staged)

If all steps succeed without manual intervention beyond documented API key entry, Phase 1 success criteria met.

### Integration Context
**System Boundaries:**

Phase 1 establishes the **foundation layer** of the RAG Best Practices POC. This phase interfaces with:

**External Systems:**
- **Docker Hub:** Pulls official Neo4j Community Edition image (neo4j:5.15-community)
- **PyPI:** Downloads Python packages via uv package manager
- **Claude Code:** MCP Server provides integration endpoint (server skeleton only, no functional handlers yet)

**Future Internal Systems (Not Yet Implemented):**
- **Phase 2A Knowledge Schema:** Will use Neo4j container established in Phase 1
- **Phase 2B Intelligent Routing:** Will extend MCP Server skeleton with LlamaIndex integration
- **Phase 3 Query Processing:** Will leverage established connectivity patterns

**Interface Contracts:**

Phase 1 defines the following integration points for subsequent phases:

**Neo4j Database Interface:**
```python
# Connection contract established in Phase 1
from neo4j import GraphDatabase
import os

# Environment-based connection (contract for Phase 2+)
NEO4J_URI = os.getenv("NEO4J_URI")  # bolt://localhost:7687
NEO4J_USER = os.getenv("NEO4J_USER")  # neo4j
NEO4J_PASSWORD = os.getenv("NEO4J_PASSWORD")  # password

# Driver instance creation (standard pattern for all phases)
driver = GraphDatabase.driver(NEO4J_URI, auth=(NEO4J_USER, NEO4J_PASSWORD))

# Session usage (Phase 2+ will execute schema creation and queries)
with driver.session() as session:
    result = session.run("RETURN 1 AS result")
    # Phase 2+ adds schema creation, data ingestion, query routing
```

**MCP Server Interface:**
```python
# MCP Server request handler contract (Phase 1 skeleton)
# Phase 2B will add: query_knowledge_base handler
# Phase 3 will add: intelligent routing logic

from mcp import Server

server = Server("rag-best-practices-poc")

@server.request_handler("health_check")
async def health_check():
    """Phase 1: Basic health check
    Phase 2B: Add Neo4j connectivity check
    Phase 3: Add LlamaIndex initialization status"""
    return {"status": "healthy", "phase": "1-foundation"}

# Future handlers to be added in Phase 2B+:
# @server.request_handler("query_knowledge_base")
# @server.request_handler("suggest_missing_topics")
```

**Environment Configuration Interface:**
```bash
# .env contract established in Phase 1
# All phases load environment via python-dotenv

# Phase 1: Connection strings
NEO4J_URI=bolt://localhost:7687
NEO4J_USER=neo4j
NEO4J_PASSWORD=password

# Phase 2B: API integrations
LAMBDA_AI_API_KEY=your_key_here
EXA_API_KEY=your_key_here

# Future phases may add:
# OPENAI_API_KEY=... (if LlamaIndex needs alternative LLM)
# LOG_LEVEL=... (when structured logging added)
```

**Cross-Phase Dependencies:**

Phase 1 unblocks subsequent phases:

**Phase 2A Dependency:**
- Requires: Neo4j container running (Phase 1)
- Requires: Python environment with neo4j driver (Phase 1)
- Requires: Environment configuration for NEO4J_URI (Phase 1)
- Will add: Cypher schema creation script
- Will add: Best practice seed data

**Phase 2B Dependency:**
- Requires: MCP Server skeleton (Phase 1)
- Requires: LlamaIndex dependency installed (Phase 1)
- Requires: API keys in .env (Phase 1)
- Will add: LlamaIndex NL→Cypher translation
- Will add: Exa/Lambda AI research integration

**Phase 3 Dependency:**
- Requires: Complete Neo4j schema (Phase 2A)
- Requires: MCP Server with handlers (Phase 2B)
- Will add: Intelligent query routing
- Will add: Cache-first vs research-first logic

**Integration Points for Build Phase:**

When build-planner translates this specification into tasks:

**File Organization Contract:**
- Docker configuration: Root directory (docker-compose.yml)
- Python source: src/ directory (mcp_server.py, future modules)
- Test utilities: scripts/ directory (test_neo4j.py, future verification scripts)
- Documentation: Root directory (README.md, .env.example)
- Configuration: Root directory (.env excluded from git, pyproject.toml, uv.lock)

**No Specific File Names Required:** Build planner has freedom to organize beyond these contracts, but must maintain:
- Neo4j container accessible at localhost:7687 (Bolt) and localhost:7474 (HTTP)
- MCP Server importable as Python module (exact filename flexible)
- Environment variables loadable via python-dotenv from .env file
- Test script executable via `uv run scripts/<test_script_name>.py`

**No Implementation Details Specified:** This specification intentionally omits:
- Specific Cypher queries beyond `RETURN 1` (Phase 2A responsibility)
- MCP Server request routing logic (Phase 2B responsibility)
- Error handling implementations (build planner decides try/catch patterns)
- Logging format (print statements acceptable for Phase 1)

Build planner translates architectural requirements into concrete tasks with freedom to choose implementation details not specified here.

## Metadata

### Iteration
3

### Version
4

### Status
draft
