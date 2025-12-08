# Real-time Implementation Guide

## 🚀 Supabase Realtime Setup

This guide covers implementing real-time features using **Supabase Realtime** instead of WebSockets. Supabase Realtime provides database-driven real-time updates with automatic reconnection and scaling.

## 🏗️ Architecture Overview

```
Database Change (PostgreSQL Trigger)
    ↓
Supabase Realtime Engine
    ↓
WebSocket Connection to Client
    ↓
Frontend Event Handler
    ↓
UI Update
```

## 📋 Frontend Implementation

### 1. Initial Setup

```javascript
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
)

// Enable realtime for specific tables
const enableRealtime = async () => {
  const { data, error } = await supabase
    .from('agents')
    .select('*')
    .limit(1)
  
  if (error) console.error('Realtime setup error:', error)
  else console.log('Realtime enabled')
}
```

### 2. Agent Status Updates

```javascript
// Subscribe to agent changes
const subscribeToAgentUpdates = (userId, onUpdate) => {
  const subscription = supabase
    .channel('agent-updates')
    .on('postgres_changes', {
      event: '*', // INSERT, UPDATE, DELETE
      schema: 'public',
      table: 'agents',
      filter: `created_by=eq.${userId}`
    }, (payload) => {
      console.log('Agent updated:', payload)
      onUpdate(payload)
    })
    .subscribe()

  return subscription
}

// Usage in React component
import { useState, useEffect } from 'react'

const AgentDashboard = () => {
  const [agents, setAgents] = useState([])
  const [user] = useAuth() // Your auth hook

  useEffect(() => {
    if (!user) return

    // Initial data load
    const loadAgents = async () => {
      const { data } = await supabase
        .from('agents')
        .select('*')
        .eq('created_by', user.id)
        .order('updated_at', { ascending: false })
      
      setAgents(data || [])
    }

    loadAgents()

    // Real-time subscription
    const subscription = subscribeToAgentUpdates(user.id, (payload) => {
      const { eventType, new: newRecord, old: oldRecord } = payload

      setAgents(current => {
        switch (eventType) {
          case 'INSERT':
            return [newRecord, ...current]
          
          case 'UPDATE':
            return current.map(agent => 
              agent.id === newRecord.id ? newRecord : agent
            )
          
          case 'DELETE':
            return current.filter(agent => agent.id !== oldRecord.id)
          
          default:
            return current
        }
      })
    })

    // Cleanup
    return () => {
      supabase.removeChannel(subscription)
    }
  }, [user])

  return (
    <div>
      {agents.map(agent => (
        <AgentCard key={agent.id} agent={agent} />
      ))}
    </div>
  )
}
```

### 3. Real-time Notifications

```javascript
// Notification subscription
const subscribeToNotifications = (userId, onNotification) => {
  return supabase
    .channel('user-notifications')
    .on('postgres_changes', {
      event: 'INSERT',
      schema: 'public',
      table: 'notifications',
      filter: `user_id=eq.${userId}`
    }, (payload) => {
      const notification = payload.new
      
      // Show in-app notification
      onNotification(notification)
      
      // Show browser notification for high priority
      if (notification.priority === 'high' || notification.priority === 'critical') {
        showBrowserNotification(notification)
      }
    })
    .subscribe()
}

// Browser notification helper
const showBrowserNotification = (notification) => {
  if ('Notification' in window && Notification.permission === 'granted') {
    new Notification(notification.title, {
      body: notification.message,
      icon: '/logo.png',
      badge: '/badge.png',
      tag: notification.id
    })
  }
}

// Request notification permission
const requestNotificationPermission = async () => {
  if ('Notification' in window) {
    const permission = await Notification.requestPermission()
    return permission === 'granted'
  }
  return false
}
```

### 4. Workflow Execution Progress

