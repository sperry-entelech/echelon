# Strategic Decisions Log

Documenting key choices for team context.

## Decision 1: Workflows First, Full Stack Agents Later

**Choice:** Build agentic workflow platform first, but the endgame is full stack async agents

**The differentiation:** Most tools are either dumb automation (Zapier) or scary black-box agents. Echelon's moat is true async agents that work across your full stack - persistent memory, autonomous execution, cross-system orchestration. Not just AI nodes in a workflow. Actual agents that run your operations.

**Why workflows first:**
- Need trust before autonomy (human in loop → earned autonomy)
- Need to understand real user workflows before building agents for them
- "Agent platform" without working agents loses credibility
- Workflows generate data we need to train agent behaviors

**The trajectory:**
1. Workflows (MVP) - prove we can orchestrate actions reliably
2. Memory layer - agents remember context across runs
3. Async execution - agents work in background without human trigger
4. Full autonomy - agents manage entire operational domains

**This is the whole product vision.** Workflows are just how we get there without scaring users or shipping vaporware. The goal is agents that actually run your business operations async across every tool you use.

**Implication for MVP:** No persistent memory yet. Users design flow, AI reasons within it. But architecture decisions now should not block the agent layer later.

## Decision 2: Stack Flexibility

**Context:** Original spec used Base44 + Supabase + Glyph + n8n (no-code approach)

**Current position:** Native code preferred if real dev available. Spec documents logic, implementation is dev's call.

**What stays:** User flow logic, schema concepts, integration requirements
**What's flexible:** Frontend framework, workflow engine choice, deployment infra

## Decision 3: MVP Integrations

**Choice:** Slack + Email only for Phase 1

**Why:** Nail two before expanding. Add Calendar, CRM in Phase 2 based on demand.

## Decision 4: Pricing

**Direction:** Usage-based, tiered by complexity. Not $29/mo flat.

**Why:** This can handle entire roles. Flat pricing ignores value delivered.

## Decision 5: Distribution

**Pre-PMF:** Direct outreach, agency owner connections, dogfooding
**Post-PMF:** Apex audience (3-5M), organic referrals

No elaborate launch before product works.

## Decision 6: Niche Entry Point

**Choice:** Commercial insurance brokers ($2-10M revenue, 5-30 employees)

**Why this niche:**
- **Specific pain:** Losing renewals and new business to faster competitors
- **Right deal size:** $3-15K implementations, not enterprise complexity
- **Clear ROI:** One saved renewal pays for the system
- **Warm intro:** HILB connection gives us a foot in the door
- **Referral-driven:** Tight-knit industry, strong word-of-mouth

**Alternatives considered:**
- Staffing agencies (still on deck for 2027 expansion)
- Generic "professional services" (too broad, no wedge)
- Enterprise insurance carriers (too long sales cycle, too much compliance)

**Implication:** All initial workflows, case studies, and templates will be insurance broker-specific. Horizontal expansion comes AFTER niche dominance.

## Decision 7: Bootstrapping Through Consulting

**Choice:** Build revenue through consulting before platform development

**Why:**
- Can't build platform without domain expertise
- Consulting generates cash flow to fund development
- Every client engagement teaches what to productize
- Case studies prove we're not vaporware

**The sequence:**
1. Consulting revenue ($0 → $50K MRR)
2. Document patterns into templates
3. Templates become platform features
4. Platform serves self-serve market

**What this means:** Echelon is currently internal tooling for our consulting. It becomes a product when the patterns are proven.
