# Dogfooding: How We Use Echelon

> **Real case studies from our AI operations consultancy**

---

## Why This Document Exists

We built Echelon while running an AI operations consultancy serving staffing agencies and professional services firms. Every feature in Echelon exists because we needed it ourselves to deliver client work efficiently.

This document shows exactly how we use our own platform internally—the good, the bad, and the lessons learned.

**TL;DR:** We saved 12 hours/week per consultant, reduced client onboarding time by 40%, and eliminated missed deliverables by using supervised automation for our own workflows.

---

## Our Business Context

**Company:** Entelech (AI operations consultancy)
**Target Clients:** Staffing agencies, insurance brokerages, financial advisors
**Services:** Workflow automation implementation, process optimization, AI integration
**Team Size:** 3 consultants (1 technical, 2 delivery-focused)
**Challenge:** How to deliver custom automation projects without scaling headcount linearly

---

## Case Study 1: Client Discovery Call Workflow

### The Problem (Before Echelon)

Every new client engagement started with a discovery call to understand their workflows and pain points. The manual process:

1. Schedule 60-90 minute Zoom call with client stakeholders
2. Take notes during call (quality varies, easy to miss details)
3. After call: spend 2-3 hours cleaning up notes and extracting requirements
4. Draft project scope document (another 2 hours)
5. Send to client for review, wait for feedback, iterate
6. **Total time: 6-8 hours per discovery call**

**Problems:**
- Note-taking during calls meant less focus on conversation
- Extracting structured requirements from messy notes was tedious
- Scope documents were inconsistent in format and detail
- Turnaround time (call → scope document) was 2-3 days

### The Echelon Workflow (After)

```
┌─────────────────────────────────────────────────────────────┐
│ STAGE 1: Call Recording & Transcription                    │
│                                                             │
│  Discovery Call Scheduled (calendar integration)           │
│           │                                                 │
│           ▼                                                 │
│  Zoom meeting auto-recorded (with client consent)          │
│           │                                                 │
│           ▼                                                 │
│  AI transcribes call with speaker labels                   │
│           │                                                 │
│           ▼                                                 │
│  Transcript stored in Supabase (linked to client record)   │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ STAGE 2: Requirement Extraction                            │
│                                                             │
│  Transcript Complete                                       │
│           │                                                 │
│           ▼                                                 │
│  AI Analyzes Transcript                                    │
│    - Identifies pain points mentioned                      │
│    - Extracts workflow steps discussed                     │
│    - Flags specific tools/systems mentioned                │
│    - Notes decision criteria and success metrics           │
│           │                                                 │
│           ▼                                                 │
│  AI Generates Structured Requirements Document             │
│    - Current State: What they're doing now                 │
│    - Pain Points: Specific problems mentioned              │
│    - Desired State: What they want to achieve              │
│    - Technical Requirements: Integrations, data sources    │
│    - Success Metrics: How they'll measure ROI              │
│           │                                                 │
│           ▼                                                 │
│  ⚠️  APPROVAL GATE: Consultant Reviews Requirements        │
│           │                                                 │
│           ▼                                                 │
│  [Approved: Move to scope generation]                      │
│  [Needs clarification: Flag gaps for follow-up email]      │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ STAGE 3: Scope Document Generation                         │
│                                                             │
│  Requirements Approved                                     │
│           │                                                 │
│           ▼                                                 │
│  AI Drafts Project Scope Document                          │
│    - Executive summary                                     │
│    - Detailed requirements (from Stage 2)                  │
│    - Proposed solution architecture                        │
│    - Implementation timeline (phases)                      │
│    - Pricing (based on complexity estimation)              │
│    - Success criteria and deliverables                     │
│           │                                                 │
│           ▼                                                 │
│  ⚠️  APPROVAL GATE: Consultant Reviews Full Scope          │
│           │                                                 │
│           ▼                                                 │
│  [Approved: Send to client]                                │
│  [Edits needed: AI incorporates changes + regenerate]      │
└─────────────────────────────────────────────────────────────┘
```

### Results

**Time Savings:**
- Transcript review: 30 min (vs. 2-3 hours of note cleanup)
- Requirements extraction: AI draft + 15 min review (vs. 1-2 hours manual)
- Scope document: AI draft + 30 min review (vs. 2 hours writing)
- **Total time: 1.25 hours (vs. 6-8 hours = 84% reduction)**

