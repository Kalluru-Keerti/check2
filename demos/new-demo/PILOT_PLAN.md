# Pilot Plan - Role-Fit Resume Analyser (Client Engineering)

## Executive summary

Move from the mock-mode demo to a 3-4 week pilot. Real employees get advisory role-fit guidance against real role requirements, scored by watsonx.ai, with measured accuracy and fairness.

## Objectives

1. **Accuracy.** Fit scores agree with expert recruiter judgement.
2. **Adoption.** Employees complete the flow quickly and find it useful.
3. **Trust.** The tool is demonstrably fair, explainable and privacy-safe.

## Success criteria

| Metric | Baseline | Target | Method |
|---|---|---|---|
| Agreement with recruiter verdict | n/a | 80% or higher | blind comparison on 100 labelled resume/role pairs |
| Median time to a result | manual review (days) | under 30 s | app telemetry |
| Employee usefulness rating | n/a | 4.0 / 5 or higher | pilot survey |
| Score gap across protected-group proxies | unknown | no significant gap | fairness test set |
| Resumes persisted | n/a | 0 | design review and log audit |

## Sprints

**Sprint 0 (2-3 days): environment and access.** watsonx.ai project/space and credentials, model lifecycle check, real role-profile source, privacy and legal sign-off for HR data, success criteria agreed.

**Sprint 1 (weeks 1-2): data and core.** Replace synthetic roles with approved role profiles (skills taxonomy). Enable live mode. Build the labelled evaluation set. Tune prompt and aliases. Add OCR path for scanned PDFs.

**Sprint 2 (weeks 2-3): integration and governance.** SSO (IBM Verify). Skills taxonomy integration. watsonx.governance factsheet, bias testing, prompt versioning. Add learning-path and alternative-role suggestions (deferred from the demo). Observability (Instana).

**Sprint 3 (weeks 3-4): hardening.** End-to-end and load testing, security review, OpenShift deployment (UBI 9), user acceptance with a pilot group, documentation and knowledge transfer.

## Team

Tech Sales (1), Client Engineers (1-2), Data Engineer (1), AI/ML Engineer (1), Project Manager (1), plus HR and Legal stakeholders.

## Risks

| Risk | Impact | Mitigation |
|---|---|---|
| Bias in scoring | High | fairness tests, protected-attribute exclusion, human review, advisory-only framing |
| Resume PII exposure | High | in-memory processing, no storage, log redaction, data-processing agreement |
| LLM hallucination | Medium | output validation against the role skill list, server-side verdict |
| Model deprecation | Medium | live catalog check, configurable model id |
| Over-reliance on scores | Medium | clear advisory messaging, show evidence |

## Post-pilot roadmap

Internal mobility marketplace integration, learning-path recommendations, manager and recruiter views with consent, multilingual resumes, and a conversational career coach (watsonx Orchestrate).
