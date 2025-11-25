# Echelon

> **Supervised Workflow Automation Infrastructure**

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Documentation](https://img.shields.io/badge/docs-latest-brightgreen.svg)](docs/)

---

## Overview

Echelon is a **supervised workflow automation platform** that enables businesses to build their own AI-enabled internal tools instead of settling for generic SaaS solutions.

**The vibe coding thesis:** By 2026, businesses will build their exact workflows internally using AI assistance rather than buying one-size-fits-all software. Echelon provides the infrastructure for supervised automation—AI handles the 80% grunt work, humans approve the 20% that requires judgment.

**Initial focus:** Professional services firms (staffing agencies, insurance brokerages, financial advisors) with complex, high-stakes workflows that can't be fully automated.

---

## Why Echelon Exists

### The Problem: Generic SaaS Doesn't Fit

Most business software is built for everyone, which means it fits nobody perfectly:

- ❌ One-size-fits-all features you don't need
- ❌ Missing the specific workflows you DO need
- ❌ Expensive customization that breaks on updates
- ❌ Vendor lock-in with no control over your data
- ❌ "AI features" that don't understand your business

**The 2026 shift:** Businesses are bringing development internal with AI-assisted tooling. Why pay for generic SaaS when you can build exactly what you need?

### The Solution: Build Your Own With Supervision

Echelon provides:

1. **Workflow automation infrastructure** - Build custom pipelines for your exact processes
2. **Supervised autonomy** - AI proposes actions, humans approve critical decisions
3. **Pre-built templates** - Start with 80% complete workflows for common use cases
4. **Full data control** - Your workflows, your data, your rules
5. **Observable** - Complete audit trails for compliance and debugging

---

## Core Use Case: Professional Services Staffing

Professional services firms (staffing agencies, insurance brokerages, financial advisors) have workflows that generic CRMs and ATS systems can't handle:

- High-stakes decisions requiring human judgment
- Complex approval workflows (recruiter → manager → client)
- Relationship-dependent processes (candidates, hiring managers, clients)
- Compliance requirements (EEOC, data privacy, industry regulations)

**Echelon enables these firms to build internal automation that fits their EXACT processes.**

---

## Use Cases

### 1. Candidate Communication Automation (Staffing Agencies)

**The workflow:**
- AI screens incoming applications against job requirements
- AI drafts personalized outreach messages
- **Recruiter reviews and approves** candidate shortlists
- AI schedules initial calls and sends calendar invites
- **Recruiter approves** interview scheduling with hiring managers

**ROI:**
- 60% reduction in recruiter admin time
- 3x more candidates engaged per recruiter
- Zero mistakes on high-value placements (human review required)

---

### 2. Placement Process Automation (Staffing Agencies)

**The workflow:**
- AI matches candidates to job specifications
- AI generates interview guides based on client requirements
- **Account manager approves** final candidate selections
- AI drafts offer letters and compensation packages
- **Manager approves** before sending to candidates

**ROI:**
- 40% faster time-to-placement
- 20% higher offer acceptance rates
- Complete audit trail for compliance

---

### 3. Client Workflow Automation (Professional Services)

**The workflow:**
- AI parses job descriptions and extracts requirements
- AI researches hiring manager preferences and company culture
- **Sales lead approves** client outreach strategy
- AI drafts positioning emails and follow-up sequences
- **Sales lead approves** pricing proposals before submission

**ROI:**
- 50% faster client onboarding
- 30% more job orders per account manager
- Higher client satisfaction (more responsive, personalized)

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                   Workflow Designer (Base44)                │
│         Visual builder + Industry-specific templates        │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│             Execution Engine (Cloudflare Workers)           │
│      Task routing + Approval gates + Audit logging          │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│             State Management (Supabase PostgreSQL)          │
│     Workflow definitions + Execution logs + Approvals       │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│           Agent Runtime (n8n + AI Models)                   │
│  Task execution + External integrations + Data processing   │
└─────────────────────────────────────────────────────────────┘
```

**Design Principles:**
- **Supervised > Autonomous** - AI assists, humans decide
- **Observable** - Every decision logged for compliance
- **Modular** - Swap components without rebuilding
- **Yours** - You control the code, data, and logic

---

## Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Frontend** | Base44 | Visual workflow designer |
| **API Gateway** | Cloudflare Workers | Edge routing, auth |
| **Database** | Supabase PostgreSQL | Workflow state, audit logs |
| **Orchestration** | n8n | Workflow execution |
| **AI Models** | Claude, OpenAI | Reasoning, generation |

---

## Dogfooding: How We Use Echelon

We built Echelon while running an AI operations consultancy serving staffing agencies. Every feature exists because we needed it ourselves.

**Our workflows:**
- Client discovery call transcription → requirement extraction → scope generation
- Candidate research automation → shortlist creation → client presentation prep
- Weekly status updates → progress summarization → client communication

**Results:**
- 12 hours/week saved per consultant
- 40% faster client onboarding
- Zero missed deliverables (approval gates prevent errors)

See [DOGFOODING.md](DOGFOODING.md) for detailed case studies.

---

## Quick Start

### Prerequisites
- Node.js 18+
- Supabase account (or PostgreSQL)
- n8n Cloud or self-hosted
- Cloudflare Workers account

### Installation

```bash
git clone https://github.com/sperry-entelech/echelon.git
cd echelon
npm install

# Setup database
psql -h YOUR_SUPABASE_URL -f schema_sql.sql

# Configure environment
cp .env.example .env
# Edit .env with your credentials

# Deploy
npm run deploy:workers
```

### First Workflow

1. Access dashboard at `https://YOUR_WORKERS_URL`
2. Choose a template (e.g., "Candidate Communication Workflow")
3. Customize approval gates and AI prompts
4. Connect your data sources (ATS, CRM, email)
5. Test with sample data
6. Deploy to production

---

## Documentation

**Core Docs:**
- [Architecture Overview](integration_overview.md) - System design
- [Database Schema](database_schema.md) - Complete schema
- [API Reference](api_reference.md) - All endpoints

**Workflow Guides:**
- [Staffing Agency Use Cases](USE_CASES_STAFFING.md) - Detailed workflows
- [Dogfooding Case Studies](DOGFOODING.md) - How we use Echelon
- [Why Supervised Autonomy](WHY_SUPERVISED_AUTONOMY.md) - Technical deep dive

**Deployment:**
- [Deployment Guide](deployment_guide.md) - Production setup
- [Integration Guide](integration_overview.md) - Connect your tools

---

## Roadmap

### Phase 1: Foundation (Current)
- [x] Core database schema and API
- [x] Supabase/n8n/Cloudflare integration
- [x] Approval workflow nodes
- [x] Audit logging
- [ ] Visual workflow designer (in progress)

### Phase 2: Templates (Next 3 months)
- [ ] Staffing agency workflow library
- [ ] Insurance brokerage templates
- [ ] Financial services automation templates
- [ ] Template customization wizard

### Phase 3: Platform (6-12 months)
- [ ] Self-serve workflow deployment
- [ ] Workflow marketplace
- [ ] Advanced analytics
- [ ] Multi-tenant architecture

---

## Contributing

Contributions welcome from developers who understand that:
- AI works best WITH supervision, not instead of humans
- Generic platforms don't fit specific business needs
- The future is businesses building their own tools

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

## License

MIT License - see [LICENSE](LICENSE)

---

## Support

**Technical:** [GitHub Issues](https://github.com/sperry-entelech/echelon/issues)
**Business:** sperry@entelech.net

---

**Echelon** - _Build your workflows, don't buy generic SaaS_