```javascript
// Subscribe to workflow execution updates
const subscribeToWorkflowProgress = (agentId, onProgress) => {
  return supabase
    .channel(`workflow-progress-${agentId}`)
    .on('postgres_changes', {
      event: '*',
      schema: 'public',
      table: 'workflow_executions',
      filter: `workflow_id=in.(${workflowIds.join(',')})`
    }, (payload) => {
      const execution = payload.new || payload.old
      onProgress(execution)
    })
    .subscribe()
}

// Progress tracking component
const WorkflowProgress = ({ agentId }) => {
  const [executions, setExecutions] = useState([])
  const [workflows, setWorkflows] = useState([])

  useEffect(() => {
    // Load workflows for agent
    const loadWorkflows = async () => {
      const { data } = await supabase
        .from('workflows')
        .select('id')
        .eq('agent_id', agentId)
      
      setWorkflows(data || [])
    }

    loadWorkflows()
  }, [agentId])

  useEffect(() => {
    if (workflows.length === 0) return

    const workflowIds = workflows.map(w => w.id)
    
    const subscription = subscribeToWorkflowProgress(workflowIds, (execution) => {
      setExecutions(current => {
        const index = current.findIndex(e => e.id === execution.id)
        if (index >= 0) {
          // Update existing
          const updated = [...current]
          updated[index] = execution
          return updated
        } else {
          // Add new
          return [execution, ...current.slice(0, 9)] // Keep latest 10
        }
      })
    })

    return () => {
      supabase.removeChannel(subscription)
    }
  }, [workflows])

  return (
    <div className="workflow-progress">
      {executions.map(execution => (
        <div key={execution.id} className={`execution ${execution.status}`}>
          <span className="status">{execution.status}</span>
          <span className="duration">
            {execution.execution_time_ms}ms
          </span>
          <div className="progress-bar">
            <div 
              className="progress-fill"
              style={{ 
                width: execution.status === 'running' ? '50%' : 
                       execution.status === 'success' ? '100%' : '0%' 
              }}
            />
          </div>
        </div>
      ))}
    </div>
  )
}
```

### 5. Mind Map Real-time Updates

```javascript
// Subscribe to AI thought process updates
const subscribeToThoughts = (agentId, executionId, onThought) => {
  return supabase
    .channel(`thoughts-${agentId}`)
    .on('postgres_changes', {
      event: 'INSERT',
      schema: 'public',
      table: 'agent_thoughts',
      filter: `agent_id=eq.${agentId}`
    }, (payload) => {
      const thought = payload.new
      
      // Only update if it's for current execution or no specific execution
      if (!executionId || thought.execution_id === executionId) {
        onThought(thought)
      }
    })
    .subscribe()
}

// Mind map component with real-time updates
const MindMapVisualization = ({ agentId, executionId }) => {
  const [thoughts, setThoughts] = useState([])
  const [mindMapData, setMindMapData] = useState({ nodes: [], edges: [] })

  useEffect(() => {
    // Load existing thoughts
    const loadThoughts = async () => {
      let query = supabase
        .from('agent_thoughts')
        .select('*')
        .eq('agent_id', agentId)
        .order('created_at', { ascending: true })

      if (executionId) {
        query = query.eq('execution_id', executionId)
      }

      const { data } = await query
      setThoughts(data || [])
    }

    loadThoughts()

    // Real-time subscription
    const subscription = subscribeToThoughts(agentId, executionId, (newThought) => {
      setThoughts(current => [...current, newThought])
    })

    return () => {
      supabase.removeChannel(subscription)
    }
  }, [agentId, executionId])

  // Convert thoughts to mind map data
  useEffect(() => {
    const nodes = thoughts.map(thought => ({
      id: thought.node_id,
      type: thought.node_type,
      data: {
        label: thought.content,
        confidence: thought.confidence_score,
        timestamp: thought.created_at
      }
    }))

    const edges = thoughts
      .filter(thought => thought.parent_node_id)
      .map(thought => ({
        id: `${thought.parent_node_id}-${thought.node_id}`,
        source: thought.parent_node_id,
        target: thought.node_id,
        animated: true
      }))

    setMindMapData({ nodes, edges })
  }, [thoughts])

  return (
    <div className="mind-map-container">
      <ReactFlow
        nodes={mindMapData.nodes}
        edges={mindMapData.edges}
        onNodesChange={onNodesChange}
        onEdgesChange={onEdgesChange}
        fitView
      >
        <Background />
        <Controls />
      </ReactFlow>
    </div>
  )
}
```

