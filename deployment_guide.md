# Deployment Guide

## 🚀 Infrastructure Setup

This guide covers deploying the Echelon AI Agents platform using **Cloudflare + Supabase + n8n** architecture.

## 📋 Prerequisites

- **Cloudflare Account** (free tier works)
- **Supabase Account** (free tier works for development)
- **n8n Account** (cloud or self-hosted)
- **Base44 Account** (for frontend hosting)
- **Domain name** (optional, for custom URLs)

## 🔧 Environment Setup

### 1. Supabase Project Setup

```bash
# Create new Supabase project
1. Go to https://supabase.com/dashboard
2. Click "New Project"
3. Choose organization and region
4. Set database password (save securely)
5. Wait for project creation (~2 minutes)
```

**Required Environment Variables:**
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### 2. Database Schema Deployment

```sql
-- Run in Supabase SQL Editor
-- Copy content from sql/schema.sql

-- Enable realtime for required tables
ALTER PUBLICATION supabase_realtime ADD TABLE agents;
ALTER PUBLICATION supabase_realtime ADD TABLE notifications;
ALTER PUBLICATION supabase_realtime ADD TABLE workflow_executions;
ALTER PUBLICATION supabase_realtime ADD TABLE agent_thoughts;
```

### 3. Cloudflare Workers Setup

```bash
# Install Wrangler CLI
npm install -g wrangler

# Login to Cloudflare
wrangler login

# Create new worker
wrangler generate echelon-api
cd echelon-api
```

**wrangler.toml:**
```toml
name = "echelon-api"
main = "src/index.js"
compatibility_date = "2025-07-13"

[env.production]
name = "echelon-api-prod"

[[env.production.kv_namespaces]]
binding = "CACHE"
id = "your-kv-namespace-id"

[env.production.vars]
SUPABASE_URL = "https://your-project.supabase.co"
SUPABASE_ANON_KEY = "your-anon-key"
```

### 4. n8n Workflow Engine

**Option A: n8n Cloud (Recommended)**
```bash
1. Go to https://n8n.cloud
2. Create account and workspace
3. Note your webhook URL: https://your-instance.app.n8n.cloud/webhook/
```

**Option B: Self-hosted n8n**
```bash
# Docker deployment
docker run -it --rm \
  --name n8n \
  -p 5678:5678 \
  -e WEBHOOK_URL=https://your-domain.com/ \
  -v ~/.n8n:/home/node/.n8n \
  n8nio/n8n
```

## 🏗️ Deployment Steps

### Phase 1: Core Infrastructure (Week 1)

#### Day 1-2: Database Setup
```bash
# 1. Create Supabase project
# 2. Run schema.sql in SQL Editor
# 3. Enable RLS policies
# 4. Configure authentication providers
# 5. Test basic CRUD operations
```

#### Day 3-4: API Gateway
```bash
# 1. Deploy Cloudflare Worker
wrangler publish

# 2. Set up KV namespace for caching
wrangler kv:namespace create "CACHE"

# 3. Configure environment variables
wrangler secret put SUPABASE_SERVICE_ROLE_KEY

# 4. Test API endpoints
curl https://echelon-api.your-domain.workers.dev/agents
```

#### Day 5-7: Base44 Frontend
```bash
# 1. Create Base44 app
# 2. Configure Supabase integration
# 3. Set up authentication flow
# 4. Build basic agent management UI
# 5. Test real-time subscriptions
```

### Phase 2: Workflow Automation (Week 2)

#### Day 1-3: n8n Integration
```bash
# 1. Set up n8n instance
# 2. Create webhook endpoints
# 3. Build agent deployment workflows
# 4. Configure error handling
# 5. Test workflow triggers
```

#### Day 4-7: Real-time Features
```bash
# 1. Implement Supabase Realtime
# 2. Add notification system
# 3. Build status monitoring
# 4. Test concurrent users
# 5. Performance optimization
```

### Phase 3: Advanced Features (Week 3-4)

#### Analytics & Monitoring
```bash
# 1. Set up monitoring dashboards
# 2. Implement cost tracking
# 3. Add performance metrics
# 4. Configure alerts
# 5. Load testing
```

## 🔒 Security Configuration

### Supabase Security
```sql
-- Enable RLS on all tables
ALTER TABLE agents ENABLE ROW LEVEL SECURITY;
ALTER TABLE deployments ENABLE ROW LEVEL SECURITY;
ALTER TABLE workflows ENABLE ROW LEVEL SECURITY;

-- Create security policies (see database-schema.md)
```

