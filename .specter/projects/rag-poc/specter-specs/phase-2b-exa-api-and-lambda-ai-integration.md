# Technical Specification: phase-2b-exa-api-and-lambda-ai-integration

## Overview

### Objectives
Integrate Exa API for best practices retrieval via LangChain and Lambda AI API for agent-based result evaluation. This phase establishes the external search capability and evaluation intelligence that enable the hybrid cache decision-making system.

**Note on Execution Sequencing**: While this specification describes both integrations together, the actual execution order (Exa first, then Lambda AI, or parallel development) should be explored and determined during implementation based on developer learning curve and integration complexity. The specification maintains flexibility rather than enforcing strict sequential ordering.

### Scope
**Included:**

**Exa API Integration:**
- LangChain Exa integration configuration with API key authentication
- Best practices search function: `search_best_practices_exa(query: str) -> List[SearchResult]`
- Result parsing and normalization to match BestPractice schema structure
- Basic error handling for API failures (retry logic optional)
- Test queries to verify Exa response quality and relevance

**Lambda AI Integration:**
- HTTP client setup for Lambda AI API (Qwen3-235B-A22B model)
- Evaluation function: `evaluate_results(query: str, results: List[BestPractice]) -> EvaluationResponse`
- Prompt design for result completeness classification (sufficient/partial/insufficient)
- Response parsing to extract classification and reasoning
- Test evaluation calls with diverse query/result combinations

**Data Structures:**
- `SearchResult` dataclass for Exa API responses
- `EvaluationResponse` dataclass with fields: classification (enum), reasoning (str), identified_gaps (List[str])

**Execution Flexibility:**
- Implementation order determined during phase execution based on:
  - Integration documentation quality and availability
  - Developer familiarity with API patterns
  - Complexity encountered in initial integration attempts
- Options: Sequential (Exa → Lambda AI), Sequential (Lambda AI → Exa), or Parallel development
- Document chosen approach and reasoning in phase notes

**Excluded:**
- Advanced Exa search filters or ranking customization
- Lambda AI model fine-tuning or advanced prompting techniques
- Retry logic with exponential backoff (basic retry acceptable)
- Rate limiting handling (assume POC usage within limits)
- Result caching for API responses
- Integration testing between Exa and Lambda AI (deferred to Phase 3)

### Dependencies
**Prerequisites:**
- Phase 1 complete: Environment variables configured for EXA_API_KEY and LAMBDA_AI_API_KEY
- Phase 1 complete: Python environment with LangChain and HTTP client libraries installed
- Phase 2A complete (optional): Understanding of BestPractice schema for result normalization helps but not strictly blocking

**Blocking Relationships:**
- This phase blocks Phase 3A: Agent evaluation logic requires working Lambda AI integration
- This phase blocks Phase 3B: Gap-filling logic requires working Exa search capability
- Phase 2A can complete independently: Neo4j + LlamaIndex integration has no dependency on external APIs

**Technical Dependencies:**
- Exa API access with valid API key and sufficient rate limits
- Lambda AI API access with Qwen3-235B-A22B model availability
- Internet connectivity for API calls
- LangChain library with Exa integration support

**Execution Sequencing Considerations (Flexible):**
- If Exa documentation is clearer: Start with Exa integration to build confidence
- If Lambda AI prompt design seems simpler: Start with evaluation logic to understand output requirements
- If parallel development preferred: Work on both simultaneously with independent testing
- Decision point: First hour of Phase 2B based on initial exploration

### Deliverables
**Exa API Deliverables:**
1. **src/exa_client.py**: Module with Exa API integration via LangChain
2. **search_best_practices_exa() function**: Accepts query string, returns structured SearchResult list
3. **Result Normalization Function**: Converts Exa SearchResult to BestPractice schema format
4. **Exa Test Script**: Runs sample queries and prints results for manual validation
5. **Error Handling**: Basic try/except for API failures with informative error messages

**Lambda AI Deliverables:**
6. **src/lambda_ai_client.py**: Module with Lambda AI API HTTP client
7. **evaluate_results() function**: Accepts query + results, returns EvaluationResponse with classification and reasoning
8. **Evaluation Prompt Template**: Structured prompt for result completeness assessment
9. **Response Parser**: Extracts classification enum and reasoning text from API response
10. **Evaluation Test Script**: Runs sample evaluations with diverse result sets

**Data Structure Deliverables:**
11. **src/models.py**: Dataclasses for SearchResult, EvaluationResponse, Classification enum
12. **Type Hints**: All functions have complete type annotations

**Documentation Deliverables:**
13. **README.md Update**: Add sections on Exa search usage and Lambda AI evaluation
14. **API Configuration Docs**: Document required environment variables and API key setup
15. **Execution Notes**: Document chosen integration order and reasoning in phase completion notes

**Success Criteria:**
- ✅ Exa API returns relevant best practices for test queries
- ✅ SearchResult objects successfully normalized to BestPractice format
- ✅ Lambda AI API returns structured evaluation with classification and reasoning
- ✅ Evaluation reasoning is readable and explains classification decision
- ✅ Both integrations tested independently with sample data
- ✅ Error handling prevents crashes on API failures
- ✅ Execution approach documented with reasoning for chosen sequencing
- ✅ Phase 2B completion time: ≤2 hours including buffer

## Metadata

### Iteration
1

### Version
2

### Status
draft
