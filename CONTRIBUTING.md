# Echelon AI Agents - Developer Integration Specifications

## Platform Overview
**Base Platform**: Base44 (AI-powered no-code platform)  
**App Type**: AI Agent Management & Deployment System  
**Architecture**: Multi-agent platform with real-time insights and workflow automation

## Core Integration Points

### 1. Authentication & User Management
**Integration Point**: Supabase Auth + Base44 Built-in Auth
```javascript
// Primary auth flow
- Base44 native OAuth/email auth (primary)
- Supabase Auth (secondary/API access)
- Role-based permissions: Admin, Agent Manager, Viewer
```

**Backend Specs**:
- **Supabase Tables**: `users`, `user_roles`, `auth_sessions`
- **API Endpoints**: `/auth/login`, `/auth/refresh`, `/auth/logout`
- **UI Components**: Login modal, user profile dropdown, role management panel

---

### 2. Agent Configuration & Deployment
**Integration Point**: n8n Workflows + Custom API + Supabase

**Database Schema** (Supabase):
```sql
-- Agent configurations
CREATE TABLE agents (
  id UUID PRIMARY KEY,
  name VARCHAR(255),
  type VARCHAR(100), -- 'market', 'websearch', 'media', 'alarm'
  config JSONB,
  status VARCHAR(50), -- 'active', 'paused', 'error'
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ
);

-- Deployment triggers
CREATE TABLE deployments (
  id UUID PRIMARY KEY,
  agent_id UUID REFERENCES agents(id),
  trigger_type VARCHAR(100),
  trigger_config JSONB,
  status VARCHAR(50),
  deployed_at TIMESTAMPTZ
);
```

**n8n Workflow Triggers**:
- Agent creation → Deploy to execution environment
- Configuration changes → Update running instances
- Status monitoring → Health checks every 5 minutes

**UI Components**:
- Agent creation wizard (multi-step form)
- Configuration editor (JSON/visual toggle)
- Deployment status dashboard
- Real-time logs viewer

---

### 3. Real-time Workflow Status
**Integration Point**: Supabase Realtime + Polling + n8n Webhooks

**Real-time Data Flow**:
```javascript
// Supabase Realtime subscription
const subscription = supabase
  .channel('agent-updates')
  .on('postgres_changes', {
    event: '*',
    schema: 'public',
    table: 'agents'
  }, (payload) => {
    updateAgentStatus(payload.new)
  })
  .on('postgres_changes', {
    event: '*', 
    schema: 'public',
    table: 'workflows'
  }, (payload) => {
    updateWorkflowProgress(payload.new)
  })
  .subscribe()

// Polling for external API status (every 30 seconds)
setInterval(async () => {
  const externalStatus = await fetch('/api/external/health')
  updateExternalServiceStatus(await externalStatus.json())
}, 30000)
```

**Backend APIs**:
- `GET /api/agents/{id}/status` - Current agent status
- `POST /api/agents/{id}/pause` - Pause agent execution
- `GET /api/workflows/active` - List running workflows
- `GET /api/external/health` - External service status (polled)

**UI Components**:
- Live status indicators (colored dots)
- Progress bars for long-running tasks
- Activity timeline
- Performance metrics dashboard

---

### 4. Data Sources & External APIs
**Integration Point**: Base44 API Connector + Custom Proxy Layer

**Supported Integrations**:
```yaml
Web3/Blockchain:
  - Ethereum/BSC RPC endpoints
  - DeFiPulse API
  - CoinGecko API
  - Moralis Web3 API

Traditional Data:
  - Google Search API
  - Twitter API v2
  - News APIs (NewsAPI, GDELT)
  - Financial APIs (Alpha Vantage, Yahoo Finance)
```

**Proxy Layer** (Cloudflare Workers):
```javascript
// Rate limiting, caching, API key management
const handleAPIRequest = async (request) => {
  const { endpoint, params, agent_id } = request;
  
  // Rate limiting by agent
  if (await isRateLimited(agent_id)) {
    return new Response('Rate limited', { status: 429 });
  }
  
  // Cache for 5 minutes for market data
  const cached = await getCache(endpoint, params);
  if (cached) return cached;
  
  // Proxy to actual API
  const response = await fetchFromAPI(endpoint, params);
  await setCache(endpoint, params, response, 300);
  
  return response;
};
```