**Quality Improvements:**
- No more missed requirements (AI catches everything mentioned)
- Consistent scope document format across all clients
- Faster turnaround: Call → scope document sent in 2-4 hours (vs. 2-3 days)

**Capacity Impact:**
- Before: 2 discovery calls per consultant per week (time-constrained)
- After: 5 discovery calls per consultant per week
- **2.5x increase in client pipeline throughput**

### Why Approval Gates Matter

**Approval at requirements extraction:**
- AI sometimes misinterprets industry jargon or acronyms
- Consultant knows which pain points are deal-breakers vs. nice-to-haves
- Human judgment required to prioritize conflicting requirements

**Approval at scope document:**
- Pricing is strategic (margin management, competitive positioning)
- Timeline estimates require knowledge of team availability
- Client relationship nuances affect how we position the solution

**Real example of approval gate catching issues:**
- AI extracted "integrate with Salesforce" as a requirement
- Consultant caught that client said "we use Salesforce, but we're migrating to HubSpot next quarter"
- Scope was adjusted to target HubSpot integration, avoiding rework

---

## Case Study 2: Candidate Research Automation

### The Problem (Before Echelon)

When delivering staffing agency projects, we needed to demonstrate our workflows by researching real candidates for client job orders. Manual process:

1. Client provides job description and candidate LinkedIn URLs
2. Manually visit each LinkedIn profile, take notes on experience/skills
3. Cross-reference resume (if provided) with LinkedIn
4. Write 2-3 paragraph summary of why candidate is a fit
5. **Total time: 20-30 min per candidate × 10-15 candidates = 3-5 hours per job order**

**Problems:**
- Tedious, repetitive work (but necessary for credibility)
- Inconsistent quality of candidate summaries
- Consultant time better spent on strategic work, not research

### The Echelon Workflow (After)

```
┌─────────────────────────────────────────────────────────────┐
│ STAGE 1: Data Collection                                   │
│                                                             │
│  Candidate LinkedIn URL Provided                           │
│           │                                                 │
│           ▼                                                 │
│  AI Scrapes LinkedIn Public Profile                        │
│    - Current role, company, tenure                         │
│    - Previous experience (titles, companies, dates)        │
│    - Skills listed                                         │
│    - Education                                             │
│    - Notable projects or posts (if public)                 │
│           │                                                 │
│           ▼                                                 │
│  If Resume Provided: AI Parses Resume                      │
│    - Work history with detailed responsibilities          │
│    - Technical skills                                      │
│    - Certifications                                        │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ STAGE 2: Candidate Analysis                                │
│                                                             │
│  LinkedIn + Resume Data Combined                           │
│           │                                                 │
│           ▼                                                 │
│  AI Matches Candidate to Job Requirements                  │
│    - Required skills: Match score with evidence            │
│    - Years of experience: Meets threshold?                 │
│    - Industry experience: Relevant domain knowledge?       │
│    - Career trajectory: Aligned with role level?           │
│           │                                                 │
│           ▼                                                 │
│  AI Generates Candidate Summary                            │
│    - 1-paragraph professional background                   │
│    - Key strengths for this specific role                  │
│    - Potential concerns or gaps                            │
│    - Overall fit score (0-100) with reasoning              │
│           │                                                 │
│           ▼                                                 │
│  ⚠️  APPROVAL GATE: Consultant Spot-Checks Summaries       │
│           │                                                 │
│           ▼                                                 │
│  [Approved: Add to client presentation deck]               │
│  [Needs revision: AI regenerates with specific feedback]   │
└─────────────────────────────────────────────────────────────┘
```

### Results

**Time Savings:**
- LinkedIn scraping: Automated (vs. 5-10 min manual browsing)
- Resume parsing: Automated (vs. 5 min manual reading)
- Summary writing: AI draft + 2 min review (vs. 10 min writing)
- **Total time: 2 min per candidate (vs. 20-30 min = 93% reduction)**

**Capacity Impact:**
- Before: 1 job order per day (3-5 hours of research)
- After: 5 job orders per day (30-40 min of research approval)
- **5x increase in demo project throughput**

**Quality Consistency:**
- All candidate summaries follow same format
- No more subjective variance in scoring
- Easy to compare candidates side-by-side

### Why Approval Gates Matter

