# Staffing Agency Use Cases for Echelon

> **Detailed workflow implementations for professional services staffing**

---

## Table of Contents

1. [Candidate Communication Automation](#1-candidate-communication-automation)
2. [Placement Process Automation](#2-placement-process-automation)
3. [Client Workflow Automation](#3-client-workflow-automation)
4. [Integration Requirements](#integration-requirements)
5. [Implementation Timeline](#implementation-timeline)
6. [ROI Calculations](#roi-calculations)

---

## 1. Candidate Communication Automation

### Business Problem

Recruiters spend 60-70% of their time on administrative tasks:
- Manually screening hundreds of applications per week
- Writing personalized outreach emails to each candidate
- Coordinating interview schedules across multiple calendars
- Following up with candidates at each pipeline stage

**Result:** Only 30-40% of time spent on high-value relationship building and client management.

### Workflow Design

```
┌─────────────────────────────────────────────────────────────┐
│ STAGE 1: Application Intake                                │
│                                                             │
│  New Application Received (ATS webhook)                    │
│           │                                                 │
│           ▼                                                 │
│  AI Parses Resume + Job Requirements                       │
│           │                                                 │
│           ▼                                                 │
│  AI Scores Match (0-100 scale)                             │
│           │                                                 │
│           ▼                                                 │
│  [Score >70: Auto-shortlist]                               │
│  [Score 50-70: Recruiter review required]                  │
│  [Score <50: Auto-reject with feedback]                    │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ STAGE 2: Candidate Outreach                                │
│                                                             │
│  Shortlisted Candidate                                     │
│           │                                                 │
│           ▼                                                 │
│  AI Researches Background (LinkedIn, portfolio, etc.)      │
│           │                                                 │
│           ▼                                                 │
│  AI Drafts Personalized Outreach Email                     │
│           │                                                 │
│           ▼                                                 │
│  ⚠️  APPROVAL GATE: Recruiter Reviews Email Draft          │
│           │                                                 │
│           ▼                                                 │
│  [Approved: Send email]                                    │
│  [Edits required: AI incorporates feedback + retry]        │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ STAGE 3: Interview Scheduling                              │
│                                                             │
│  Candidate Responds (email tracking)                       │
│           │                                                 │
│           ▼                                                 │
│  AI Proposes Interview Times (checks recruiter calendar)   │
│           │                                                 │
│           ▼                                                 │
│  ⚠️  APPROVAL GATE: Recruiter Confirms Time Slot           │
│           │                                                 │
│           ▼                                                 │
│  AI Sends Calendar Invite + Zoom Link                      │
│           │                                                 │
│           ▼                                                 │
│  AI Sends Reminder 24h Before Interview                    │
└─────────────────────────────────────────────────────────────┘
```

### Approval Gates Explained

**Why approval at email drafts?**
- First impression with candidate is critical
- Tone and positioning must match agency brand
- Recruiter knows specific nuances about the role

**Why approval at scheduling?**
- Recruiter may have urgent calls that override calendar availability
- Client meetings may require buffer time
- VIP candidates may need priority scheduling

### Example AI Prompt (Personalized Outreach)

```
You are drafting an outreach email from a professional recruiter to a candidate.

CANDIDATE INFORMATION:
- Name: [extracted from resume]
- Current Role: [LinkedIn data]
- Skills: [resume + LinkedIn]
- Notable Projects: [portfolio links, GitHub, etc.]

JOB INFORMATION:
- Title: Senior Full-Stack Engineer
- Company: Fintech startup (Series B)
- Key Requirements: React, Node.js, AWS, microservices
- Salary Range: $140K-$180K
- Location: Remote (US timezones)

RECRUITER CONTEXT:
- Recruiter Name: Sarah Chen
- Agency: Apex Staffing Partners
- Previous Placements: 3 engineers at similar fintech companies

TASK:
Write a 3-4 paragraph email that:
1. Opens with a specific detail from the candidate's background (NOT generic)
2. Explains why this role aligns with their career trajectory
3. Highlights the company's growth stage and technical stack
4. Includes a clear call-to-action for a 15-minute exploratory call

TONE: Professional but warm. No recruiter clichés ("rock star," "unicorn," "ninja").
```

### Expected Outputs

**For recruiter approval:**
- Candidate match score with reasoning (why 85/100?)
- Personalized email draft with highlighting showing AI-generated sections
- Recommended interview times with conflict warnings

**Audit trail:**
- Every application scored with reasoning chain
- Every email sent with approval timestamp
- Every schedule conflict flagged and resolved

### ROI Breakdown

**Time Savings:**
- Resume screening: 5 min → 30 sec (90% reduction)
- Email drafting: 10 min → 2 min (80% reduction, includes review time)
- Scheduling coordination: 15 min → 3 min (80% reduction)

**Total per candidate:** 30 min → 5.5 min = 81% time savings

**Capacity increase:**
- Before: 20 candidates/week per recruiter
- After: 60 candidates/week per recruiter (3x throughput)

**Revenue impact:**
- Avg placement fee: $25K
- Placements per recruiter/year: 8 → 24
- Revenue increase: $200K → $600K (+$400K per recruiter)

---

## 2. Placement Process Automation

### Business Problem

Account managers juggle 10-20 active job orders simultaneously:
- Manually matching candidate profiles to job specs
- Creating custom interview guides for each client
- Drafting offer letters with complex compensation structures
- Coordinating multi-stakeholder approvals (recruiter → manager → client)

**Result:** 36-day average time-to-placement, 30% offer rejection rate.

### Workflow Design

```
┌─────────────────────────────────────────────────────────────┐
│ STAGE 1: Candidate-Job Matching                            │
│                                                             │
│  New Job Order Received                                    │
│           │                                                 │
│           ▼                                                 │
│  AI Parses Job Description (skills, experience, culture)   │
│           │                                                 │
│           ▼                                                 │
│  AI Searches Candidate Database (vector similarity)        │
│           │                                                 │
│           ▼                                                 │
│  AI Ranks Top 10 Matches with Reasoning                    │
│           │                                                 │
│           ▼                                                 │
│  ⚠️  APPROVAL GATE: Account Manager Selects Top 3          │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ STAGE 2: Interview Preparation                             │
│                                                             │
│  Selected Candidates (from approval)                       │
│           │                                                 │
│           ▼                                                 │
│  AI Generates Custom Interview Guide                       │
│    - Technical questions tailored to job requirements      │
│    - Behavioral questions based on company culture         │
│    - Evaluation rubric with scoring criteria               │
│           │                                                 │
│           ▼                                                 │
│  AI Creates Candidate Briefing Document                    │
│    - Company background research                           │
│    - Hiring manager LinkedIn summary                       │
│    - Suggested questions for candidate to ask              │
│           │                                                 │
│           ▼                                                 │
│  Documents sent to account manager for distribution        │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ STAGE 3: Offer Generation                                  │
│                                                             │
│  Client Selects Finalist                                   │
│           │                                                 │
│           ▼                                                 │
│  AI Drafts Offer Letter                                    │
│    - Base salary (from job order)                          │
│    - Equity/bonus structure (if applicable)                │
│    - Benefits summary                                      │
│    - Start date calculation (2-week notice + buffer)       │
│           │                                                 │
│           ▼                                                 │
│  AI Calculates Compensation Comparison                     │
│    - Market data for role/location                         │
│    - Candidate's current comp (if known)                   │
│    - Competing offers (if disclosed)                       │
│           │                                                 │
│           ▼                                                 │
│  ⚠️  APPROVAL GATE: Manager Reviews Offer Terms            │
│           │                                                 │
│           ▼                                                 │
│  [Approved: Send to client for final approval]             │
│  [Edits: AI incorporates changes + regenerate]             │
└─────────────────────────────────────────────────────────────┘
```

### Approval Gates Explained

**Why approval at candidate selection?**
- Account manager knows client's unstated preferences
- Cultural fit is subjective and requires human judgment
- Client relationship nuances affect candidate positioning

**Why approval at offer stage?**
- Compensation is high-stakes (affects margins and candidate retention)
- Manager must ensure offer competitiveness
- Legal/compliance review may be required for certain terms

### Example AI Prompt (Candidate Matching)

```
You are matching candidates to a job order for a professional staffing agency.

JOB ORDER DETAILS:
- Role: VP of Engineering
- Company: Series B SaaS (100 employees, $20M ARR)
- Industry: Healthcare IT
- Required Experience:
  * 10+ years engineering leadership
  * Managed teams of 20+ engineers
  * Experience scaling from startup to mid-stage
  * Healthcare/regulated industry experience preferred
- Technical Stack: Python, React, AWS, Kubernetes
- Compensation: $220K-$260K + equity
- Location: Remote (preference for East Coast timezone)

CANDIDATE DATABASE:
[Vector embeddings of 500+ candidates with experience, skills, preferences]

TASK:
1. Search candidate database using semantic similarity
2. Rank top 10 candidates by fit score (0-100)
3. For each candidate, provide:
   - Match score with breakdown (technical fit, leadership fit, industry fit)
   - Key strengths that align with role
   - Potential concerns or gaps
   - Likelihood of interest (based on career trajectory and preferences)

PRIORITIZATION CRITERIA:
- Healthcare/regulated industry experience = +15 points
- Current VP/Director title = +10 points
- East Coast location = +5 points
- Recent job change (<1 year) = -20 points (probably not looking)
```

### Expected Outputs

**For account manager approval:**
- Candidate ranking table with match scores and reasoning
- Side-by-side comparison of top 3 candidates
- Interview guide draft (10-15 questions + rubric)
- Offer letter draft with compensation analysis

**Audit trail:**
- Candidate selection rationale logged
- Interview guide versions tracked
- Offer terms approval chain documented

### ROI Breakdown

**Time Savings:**
- Candidate search: 2 hours → 15 min (87% reduction)
- Interview guide creation: 1 hour → 10 min (83% reduction)
- Offer letter drafting: 45 min → 10 min (78% reduction)

**Total per placement:** 4 hours → 35 min = 85% time savings

**Quality improvements:**
- Time-to-placement: 36 days → 22 days (40% faster)
- Offer acceptance rate: 70% → 84% (+14% from better comp positioning)
- Client satisfaction: 7.2/10 → 8.9/10 (faster, more thorough process)

**Revenue impact:**
- Avg placement fee: $45K (higher for VP-level roles)
- Placements per account manager/year: 12 → 18 (+50% capacity)
- Revenue increase: $540K → $810K (+$270K per account manager)

---

## 3. Client Workflow Automation

### Business Problem

Sales/BD teams struggle to scale client acquisition:
- Manually researching each company's hiring needs
- Generic outreach emails with low response rates
- Inconsistent follow-up (deals slip through cracks)
- No systematic process for pricing proposals

**Result:** 2-3% cold email response rate, 60-day sales cycle.

### Workflow Design

```
┌─────────────────────────────────────────────────────────────┐
│ STAGE 1: Client Research                                   │
│                                                             │
│  Target Company Identified (from CRM or prospecting list)  │
│           │                                                 │
│           ▼                                                 │
│  AI Researches Company                                     │
│    - Recent funding rounds / financial news                │
│    - Job postings (quantity, roles, urgency signals)       │
│    - Glassdoor/LinkedIn hiring trends                      │
│    - Competitors' hiring patterns                          │
│           │                                                 │
│           ▼                                                 │
│  AI Researches Decision Maker                              │
│    - LinkedIn profile summary                              │
│    - Recent posts/activity (pain points mentioned?)        │
│    - Career history (previous agencies used?)              │
│    - Mutual connections                                    │
│           │                                                 │
│           ▼                                                 │
│  AI Generates Positioning Strategy                         │
│    - Primary pain point to address                         │
│    - Relevant case studies to reference                    │
│    - Recommended talking points                            │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ STAGE 2: Outreach Campaign                                 │
│                                                             │
│  Positioning Strategy Complete                             │
│           │                                                 │
│           ▼                                                 │
│  AI Drafts Email Sequence (3-email campaign)               │
│    - Email 1: Problem-focused, no ask                      │
│    - Email 2: Case study + soft CTA                        │
│    - Email 3: Direct offer for discovery call              │
│           │                                                 │
│           ▼                                                 │
│  ⚠️  APPROVAL GATE: Sales Lead Reviews Campaign            │
│           │                                                 │
│           ▼                                                 │
│  [Approved: Schedule send times]                           │
│  [Edits: AI incorporates feedback + regenerate]            │
│           │                                                 │
│           ▼                                                 │
│  AI Tracks Opens/Clicks/Replies                            │
│           │                                                 │
│           ▼                                                 │
│  AI Drafts Reply to Interested Prospects                   │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ STAGE 3: Proposal Generation                               │
│                                                             │
│  Discovery Call Completed (transcript recorded)            │
│           │                                                 │
│           ▼                                                 │
│  AI Extracts Requirements from Transcript                  │
│    - Roles needed (titles, seniority, quantity)            │
│    - Timeline urgency                                      │
│    - Budget constraints (if mentioned)                     │
│    - Decision criteria                                     │
│           │                                                 │
│           ▼                                                 │
│  AI Generates Pricing Proposal                             │
│    - Fee structure (contingent, retained, hybrid)          │
│    - Estimated timeline to first placement                 │
│    - Service level commitments                             │
│    - Payment terms                                         │
│           │                                                 │
│           ▼                                                 │
│  ⚠️  APPROVAL GATE: Sales Lead Reviews Pricing             │
│           │                                                 │
│           ▼                                                 │
│  [Approved: Send proposal]                                 │
│  [Adjust pricing: AI recalculates + regenerate]            │
└─────────────────────────────────────────────────────────────┘
```

### Approval Gates Explained

**Why approval at outreach campaign?**
- First touchpoint with potential client (brand reputation at stake)
- Sales lead knows industry-specific sensitivities
- Tone must match agency positioning (boutique vs. high-volume)

**Why approval at pricing?**
- Margin management requires human judgment
- Pricing strategy may vary based on strategic importance of client
- Legal/compliance review for non-standard terms

### Example AI Prompt (Client Research)

```
You are researching a target company for a staffing agency's outbound campaign.

TARGET COMPANY:
- Name: TechHealth Solutions
- Industry: Healthcare SaaS
- Size: 150 employees
- Funding: Series B ($30M raised in June 2025)
- Website: [URL]

RESEARCH TASKS:
1. Analyze recent funding announcement:
   - What are they planning to spend the money on?
   - Any mention of hiring goals or team expansion?
   - Who led the round? (VC firms may have hiring expectations)

2. Scan job postings (Indeed, LinkedIn, Greenhouse):
   - How many open roles?
   - What roles? (engineering, sales, ops?)
   - How long have postings been open? (urgency indicator)
   - Quality of job descriptions (suggests internal recruiting maturity)

3. Research decision maker (Sarah Johnson, VP of People):
   - LinkedIn summary (when did she join? previous experience?)
   - Recent posts (any frustration about hiring challenges?)
   - Mutual connections (can we get warm intro?)

4. Competitive intelligence:
   - Are competitors (similar stage healthcare SaaS) hiring aggressively?
   - What agencies do they use? (check LinkedIn "People also viewed")

OUTPUT FORMAT:
- Executive summary (3-4 sentences on hiring situation)
- Primary pain point (e.g., "Struggling to hire senior engineers in competitive market")
- Recommended positioning (how our agency solves their specific problem)
- Urgency score (1-10, based on signals)
```

### Expected Outputs

**For sales lead approval:**
- Client research summary with pain point analysis
- 3-email outreach sequence with personalization
- Pricing proposal with margin calculations
- Follow-up task reminders (if no response after email 3)

**Audit trail:**
- Research sources logged (LinkedIn, Glassdoor, job boards)
- Email performance tracked (open rate, reply rate)
- Proposal versions documented with approval timestamps

### ROI Breakdown

**Time Savings:**
- Company/decision maker research: 45 min → 10 min (78% reduction)
- Email sequence drafting: 30 min → 5 min (83% reduction)
- Proposal creation: 1 hour → 15 min (75% reduction)

**Total per prospect:** 2.25 hours → 30 min = 78% time savings

**Conversion improvements:**
- Email response rate: 2% → 8% (better personalization)
- Discovery call → proposal sent: 60% → 85% (faster turnaround)
- Proposal → closed deal: 25% → 35% (better pricing positioning)

**Revenue impact:**
- Prospects contacted per BD rep/month: 40 → 120 (3x capacity)
- Closed deals/year per rep: 6 → 18 (higher volume + conversion)
- Avg contract value: $180K (annual fees from placements)
- Revenue increase: $1.08M → $3.24M (+$2.16M per rep)

---

## Integration Requirements

### Core Systems (Required)

**Applicant Tracking System (ATS):**
- Supported: Bullhorn, JobAdder, Vincere, Crelate
- Integration method: Webhooks + REST API
- Data synced: Applications, candidate profiles, job orders, pipeline stages

**Customer Relationship Management (CRM):**
- Supported: Salesforce, HubSpot, Pipedrive
- Integration method: REST API + OAuth
- Data synced: Client accounts, contacts, opportunities, communication logs

**Email Platform:**
- Supported: Gmail, Outlook, SendGrid
- Integration method: IMAP/SMTP + API
- Data synced: Sent emails, replies, open/click tracking

**Calendar:**
- Supported: Google Calendar, Outlook Calendar
- Integration method: CalDAV + API
- Data synced: Availability, booked meetings, scheduling conflicts

### Optional Integrations (Enhanced Features)

**Background Check Services:**
- Checkr, Sterling, HireRight
- Automate background check initiation upon offer acceptance

**Compensation Data:**
- Levels.fyi API, Payscale, Salary.com
- Real-time market comp data for offer positioning

**LinkedIn Recruiter:**
- LinkedIn Recruiter System Connect (RSC)
- Sync candidate profiles, InMail tracking

**Video Interview Platforms:**
- HireVue, Spark Hire, Modern Hire
- Auto-schedule video interviews, extract transcript for analysis

---

## Implementation Timeline

### Week 1-2: Discovery & Mapping
- Workshop with recruiting team to map exact workflows
- Identify approval thresholds and decision criteria
- Review existing integrations and data quality
- Define success metrics (time savings, throughput, quality)

### Week 3-4: Configuration & Testing
- Connect ATS, CRM, email, calendar integrations
- Configure AI prompts for agency's specific tone/positioning
- Set up approval gates with appropriate stakeholders
- Test workflows with sample data (no live candidates yet)

### Week 5-6: Pilot Deployment
- Launch with 2-3 recruiters on non-critical job orders
- Monitor approval rates (are humans trusting AI outputs?)
- Collect feedback on AI output quality
- Iterate on prompts and approval thresholds

### Week 7-8: Full Rollout
- Train entire recruiting team
- Roll out to all active job orders
- Establish weekly performance review cadence
- Document case studies for internal knowledge base

### Month 3+: Optimization
- Analyze which workflows have highest ROI
- Fine-tune AI prompts based on approval patterns
- Add additional integrations (compensation data, LinkedIn, etc.)
- Expand to additional use cases (onboarding automation, client reporting)

---

## ROI Calculations

### Candidate Communication Automation

**Assumptions:**
- Recruiting team size: 5 recruiters
- Applications processed per week: 200 (40 per recruiter)
- Time saved per application: 24.5 minutes
- Fully-burdened recruiter cost: $80K/year = $40/hour

**Time Savings:**
- Total time saved: 200 apps/week × 24.5 min = 81.7 hours/week
- Annual time savings: 81.7 hours/week × 50 weeks = 4,085 hours
- Dollar value: 4,085 hours × $40/hour = **$163,400/year**

**Capacity Increase:**
- Additional candidates engaged: 200/week → 600/week (3x)
- Additional placements (assuming 2% conversion): 12/year → 36/year
- Placement fee revenue: 24 placements × $25K = **$600,000/year**

**Total ROI: $763,400/year**

---

### Placement Process Automation

**Assumptions:**
- Account manager team size: 3 managers
- Active placements per month: 6 (2 per manager)
- Time saved per placement: 3.4 hours
- Fully-burdened manager cost: $120K/year = $60/hour

**Time Savings:**
- Total time saved: 6 placements/month × 3.4 hours = 20.4 hours/month
- Annual time savings: 20.4 hours/month × 12 = 245 hours
- Dollar value: 245 hours × $60/hour = **$14,700/year**

**Quality Improvements:**
- Faster placements: 36 days → 22 days (14-day reduction)
- Additional placements due to speed: 6/year increase across team
- Placement fee revenue: 6 placements × $45K = **$270,000/year**

**Higher offer acceptance:**
- Acceptance rate increase: 70% → 84% (+14%)
- Saved recruiting cycles (fewer rejections): 4/year
- Cost savings (not restarting search): 4 × $5K = **$20,000/year**

**Total ROI: $304,700/year**

---

### Client Workflow Automation

**Assumptions:**
- BD/sales team size: 2 reps
- Prospects contacted per month: 80 (40 per rep)
- Time saved per prospect: 1.75 hours
- Fully-burdened sales rep cost: $100K/year = $50/hour

**Time Savings:**
- Total time saved: 80 prospects/month × 1.75 hours = 140 hours/month
- Annual time savings: 140 hours/month × 12 = 1,680 hours
- Dollar value: 1,680 hours × $50/hour = **$84,000/year**

**Conversion Improvements:**
- Email response rate: 2% → 8% (+6%)
- Additional discovery calls: 80 prospects/month × 6% = 4.8/month = 58/year
- Conversion to closed deal: 58 calls × 35% = 20 new clients/year
- Avg annual contract value: $180K
- Revenue increase: 20 clients × $180K = **$3,600,000/year**

**Total ROI: $3,684,000/year**

---

### Combined ROI Summary

| Use Case | Time Savings | Revenue Impact | Total Annual ROI |
|----------|--------------|----------------|------------------|
| Candidate Communication | $163,400 | $600,000 | $763,400 |
| Placement Process | $14,700 | $290,000 | $304,700 |
| Client Workflow | $84,000 | $3,600,000 | $3,684,000 |
| **TOTAL** | **$262,100** | **$4,490,000** | **$4,752,100** |

**Platform Cost:**
- Implementation: $50K (one-time)
- Monthly platform fee: $5K × 12 = $60K/year
- First-year total cost: $110K

**Net ROI (Year 1): $4,642,100**
**ROI Multiple: 42x**

---

## Next Steps

Ready to implement Echelon for your staffing agency?

1. **Schedule Discovery Workshop:** 2-hour session to map your exact workflows → [Book time](mailto:sperry@entelech.net)
2. **Review Integration Requirements:** Ensure your ATS/CRM are supported
3. **Define Success Metrics:** What does a successful pilot look like for your team?
4. **Pilot Deployment:** 4-week pilot with 2-3 recruiters to validate ROI

**Questions?** Email sperry@entelech.net or [open a GitHub issue](https://github.com/sperry-entelech/echelon/issues).

---

*These use cases are based on real implementations with staffing agencies in the financial services vertical. Your ROI may vary based on team size, workflow complexity, and integration requirements.*
