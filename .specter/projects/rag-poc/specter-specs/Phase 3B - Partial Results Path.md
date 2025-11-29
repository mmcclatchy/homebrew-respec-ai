# Technical Specification: Phase 3B - Partial Results Path (Optional)

## Overview

### Objectives
Extend the binary routing system to handle partial results by implementing gap identification logic that determines what specific knowledge is missing from Neo4j results, triggers targeted Exa searches for missing pieces, and merges cached + fresh results before returning to the user (OPTIONAL - implement only if Phase 3A completes with time remaining).

**Success Criteria:**
- Agent evaluation can classify results as "partial" and identify specific knowledge gaps
- Gap identification prompt produces actionable search queries for missing pieces
- Targeted Exa searches retrieve only missing information (not duplicating cached results)
- Hybrid result merging combines cached + fresh results coherently
- At least 2/5 partial test cases show correct gap identification and retrieval
- Merged results indicate source (cache vs fresh) for transparency

### Scope
**Included:**
- Extended agent evaluation prompt for three-tier classification (sufficient/partial/insufficient)
- Gap identification logic: parse evaluation reasoning to extract missing topics/concepts
- Targeted Exa query generation based on identified gaps
- Hybrid result merging: combine Neo4j results + Exa results with source indication
- Partial path routing: Query Neo4j → Evaluate → Identify gaps → Query Exa (targeted) → Store → Merge → Return
- Test cases for partial scenarios (e.g., partial match in database)

**Excluded:**
- Advanced gap analysis (semantic similarity, topic modeling)
- Result deduplication across sources
- Conflict resolution between cached and fresh results
- Ranking or prioritization of merged results
- Multi-round gap filling (single Exa search only)

### Dependencies
**Prerequisites:**
- Phase 3A complete: Binary routing functional with sufficient/insufficient paths
- Agent evaluation working reliably for binary classification
- Storage logic successfully persists Exa results to Neo4j

**Blocking Relationships:**
- Phase 3A must be complete and validated before Phase 3B begins
- If Phase 3A takes longer than 4 hours, defer Phase 3B to post-POC
- Binary routing must be stable before adding partial path complexity

### Deliverables
1. **src/agent/prompts.py (updated)** - Three-tier evaluation prompt (sufficient/partial/insufficient)
2. **src/agent/gap_analyzer.py** - Gap identification logic parsing evaluation reasoning
3. **src/routing/query_router.py (updated)** - Partial path routing logic
4. **src/merging/result_merger.py** - Hybrid result merging with source indication
5. **scripts/test_partial_routing.py** - Test script for partial path scenarios
6. **Partial Path Test Log** - Results from partial test cases showing gap identification accuracy

**Research Focus:**
- Prompt engineering for structured gap identification output
- Result merging strategies preserving context and source attribution
- LlamaIndex query result formats and how to combine with external results
- Exa API query refinement for targeted searches (exclude certain topics)

**Visual Deliverable (update sequence diagram):**
- Complete decision tree: Query → Neo4j → Evaluation (Sufficient: Return | Partial: Gaps → Exa (targeted) → Store → Merge → Return | Insufficient: Exa (full) → Store → Return)

## Metadata

### Iteration
0

### Version
1

### Status
draft
