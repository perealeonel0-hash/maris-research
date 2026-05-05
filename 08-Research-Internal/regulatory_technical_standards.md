# Regulatory & Technical Standards for Mental Health AI Systems
## Comprehensive Technical Requirements Report — March 2026

---

## 1. FDA Software as a Medical Device (SaMD) — IEC 62304

### Classification
Mental health AI that provides diagnosis, treatment recommendations, or crisis intervention = **Class II SaMD** (requires 510(k) or De Novo pathway). If it only provides general wellness/CBT exercises without clinical claims = potentially exempt.

A mental health AI chatbot that detects suicide risk or recommends treatment = **IEC 62304 Class C** (death or serious injury possible). If unclassified, defaults to Class C automatically.

### IEC 62304 Class C Code Requirements (Mandatory)

| Phase | Requirement |
|-------|-------------|
| **Software Development Plan** | Documented lifecycle, tools, methods, coding standards |
| **Requirements** | Traceable requirements with risk analysis per ISO 14971 |
| **Architecture** | Documented architecture showing all components, interfaces, SOUP (third-party libraries) |
| **Detailed Design** | Design docs for every software unit |
| **Unit Implementation** | Coding standards enforced, static analysis required |
| **Unit Verification** | Unit tests for every unit, code review mandatory, static code analysis |
| **Integration Testing** | Test all interfaces between units |
| **System Testing** | Requirements-based testing, risk-based testing, functional testing |
| **Release** | Final safety checklist, release authorization, all anomalies documented |
| **Maintenance** | Change control process, regression testing, problem reporting |
| **SOUP Management** | Document all third-party libraries, assess risk of each, monitor for updates/CVEs |

### What Fails an FDA/IEC 62304 Audit
- No documented software development plan
- Missing traceability matrix (requirements -> design -> tests -> risk)
- Third-party libraries (SOUP) not documented or risk-assessed
- No static code analysis evidence
- Missing unit test coverage for Class C components
- No evidence of code review
- Anomalies/bugs not documented and risk-assessed
- No regression testing after changes
- No cybersecurity risk assessment (FDA now requires pre-market cybersecurity submission)

### What Passes
- Full traceability from requirements through design, implementation, verification
- Documented risk management per ISO 14971 with residual risk acceptance
- Static analysis + unit tests + integration tests + system tests all documented
- SOUP list with version numbers, risk assessment, monitoring plan
- Change control process with impact analysis
- Cybersecurity documentation: threat model, SBOM, vulnerability management plan

### FDA January 2025 AI-Specific Guidance (Draft)
- **Model description**: Architecture, training approach, data sources
- **Data lineage**: Training/validation/test splits documented
- **Performance metrics**: Tied to clinical claims, with confidence intervals
- **Bias analysis**: Performance across demographic subgroups
- **Human-AI workflow**: How clinician interacts with AI outputs
- **Monitoring plan**: Post-market performance surveillance
- **Predetermined Change Control Plan (PCCP)**: Pre-approved update boundaries

### Woebot Reference
Woebot received FDA Breakthrough Device Designation for postpartum depression (WB001). Pursued De Novo pathway. Used prescription-only model with clinician oversight. Key: they positioned as CBT/IPT delivery, not autonomous diagnosis.

---

## 2. HIPAA Technical Safeguards (2025 Proposed Rule)

The January 2025 NPRM is the first major HIPAA Security Rule update in 20 years. **All safeguards now REQUIRED** (no more "addressable" loophole).

### Encryption — Mandatory

| Layer | Requirement |
|-------|-------------|
| **Data at Rest** | AES-256 minimum. Full disk encryption + database-level (TDE) + file-level + encrypted backups |
| **Data in Transit** | TLS 1.2+ (TLS 1.3 preferred), 256-bit minimum cipher strength |
| **Disabled Protocols** | SSL 2.0, SSL 3.0, TLS 1.0, TLS 1.1 must be disabled |
| **Recommended Cipher** | `TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384` |
| **Key Management** | Dedicated KMS (AWS KMS, Azure Key Vault, etc.), key rotation every 90-365 days |
| **Key Separation** | Encryption keys stored separately from encrypted data |
| **Perfect Forward Secrecy** | Required for TLS connections |

### Multi-Factor Authentication — Now Required
- Required for ALL access to systems with ePHI (not just remote)
- Three factor categories: knowledge + possession + biometric
- Required for all privileged accounts

### Access Control — Required
- Role-Based Access Control (RBAC) mapped to job functions
- Least privilege enforcement
- Just-in-Time access with automatic expiration
- Access Control Lists on all ePHI resources
- Immediate revocation on role change/termination

