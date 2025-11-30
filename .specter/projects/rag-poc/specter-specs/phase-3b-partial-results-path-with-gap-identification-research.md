# Technical Specification: Phase 3B - Partial Results Path with Gap Identification Research

## Overview

### Objectives
Implement the "partial results" evaluation path that identifies specific knowledge gaps in cached results, searches for missing information via Exa API, and combines cached + fresh data into comprehensive responses. This phase completes the three-path routing system (sufficient/partial/insufficient) that defines the hybrid cache intelligence.

**Research-Driven Approach**: Gap identification implementation should be explored and researched during this phase rather than following a predetermined algorithm. Developer should investigate and experiment with keyword-based matching, semantic similarity, or other approaches to determine what works best for the POC context.

### Scope
**Included:**
- "Partial" classification addition to evaluation logic (sufficient/partial/insufficient)
- **Gap Identification Research and Implementation**:
  - Explore approaches: keyword extraction, missing topic detection, semantic comparison
  - Experiment with simple pattern matching vs more sophisticated techniques
  - Document chosen approach and reasoning in implementation notes
  - Accept iterative refinement based on test results
- Targeted Exa search based on identified gaps (not broad re-search)
- Result combination logic: merge cached results with gap-filling fresh results
- Evaluation prompt expansion to support partial classification with gap details
- Partial path testing scenario with measurable gap identification

**Research Tasks (Exploratory):**
- Investigate keyword-based gap detection: extract key terms from query, compare to cached result topics
- Consider semantic similarity: use simple text overlap or more advanced embedding comparison (if time permits)
- Test different gap identification granularities: topic-level vs specific detail-level gaps
- Evaluate trade-offs between implementation complexity and gap detection accuracy for POC
- Document chosen approach with rationale in code comments and phase notes

**Excluded:**
- Production-quality gap identification algorithms (POC-level experimentation acceptable)
- Advanced natural language understanding for gap detection
- Confidence scoring for partial classifications
- Gap prioritization or ranking (treat all identified gaps equally)
- Sophisticated result merging beyond simple concatenation or list combination
- Deduplication of overlapping information between cached and fresh results

### Dependencies
**Prerequisites:**
- Phase 3A complete: Binary evaluation and routing working (sufficient/insufficient paths)
- Phase 2A complete: Neo4j query and storage capabilities
- Phase 2B complete: Exa search and Lambda AI evaluation functioning

**Blocking Relationships:**
- This phase blocks Phase 4 comprehensive testing: All three paths must work for end-to-end validation
- Phase 3A must be complete: Partial path builds on binary evaluation infrastructure

**Technical Dependencies:**
- `evaluate_results()` function supporting partial classification output
- `search_best_practices_exa()` for gap-filling searches
- `query_knowledge_base()` for cached result retrieval
- `store_best_practice()` for storing gap-filling results

**Research Dependencies:**
- Access to diverse test queries to validate gap identification approaches
- Flexibility to iterate on implementation based on experimental results
- Acceptance that gap identification may be imperfect for POC

### Deliverables
**Research and Exploration Deliverables:**
1. **Gap Identification Exploration Notes**: Document in code comments or separate notes file
   - Approaches investigated (keyword-based, semantic, pattern matching, etc.)
   - Trade-offs considered (accuracy vs complexity, implementation time)
   - Chosen approach with reasoning and limitations acknowledged
2. **Experimental Test Queries**: Set of queries used to validate gap identification logic
3. **Gap Detection Examples**: Documented examples showing identified gaps for specific query/result pairs

**Core Logic Deliverables:**
4. **identify_gaps() function**: Implemented based on research findings
   - Input: user_query (str), cached_results (List[BestPractice])
   - Output: identified_gaps (List[str]) - specific missing topics or details
   - Implementation: Chosen approach (keyword-based, semantic, etc.)
5. **Partial Evaluation Path**: Integration into evaluate_and_route() logic
   - Classification: "partial" when cached results are incomplete but not empty
   - Gap extraction from evaluation response
   - Targeted Exa search for identified gaps only

**Result Combination Deliverables:**
6. **combine_results() function**: Merge cached and fresh results
   - Input: cached_results (List[BestPractice]), fresh_results (List[BestPractice])
   - Output: combined_results (List[BestPractice])
   - Implementation: Simple concatenation with metadata indicating sources
7. **Source Metadata**: Mark results with origin (cache vs fresh) for transparency

**Prompt Engineering Deliverables:**
8. **Partial Evaluation Prompt**: Expanded prompt supporting three-way classification
   - Criteria for "partial" classification
   - Gap identification guidance for agent
   - Structured output including identified_gaps field
9. **Prompt Refinement Notes**: Document iterations made based on test results

**Testing Deliverables:**
10. **Partial Path Test Scenario**:
    - Setup: Neo4j contains partial information (e.g., Python error handling basics but not advanced patterns)
    - Query: "Python error handling best practices including context managers"
    - Expected: Classified as partial → Gaps identified ("context managers") → Exa search for gaps → Combined results returned
11. **Gap Identification Validation**: Manual verification that identified gaps match actual missing information

**Integration Deliverables:**
12. **MCP Server Response Update**: Include gap_identified field and combined_source metadata in responses
13. **Logging Enhancement**: Log identified gaps and gap-filling search queries for debugging

**Success Criteria:**
- ✅ Evaluation logic supports sufficient/partial/insufficient classifications
- ✅ Gap identification approach documented with clear reasoning
- ✅ Partial results trigger targeted Exa search (not broad re-search of entire query)
- ✅ Identified gaps are specific and actionable (e.g., "context managers", "async patterns")
- ✅ Fresh results successfully fill identified gaps (manual validation)
- ✅ Combined results include both cached and gap-filling data with source indicators
- ✅ At least one successful partial path execution with measurable gap filling
- ✅ Research findings documented for future refinement
- ✅ Phase 3B completion time: ≤2 hours including buffer and research exploration

## Metadata

### Iteration
0

### Version
1

### Status
draft
