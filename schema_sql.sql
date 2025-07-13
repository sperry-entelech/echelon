-- Echelon AI Agents Database Schema
-- PostgreSQL + Supabase
-- Run this in Supabase SQL Editor

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Custom types
CREATE TYPE agent_status AS ENUM ('active', 'paused', 'error', 'inactive');
CREATE TYPE deployment_status AS ENUM ('pending', 'deploying', 'deployed', 'failed', 'stopped');
CREATE TYPE workflow_status AS ENUM ('active', 'paused', 'error', 'inactive');
CREATE TYPE execution_status AS ENUM ('running', 'success', 'error', 'waiting');
CREATE TYPE notification_priority AS ENUM ('low', 'medium', 'high', 'critical');
CREATE TYPE node_type AS ENUM ('input', 'processing', 'action', 'output');

-- =============================================
-- CORE TABLES
-- =============================================

-- Users (extends Supabase auth.users)
CREATE TABLE public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email VARCHAR(255) UNIQUE NOT NULL,
  full_name VARCHAR(255),
  avatar_url TEXT,
  subscription_tier VARCHAR(50) DEFAULT 'free',
  settings JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Teams (for multi-tenant support)
CREATE TABLE teams (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  slug VARCHAR(100) UNIQUE NOT NULL,
  plan VARCHAR(50) DEFAULT 'starter',
  settings JSONB DEFAULT '{}',
  created_by UUID REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- User roles within teams
CREATE TABLE user_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
  role VARCHAR(50) NOT NULL, -- 'admin', 'agent_manager', 'viewer'
  granted_by UUID REFERENCES users(id),
  granted_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(user_id, team_id)
);

-- =============================================
-- AGENT MANAGEMENT
-- =============================================

-- Agent templates
CREATE TABLE agent_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  description TEXT,
  type VARCHAR(100) NOT NULL, -- 'market', 'websearch', 'media', 'alarm'
  default_config JSONB NOT NULL DEFAULT '{}',
  is_public BOOLEAN DEFAULT false,
  tags TEXT[] DEFAULT '{}',
  created_by UUID REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Main agents table
CREATE TABLE agents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  description TEXT,
  type VARCHAR(100) NOT NULL,
  status agent_status DEFAULT 'inactive',
  config JSONB NOT NULL DEFAULT '{}',
  deployment_config JSONB DEFAULT '{}',
  version INTEGER DEFAULT 1,
  template_id UUID REFERENCES agent_templates(id) ON DELETE SET NULL,
  created_by UUID REFERENCES users(id) ON DELETE CASCADE,
  team_id UUID REFERENCES teams(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  last_activity TIMESTAMPTZ,
  
  -- Constraints
  CONSTRAINT valid_agent_type CHECK (type IN ('market', 'websearch', 'media', 'alarm'))
);

-- Agent deployment history
CREATE TABLE deployments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  agent_id UUID REFERENCES agents(id) ON DELETE CASCADE,
  version INTEGER NOT NULL DEFAULT 1,
  status deployment_status DEFAULT 'pending',
  trigger_type VARCHAR(100), -- 'manual', 'config_change', 'scheduled'
  trigger_config JSONB DEFAULT '{}',
  deployment_url TEXT,
  error_message TEXT,
  metadata JSONB DEFAULT '{}',
  deployed_at TIMESTAMPTZ,
  stopped_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- WORKFLOW MANAGEMENT
-- =============================================

-- Workflows for agents
CREATE TABLE workflows (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  agent_id UUID REFERENCES agents(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  n8n_workflow_id VARCHAR(255),
  trigger_config JSONB DEFAULT '{}',
  status workflow_status DEFAULT 'inactive',
  last_execution TIMESTAMPTZ,
  next_execution TIMESTAMPTZ,
  execution_count INTEGER DEFAULT 0,
  success_count INTEGER DEFAULT 0,
  error_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Workflow execution logs
CREATE TABLE workflow_executions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workflow_id UUID REFERENCES workflows(id) ON DELETE CASCADE,
  execution_id VARCHAR(255), -- n8n execution ID
  status execution_status,
  input_data JSONB,
  output_data JSONB,
  error_data JSONB,
  execution_time_ms INTEGER,
  cost_usd DECIMAL(8,4),
  started_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ
);

-- =============================================
-- REAL-TIME COMMUNICATION
-- =============================================

-- User notifications
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  type VARCHAR(100) NOT NULL,
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  data JSONB DEFAULT '{}',
  priority notification_priority DEFAULT 'medium',
  read_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Agent thought process (for mind map)
CREATE TABLE agent_thoughts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  agent_id UUID REFERENCES agents(id) ON DELETE CASCADE,
  execution_id UUID REFERENCES workflow_executions(id) ON DELETE CASCADE,
  node_id VARCHAR(100) NOT NULL,
  node_type node_type NOT NULL,
  content TEXT NOT NULL,
  metadata JSONB DEFAULT '{}',
  parent_node_id VARCHAR(100),
  confidence_score DECIMAL(3,2),
  processing_time_ms INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- ANALYTICS & MONITORING
-- =============================================

-- Agent performance metrics
CREATE TABLE agent_metrics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  agent_id UUID REFERENCES agents(id) ON DELETE CASCADE,
  metric_type VARCHAR(100) NOT NULL,
  value DECIMAL(10,4) NOT NULL,
  unit VARCHAR(50),
  metadata JSONB DEFAULT '{}',
  recorded_at TIMESTAMPTZ DEFAULT NOW()
);