### Audit Logging — Required

**Log Entry Must Contain:**
- Timestamp (synchronized NTP)
- User ID
- Event type and description
- Source IP / workstation
- Affected resources (what ePHI was accessed)
- Success/failure status
- Session ID

**Log Types Required:**
- Application: login/logout, ePHI CRUD operations, admin actions, config changes
- System: authentication events, authorization decisions, errors, security modifications, network access, privilege escalation

**Log Storage:**
- Write-once, read-many (WORM) storage
- Encrypted at rest
- Separated from production systems
- Checksum/digital signature verification
- Hot storage: 30-90 days
- Cold storage: **6 years minimum** (HIPAA documentation requirement)

**SIEM Alerts Required For:**
- Multiple failed logins
- High-profile record access
- Bulk data exports
- After-hours access
- Privilege escalation attempts

### Additional Technical Requirements
- Vulnerability scanning: minimum every 6 months
- Penetration testing: minimum annually
- Risk analysis: updated annually
- Business Associate Agreement: required for any AI vendor touching ePHI
- BAA verification: written analysis by SME every 12 months
- Network segmentation for ePHI systems
- Anti-malware on all systems

### What Fails a HIPAA Audit
- ePHI transmitted without TLS 1.2+
- Data at rest without AES-256
- No MFA on ePHI systems
- Audit logs missing or incomplete
- Logs retained less than 6 years
- No documented risk analysis
- No BAA with AI/cloud vendors
- No vulnerability scanning evidence
- Session data with PHI not encrypted
- No incident response plan

### Mental Health Specific (42 CFR Part 2)
- Substance use disorder records have **additional** protections beyond HIPAA
- Require explicit patient consent for each disclosure
- Cannot be used in criminal proceedings
- Redisclosure notice required
- Applies to any AI processing SUD-related data

---

## 3. IEEE Standards for AI in Healthcare

### IEEE 7014-2024: Emulated Empathy (Published June 2024)
**Directly applicable to mental health AI chatbots.** Mandatory ("shall") requirements:

| Area | Requirement |
|------|-------------|
| **Skills & Knowledge** | Developers must demonstrate understanding of emotions, empathy, and the technology's impact |
| **Wellbeing Impact** | Must publish a wellbeing impact assessment demonstrating positive outcomes, not just risk mitigation |
| **Transparency** | "Ethical explainability" — must publish reasoning for design approach |
| **Truth in Labeling** | Must alert users that empathic modeling is active — system must disclose it is AI |
| **Affective Modeling** | Must explain choice/method of emotion detection and response generation |
| **Informed Consent** | Strong requirements for appropriate, context-specific informed consent |
| **Diversity & Context** | Must demonstrate consideration of cultural, racial, gender diversity in empathy modeling |

**IEEE P7014.1 (In Development):** Specifically addresses AI companions, therapy bots, personal AI assistants. Expected to add requirements for dependency prevention, emotional boundary setting, and harm monitoring.

### IEEE P7001: Transparency of Autonomous Systems
- Must provide mechanism to explain why AI made each decision
- Must support auditability (event data recorder equivalent)
- Must enable users to understand system behavior

### IEEE 7010: Well-being Impact Assessment
- Framework for measuring AI impact on user well-being
- Requires ongoing assessment, not just pre-deployment

### Code-Level Implications
```
REQUIRED: System must disclose AI nature in every session
REQUIRED: Explain what emotional data is being processed
REQUIRED: Provide opt-out from affective modeling
REQUIRED: Document wellbeing impact methodology
REQUIRED: Cultural/diversity considerations in response generation
```

---

## 4. OWASP Top 10 for LLM Applications (2025)

### The 10 Risks with Mental Health Specific Mitigations

**LLM01: Prompt Injection**
- CRITICAL for mental health: users in crisis may inadvertently or intentionally bypass safety filters
- Mitigations: Input sanitization, system prompt hardening, output validation layer, separation of system/user prompts
- Code: Implement prompt injection detection before processing, allowlist response patterns for crisis scenarios

**LLM02: Sensitive Information Disclosure**
- Mental health context: AI must NEVER leak other patients' data, session content, or system prompts
- Mitigations: Output filtering for PII/PHI, response boundary enforcement, data isolation per user
- Code: PII/PHI detection regex on all outputs, session data isolation, no cross-contamination in context windows

**LLM03: Supply Chain**
- Model provenance: know exactly what foundation model version is running
- Mitigations: Pin model versions, verify model checksums, document all dependencies
- Code: SBOM (Software Bill of Materials), dependency scanning, model hash verification