### Cloudflare Security
```javascript
// Add to worker for API security
const corsHeaders = {
  'Access-Control-Allow-Origin': 'https://your-base44-app.com',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
}

// Rate limiting
const rateLimiter = new Map()
const isRateLimited = (ip) => {
  const now = Date.now()
  const requests = rateLimiter.get(ip) || []
  const recentRequests = requests.filter(time => now - time < 60000)
  
  if (recentRequests.length >= 100) return true
  
  recentRequests.push(now)
  rateLimiter.set(ip, recentRequests)
  return false
}
```

## 📊 Monitoring & Analytics

### Cloudflare Analytics
```bash
# View worker analytics
wrangler tail

# Custom metrics
await env.ANALYTICS.writeDataPoint({
  blobs: [request.url, userAgent],
  doubles: [responseTime],
  indexes: [userId]
})
```

### Supabase Monitoring
```javascript
// Custom analytics in Supabase
const { data, error } = await supabase
  .from('analytics_events')
  .insert({
    event_type: 'agent_deployed',
    user_id: userId,
    metadata: { agent_id, deployment_time }
  })
```

## 🚀 Production Deployment Checklist

### Pre-deployment
- [ ] Database schema deployed and tested
- [ ] All environment variables configured
- [ ] Security policies enabled (RLS, CORS, rate limiting)
- [ ] API endpoints tested
- [ ] Real-time subscriptions working
- [ ] n8n workflows functional
- [ ] Error handling implemented

### Deployment
- [ ] Deploy Cloudflare Workers to production
- [ ] Update Base44 app with production API URLs
- [ ] Configure custom domain (optional)
- [ ] Set up monitoring and alerts
- [ ] Run load tests
- [ ] Verify all integrations working

### Post-deployment
- [ ] Monitor error rates and performance
- [ ] Set up backup schedules
- [ ] Document operational procedures
- [ ] Train team on monitoring tools
- [ ] Plan scaling strategy

## 🔧 Configuration Files

### `.env.production`
```env
# Supabase
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=eyJ...
SUPABASE_SERVICE_ROLE_KEY=eyJ...

# n8n
N8N_WEBHOOK_URL=https://your-instance.app.n8n.cloud/webhook/
N8N_API_KEY=your-n8n-api-key

# Cloudflare
CLOUDFLARE_API_TOKEN=your-api-token
CLOUDFLARE_ZONE_ID=your-zone-id

# External APIs
COINGECKO_API_KEY=your-api-key
TWITTER_BEARER_TOKEN=your-bearer-token
```

### `cloudflare-worker.js` (Basic Structure)
```javascript
export default {
  async fetch(request, env) {
    const url = new URL(request.url)
    
    // CORS headers
    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: corsHeaders })
    }
    
    // Rate limiting
    const clientIP = request.headers.get('CF-Connecting-IP')
    if (isRateLimited(clientIP)) {
      return new Response('Rate limited', { status: 429 })
    }
    
    // Route handlers
    if (url.pathname.startsWith('/agents')) {
      return handleAgents(request, env)
    }
    
    if (url.pathname.startsWith('/workflows')) {
      return handleWorkflows(request, env)
    }
    
    return new Response('Not found', { status: 404 })
  }
}
```

## 🔄 CI/CD Pipeline

### GitHub Actions (Optional)
```yaml
# .github/workflows/deploy.yml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          
      - name: Install dependencies
        run: npm install
        
      - name: Deploy to Cloudflare
        run: |
          npm install -g wrangler
          wrangler publish
        env:
          CLOUDFLARE_API_TOKEN: ${{ secrets.CLOUDFLARE_API_TOKEN }}
```

## 📈 Scaling Considerations

### Database Scaling
- **Free tier**: 500MB storage, 2GB bandwidth
- **Pro tier**: 8GB storage, 50GB bandwidth
- **Pay-as-you-go**: Unlimited with usage-based pricing

### Cloudflare Workers Scaling
- **Free tier**: 100,000 requests/day
- **Paid tier**: 10 million requests/month
- **Enterprise**: Unlimited with custom pricing

### Cost Optimization
```javascript
// Implement smart caching
const cache = await caches.open('api-cache')
const cachedResponse = await cache.match(request)

if (cachedResponse) {
  return cachedResponse
}

// Only cache successful responses
if (response.status === 200) {
  response.headers.set('Cache-Control', 'max-age=300')
  await cache.put(request, response.clone())
}
```

This deployment guide provides a complete roadmap for launching your AI agent platform in production.