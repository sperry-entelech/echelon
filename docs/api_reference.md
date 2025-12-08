# API Reference

## 🔗 Base URL & Authentication

**Base URL**: `https://api.echelon-agents.com/v1` (or your Cloudflare Workers domain)

**Authentication**: Bearer JWT tokens from Supabase Auth
```javascript
Authorization: Bearer <supabase_jwt_token>
Content-Type: application/json
```

## 📋 Core Endpoints

### 🔐 Authentication

#### `POST /auth/refresh`
Refresh expired JWT token using refresh token.

**Request:**
```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_in": 3600,
  "user": {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "email": "user@example.com",
    "role": "agent_manager"
  }
}
```

---

### 🤖 Agent Management

#### `GET /agents`
List all agents for the authenticated user.

**Query Parameters:**
- `status` (optional): Filter by status (`active`, `paused`, `error`, `inactive`)
- `type` (optional): Filter by type (`market`, `websearch`, `media`, `alarm`)
- `limit` (optional): Number of results (default: 50, max: 100)
- `offset` (optional): Pagination offset (default: 0)

**Response:**
```json
{
  "data": [
    {
      "id": "123e4567-e89b-12d3-a456-426614174000",
      "name": "BTC Price Monitor",
      "description": "Monitors Bitcoin price and sends alerts",
      "type": "market",
      "status": "active",
      "config": {
        "symbol": "BTC",
        "threshold_high": 50000,
        "threshold_low": 30000,
        "check_interval": 300
      },
      "created_at": "2025-07-13T10:00:00Z",
      "updated_at": "2025-07-13T12:30:00Z",
      "last_activity": "2025-07-13T12:28:00Z"
    }
  ],
  "meta": {
    "total": 25,
    "limit": 50,
    "offset": 0
  }
}
```

#### `POST /agents`
Create a new agent.

**Request:**
```json
{
  "name": "ETH DeFi Monitor",
  "description": "Monitors DeFi protocols for opportunities",
  "type": "market",
  "config": {
    "protocols": ["uniswap", "compound", "aave"],
    "min_apy": 5.0,
    "alert_threshold": 10.0
  }
}
```

**Response:**
```json
{
  "data": {
    "id": "456e7890-e89b-12d3-a456-426614174001",
    "name": "ETH DeFi Monitor",
    "description": "Monitors DeFi protocols for opportunities",
    "type": "market",
    "status": "inactive",
    "config": {
      "protocols": ["uniswap", "compound", "aave"],
      "min_apy": 5.0,
      "alert_threshold": 10.0
    },
    "created_at": "2025-07-13T13:00:00Z",
    "updated_at": "2025-07-13T13:00:00Z"
  }
}
```

#### `GET /agents/{id}`
Get specific agent details.

**Response:**
```json
{
  "data": {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "name": "BTC Price Monitor",
    "type": "market",
    "status": "active",
    "config": { ... },
    "deployment": {
      "status": "deployed",
      "deployed_at": "2025-07-13T10:30:00Z",
      "version": 3,
      "url": "https://worker.echelon.dev/agent-123e4567"
    },
    "metrics": {
      "uptime_percent": 99.2,
      "total_executions": 1440,
      "success_rate": 98.5,
      "avg_response_time_ms": 250
    }
  }
}
```

#### `PUT /agents/{id}`
Update agent configuration.

**Request:**
```json
{
  "name": "BTC Price Monitor Pro",
  "config": {
    "symbol": "BTC",
    "threshold_high": 55000,
    "threshold_low": 28000,
    "check_interval": 180
  }
}
```

#### `DELETE /agents/{id}`
Delete an agent and all associated data.

**Response:**
```json
{
  "message": "Agent deleted successfully",
  "data": {
    "deleted_at": "2025-07-13T14:00:00Z"
  }
}
```

#### `POST /agents/{id}/deploy`
Deploy or redeploy an agent.

**Request:**
```json
{
  "deployment_config": {
    "region": "us-east-1",
    "memory": "512MB",
    "timeout": 300,
    "environment": "production"
  }
}
```

**Response:**
```json
{
  "data": {
    "deployment_id": "789e0123-e89b-12d3-a456-426614174002",
    "status": "deploying",
    "estimated_completion": "2025-07-13T14:05:00Z"
  }
}
```

#### `POST /agents/{id}/pause`
Pause agent execution.

#### `POST /agents/{id}/resume`
Resume paused agent execution.