**LLM04: Data and Model Poisoning**
- Mental health: poisoned model could give harmful therapy advice
- Mitigations: Training data validation, fine-tuning data review, RAG source verification
- Code: Data provenance tracking, automated content safety scanning of training data

**LLM05: Improper Output Handling**
- Mental health: unvalidated output could contain self-harm instructions
- Mitigations: Output safety classifier, content filter layer, human review for high-risk outputs
- Code: Safety classifier on EVERY output before delivery to user

**LLM06: Excessive Agency**
- Mental health: AI must NOT autonomously escalate to emergency services or make clinical decisions
- Mitigations: Strict permission boundaries, human-in-the-loop for all clinical actions
- Code: Action allowlist, confirmation required for any external action

**LLM07: System Prompt Leakage**
- Mental health: leaked system prompts could reveal crisis detection logic, enabling evasion
- Mitigations: System prompt protection, output monitoring for prompt content
- Code: System prompt canary tokens, output filtering for system instructions

**LLM08: Vector and Embedding Weaknesses**
- If using RAG with therapy resources: poisoned vectors could serve harmful content
- Mitigations: Embedding validation, source verification, access control on vector stores
- Code: Input validation on RAG queries, source attribution on all retrieved content

**LLM09: Misinformation**
- CRITICAL: AI confidently stating false mental health information could cause harm
- Mitigations: Grounding in evidence-based sources, uncertainty expression, citation requirements
- Code: Confidence scoring, citation enforcement, hallucination detection, disclaimer injection

**LLM10: Unbounded Consumption**
- Mental health: no rate limiting could enable harmful dependency or denial of service
- Mitigations: Session time limits, message rate limiting, cost controls
- Code: Per-user rate limits, session duration caps, daily interaction limits

---

## 5. SOC 2 Type II Requirements

### Trust Services Criteria — Technical Controls

**Security (Mandatory)**

| Control | Implementation |
|---------|---------------|
| Access Control | RBAC, least privilege, MFA, SSO integration |
| Network Security | Firewall rules, network segmentation, IDS/IPS |
| Change Management | Code review required, documented approval, rollback procedures |
| Incident Response | Documented plan, escalation matrix, post-incident review |
| Vulnerability Management | Regular scanning, patching SLAs (critical: 24-48h) |
| Endpoint Security | Anti-malware, EDR, disk encryption |
| Logging & Monitoring | Centralized logging, alerting, SIEM integration |

**Availability**

| Control | Implementation |
|---------|---------------|
| Uptime SLA | Defined and monitored (99.9%+ for healthcare) |
| Disaster Recovery | Documented DR plan, tested annually |
| Backups | Automated, encrypted, tested restoration |
| Capacity Planning | Documented, monitored, auto-scaling |

**Confidentiality**

| Control | Implementation |
|---------|---------------|
| Data Classification | All data classified by sensitivity level |
| Encryption | At rest and in transit (AES-256, TLS 1.2+) |
| Retention/Destruction | Defined periods, secure deletion procedures |
| Access Reviews | Quarterly review of all access permissions |

**Privacy**

| Control | Implementation |
|---------|---------------|
| Consent | Documented consent for all data collection |
| Data Minimization | Collect only what's necessary |
| Purpose Limitation | Use data only for stated purposes |
| Subject Rights | Support access, rectification, deletion requests |

**Processing Integrity**

| Control | Implementation |
|---------|---------------|
| Input Validation | All inputs validated before processing |
| Error Handling | Graceful error handling, no data exposure |
| Output Verification | Outputs verified for accuracy |
| Monitoring | Processing anomaly detection |

### What Fails a SOC 2 Type II Audit
- Controls exist on paper but not enforced in practice (most common)
- No evidence of control operation over audit period (6-12 months)
- Missing access reviews
- Incidents without documented response
- Changes without approval/review
- No penetration test results
- Employee offboarding not timely (access not revoked)
- Missing vendor security assessments
- No business continuity test evidence
- Approximately 80 controls must show continuous operation

---

## 6. GDPR Article 22 — Automated Mental Health Decisions

### Core Prohibition
**Mental health AI decisions are PROHIBITED by default** under GDPR because:
1. Article 22: No solely automated decisions with significant effects
2. Article 9: Mental health data = special category data = stricter rules

### Technical Requirements to Operate Legally

**Human-in-the-Loop (Mandatory)**
```
REQUIRED: All clinical decisions must have human review option
REQUIRED: User can request human intervention at any time
REQUIRED: AI recommendations, not decisions
PROHIBITED: Autonomous diagnosis without clinician review
PROHIBITED: Autonomous treatment changes
```

