# Database Schema

## 🗄️ Database Design Overview

The Echelon AI Agents platform uses **Supabase (PostgreSQL)** as the primary database with real-time subscriptions enabled. The schema is designed for scalability, real-time updates, and multi-tenant support.

## 📋 Core Tables

### 1. User Management

#### `users` (extends Supabase auth.users)
```sql
CREATE TABLE public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  email VARCHAR(255) UNIQUE NOT NULL,
  full_name VARCHAR(255),
  avatar_url TEXT,
  subscription_tier VARCHAR(50) DEFAULT 'free',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### `user_roles`
```sql
CREATE TABLE user_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  role VARCHAR(50) NOT NULL, -- 'admin', 'agent_manager', 'viewer'
  team_id UUID REFERENCES teams(id),
  granted_by UUID REFERENCES users(id),
  granted_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### `teams` (for multi-tenant support)
```sql
CREATE TABLE teams (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  slug VARCHAR(100) UNIQUE NOT NULL,
  plan VARCHAR(50) DEFAULT 'starter',
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 2. Agent Management

#### `agents`
```sql
CREATE TABLE agents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  description TEXT,
  type VARCHAR(100) NOT NULL, -- 'market', 'websearch', 'media', 'alarm'
  status VARCHAR(50) DEFAULT 'inactive', -- 'active', 'paused', 'error', 'inactive'
  config JSONB NOT NULL DEFAULT '{}',
  deployment_config JSONB DEFAULT '{}',
  created_by UUID REFERENCES users(id) ON DELETE CASCADE,
  team_id UUID REFERENCES teams(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  last_activity TIMESTAMPTZ,
  
  -- Indexes for performance
  INDEX idx_agents_created_by (created_by),
  INDEX idx_agents_team_id (team_id),
  INDEX idx_agents_type (type),
  INDEX idx_agents_status (status)
);
```

#### `agent_templates`
```sql
CREATE TABLE agent_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  description TEXT,
  type VARCHAR(100) NOT NULL,
  default_config JSONB NOT NULL,
  is_public BOOLEAN DEFAULT false,
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 3. Workflow & Deployment Management

#### `deployments`
```sql
CREATE TABLE deployments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  agent_id UUID REFERENCES agents(id) ON DELETE CASCADE,
  version INTEGER NOT NULL DEFAULT 1,
  status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'deploying', 'deployed', 'failed', 'stopped'
  trigger_type VARCHAR(100), -- 'manual', 'config_change', 'scheduled'
  trigger_config JSONB DEFAULT '{}',
  deployment_url TEXT,
  error_message TEXT,
  deployed_at TIMESTAMPTZ,
  stopped_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  INDEX idx_deployments_agent_id (agent_id),
  INDEX idx_deployments_status (status)
);
```

#### `workflows`
```sql
CREATE TABLE workflows (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  agent_id UUID REFERENCES agents(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  n8n_workflow_id VARCHAR(255),
  trigger_config JSONB DEFAULT '{}',
  status VARCHAR(50) DEFAULT 'inactive', -- 'active', 'paused', 'error', 'inactive'
  last_execution TIMESTAMPTZ,
  next_execution TIMESTAMPTZ,
  execution_count INTEGER DEFAULT 0,
  success_count INTEGER DEFAULT 0,
  error_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### `workflow_executions`
```sql
CREATE TABLE workflow_executions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workflow_id UUID REFERENCES workflows(id) ON DELETE CASCADE,
  execution_id VARCHAR(255), -- n8n execution ID
  status VARCHAR(50), -- 'running', 'success', 'error', 'waiting'
  input_data JSONB,
  output_data JSONB,
  error_data JSONB,
  execution_time_ms INTEGER,
  started_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  
  INDEX idx_workflow_executions_workflow_id (workflow_id),
  INDEX idx_workflow_executions_status (status),
  INDEX idx_workflow_executions_started_at (started_at)
);
```

### 4. Real-time Communication

#### `notifications`
```sql
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  type VARCHAR(100) NOT NULL, -- 'agent_error', 'deployment_success', 'rate_limit_warning'
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  data JSONB DEFAULT '{}',
  priority VARCHAR(20) DEFAULT 'medium', -- 'low', 'medium', 'high', 'critical'
  read_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  INDEX idx_notifications_user_id (user_id),
  INDEX idx_notifications_created_at (created_at),
  INDEX idx_notifications_priority (priority)
);
```

#### `agent_thoughts` (for mind map visualization)
```sql
CREATE TABLE agent_thoughts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  agent_id UUID REFERENCES agents(id) ON DELETE CASCADE,
  execution_id UUID REFERENCES workflow_executions(id),
  node_id VARCHAR(100) NOT NULL,
  node_type VARCHAR(50) NOT NULL, -- 'input', 'processing', 'action', 'output'
  content TEXT NOT NULL,
  metadata JSONB DEFAULT '{}',
  parent_node_id VARCHAR(100),
  confidence_score DECIMAL(3,2),
  processing_time_ms INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  INDEX idx_agent_thoughts_agent_id (agent_id),
  INDEX idx_agent_thoughts_execution_id (execution_id),
  INDEX idx_agent_thoughts_created_at (created_at)
);
```

### 5. Analytics & Monitoring

#### `agent_metrics`
```sql
CREATE TABLE agent_metrics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  agent_id UUID REFERENCES agents(id) ON DELETE CASCADE,
  metric_type VARCHAR(100) NOT NULL, -- 'response_time', 'accuracy', 'cost', 'success_rate'
  value DECIMAL(10,4) NOT NULL,
  unit VARCHAR(50), -- 'ms', 'usd', 'percent', 'count'
  metadata JSONB DEFAULT '{}',
  recorded_at TIMESTAMPTZ DEFAULT NOW(),
  
  INDEX idx_agent_metrics_agent_id (agent_id),
  INDEX idx_agent_metrics_type (metric_type),
  INDEX idx_agent_metrics_recorded_at (recorded_at)
);
```

#### `api_usage`
```sql
CREATE TABLE api_usage (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  agent_id UUID REFERENCES agents(id) ON DELETE SET NULL,
  endpoint VARCHAR(255) NOT NULL,
  method VARCHAR(10) NOT NULL,
  status_code INTEGER NOT NULL,
  response_time_ms INTEGER,
  cost_usd DECIMAL(8,4),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  INDEX idx_api_usage_user_id (user_id),
  INDEX idx_api_usage_agent_id (agent_id),
  INDEX idx_api_usage_created_at (created_at)
);
```

## 🔒 Row Level Security (RLS) Policies

### Users can only access their own data
```sql
-- Enable RLS on all tables
ALTER TABLE agents ENABLE ROW LEVEL SECURITY;
ALTER TABLE deployments ENABLE ROW LEVEL SECURITY;
ALTER TABLE workflows ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Agents policy
CREATE POLICY "Users can manage their own agents"
ON agents FOR ALL
USING (auth.uid() = created_by);

