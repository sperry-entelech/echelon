# Echelon MicroSaaS - MVP Specification (Condensed)

**Goal**: Self-serve portal for clients to create, deploy, and manage custom AI agents.

**Stack**: Base44 (frontend), Supabase (backend/auth/db), Glyph (chatbot), n8n Cloud (workflows), LLM APIs (agent logic)

---

## 1. User Flow Overview

### Authentication & Dashboard
1. **Login** (`portal.echelon.com/login`) → Supabase Auth
2. **Dashboard** → View existing agents, create new agent, activity feed

### Agent Creation (Chatbot-Guided)
3. **Goal Definition** → User describes what agent should do
4. **Tool Selection** → Choose integrations (CRM, Slack, Email, Calendar, SMS, PM tools)
5. **OAuth Connections** → Authorize each selected tool
6. **Behavior Config** → Set communication style, approval level, active hours, error handling
7. **Review** → Confirm configuration
8. **Deploy** → Agent created, n8n workflow generated, goes live

### Post-Deployment
9. **Agent Dashboard** → View activity, performance metrics, manage agent
10. **Activity Logs** → Track what agent has done
11. **Settings** → Pause/edit/delete agent

---

## 2. Architecture

**Frontend Layer** (Base44)
- Portal UI (login, dashboard, onboarding, agent management)
- Glyph chatbot embedded in onboarding flow
- User interacts with chatbot to configure agent

**Data Layer** (Supabase)
- **Tables**: `users`, `agents`, `integration_connections`, `workflows`, `activity_logs`
- **Auth**: Email/password, OAuth integrations
- **Storage**: Agent configs (JSONB), credentials (encrypted)

**Automation Layer** (n8n Cloud)
- Workflow templates for common agent patterns
- LLM integration (Claude/OpenAI) for agent decision-making
- Integration handlers (CRM APIs, Slack, ConvertKit, Twilio, etc.)
- Trigger → Logic → Action flows

**External Integrations**
- CRM (Salesforce, HubSpot, Pipedrive)
- Communication (Slack, Twilio, email)
- Productivity (Google Calendar, Asana, Trello)

**Data Flow**:
```
User Input → Portal → Chatbot → Supabase → n8n Workflow → External APIs → Results → Dashboard
```

---

## 3. Chatbot Configuration Flow

### A. Welcome & Goal Setting
- Ask user's name
- Discover primary goal (e.g., "follow up with leads", "schedule meetings", "monitor tickets")
- Define success criteria (what does success look like?)

### B. Tool Selection
- Present tool checklist (CRM, Slack, Email, Calendar, SMS, PM)
- Launch OAuth for each selected tool
- Store credentials securely in Supabase

### C. Behavior Configuration
**Communication Style**: Friendly/professional/concise/detailed
**Approval Level**:
- Manual approval for all actions
- Approval for high-stakes actions only
- Notify but proceed automatically
- Full automation with weekly reports

**Active Hours**: Business hours / Extended / 24/7 with quiet hours / Full 24/7
**Error Handling**: Retry / Notify immediately / Pause for guidance / Log and continue

### D. Review & Deploy
- Show config summary
- Options: Deploy / Edit / Save as draft
- On deploy: Create n8n workflow, activate agent

---

## 4. Developer Handoff

### Required Setup
**Accounts**:
- Base44 (frontend hosting)
- Supabase (backend/db/auth)
- Glyph (chatbot)
- n8n Cloud (workflows)
- LLM API (Claude/OpenAI)
- OAuth apps for each integration (Slack, Google, Salesforce, etc.)

**Environment Variables**:
```
SUPABASE_URL=
SUPABASE_ANON_KEY=
GLYPH_API_KEY=
N8N_API_URL=
N8N_API_KEY=
CLAUDE_API_KEY=
OPENAI_API_KEY=

# OAuth credentials for each integration
SLACK_CLIENT_ID=
SLACK_CLIENT_SECRET=
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
# ... (etc for each tool)
```

### Database Schema (Supabase)

**users**
- id (uuid, PK)
- email (string, unique)
- created_at (timestamp)

**agents**
- id (uuid, PK)
- user_id (uuid, FK → users)
- name (string)
- goals (jsonb) - {primary_goal, success_criteria}
- tools (jsonb) - {selected_tools[], tool_credentials{}}
- preferences (jsonb) - {communication_style, approval_level, active_hours, error_handling}
- status (enum: draft, active, paused, deleted)
- n8n_workflow_id (string)
- created_at, updated_at (timestamp)

**integration_connections**
- id (uuid, PK)
- user_id (uuid, FK → users)
- agent_id (uuid, FK → agents, nullable)
- service_name (string) - e.g., "slack", "google_calendar"
- credentials (encrypted jsonb) - OAuth tokens
- status (enum: connected, disconnected, error)
- last_synced (timestamp)