-- API usage tracking
CREATE TABLE api_usage (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  agent_id UUID REFERENCES agents(id) ON DELETE SET NULL,
  endpoint VARCHAR(255) NOT NULL,
  method VARCHAR(10) NOT NULL,
  status_code INTEGER NOT NULL,
  response_time_ms INTEGER,
  cost_usd DECIMAL(8,4),
  ip_address INET,
  user_agent TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- System analytics events
CREATE TABLE analytics_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_type VARCHAR(100) NOT NULL,
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  agent_id UUID REFERENCES agents(id) ON DELETE SET NULL,
  properties JSONB DEFAULT '{}',
  session_id VARCHAR(255),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- INDEXES FOR PERFORMANCE
-- =============================================

-- Users
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_subscription_tier ON users(subscription_tier);

-- Teams
CREATE INDEX idx_teams_slug ON teams(slug);
CREATE INDEX idx_teams_created_by ON teams(created_by);

-- User roles
CREATE INDEX idx_user_roles_user_id ON user_roles(user_id);
CREATE INDEX idx_user_roles_team_id ON user_roles(team_id);

-- Agent templates
CREATE INDEX idx_agent_templates_type ON agent_templates(type);
CREATE INDEX idx_agent_templates_public ON agent_templates(is_public) WHERE is_public = true;

-- Agents
CREATE INDEX idx_agents_created_by ON agents(created_by);
CREATE INDEX idx_agents_team_id ON agents(team_id);
CREATE INDEX idx_agents_type ON agents(type);
CREATE INDEX idx_agents_status ON agents(status);
CREATE INDEX idx_agents_updated_at ON agents(updated_at);
CREATE INDEX idx_agents_user_status ON agents(created_by, status);

-- Deployments
CREATE INDEX idx_deployments_agent_id ON deployments(agent_id);
CREATE INDEX idx_deployments_status ON deployments(status);
CREATE INDEX idx_deployments_created_at ON deployments(created_at);

-- Workflows
CREATE INDEX idx_workflows_agent_id ON workflows(agent_id);
CREATE INDEX idx_workflows_status ON workflows(status);
CREATE INDEX idx_workflows_next_execution ON workflows(next_execution) WHERE status = 'active';

-- Workflow executions
CREATE INDEX idx_workflow_executions_workflow_id ON workflow_executions(workflow_id);
CREATE INDEX idx_workflow_executions_status ON workflow_executions(status);
CREATE INDEX idx_workflow_executions_started_at ON workflow_executions(started_at);

-- Notifications
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_created_at ON notifications(created_at);
CREATE INDEX idx_notifications_priority ON notifications(priority);
CREATE INDEX idx_notifications_unread ON notifications(user_id, created_at) WHERE read_at IS NULL;

-- Agent thoughts
CREATE INDEX idx_agent_thoughts_agent_id ON agent_thoughts(agent_id);
CREATE INDEX idx_agent_thoughts_execution_id ON agent_thoughts(execution_id);
CREATE INDEX idx_agent_thoughts_created_at ON agent_thoughts(created_at);

-- Metrics
CREATE INDEX idx_agent_metrics_agent_id ON agent_metrics(agent_id);
CREATE INDEX idx_agent_metrics_type ON agent_metrics(metric_type);
CREATE INDEX idx_agent_metrics_recorded_at ON agent_metrics(recorded_at);

-- API usage
CREATE INDEX idx_api_usage_user_id ON api_usage(user_id);
CREATE INDEX idx_api_usage_agent_id ON api_usage(agent_id);
CREATE INDEX idx_api_usage_created_at ON api_usage(created_at);
CREATE INDEX idx_api_usage_endpoint ON api_usage(endpoint);

-- Analytics events
CREATE INDEX idx_analytics_events_type ON analytics_events(event_type);
CREATE INDEX idx_analytics_events_user_id ON analytics_events(user_id);
CREATE INDEX idx_analytics_events_created_at ON analytics_events(created_at);

-- =============================================
-- FUNCTIONS & TRIGGERS
-- =============================================

-- Function to update updated_at timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply updated_at triggers
CREATE TRIGGER update_users_updated_at 
  BEFORE UPDATE ON users 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_teams_updated_at 
  BEFORE UPDATE ON teams 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_agents_updated_at 
  BEFORE UPDATE ON agents 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_agent_templates_updated_at 
  BEFORE UPDATE ON agent_templates 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_workflows_updated_at 
  BEFORE UPDATE ON workflows 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to create notifications on agent status changes
CREATE OR REPLACE FUNCTION notify_agent_status_change()
RETURNS TRIGGER AS $$
BEGIN
  -- Only create notification if status actually changed
  IF OLD.status IS DISTINCT FROM NEW.status THEN
    INSERT INTO notifications (user_id, type, title, message, data, priority)
    VALUES (
      NEW.created_by,
      'agent_status_change',
      'Agent Status Updated',
      'Agent "' || NEW.name || '" status changed from ' || OLD.status || ' to ' || NEW.status,
      jsonb_build_object(
        'agent_id', NEW.id, 
        'agent_name', NEW.name,
        'old_status', OLD.status, 
        'new_status', NEW.status
      ),
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

-- Trigger for agent status notifications
CREATE TRIGGER agent_status_notification
  AFTER UPDATE ON agents
  FOR EACH ROW EXECUTE FUNCTION notify_agent_status_change();

-- Function to update workflow statistics
CREATE OR REPLACE FUNCTION update_workflow_stats()
RETURNS TRIGGER AS $$
BEGIN
  -- Update execution counts when workflow execution completes
  IF NEW.status IN ('success', 'error') AND OLD.status = 'running' THEN
    UPDATE workflows 
    SET 
      execution_count = execution_count + 1,
      success_count = CASE WHEN NEW.status = 'success' THEN success_count + 1 ELSE success_count END,
      error_count = CASE WHEN NEW.status = 'error' THEN error_count + 1 ELSE error_count END,
      last_execution = NEW.completed_at
    WHERE id = NEW.workflow_id;
  END IF;
  
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger for workflow statistics
CREATE TRIGGER update_workflow_statistics
  AFTER UPDATE ON workflow_executions
  FOR EACH ROW EXECUTE FUNCTION update_workflow_stats();

-- =============================================
-- ROW LEVEL SECURITY (RLS)
-- =============================================

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE agent_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE agents ENABLE ROW LEVEL SECURITY;
ALTER TABLE deployments ENABLE ROW LEVEL SECURITY;
ALTER TABLE workflows ENABLE ROW LEVEL SECURITY;
ALTER TABLE workflow_executions ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE agent_thoughts ENABLE ROW LEVEL SECURITY;
ALTER TABLE agent_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE api_usage ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics_events ENABLE ROW LEVEL SECURITY;

-- Users can manage their own profile
CREATE POLICY "Users can manage their own profile"
ON users FOR ALL
USING (auth.uid() = id);

-- Public agent templates are viewable by all
CREATE POLICY "Public templates are viewable by all"
ON agent_templates FOR SELECT
USING (is_public = true OR auth.uid() = created_by);

-- Users can manage templates they created
CREATE POLICY "Users can manage their own templates"
ON agent_templates FOR ALL
USING (auth.uid() = created_by);

-- Users can manage their own agents
CREATE POLICY "Users can manage their own agents"
ON agents FOR ALL
USING (auth.uid() = created_by);

-- Team members can view team agents
CREATE POLICY "Team members can view team agents"
ON agents FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM user_roles 
    WHERE user_id = auth.uid() 
    AND team_id = agents.team_id
  )
);