-- Team access policy
CREATE POLICY "Team members can view team agents"
ON agents FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM user_roles 
    WHERE user_id = auth.uid() 
    AND team_id = agents.team_id
  )
);

-- Notifications policy
CREATE POLICY "Users can access their own notifications"
ON notifications FOR ALL
USING (auth.uid() = user_id);

-- Deployments policy
CREATE POLICY "Users can access deployments for their agents"
ON deployments FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM agents 
    WHERE agents.id = deployments.agent_id 
    AND agents.created_by = auth.uid()
  )
);
```

## 📊 Database Functions & Triggers

### Automatic timestamp updates
```sql
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply to relevant tables
CREATE TRIGGER update_agents_updated_at 
  BEFORE UPDATE ON agents 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_users_updated_at 
  BEFORE UPDATE ON users 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

### Agent status update notifications
```sql
CREATE OR REPLACE FUNCTION notify_agent_status_change()
RETURNS TRIGGER AS $$
BEGIN
  -- Create notification when agent status changes
  IF OLD.status IS DISTINCT FROM NEW.status THEN
    INSERT INTO notifications (user_id, type, title, message, data, priority)
    VALUES (
      NEW.created_by,
      'agent_status_change',
      'Agent Status Updated',
      'Agent "' || NEW.name || '" status changed from ' || OLD.status || ' to ' || NEW.status,
      jsonb_build_object('agent_id', NEW.id, 'old_status', OLD.status, 'new_status', NEW.status),
      CASE 
        WHEN NEW.status = 'error' THEN 'high'
        WHEN NEW.status = 'active' THEN 'medium'
        ELSE 'low'
      END
    );
  END IF;
  
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER agent_status_notification
  AFTER UPDATE ON agents
  FOR EACH ROW EXECUTE FUNCTION notify_agent_status_change();
```

## 🔄 Real-time Subscriptions Setup

### Frontend subscription patterns
```javascript
// Subscribe to agent changes
const agentSubscription = supabase
  .channel('agent-changes')
  .on('postgres_changes', {
    event: '*',
    schema: 'public',
    table: 'agents',
    filter: `created_by=eq.${userId}`
  }, handleAgentChange)
  .subscribe()

// Subscribe to notifications
const notificationSubscription = supabase
  .channel('user-notifications')
  .on('postgres_changes', {
    event: 'INSERT',
    schema: 'public',
    table: 'notifications',
    filter: `user_id=eq.${userId}`
  }, handleNewNotification)
  .subscribe()
```

## 📈 Performance Optimization

### Essential Indexes
```sql
-- Composite indexes for common queries
CREATE INDEX idx_agents_user_status ON agents(created_by, status);
CREATE INDEX idx_deployments_agent_status ON deployments(agent_id, status);
CREATE INDEX idx_workflow_executions_workflow_status ON workflow_executions(workflow_id, status);

-- Partial indexes for active records
CREATE INDEX idx_active_agents ON agents(created_by) WHERE status = 'active';
CREATE INDEX idx_unread_notifications ON notifications(user_id, created_at) WHERE read_at IS NULL;
```

### Query Optimization
```sql
-- Efficient agent dashboard query
SELECT 
  a.*,
  d.status as deployment_status,
  d.deployed_at,
  w.execution_count,
  w.success_count,
  w.error_count
FROM agents a
LEFT JOIN LATERAL (
  SELECT status, deployed_at 
  FROM deployments 
  WHERE agent_id = a.id 
  ORDER BY created_at DESC 
  LIMIT 1
) d ON true
LEFT JOIN LATERAL (
  SELECT execution_count, success_count, error_count
  FROM workflows 
  WHERE agent_id = a.id 
  ORDER BY created_at DESC 
  LIMIT 1
) w ON true
WHERE a.created_by = $1
ORDER BY a.updated_at DESC;
```

This schema provides a solid foundation for the AI agent platform with built-in scalability, security, and real-time capabilities.