**workflows**
- id (uuid, PK)
- agent_id (uuid, FK → agents)
- n8n_workflow_id (string)
- workflow_config (jsonb)
- executions_count (int)
- last_executed (timestamp)

**activity_logs**
- id (uuid, PK)
- agent_id (uuid, FK → agents)
- action (string) - "sent_email", "created_task", "updated_crm"
- details (jsonb)
- status (enum: success, failed, pending)
- created_at (timestamp)

### API Endpoints

**Base44 Portal Routes**:
- `POST /api/auth/login` → Supabase auth
- `GET /api/dashboard` → Fetch user's agents
- `POST /api/agent/create` → Initialize new agent (chatbot session)
- `PUT /api/agent/:id/update` → Update agent config
- `POST /api/agent/:id/deploy` → Trigger n8n workflow creation
- `GET /api/agent/:id/activity` → Fetch activity logs
- `PUT /api/agent/:id/pause` → Pause agent
- `DELETE /api/agent/:id` → Delete agent

**Supabase API Calls** (via Supabase client):
- CRUD operations on all tables
- Real-time subscriptions for activity logs
- Row-level security (users can only access their own data)

**n8n Cloud Integration**:
- `POST /workflows` → Create workflow from template
- `PUT /workflows/:id/activate` → Activate workflow
- `PUT /workflows/:id/deactivate` → Pause workflow
- `DELETE /workflows/:id` → Delete workflow
- `GET /executions/:workflow_id` → Get execution history

---

## 5. Development Phases

### Phase 1: Core Infrastructure (Week 1-2)
- Base44 portal setup (login, dashboard)
- Supabase database + auth
- Basic agent CRUD (without chatbot)

### Phase 2: Chatbot Integration (Week 3-4)
- Glyph chatbot embedded in onboarding
- Chatbot prompt configuration (goal, tools, behavior)
- OAuth flow for tool connections

### Phase 3: Workflow Automation (Week 5-8)
- n8n workflow templates (lead followup, scheduling, monitoring, reporting)
- LLM integration for agent logic
- External API handlers (CRM, Slack, ConvertKit, Twilio)
- Activity logging and dashboard

### Phase 4: Testing & Polish (Week 9-11)
- End-to-end testing (full agent creation and execution)
- Error handling and edge cases
- Performance optimization
- User acceptance testing

---

## 6. Success Metrics

**User Metrics**:
- Agent creation completion rate (target: 70%+)
- Time to first agent deployed (target: <10 min)
- Active agents per user (target: 1.5 avg)
- User retention (30-day: 60%+)

**Agent Performance**:
- Workflow execution success rate (target: 95%+)
- Average response time (target: <30 sec)
- Error rate (target: <5%)
- Integration uptime (target: 99%+)

**Business Metrics**:
- Monthly Active Users (MAU)
- Agent deployments per month
- Revenue per user (if monetized)
- Customer satisfaction (NPS)

---

## 7. Technical Considerations

### Security
- Encrypt all OAuth credentials in Supabase
- Row-level security policies on all tables
- API rate limiting
- Input validation and sanitization
- Audit logging for sensitive actions

### Performance
- Use Supabase edge functions for API routes (low latency)
- Cache frequently accessed data (user profile, agent configs)
- Optimize n8n workflows (minimize API calls, batch operations)
- Monitor execution times and set timeouts

### Scalability
- Supabase scales automatically (PostgreSQL with auto-scaling)
- n8n Cloud handles workflow concurrency
- Base44 CDN for static assets
- Queue background jobs for async processing

---

## 8. Migration Path to Emergence AI

Once MVP validated, migrate to Emergence AI (self-hosted agentic platform):
- **Why**: More control, advanced multi-agent orchestration, custom logic
- **When**: After 100+ users and proven product-market fit
- **How**: Replicate agent configs from Supabase → Emergence AI, migrate n8n workflows to Emergence orchestration engine

---

## Next Actions for Developers

**Immediate** (This Week):
1. Set up Base44 project and Supabase instance
2. Create database schema (run migrations)
3. Build login + dashboard skeleton
4. Test Supabase auth integration

**Week 2**:
1. Integrate Glyph chatbot into portal
2. Build onboarding flow (steps 3-7)
3. Implement OAuth handlers for 2-3 key integrations (Slack, Google Calendar)

**Week 3**:
1. Set up n8n Cloud account and API access
2. Create first workflow template (e.g., "lead followup")
3. Connect portal → n8n (create workflow on agent deploy)
4. Test end-to-end: create agent → deploy → execute workflow

---

**This condensed version removes ~60% of the original document while preserving all critical information for developers.**