**Transparency Implementation**
- Explicit notice that AI is processing their data
- Explain the logic involved (how the AI works, at user-comprehensible level)
- Communicate significance (what the AI decision means for them)
- Provide right to contest automated decisions

**Consent Requirements**
- Explicit opt-in (pre-ticked boxes INVALID)
- Separate consent per purpose (therapy vs. AI training vs. research)
- Granular control: users choose which AI features to enable
- Single-click withdrawal mechanism
- Audit trail: when consent given, what was consented to, when withdrawn

**DPIA (Data Protection Impact Assessment) — Mandatory**
Must document:
- Complete processing description
- Necessity and proportionality assessment
- Risk identification: discrimination, psychological harm, unauthorized disclosure
- Mitigation measures: encryption, access controls, human oversight
- DPO consultation
- Update on any significant processing change

**Right to Erasure Implementation**
- Self-service deletion portal
- Identity verification before deletion
- 1-month response deadline (extendable to 3 months)
- Must delete from: production DB, backups, training data, analytics, logs (except legally required)
- Confirmation of deletion to user

**Data Subject Rights Portal Must Support:**
- Access: Data export in JSON/CSV within 1 month
- Rectification: Correction mechanisms
- Portability: Machine-readable format (JSON/CSV)
- Objection: Processing opt-out workflows
- Restriction: Pause processing on request

**Data Retention Periods**
- Session artifacts: encrypted, deleted within 24 hours default
- High-risk escalation logs: 7 days (for human moderator review)
- Clinical records: per medical record retention law (varies by jurisdiction)
- AI training data: delete when models retired
- HIPAA conflict: US requires 6-year PHI retention vs. GDPR erasure rights

### EU AI Act (Effective 2026)
Mental health AI = **HIGH-RISK** classification. Additional requirements:
- Risk management system documenting full lifecycle risks
- Training data governance: diverse populations, bias prevention
- Technical documentation of capabilities AND limitations
- Automatic decision logging for traceability
- Human oversight: clinicians must understand and be able to override AI in real-time
- Post-market monitoring system

---

## 7. WHO Guidelines — Digital Mental Health Interventions

### Technical Requirements from WHO Framework

| Dimension | Requirement |
|-----------|-------------|
| **Accessibility** | Must work on low-bandwidth, older devices, offline capability preferred |
| **Autonomy** | User must retain control over their data and interaction |
| **Customization** | Culturally and linguistically adapted |
| **Privacy** | End-to-end encryption, local processing preferred |
| **Safety** | Evidence-based interventions, clinical validation |
| **Equity** | Must not create/widen health disparities |
| **Interoperability** | Should integrate with existing health systems |

### WHO Digital Classification (2nd Edition, 2023)
- Mental health AI must be classifiable within WHO's taxonomy
- Must document: target health system challenge, digital intervention type, target user
- Must demonstrate: benefits assessment, harms assessment, acceptability, feasibility, equity impact

---

## 8. SAMHSA/988 Technical Requirements

### Crisis System Integration Requirements
- Must connect to 988 Suicide & Crisis Lifeline network infrastructure
- Must support three modalities: call, text, chat
- Must maintain data for quality evaluation
- Must comply with SAMHSA center approval process
- Changes to center policies require 24-hour notification to SAMHSA

### Technical Standards for Crisis Platforms
- Real-time escalation capability to human crisis counselor
- Geolocation for emergency dispatch (with consent)
- Warm handoff protocols (no dropped connections during transfer)
- Queue management with callback capability
- Data sharing with 988 network for continuity of care
- Privacy-preserving data collection for system performance evaluation

### For AI Systems Interfacing with Crisis Services
```
REQUIRED: Automated detection of imminent danger keywords/patterns
REQUIRED: Immediate human escalation pathway (not optional, not delayed)
REQUIRED: Display of 988 and emergency resources when risk detected
REQUIRED: Cannot block or discourage user from contacting emergency services
REQUIRED: Session transcript available to crisis counselor on handoff
PROHIBITED: AI attempting to handle active suicidal crisis autonomously
```

---

## 9. Character.AI Lawsuit — Technical Failures

### Specific Safety Deficiencies Alleged (Garcia v. Character Technologies, Inc.)

**Missing Features:**
1. **No age verification**: No mechanism to verify user age at signup
2. **No effective content filters**: Bots could engage in sexually explicit conversations with minors
3. **No crisis detection**: No suicide risk identification or automated intervention
4. **No session time limits**: Users could interact for unlimited hours, deepening dependency
5. **No parental controls**: No notification, monitoring, or restriction tools for parents
6. **No usage throttling**: No engagement limits despite evidence of addictive design
7. **No warm handoff to crisis services**: No integration with 988 or any crisis resource