-- Users can access deployments for their agents
CREATE POLICY "Users can access deployments for their agents"
ON deployments FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM agents 
    WHERE agents.id = deployments.agent_id 
    AND agents.created_by = auth.uid()
  )
);

-- Users can access workflows for their agents
CREATE POLICY "Users can access workflows for their agents"
ON workflows FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM agents 
    WHERE agents.id = workflows.agent_id 
    AND agents.created_by = auth.uid()
  )
);

-- Users can access workflow executions for their workflows
CREATE POLICY "Users can access their workflow executions"
ON workflow_executions FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM workflows w
    JOIN agents a ON a.id = w.agent_id
    WHERE w.id = workflow_executions.workflow_id 
    AND a.created_by = auth.uid()
  )
);

-- Users can access their own notifications
CREATE POLICY "Users can access their own notifications"
ON notifications FOR ALL
USING (auth.uid() = user_id);

-- Users can access thoughts for their agents
CREATE POLICY "Users can access thoughts for their agents"
ON agent_thoughts FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM agents 
    WHERE agents.id = agent_thoughts.agent_id 
    AND agents.created_by = auth.uid()
  )
);

-- Users can access metrics for their agents
CREATE POLICY "Users can access metrics for their agents"
ON agent_metrics FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM agents 
    WHERE agents.id = agent_metrics.agent_id 
    AND agents.created_by = auth.uid()
  )
);