---

### 🔄 Workflow Management

#### `GET /workflows`
List workflows for user's agents.

**Response:**
```json
{
  "data": [
    {
      "id": "workflow-123",
      "agent_id": "123e4567-e89b-12d3-a456-426614174000",
      "name": "Price Alert Workflow",
      "status": "active",
      "trigger_config": {
        "type": "interval",
        "interval": "5m"
      },
      "last_execution": "2025-07-13T13:45:00Z",
      "next_execution": "2025-07-13T13:50:00Z",
      "success_rate": 99.1
    }
  ]
}
```

#### `POST /workflows`
Create a new workflow.

#### `GET /workflows/{id}/executions`
Get execution history for a workflow.

**Query Parameters:**
- `limit` (optional): Number of results (default: 20, max: 100)
- `status` (optional): Filter by execution status

**Response:**
```json
{
  "data": [
    {
      "id": "exec-456",
      "status": "success",
      "input_data": { "symbol": "BTC" },
      "output_data": { "price": 42500, "change": "+2.5%" },
      "execution_time_ms": 1250,
      "started_at": "2025-07-13T13:45:00Z",
      "completed_at": "2025-07-13T13:45:01Z"
    }
  ]
}
```

#### `POST /workflows/{id}/trigger`
Manually trigger a workflow execution.

---

### 📊 Analytics & Metrics

#### `GET /analytics/agents/{id}/performance`
Get performance metrics for a specific agent.

**Query Parameters:**
- `period`: Time period (`1h`, `24h`, `7d`, `30d`)
- `metrics`: Comma-separated list of metrics (`response_time`, `success_rate`, `cost`)

**Response:**
```json
{
  "data": {
    "period": "24h",
    "metrics": {
      "response_time": {
        "avg": 245,
        "min": 120,
        "max": 850,
        "p95": 450,
        "unit": "ms"
      },
      "success_rate": {
        "value": 98.5,
        "unit": "percent"
      },
      "cost": {
        "total": 2.45,
        "avg_per_execution": 0.0017,
        "unit": "usd"
      }
    },
    "timeline": [
      {
        "timestamp": "2025-07-13T00:00:00Z",
        "response_time": 230,
        "success_rate": 100,
        "cost": 0.12
      }
    ]
  }
}
```

#### `GET /analytics/costs/breakdown`
Get cost breakdown by agent, time period, and service.

**Response:**
```json
{
  "data": {
    "total_cost": 15.67,
    "period": "30d",
    "breakdown": {
      "by_agent": [
        {
          "agent_id": "123e4567-e89b-12d3-a456-426614174000",
          "agent_name": "BTC Price Monitor",
          "cost": 8.45,
          "percentage": 53.9
        }
      ],
      "by_service": {
        "api_calls": 12.30,
        "compute": 2.15,
        "storage": 0.89,
        "data_transfer": 0.33
      }
    }
  }
}
```

---

### 🧠 Mind Map & Thought Process

#### `GET /agents/{id}/thoughts`
Get AI reasoning/thought process for an agent.

**Query Parameters:**
- `execution_id` (optional): Specific workflow execution
- `limit` (optional): Number of thought nodes (default: 50)

**Response:**
```json
{
  "data": {
    "execution_id": "exec-789",
    "agent_id": "123e4567-e89b-12d3-a456-426614174000",
    "thought_process": {
      "nodes": [
        {
          "id": "query_analysis",
          "type": "input",
          "content": "User requested BTC price analysis",
          "confidence": 0.95,
          "timestamp": "2025-07-13T13:45:00.123Z",
          "processing_time_ms": 45
        },
        {
          "id": "data_fetch",
          "type": "action",
          "content": "Fetching price data from CoinGecko API",
          "parent_node_id": "query_analysis",
          "confidence": 0.88,
          "timestamp": "2025-07-13T13:45:00.168Z",
          "processing_time_ms": 1200
        },
        {
          "id": "analysis_complete",
          "type": "output",
          "content": "Price analysis completed: $42,500 (+2.5%)",
          "parent_node_id": "data_fetch",
          "confidence": 0.92,
          "timestamp": "2025-07-13T13:45:01.368Z",
          "processing_time_ms": 25
        }
      ],
      "edges": [
        {
          "from": "query_analysis",
          "to": "data_fetch",
          "weight": 0.85
        },
        {
          "from": "data_fetch",
          "to": "analysis_complete",
          "weight": 0.90
        }
      ]
    }
  }
}
```