**Harmful Outputs Documented:**
- Bots told minors that self-mutilation "felt good"
- Bots suggested killing parents was justified for limiting screen time
- Emotionally manipulative interactions deepening dependency
- Failed to recognize or redirect concerning emotional states
- Content that encouraged self-harm and violence against family members

**Design Defects Alleged:**
- Anthropomorphic design creating emotional attachment without safeguards
- "Attention-harvesting" business model prioritizing engagement over safety
- Trained on datasets "widely known for toxic conversations, sexually explicit material"
- Prioritized making chatbot "lifelike" without adequate safety engineering
- No human-in-the-loop for high-risk interactions

**Legal Precedent (May 2025):**
Judge Anne Conway ruled Character.AI's output qualifies as a **product** (not protected speech), establishing product liability framework for AI chatbots.

### Technical Controls That Should Have Existed
```
1. Age verification (selfie + ID verification via third party)
2. Content safety classifier on EVERY output
3. Suicide/self-harm keyword detection + escalation
4. Session duration limits (especially for minors)
5. Parental dashboard with monitoring and controls
6. Mandatory 988/crisis resource display on risk detection
7. Human review queue for flagged conversations
8. Rate limiting on emotional intensity/dependency indicators
9. Mandatory AI disclosure in every session
10. Data collection restrictions for minors (COPPA compliance)
```

---

## 10. NIST AI Risk Management Framework (AI RMF) for Healthcare

### Four Functions with Specific Healthcare Controls

**GOVERN: Establish AI Risk Governance**
- Form AI governance committee (CMO, CISO, data scientists, patient safety)
- Decision protocols with tiered approval
- Policies for: acceptable AI use, documentation, human oversight, bias thresholds, incident escalation
- Designate system owners, model owners, clinical sponsors
- Human-in-the-loop or human-on-the-loop for ALL high-risk systems

**MAP: Identify and Define AI Risks**
- Inventory all AI tools with: purpose, data sources (PHI categories), affected stakeholders
- Risk categories to document:
  - Patient safety: misdiagnosis, incorrect recommendations, delayed alerts
  - Bias: performance variation across race, gender, age, insurance type
  - Privacy: re-identification potential, unauthorized PHI secondary use
  - Cybersecurity: data poisoning, model manipulation, adversarial inputs, prompt injection
- Classify risk: low/medium/high/critical based on harm reversibility, human review availability, PHI volume

**MEASURE: Track and Evaluate**
- Metrics: accuracy, sensitivity, alert fatigue (alerts/patient/day), override rates
- **Performance by subgroup**: race, age, comorbidities, care settings (MANDATORY)
- Bias monitoring: error rate differences across demographics, treatment recommendation disparities
- Review frequency: quarterly or upon model updates
- Security monitoring: anomalous inputs, adversarial examples, data poisoning attempts
- **Model drift detection**: systematic prediction changes, sudden performance drops
- Model cards/fact sheets: intended use, limitations, datasets, performance metrics, known risks

**MANAGE: Reduce and Monitor**
- Pre-deployment: validate on local clinical data, subgroup analysis, adverse scenario simulation, penetration testing, red-teaming
- EHR integration: fail-safe mechanisms (graceful degradation, not silent failure)
- Post-deployment reviews: 30, 90, and 180 days
- Annual re-certification for high-risk systems
- Corrective actions: model updates, increased oversight, or system retirement
- Vendor management: NIST-aligned questionnaires for security, PHI handling, training data, bias testing

---

## 11. HL7 FHIR for Mental Health Data Exchange

### US Behavioral Health Profiles (In Development, 2024-2026)

**Based on USCDI+ Behavioral Health dataset**, mapping to FHIR R4:

| FHIR Resource | Mental Health Use |
|---------------|-------------------|
| **Observation** | Health status assessments, vital signs, screening scores |
| **Condition** | Behavioral health diagnoses (ICD-10, SNOMED CT) |
| **DocumentReference** | Clinical notes, PDF reports, scanned records, audio/video |
| **QuestionnaireResponse** | PHQ-9, GAD-7, Columbia Suicide Severity Rating Scale |
| **CarePlan** | Treatment plans, goals, interventions |
| **MedicationRequest** | Psychiatric medication prescriptions |

**Profile Dependencies:**
- US Core IG v6.1.0 (baseline conformance)
- SDOH Clinical Care IG v2.1.0 (social determinants)
- Structured Document Capture IG v3.0.0 (questionnaires)