## 🔄 Strategic Polling for External Data

For data that's not stored in your database (external API status, real-time market data), use strategic polling:

```javascript
// External API status polling
const useExternalServiceStatus = () => {
  const [status, setStatus] = useState({})
  const [lastUpdate, setLastUpdate] = useState(null)

  useEffect(() => {
    const fetchStatus = async () => {
      try {
        const response = await fetch('/api/external/health')
        const data = await response.json()
        setStatus(data.data.services)
        setLastUpdate(new Date())
      } catch (error) {
        console.error('Failed to fetch external status:', error)
      }
    }

    // Initial fetch
    fetchStatus()

    // Poll every 30 seconds
    const interval = setInterval(fetchStatus, 30000)

    return () => clearInterval(interval)
  }, [])

  return { status, lastUpdate }
}

// Usage in component
const ExternalServiceStatus = () => {
  const { status, lastUpdate } = useExternalServiceStatus()

  return (
    <div className="service-status">
      <h3>External Services</h3>
      {Object.entries(status).map(([service, info]) => (
        <div key={service} className={`service ${info.status}`}>
          <span className="name">{service}</span>
          <span className="status">{info.status}</span>
          <span className="response-time">{info.response_time_ms}ms</span>
        </div>
      ))}
      {lastUpdate && (
        <p className="last-update">
          Last updated: {lastUpdate.toLocaleTimeString()}
        </p>
      )}
    </div>
  )
}
```

## 🎯 Channel Management & Cleanup

```javascript
// Channel manager for better organization
class RealtimeManager {
  constructor(supabase) {
    this.supabase = supabase
    this.subscriptions = new Map()
  }

  subscribe(channelName, config, callback) {
    // Remove existing subscription if exists
    this.unsubscribe(channelName)

    const channel = this.supabase
      .channel(channelName)
      .on('postgres_changes', config, callback)
      .subscribe()

    this.subscriptions.set(channelName, channel)
    return channel
  }

  unsubscribe(channelName) {
    const existing = this.subscriptions.get(channelName)
    if (existing) {
      this.supabase.removeChannel(existing)
      this.subscriptions.delete(channelName)
    }
  }

  unsubscribeAll() {
    this.subscriptions.forEach((channel, name) => {
      this.supabase.removeChannel(channel)
    })
    this.subscriptions.clear()
  }
}

// Usage in React app
const useRealtimeManager = () => {
  const managerRef = useRef(null)

  useEffect(() => {
    managerRef.current = new RealtimeManager(supabase)

    return () => {
      managerRef.current?.unsubscribeAll()
    }
  }, [])

  return managerRef.current
}
```

## 📊 Performance Optimization

### 1. Selective Subscriptions
```javascript
// Only subscribe to data you actually need
const subscription = supabase
  .channel('agents-minimal')
  .on('postgres_changes', {
    event: 'UPDATE',
    schema: 'public',
    table: 'agents',
    filter: `created_by=eq.${userId}`,
    // Only listen for status changes
    columns: ['id', 'status', 'updated_at']
  }, callback)
  .subscribe()
```

### 2. Debounced Updates
```javascript
import { debounce } from 'lodash'

const debouncedUpdate = debounce((updates) => {
  // Batch multiple rapid updates
  setAgents(current => {
    return current.map(agent => {
      const update = updates.find(u => u.id === agent.id)
      return update ? { ...agent, ...update } : agent
    })
  })
}, 100)
```

### 3. Connection State Management
```javascript
const useConnectionState = () => {
  const [isConnected, setIsConnected] = useState(true)

  useEffect(() => {
    const channel = supabase.channel('connection-test')
    
    channel.subscribe((status) => {
      setIsConnected(status === 'SUBSCRIBED')
    })

    return () => {
      supabase.removeChannel(channel)
    }
  }, [])

  return isConnected
}
```

This implementation provides robust real-time functionality while being simpler to maintain than custom WebSocket solutions.