**UI Components**:
- API configuration panel
- Data source connection status
- Rate limit monitoring
- Cache performance metrics

---

### 5. Mind Map Visualization
**Integration Point**: D3.js + Supabase Realtime + Polling

**Data Structure**:
```javascript
{
  "thought_process": {
    "nodes": [
      {
        "id": "query_analysis",
        "type": "input",
        "data": "User asked about BTC price",
        "timestamp": "2025-07-13T10:30:00Z",
        "confidence": 0.95
      },
      {
        "id": "market_search",
        "type": "action", 
        "data": "Fetching CoinGecko API",
        "parent": "query_analysis",
        "status": "completed"
      }
    ],
    "edges": [
      { "from": "query_analysis", "to": "market_search", "weight": 0.8 }
    ]
  }
}
```

**Backend Implementation**:
- Real-time updates via Supabase Realtime when thoughts are saved to DB
- Store thought process in `agent_thoughts` table
- Poll external AI services every 15 seconds for live reasoning updates
- Generate visualization data on agent decision points

**Supabase Realtime Subscription**:
```javascript
supabase
  .channel('mind-map-updates')
  .on('postgres_changes', {
    event: 'INSERT',
    schema: 'public',
    table: 'agent_thoughts'
  }, (payload) => {
    addNodeToMindMap(payload.new)
  })
  .subscribe()
```

**UI Components**:
- Interactive D3.js mind map
- Zoom/pan controls
- Node detail popover
- Thought process timeline

---

### 6. Notification & Alert System
**Integration Point**: n8n + Base44 Email + Supabase Realtime + Push Notifications

**Alert Types**:
```javascript
const alertTypes = {
  AGENT_ERROR: { priority: 'high', notify: ['email', 'realtime', 'push'] },
  DEPLOYMENT_SUCCESS: { priority: 'medium', notify: ['realtime'] },
  RATE_LIMIT_WARNING: { priority: 'medium', notify: ['realtime', 'email'] },
  INSIGHT_GENERATED: { priority: 'low', notify: ['realtime'] }
};
```

**Real-time Notifications**:
```javascript
// Listen for new notifications in database
supabase
  .channel('notifications')
  .on('postgres_changes', {
    event: 'INSERT',
    schema: 'public',
    table: 'notifications',
    filter: `user_id=eq.${userId}`
  }, (payload) => {
    showInAppNotification(payload.new)
  })
  .subscribe()
```

**n8n Alert Workflow**:
1. Trigger: Agent status change/error
2. Filter: Check alert preferences
3. Format: Generate notification content
4. Insert: Add to notifications table (triggers Supabase Realtime)
5. Send: Email + push notification for high-priority alerts
6. Log: Audit trail in notifications table

---

### 7. Analytics & Performance Monitoring
**Integration Point**: Supabase + Custom Analytics API

**Metrics Collection**:
```sql
CREATE TABLE agent_metrics (
  id UUID PRIMARY KEY,
  agent_id UUID REFERENCES agents(id),
  metric_type VARCHAR(100), -- 'response_time', 'accuracy', 'cost'
  value DECIMAL,
  metadata JSONB,
  recorded_at TIMESTAMPTZ
);

CREATE TABLE workflow_analytics (
  id UUID PRIMARY KEY,
  workflow_id UUID,
  total_steps INTEGER,
  completed_steps INTEGER,
  execution_time_ms INTEGER,
  cost_usd DECIMAL,
  recorded_at TIMESTAMPTZ
);
```

**Dashboard Endpoints**:
- `GET /api/analytics/agents/{id}/performance` - Agent KPIs
- `GET /api/analytics/workflows/summary` - Workflow statistics
- `GET /api/analytics/costs/breakdown` - Cost analysis

---

## Deployment Architecture

