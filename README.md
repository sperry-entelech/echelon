# Echelon

> **Supervised Autonomy Infrastructure for Enterprise AI**

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Documentation](https://img.shields.io/badge/docs-latest-brightgreen.svg)](docs/)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

---

## Overview

Echelon is an **intelligent workflow automation platform** that enables enterprises to build custom AI agent pipelines with built-in human oversight. Unlike generic AI SaaS tools that promise full autonomy, Echelon is architected around **supervised autonomy**—the proven pattern where AI handles high-volume tasks with human approval at critical decision points.

**Built for:** Mid-market to enterprise operations teams (50-5000 employees) who need their EXACT workflows automated, not generic 80% solutions.

---

## Why Echelon Exists

### The Problem with Generic AI SaaS

Most AI tools fail in enterprise because they're built for everyone, which means they fit nobody perfectly. Enterprise clients need:

- Their specific data sources integrated
- Their custom approval thresholds enforced
- Their unique output formats maintained
- Their existing tool ecosystems connected
- Their compliance requirements satisfied

**Generic platforms can't deliver this without extensive forward-deployed engineering.**

### Our Solution

Echelon provides:

1. **Visual workflow builder** - Design complex multi-step automation pipelines
2. **Industry-specific templates** - Pre-built workflows for common use cases (80% complete)
3. **Supervised autonomy by default** - Human approval nodes built into every critical decision
4. **Transparent reasoning chains** - Full audit trails showing why AI made each decision
5. **Forward-deployed engineering** - Implementation support to achieve 100% workflow fit

---

## Core Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                   Workflow Designer (Base44)                │
│         Visual workflow builder + Industry templates        │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│             Execution Engine (Cloudflare Workers)           │
│      Task routing + Approval management + Audit logging     │
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

**Key Design Principles:**
- **Supervised > Autonomous** - AI proposes, humans approve at critical points
- **Observable** - Every decision logged with reasoning for audit/compliance
- **Modular** - Swap AI models, data sources, approval logic without rebuilding
- **Reliable** - Graceful degradation when AI confidence is low

---

## Use Cases

### Logistics & Transportation
**Workflow:** Route optimization with driver communication
- AI analyzes traffic, weather, and load priorities
- Human dispatcher approves route changes affecting SLAs
- Automated driver notifications with ETA updates
- **ROI:** 15-25% reduction in dispatch labor, 10-15% fuel savings

### Professional Services
**Workflow:** Client intake and project scoping
- AI extracts requirements from RFPs and discovery calls
- Human partner approves scope and pricing
- Automated SOW generation and client communication
- **ROI:** 40-60% faster intake, 20-30% higher proposal volume

### Healthcare Operations
**Workflow:** Patient intake and insurance verification
- AI pre-fills forms from documents and conversation
- Human staff verifies insurance eligibility
- Automated appointment scheduling and reminders
- **ROI:** 30-50% faster intake, 90%+ pre-authorization accuracy

---

## Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Frontend** | Base44 | Visual workflow designer, dashboards |
| **API Gateway** | Cloudflare Workers | Edge routing, auth, rate limiting |
| **Database** | Supabase PostgreSQL | Workflow state, audit logs, user data |
| **Real-time** | Supabase Realtime | Live status updates, collaboration |
| **Orchestration** | n8n | Workflow execution, external integrations |
| **AI Models** | Claude, OpenAI | Task-specific reasoning and generation |
| **Notifications** | SendGrid, Twilio | Email, SMS alerts for approvals |

---

## Quick Start for Developers

### Prerequisites
- Node.js 18+
- PostgreSQL (or Supabase account)
- n8n Cloud or self-hosted instance
- Cloudflare Workers account

### 1. Clone and Install
```bash
git clone https://github.com/sperry-entelech/echelon.git
cd echelon
npm install
```

### 2. Database Setup
```bash
# Run schema migrations
psql -h YOUR_SUPABASE_URL -f database/schema_sql.sql

# Verify tables created
psql -h YOUR_SUPABASE_URL -c "\dt"
```

### 3. Environment Configuration
```bash
cp .env.example .env

# Required variables
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_SERVICE_KEY=eyJ...
N8N_WEBHOOK_URL=https://n8n.example.com/webhook
CLOUDFLARE_ACCOUNT_ID=xxx
OPENAI_API_KEY=sk-xxx
```

### 4. Deploy Cloudflare Workers
```bash
npm run deploy:workers
```

### 5. Access Dashboard
Navigate to `https://YOUR_WORKERS_URL` to access the workflow designer.

---

## Documentation

### For Developers
- **[Architecture Overview](ARCHITECTURE.md)** - System design and data flow
- **[Database Schema](database_schema.md)** - Complete schema with relationships
- **[API Reference](api_reference.md)** - All endpoints with examples
- **[Real-time Implementation](realtime_implementation.md)** - WebSocket subscriptions

### For Operators
- **[Deployment Guide](deployment_guide.md)** - Production infrastructure setup
- **[Workflow Templates](docs/workflow_templates.md)** - Industry-specific examples
- **[Best Practices](docs/best_practices.md)** - Supervised autonomy patterns

---

## Development Roadmap

### Q4 2025: Foundation
- [x] Core database schema
- [x] Authentication and authorization
- [x] Basic workflow designer (Base44)
- [x] n8n integration
- [ ] Approval workflow nodes
- [ ] Audit log visualization

### Q1 2026: Vertical Templates
- [ ] Logistics workflow templates
- [ ] Professional services templates
- [ ] Healthcare operations templates
- [ ] Template customization wizard
- [ ] ROI calculator per vertical

### Q2 2026: Enterprise Features
- [ ] Multi-tenant architecture
- [ ] Role-based approval routing
- [ ] Compliance reporting (SOC 2, HIPAA)
- [ ] Advanced analytics dashboard
- [ ] Slack/Teams integrations

### Q3-Q4 2026: Scale & Expansion
- [ ] Self-service workflow marketplace
- [ ] Partner ecosystem (consultants)
- [ ] Advanced AI model routing
- [ ] Global deployment (multi-region)

---

## Contributing

We welcome contributions from developers who understand the nuances of enterprise automation and AI limitations.

### Contribution Guidelines
1. **Read** `STRATEGIC_POSITIONING.md` to understand our philosophy
2. **Review** existing issues and PRs to avoid duplication
3. **Follow** our code standards (see `CONTRIBUTING.md`)
4. **Test** supervised autonomy flows (don't just test happy paths)
5. **Document** why AI decisions were made (observability first)

---

## Security & Compliance

### Data Handling
- All sensitive data encrypted at rest (AES-256)
- PII redacted from AI model requests
- Role-based access control (RBAC) for workflows
- Audit logs retained for 7 years

### Compliance Certifications (Planned)
- SOC 2 Type II (Q2 2026)
- HIPAA BAA available (Q3 2026)
- GDPR compliant (architecture designed for EU deployment)

### Responsible AI
- Transparent reasoning chains (no black boxes)
- Human approval required for high-stakes decisions
- Bias testing and monitoring
- Model performance benchmarks published quarterly

---

## Support

### For Technical Issues
- **GitHub Issues:** [Create new issue](https://github.com/sperry-entelech/echelon/issues/new)
- **Email:** support@entelech.net

### For Business Inquiries
- **Demos:** sperry@entelech.net
- **Partnerships:** partners@entelech.net

---

## License

MIT License - see [LICENSE](LICENSE) for details

---

**Echelon** - _Supervised Autonomy Infrastructure for Enterprise AI_