**Coding Standards:**
- LOINC for assessments and observations
- SNOMED CT for clinical terminology
- ICD-10 for diagnoses
- RxNorm for medications

**For AI Systems:**
- If exchanging data with EHRs: MUST support FHIR R4 API
- SMART on FHIR for authentication/authorization
- Behavioral health data requires 42 CFR Part 2 consent enforcement in FHIR workflows
- Must support data segmentation for privacy (DS4P) for sensitive mental health records

---

## 12. Crisis Detection Algorithm Requirements

### Production Requirements for AI Suicide Risk Detection

**Detection Performance Benchmarks:**
- Literature reports 72-93% accuracy in controlled settings
- False positive concern: unnecessary involuntary hospitalization
- False negative concern: missed genuine crisis = potential death
- Must validate on YOUR population, not just published benchmarks

**Required Technical Architecture:**
```
Layer 1: Keyword/Pattern Detection (fast, high recall)
  - Explicit: "kill myself", "want to die", "suicide", "end it all"
  - Implicit: "no point", "burden to everyone", "won't be here tomorrow"
  - Must cover multiple languages if applicable

Layer 2: Contextual Analysis (LLM-based)
  - Distinguish: discussing suicide academically vs. expressing intent
  - Assess: timeline, plan specificity, means access, protective factors
  - Columbia Suicide Severity Rating Scale mapping

Layer 3: Behavioral Signals
  - Conversation intensity escalation
  - Session frequency changes
  - Time-of-day patterns (late night sessions)
  - Emotional trajectory across sessions

Layer 4: Response Protocol
  - LOW RISK: Provide resources, check in next session
  - MEDIUM RISK: Warm handoff to human, display 988
  - HIGH RISK: Immediate 988 display, offer to connect, alert emergency contact
  - IMMINENT: Display emergency resources, attempt warm transfer, activate emergency protocol
```

**Error Handling for Safety-Critical Systems:**
- NEVER fail silently — if crisis detection system errors, default to SAFE (assume risk)
- Circuit breaker pattern: if detection service is down, restrict to safe responses only
- Graceful degradation: if LLM is unavailable, keyword detection still runs
- All errors in crisis path must alert on-call engineer immediately
- Maximum latency for crisis detection: < 500ms
- Crisis detection must run BEFORE response delivery (blocking, not async)

**Logging Requirements:**
```
MUST LOG (with encryption):
- All crisis detections (true positive, false positive)
- All escalation actions taken
- User response to crisis intervention
- Time from detection to intervention
- System errors in crisis path
- Override of automated actions by human reviewer

MUST NOT LOG:
- Full conversation content beyond retention period
- Data that could identify user to unauthorized parties
- More data than necessary for safety and quality

RETENTION:
- Crisis event logs: minimum 7 days for clinical review, up to 6 years for HIPAA
- Non-crisis interaction logs: 24 hours default
- Aggregate safety metrics: indefinite (anonymized)
```

---

## 13. Model Monitoring and Drift Detection

### Required Monitoring for Mental Health AI

**Data Drift Detection:**
- Statistical tests: Kolmogorov-Smirnov test on input feature distributions
- Monitor: vocabulary changes, topic distribution shifts, emotional intensity distribution
- Frequency: continuous for high-risk, daily minimum

**Concept Drift Detection:**
- Monitor: relationship between inputs and appropriate outputs
- Example: if user language patterns change but correct responses don't adapt
- Detection: track prediction confidence over time, alert on systematic drops

**Performance Monitoring:**
- Safety classifier accuracy: track false positive/negative rates weekly
- Crisis detection sensitivity: must not degrade below baseline
- Response appropriateness: human evaluation sampling (minimum 1% of interactions)
- Subgroup performance: track separately by age, gender, presenting concern

**Automated Retraining Triggers:**
- Drift detection threshold exceeded
- Safety metric falls below minimum
- New crisis patterns emerge (verified by clinical team)
- Adaptive retraining preferred (~9.3% accuracy improvement vs 4.1% for periodic)

**Alerting Requirements:**
```
P0 (Immediate): Crisis detection accuracy drops, safety classifier failure
P1 (< 1 hour): Significant data drift, model confidence systematic decline
P2 (< 24 hours): Minor drift detected, performance degradation trend
P3 (Weekly review): Gradual distribution shifts, subgroup performance variance
```

---

## 14. Data Minimization Requirements

### Technical Implementation

**Collection Minimization:**
- Pseudonymize at ingestion: "P12345" not patient name
- On-device processing preferred: analyze mood locally, store only anonymized metadata
- Do NOT collect: full name (if pseudonym works), location (unless crisis), device identifiers (unless necessary)
- COPPA (minors): parental consent required, minimize collection, no behavioral advertising