### Platform Choice: **Cloudflare** (Recommended)
**Rationale**: 
- Edge deployment for global low latency
- Built-in DDoS protection
- Serverless functions for API proxy
- KV storage for caching
- WebSocket support via Durable Objects

### Alternative: **Railway/Vercel**
- Simpler deployment
- Built-in CI/CD
- Database hosting included

### Infrastructure Components:
```yaml
Frontend: Base44 hosted app
API Gateway: Cloudflare Workers
Database: Supabase (PostgreSQL + Realtime subscriptions)
Workflow Engine: n8n (self-hosted or cloud)
Caching: Cloudflare KV
Real-time Updates: Supabase Realtime + Strategic Polling
File Storage: Supabase Storage
Push Notifications: Web Push API + Service Workers
Monitoring: Built-in Supabase Analytics + Custom dashboards
```

---

## Implementation Priorities

### Phase 1: Core Foundation (2-3 weeks)
1. ✅ Supabase project setup + database schema
2. ✅ Base44 app with basic auth integration
3. ✅ Agent CRUD operations
4. ✅ Simple deployment triggers via n8n

### Phase 2: Real-time Features (2-3 weeks)
1. ✅ WebSocket integration for live updates
2. ✅ Status monitoring dashboard
3. ✅ Basic mind map visualization
4. ✅ Alert system implementation

### Phase 3: Advanced Features (3-4 weeks)
1. ✅ Multi-agent workflows
2. ✅ Advanced analytics dashboard
3. ✅ Cost optimization features
4. ✅ Performance monitoring

### Phase 4: Scale & Polish (2 weeks)
1. ✅ Load testing & optimization
2. ✅ UI/UX refinements
3. ✅ Documentation
4. ✅ Production deployment

---

## API Specifications

### Authentication Headers
```javascript
{
  "Authorization": "Bearer <supabase_jwt>",
  "X-Agent-ID": "<agent_uuid>", // For agent-specific operations
  "Content-Type": "application/json"
}
```

### Core Endpoints
```javascript
// Agent Management
POST   /api/agents           - Create new agent
GET    /api/agents           - List user's agents  
GET    /api/agents/{id}      - Get agent details
PUT    /api/agents/{id}      - Update agent config
DELETE /api/agents/{id}      - Delete agent
POST   /api/agents/{id}/deploy - Deploy agent

// Workflow Control
POST   /api/workflows        - Start new workflow
GET    /api/workflows/{id}   - Get workflow status
POST   /api/workflows/{id}/pause - Pause workflow
POST   /api/workflows/{id}/resume - Resume workflow

// Real-time Data (Polling endpoints)
GET    /api/agents/{id}/live-status    - Current runtime status
GET    /api/workflows/{id}/progress    - Detailed progress info
GET    /api/external/health            - External service status

// Supabase Realtime handles:
// - Database changes (agents, workflows, notifications)
// - User presence
// - Collaborative features
```

### Error Handling
```javascript
{
  "error": {
    "code": "AGENT_DEPLOYMENT_FAILED",
    "message": "Failed to deploy agent to execution environment",
    "details": {
      "agent_id": "uuid",
      "reason": "Insufficient resources",
      "retry_after": 300
    },
    "timestamp": "2025-07-13T10:30:00Z"
  }
}
```

---

## Security Considerations

### API Security
- JWT-based authentication via Supabase
- Row-level security (RLS) on all tables
- Rate limiting: 100 requests/minute per user
- Input validation on all endpoints
- CORS configuration for Base44 domain only

### Data Protection
- Encrypt sensitive agent configurations
- Audit logs for all agent deployments
- Regular security scans of dependencies
- Secure API key storage in Cloudflare Workers

### Access Control
```sql
-- Row Level Security Examples
ALTER TABLE agents ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only see their own agents"
ON agents FOR ALL
USING (auth.uid() = created_by);

CREATE POLICY "Agents are viewable by team members"
ON agents FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM team_members 
    WHERE team_id = agents.team_id 
    AND user_id = auth.uid()
  )
);
```

This specification provides actionable backend requirements for immediate development handoff. The modular approach allows for incremental implementation while maintaining system coherence.