---

### 🔔 Notifications

#### `GET /notifications`
Get user notifications.

**Query Parameters:**
- `unread_only` (optional): Only unread notifications (default: false)
- `priority` (optional): Filter by priority (`low`, `medium`, `high`, `critical`)
- `limit` (optional): Number of results (default: 20, max: 100)

**Response:**
```json
{
  "data": [
    {
      "id": "notif-123",
      "type": "agent_error",
      "title": "Agent Deployment Failed",
      "message": "BTC Price Monitor failed to deploy due to configuration error",
      "priority": "high",
      "data": {
        "agent_id": "123e4567-e89b-12d3-a456-426614174000",
        "error_code": "CONFIG_VALIDATION_ERROR"
      },
      "read_at": null,
      "created_at": "2025-07-13T14:30:00Z"
    }
  ]
}
```

#### `PUT /notifications/{id}/read`
Mark notification as read.

#### `POST /notifications/mark-all-read`
Mark all notifications as read.

---

### 🌐 External API Proxy

#### `GET /external/health`
Check status of external services.

**Response:**
```json
{
  "data": {
    "services": {
      "coingecko": {
        "status": "operational",
        "response_time_ms": 145,
        "rate_limit": {
          "remaining": 850,
          "reset_at": "2025-07-13T15:00:00Z"
        }
      },
      "twitter_api": {
        "status": "degraded",
        "response_time_ms": 2500,
        "rate_limit": {
          "remaining": 23,
          "reset_at": "2025-07-13T14:45:00Z"
        }
      }
    },
    "overall_status": "degraded"
  }
}
```

#### `POST /external/proxy`
Proxy request to external API with rate limiting and caching.

**Request:**
```json
{
  "service": "coingecko",
  "endpoint": "/simple/price",
  "params": {
    "ids": "bitcoin",
    "vs_currencies": "usd"
  },
  "agent_id": "123e4567-e89b-12d3-a456-426614174000"
}
```

---

## 🚨 Error Responses

All endpoints return consistent error format:

```json
{
  "error": {
    "code": "AGENT_NOT_FOUND",
    "message": "Agent with ID 123e4567-e89b-12d3-a456-426614174000 not found",
    "details": {
      "agent_id": "123e4567-e89b-12d3-a456-426614174000",
      "user_id": "user-456"
    },
    "timestamp": "2025-07-13T14:30:00Z",
    "request_id": "req_abc123"
  }
}
```

### Common Error Codes

| Code | HTTP Status | Description |
|------|-------------|-------------|
| `UNAUTHORIZED` | 401 | Invalid or expired JWT token |
| `FORBIDDEN` | 403 | User lacks permission for resource |
| `AGENT_NOT_FOUND` | 404 | Agent doesn't exist or not accessible |
| `VALIDATION_ERROR` | 400 | Request data validation failed |
| `RATE_LIMITED` | 429 | Too many requests |
| `DEPLOYMENT_FAILED` | 422 | Agent deployment failed |
| `EXTERNAL_SERVICE_ERROR` | 502 | External API unavailable |
| `INTERNAL_ERROR` | 500 | Unexpected server error |

---

## 📊 Rate Limits

| Endpoint Category | Limit | Window |
|------------------|-------|---------|
| Authentication | 10 requests | 1 minute |
| Agent Management | 100 requests | 1 minute |
| Analytics | 200 requests | 1 minute |
| Workflow Triggers | 50 requests | 1 minute |
| External Proxy | 1000 requests | 1 hour |

Rate limit headers included in all responses:
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 85
X-RateLimit-Reset: 1642694400
```

---

## 🔧 SDK & Code Examples

### JavaScript/TypeScript SDK
```bash
npm install @echelon-agents/sdk
```

```javascript
import { EchelonClient } from '@echelon-agents/sdk'

const client = new EchelonClient({
  apiKey: 'your-supabase-jwt-token',
  baseURL: 'https://api.echelon-agents.com/v1'
})

// Create agent
const agent = await client.agents.create({
  name: 'My Trading Bot',
  type: 'market',
  config: { symbol: 'ETH', threshold: 3000 }
})

// Deploy agent
await client.agents.deploy(agent.id)

// Listen for real-time updates
client.realtime.subscribe('agent-updates', (update) => {
  console.log('Agent updated:', update)
})
```

This API reference provides comprehensive documentation for integrating with the Echelon AI Agents platform.