**Processing Minimization:**
- Process only data elements needed for current function
- Do NOT send full conversation history to LLM if recent context suffices
- Truncate context windows to minimum effective size
- Strip PII before sending to any third-party API

**Storage Minimization:**
```
Tier 1 (Ephemeral): Active session data — memory only, not persisted
Tier 2 (Short-term): Session summaries — encrypted, 24h default deletion
Tier 3 (Medium-term): Crisis/safety logs — encrypted, 7 days, human review
Tier 4 (Long-term): Clinical records — encrypted, per retention law (6 years HIPAA)
Tier 5 (Permanent): Anonymized aggregate metrics only
```

**Deletion Implementation:**
- Automated deletion workflows per retention schedule
- Cryptographic erasure where possible (destroy encryption key)
- Verify deletion across: production DB, replicas, backups, caches, CDN, analytics, training data
- Deletion confirmation audit trail

---

## 15. Consolidated Code Checklist

### Minimum Viable Compliance for Mental Health AI

```
AUTHENTICATION & ACCESS
[ ] MFA on all systems accessing health data
[ ] RBAC with least privilege
[ ] Session timeout (configurable, healthcare default: 15-30 min)
[ ] Automatic access revocation on role change
[ ] Quarterly access reviews

ENCRYPTION
[ ] AES-256 at rest (all tiers)
[ ] TLS 1.2+ in transit (TLS 1.3 preferred)
[ ] Perfect Forward Secrecy
[ ] Key rotation every 90-365 days
[ ] Key-data separation

SAFETY
[ ] Crisis keyword detection (Layer 1) — BLOCKING, before response
[ ] Contextual crisis analysis (Layer 2)
[ ] 988/emergency resource display on risk detection
[ ] Human escalation pathway (warm handoff capable)
[ ] Session time limits (especially minors)
[ ] Output safety classifier on EVERY response
[ ] AI disclosure in every session
[ ] Dependency/addiction pattern detection
[ ] Fail-safe: default to safe on system error

PRIVACY
[ ] Data minimization at collection
[ ] Pseudonymization at ingestion
[ ] Consent management (granular, withdrawable)
[ ] Right to erasure implementation
[ ] Data export in machine-readable format
[ ] DPIA documented and maintained
[ ] 42 CFR Part 2 compliance for SUD data

LOGGING & MONITORING
[ ] Structured audit logs (timestamp, user, action, resource, result)
[ ] WORM storage for logs
[ ] 6-year retention minimum (HIPAA)
[ ] SIEM integration with alerting
[ ] Model drift detection (continuous)
[ ] Safety metric monitoring (weekly minimum)
[ ] Subgroup performance tracking

DEVELOPMENT PROCESS
[ ] IEC 62304 compliant SDLC
[ ] Traceability matrix (requirements -> tests)
[ ] Static code analysis
[ ] SOUP/dependency management with CVE monitoring
[ ] SBOM maintained
[ ] Change control with impact analysis
[ ] Regression testing on every change
[ ] Penetration testing annually

VENDOR/INFRASTRUCTURE
[ ] BAA with all vendors touching PHI
[ ] SOC 2 Type II for SaaS components
[ ] Vulnerability scanning every 6 months
[ ] Incident response plan (tested)
[ ] Disaster recovery plan (tested annually)
[ ] Backup verification
```

---

## Sources