**Approval at candidate summaries:**
- AI occasionally misreads tenure (e.g., "2023-Present" as only 1 year when it's 2+ years)
- Consultant knows which skills are must-haves vs. nice-to-haves for client
- Human judgment on cultural fit signals (e.g., job-hopping pattern)

**Real example of approval gate catching issues:**
- AI gave candidate 85/100 fit score based on technical skills
- Consultant noticed candidate had 5 jobs in 3 years (red flag for client)
- Adjusted score to 60/100 and flagged retention risk in summary

---

## Case Study 3: Weekly Client Status Updates

### The Problem (Before Echelon)

Clients expect weekly progress updates during implementation projects. Manual process:

1. Consultant reviews Notion task board, checks what was completed
2. Drafts email summarizing progress, blockers, next steps
3. Formats as bullet points with polite client-facing language
4. **Total time: 30-45 min per client × 5 active clients = 2.5-3.75 hours/week**

**Problems:**
- Weekly status emails felt like busywork
- Easy to forget to send (leads to client anxiety)
- Inconsistent level of detail (sometimes too technical, sometimes too vague)

### The Echelon Workflow (After)

```
┌─────────────────────────────────────────────────────────────┐
│ STAGE 1: Progress Tracking                                 │
│                                                             │
│  Notion Database Integration (tasks linked to clients)     │
│           │                                                 │
│           ▼                                                 │
│  AI Queries Notion API (every Friday 9am)                  │
│    - Tasks completed this week (by client)                 │
│    - Tasks in progress (with assignee)                     │
│    - Blocked tasks (with blocker reason)                   │
│    - Upcoming milestones (next 2 weeks)                    │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ STAGE 2: Status Report Generation                          │
│                                                             │
│  Notion Data Fetched                                       │
│           │                                                 │
│           ▼                                                 │
│  AI Generates Weekly Status Email                          │
│    - Greeting personalized to client                       │
│    - "This Week's Progress" section (completed tasks)      │
│    - "In Progress" section (active work)                   │
│    - "Blockers" section (if any, with next steps)          │
│    - "Next Week's Focus" section                           │
│    - CTA (if client action needed)                         │
│           │                                                 │
│           ▼                                                 │
│  ⚠️  APPROVAL GATE: Consultant Reviews Email Draft         │
│           │                                                 │
│           ▼                                                 │
│  [Approved: Schedule send for Friday 4pm]                  │
│  [Needs edits: AI incorporates feedback + regenerate]      │
└─────────────────────────────────────────────────────────────┘
```

### Results

**Time Savings:**
- Progress review: Automated (vs. 10-15 min manual Notion review)
- Email drafting: AI draft + 5 min review (vs. 20-30 min writing)
- **Total time: 5 min per client (vs. 30-45 min = 89% reduction)**

**Per-week impact:**
- Before: 2.5-3.75 hours/week across 5 clients
- After: 25 min/week across 5 clients
- **Saves 2-3.5 hours/week = 104-182 hours/year per consultant**

**Client Satisfaction:**
- 100% on-time status updates (automated scheduling prevents forgetting)
- Consistent format (clients know where to look for blockers)
- Faster response to blockers (flagged immediately, not buried in update)

### Why Approval Gates Matter

**Approval at status email:**
- AI sometimes over-explains technical details (confuses non-technical clients)
- Consultant knows when to soften language around delays or blockers
- Human judgment on what to highlight (client cares about outcomes, not tasks)

**Real example of approval gate catching issues:**
- AI draft: "Completed database migration to PostgreSQL 15 with pgvector extension"
- Consultant edit: "Completed backend setup to enable AI-powered candidate matching"
- Client doesn't care about PostgreSQL version, they care about feature unlock

---

## Lessons Learned

### 1. Approval Gates Are Not Optional

**Early mistake:** We tried running workflows fully autonomous (no approval gates) to save time.

**What happened:**
- AI sent a candidate summary with wrong company name (parsed LinkedIn incorrectly)
- Client noticed and lost confidence in our process
- Had to apologize and re-do all summaries with manual review

**Lesson:** Supervised autonomy (AI proposes, human approves) is the only way to maintain quality and trust. Full autonomy fails on edge cases.

---

### 2. AI Prompts Require Iteration

**Early mistake:** Wrote generic prompts like "Summarize this candidate's background."

**What happened:**
- AI summaries were too generic (could apply to anyone)
- Lacked specific evidence for why candidate matched role
- Required heavy editing, defeating the purpose of automation

**Lesson:** Prompts must be specific about format, tone, and what evidence to include. We iterated 5-7 times on each prompt before reaching production quality.

**Example of good prompt specificity:**
```
Write a 2-3 paragraph candidate summary for a staffing agency presentation.

Paragraph 1: Professional background (current role, years of experience, industry)
Paragraph 2: Key strengths for THIS ROLE (reference specific job requirements)
Paragraph 3: Fit assessment (overall score 0-100, any concerns)

Tone: Professional but conversational. Client-facing language (avoid recruiter jargon).
Evidence: Always cite specific examples from resume/LinkedIn (e.g., "Led 10-person team at ABC Corp").
```

---

### 3. Integration Reliability Matters More Than AI Intelligence

**Early mistake:** Focused on getting the "smartest" AI outputs, didn't invest enough in integration stability.

**What happened:**
- Notion API rate limits caused workflow failures
- LinkedIn scraping broke when they changed HTML structure
- Zoom recording webhooks occasionally failed (no transcript = workflow stalled)

**Lesson:** 90% of production issues are integration failures, not AI quality. We now spend more time on error handling, retries, and fallback logic than on prompt engineering.

**Our integration reliability checklist:**
- Rate limit handling (exponential backoff)
- Webhook failure detection (alert if no data received)
- Fallback logic (manual upload if auto-scrape fails)
- Health checks (test integrations daily, not just when workflow runs)

---

### 4. Measure Everything (Time Savings Are Real)

**Early mistake:** Assumed automation was saving time, didn't measure rigorously.

**What we did:**
- Tracked time spent on each workflow step (before and after automation)
- Logged every approval gate interaction (how often AI needed edits)
- Surveyed team on subjective quality of life improvements

**Results that surprised us:**
- AI outputs required edits 40% of the time initially (now down to 15% after prompt iteration)
- Time savings were HIGHER than expected (we underestimated how much time we spent on admin)
- Biggest impact wasn't time savings—it was consistency (no more forgotten status updates, inconsistent candidate summaries)

**Lesson:** Measure rigorously to justify continued investment in automation. Time tracking data also helps sell Echelon to clients ("we saved X hours using this exact workflow").

---

## Current Stats (As of November 2025)

**Workflows Automated:**
- Client discovery call → scope document: 15 clients
- Candidate research automation: 8 projects (120+ candidates analyzed)
- Weekly status updates: 5 active clients (20+ weeks continuous)

**Time Saved:**
- Per consultant: 12 hours/week average
- Across team of 3: 36 hours/week = **1,872 hours/year**

**Quality Metrics:**
- Scope document accuracy: 95% (client approval without major revisions)
- Candidate summary approval rate: 85% (first draft approved without edits)
- Status update on-time delivery: 100% (automated scheduling)

**Business Impact:**
- Client onboarding time: 2 weeks → 1.2 weeks (40% faster)
- Active client capacity: 3 clients/consultant → 5 clients/consultant (67% increase)
- Zero missed deliverables in 6 months (previously 2-3 per quarter)

---

## What We're Building Next

### Q1 2026: Client Reporting Dashboard
- Auto-generate monthly ROI reports for clients (time saved, workflows automated)
- Replace manual spreadsheet tracking with real-time Supabase queries
- Target: Save 2 hours/month per client

### Q2 2026: Proposal Generation Workflow
- Auto-draft proposals from discovery call transcripts
- Include pricing calculator based on workflow complexity estimation
- Target: 3 hours → 30 min per proposal

### Q3 2026: Implementation Progress Tracking
- Real-time dashboard showing project status across all clients
- Predictive alerts for timeline risks (e.g., blocked tasks accumulating)
- Target: Reduce project manager overhead by 50%

---

## Why We're Sharing This

**Transparency:** We believe in showing our work, not just the polished final product.

**Credibility:** Anyone can claim AI automation works. We're showing the messy reality: what works, what doesn't, and what we learned.

**Accountability:** By dogfooding Echelon, we're forced to build features that actually matter (not vaporware). If it doesn't work for us, we won't ship it to clients.

---

## Questions?

Want to see these workflows in action or discuss implementing similar automation for your consultancy?

**Email:** sperry@entelech.net
**GitHub Issues:** [Ask a question](https://github.com/sperry-entelech/echelon/issues)

---

*Last updated: November 2025. We update this document quarterly as we add new workflows and learn more about what works in production.*