-- Users can access their own API usage
CREATE POLICY "Users can access their own API usage"
ON api_usage FOR ALL
USING (auth.uid() = user_id);

-- Users can access their own analytics events
CREATE POLICY "Users can access their own analytics events"
ON analytics_events FOR ALL
USING (auth.uid() = user_id);

-- =============================================
-- REALTIME PUBLICATIONS
-- =============================================

-- Enable realtime for key tables
ALTER PUBLICATION supabase_realtime ADD TABLE agents;
ALTER PUBLICATION supabase_realtime ADD TABLE deployments;
ALTER PUBLICATION supabase_realtime ADD TABLE workflows;
ALTER PUBLICATION supabase_realtime ADD TABLE workflow_executions;
ALTER PUBLICATION supabase_realtime ADD TABLE notifications;
ALTER PUBLICATION supabase_realtime ADD TABLE agent_thoughts;

-- =============================================
-- INITIAL DATA
-- =============================================

-- Insert default agent templates
INSERT INTO agent_templates (name, description, type, default_config, is_public) VALUES
('Basic Market Monitor', 'Simple cryptocurrency price monitoring', 'market', '{"symbols": ["BTC", "ETH"], "check_interval": 300}', true),
('Web Search Assistant', 'Intelligent web search and data extraction', 'websearch', '{"search_engines": ["google", "bing"], "max_results": 10}', true),
('Media Content Analyzer', 'Analysis and processing of media content', 'media', '{"supported_formats": ["jpg", "png", "mp4"], "analysis_types": ["sentiment", "objects"]}', true),
('Alert System', 'Monitoring and notification system', 'alarm', '{"check_interval": 60, "alert_methods": ["email", "webhook"]}', true);

-- Create system analytics events
INSERT INTO analytics_events (event_type, properties) VALUES
('schema_deployed', '{"version": "1.0.0", "timestamp": "' || NOW() || '"}');

-- =============================================
-- UTILITY FUNCTIONS
-- =============================================

-- Function to get agent dashboard data efficiently
CREATE OR REPLACE FUNCTION get_agent_dashboard(user_uuid UUID)
RETURNS TABLE (
  agent_id UUID,
  agent_name VARCHAR,
  agent_type VARCHAR,
  agent_status agent_status,
  deployment_status deployment_status,
  deployed_at TIMESTAMPTZ,
  execution_count INTEGER,
  success_rate DECIMAL,
  last_activity TIMESTAMPTZ
) AS $
BEGIN
  RETURN QUERY
  SELECT 
    a.id,
    a.name,
    a.type,
    a.status,
    d.status,
    d.deployed_at,
    COALESCE(w.execution_count, 0),
    CASE 
      WHEN COALESCE(w.execution_count, 0) = 0 THEN 0
      ELSE ROUND((w.success_count::DECIMAL / w.execution_count::DECIMAL) * 100, 2)
    END,
    a.last_activity
  FROM agents a
  LEFT JOIN LATERAL (
    SELECT status, deployed_at 
    FROM deployments 
    WHERE agent_id = a.id 
    ORDER BY created_at DESC 
    LIMIT 1
  ) d ON true
  LEFT JOIN LATERAL (
    SELECT execution_count, success_count
    FROM workflows 
    WHERE agent_id = a.id 
    ORDER BY created_at DESC 
    LIMIT 1
  ) w ON true
  WHERE a.created_by = user_uuid
  ORDER BY a.updated_at DESC;