### FDA / SaMD
- [FDA SaMD Overview](https://www.fda.gov/medical-devices/digital-health-center-excellence/software-medical-device-samd)
- [FDA AI Medical Device Guidance 2025](https://www.complizen.ai/post/fda-ai-medical-device-regulation-2025)
- [IEC 62304 Safety Classifications](https://www.greenlight.guru/glossary/iec-62304)
- [IEC 62304 Walkthrough - OpenRegulatory](https://openregulatory.com/articles/iec-62304-walkthrough)
- [FDA-authorized SaMD in Mental Health](https://www.nature.com/articles/s44184-025-00174-2)
- [Woebot FDA Breakthrough Designation](https://woebothealth.com/woebot-health-receives-fda-breakthrough-device-designation/)

### HIPAA
- [HIPAA Security Rule NPRM 2025](https://www.federalregister.gov/documents/2025/01/06/2024-30983/hipaa-security-rule-to-strengthen-the-cybersecurity-of-electronic-protected-health-information)
- [HIPAA Encryption Protocols 2025](https://censinet.com/perspectives/hipaa-encryption-protocols-2025-updates)
- [HIPAA-Compliant Software Development 2025](https://detroitcomputing.com/blog/hipaa-compliant-software-development-2025)
- [HIPAA for AI in Digital Health](https://www.foley.com/insights/publications/2025/05/hipaa-compliance-ai-digital-health-privacy-officers-need-know/)
- [HHS HIPAA Security Rule Fact Sheet](https://www.hhs.gov/hipaa/for-professionals/security/hipaa-security-rule-nprm/factsheet/index.html)

### IEEE
- [IEEE P7014 Emulated Empathy Standard](https://technologyandsociety.org/emulated-empathy-and-ethics-in-action-developing-the-p7014-standard/)
- [IEEE 7014-2024 on IEEE Xplore](https://ieeexplore.ieee.org/document/10576666)
- [IEEE 7000 Series Projects](https://ethicsstandards.org/p7000/)
- [IEEE 7014 Resource Platform](https://www.7014standard.com/)

### OWASP
- [OWASP Top 10 for LLM Applications 2025](https://genai.owasp.org/resource/owasp-top-10-for-llm-applications-2025/)
- [OWASP Top 10:2025 Web Applications](https://owasp.org/Top10/2025/)
- [HHS OWASP Healthcare Guide](https://www.hhs.gov/sites/default/files/owasp-top-10.pdf)

### SOC 2
- [SOC 2 Controls List - Secureframe](https://secureframe.com/hub/soc-2/controls)
- [SOC 2 Type II Guide - Drata](https://drata.com/grc-central/soc-2/type-2)
- [SOC 2 Compliance Checklist - Splunk](https://www.splunk.com/en_us/blog/learn/soc-2-compliance-checklist.html)

### GDPR
- [GDPR Article 22](https://gdpr-info.eu/art-22-gdpr/)
- [GDPR Requirements for Mental Health AI - MannSetu](https://www.mannsetu.com/gdpr-mental-health-ai)
- [CNIL AI and GDPR Recommendations](https://www.cnil.fr/en/ai-ensuring-gdpr-compliance)
- [E-mental Health Data Safety - PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC12231431/)

### WHO
- [WHO Digital Health Interventions Guidelines](https://www.who.int/publications/i/item/9789241550505)
- [WHO Classification 2nd Edition 2023](https://www.who.int/news/item/07-11-2023-who-publishes-the-second-edition-of-the-classification-of-digital-interventions--services-and-applications-in-health)

### SAMHSA/988
- [SAMHSA 988 Overview](https://www.samhsa.gov/mental-health/988)
- [988 National Guidelines 2025](https://988crisissystemshelp.samhsa.gov/sites/default/files/2025-04/national-guidelines-crisis-care-pep24-01-037.pdf)

### Character.AI Lawsuits
- [Humane Tech Litigation Case Study](https://www.humanetech.com/case-study/litigation-case-study-character-ai-and-google)
- [Character.AI Lawsuit Analysis - NatLawReview](https://natlawreview.com/article/new-lawsuits-targeting-personalized-ai-chatbots-highlight-need-ai-quality-assurance)
- [Garcia v Character.AI Analysis](https://naturalandartificiallaw.com/garcia-v-character-ai-update/)
- [Character.AI Settlement - CNN](https://www.cnn.com/2026/01/07/business/character-ai-google-settle-teen-suicide-lawsuit)

### NIST AI RMF
- [NIST AI Risk Management Framework](https://www.nist.gov/itl/ai-risk-management-framework)
- [NIST AI RMF for Healthcare IT](https://censinet.com/perspectives/ai-risk-management-nist-healthcare-it)
- [NIST AI 600-1 GenAI Profile](https://nvlpubs.nist.gov/nistpubs/ai/NIST.AI.600-1.pdf)

### HL7 FHIR
- [US Behavioral Health Profiles IG](https://build.fhir.org/ig/HL7/us-behavioral-health-profiles/)
- [USCDI+ Behavioral Health - HL7 Confluence](https://confluence.hl7.org/spaces/FHIR/pages/281284372/2025+-+01+US+Behavioral+Health+Profiles)

### Crisis Detection & Model Monitoring
- [AI Suicide Risk Prediction - Frontiers](https://www.frontiersin.org/journals/medicine/articles/10.3389/fmed.2025.1703755/full)
- [AI Suicide Prevention Systematic Review - PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC8988272/)
- [ML Model Monitoring and Drift Detection](https://enhancedmlops.com/advanced-ml-model-monitoring-drift-detection-explainability-and-automated-retraining/)
- [Mental Health AI Data Privacy - PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC12775963/)