END;
$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to clean up old data
CREATE OR REPLACE FUNCTION cleanup_old_data()
RETURNS void AS $
BEGIN
  -- Delete old workflow executions (keep last 30 days)
  DELETE FROM workflow_executions 
  WHERE started_at < NOW() - INTERVAL '30 days';
  
  -- Delete old notifications (keep last 90 days)
  DELETE FROM notifications 
  WHERE created_at < NOW() - INTERVAL '90 days';
  
  -- Delete old API usage logs (keep last 30 days)
  DELETE FROM api_usage 
  WHERE created_at < NOW() - INTERVAL '30 days';
  
  -- Delete old agent thoughts (keep last 7 days)
  DELETE FROM agent_thoughts 
  WHERE created_at < NOW() - INTERVAL '7 days';
  
  -- Delete expired notifications
  DELETE FROM notifications 
  WHERE expires_at IS NOT NULL AND expires_at < NOW();
  
  RAISE NOTICE 'Old data cleanup completed';
END;
$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to calculate agent performance metrics
CREATE OR REPLACE FUNCTION calculate_agent_metrics(agent_uuid UUID, days INTEGER DEFAULT 7)
RETURNS TABLE (
  metric_name VARCHAR,
  metric_value DECIMAL,
  metric_unit VARCHAR
) AS $
BEGIN
  RETURN QUERY
  WITH execution_stats AS (
    SELECT 
      COUNT(*) as total_executions,
      COUNT(*) FILTER (WHERE status = 'success') as successful_executions,
      AVG(execution_time_ms) as avg_execution_time,
      SUM(cost_usd) as total_cost
    FROM workflow_executions we
    JOIN workflows w ON w.id = we.workflow_id
    WHERE w.agent_id = agent_uuid
    AND we.started_at > NOW() - (days || ' days')::INTERVAL
  )
  SELECT 'total_executions'::VARCHAR, total_executions::DECIMAL, 'count'::VARCHAR FROM execution_stats
  UNION ALL
  SELECT 'success_rate'::VARCHAR, 
         CASE WHEN total_executions > 0 
              THEN (successful_executions::DECIMAL / total_executions::DECIMAL) * 100 
              ELSE 0 END, 
         'percent'::VARCHAR 
  FROM execution_stats
  UNION ALL
  SELECT 'avg_execution_time'::VARCHAR, COALESCE(avg_execution_time, 0), 'ms'::VARCHAR FROM execution_stats
  UNION ALL
  SELECT 'total_cost'::VARCHAR, COALESCE(total_cost, 0), 'usd'::VARCHAR FROM execution_stats;
END;
$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- SAMPLE DATA FOR DEVELOPMENT
-- =============================================

-- Note: This section should only be run in development environments
-- Comment out for production deployments

/*
-- Create a sample user (this would normally be handled by Supabase Auth)
INSERT INTO auth.users (id, email, email_confirmed_at, created_at, updated_at)
VALUES (
  'sample-user-uuid-here',
  'dev@example.com',
  NOW(),
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Create user profile
INSERT INTO users (id, email, full_name, subscription_tier)
VALUES (
  'sample-user-uuid-here',
  'dev@example.com',
  'Development User',
  'pro'
) ON CONFLICT (id) DO NOTHING;

-- Create sample team
INSERT INTO teams (id, name, slug, created_by)
VALUES (
  'sample-team-uuid-here',
  'Development Team',
  'dev-team',
  'sample-user-uuid-here'
) ON CONFLICT (id) DO NOTHING;

-- Create sample agents
INSERT INTO agents (id, name, description, type, status, config, created_by, team_id)
VALUES 
(
  'sample-agent-1-uuid',
  'BTC Price Monitor',
  'Monitors Bitcoin price and sends alerts',
  'market',
  'active',
  '{"symbol": "BTC", "threshold_high": 50000, "threshold_low": 30000}',
  'sample-user-uuid-here',
  'sample-team-uuid-here'
),
(
  'sample-agent-2-uuid',
  'News Sentiment Analyzer',
  'Analyzes news sentiment for market insights',
  'websearch',
  'paused',
  '{"keywords": ["bitcoin", "cryptocurrency"], "sources": ["coindesk", "cointelegraph"]}',
  'sample-user-uuid-here',
  'sample-team-uuid-here'
) ON CONFLICT (id) DO NOTHING;
*/

-- =============================================
-- COMPLETION MESSAGE
-- =============================================

DO $
BEGIN
  RAISE NOTICE '==============================================';
  RAISE NOTICE 'Echelon AI Agents Database Schema Deployed!';
  RAISE NOTICE '==============================================';
  RAISE NOTICE 'Next steps:';
  RAISE NOTICE '1. Verify all tables were created successfully';
  RAISE NOTICE '2. Test RLS policies with your authentication';
  RAISE NOTICE '3. Enable realtime for your application';
  RAISE NOTICE '4. Run initial data migrations if needed';
  RAISE NOTICE '5. Set up monitoring and backup schedules';
  RAISE NOTICE '==============================================';
END $;