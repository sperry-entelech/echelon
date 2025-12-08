# Agentic Capabilities Roadmap

Technical reference for layering agent capabilities over time.

## The Distinction

**Agentic Workflows (Phase 1 / MVP)**
- Structured automation with AI at decision points
- User designs flow, AI reasons within it
- Fresh context each run
- Zapier with AI nodes

**True Agents (Phase 2+)**
- Persistent memory across runs
- Autonomous execution on triggers
- Decides own path based on goals

## Phase 1: Agentic Workflows (Current)

Architecture:
```
User Input > Guided Setup > Config in DB > Workflow Engine > External APIs > Dashboard
```

- Workflow is deterministic, AI handles reasoning at nodes
- Each run stateless
- Human triggers or simple event triggers
- All actions logged

## Phase 2: Memory Layer

Add persistent memory without full autonomy.

Tech requirements:
- Postgres with pgvector (if on Supabase)
- Memory retrieval before LLM calls
- Store embeddings after each action

Schema addition:
```sql
create table agent_memory (
  id uuid primary key,
  agent_id uuid references agents(id),
  entity_type text,
  entity_id text,
  content text,
  embedding vector(1536),
  metadata jsonb,
  created_at timestamptz default now()
);
```

## Phase 3: Learning

Track outcomes, surface optimization suggestions to users. Human approves changes.

## Phase 4: Autonomous Execution

True agent behavior. Only after trust established. Requires constraint system, autonomous lifecycle runner, kill switches.

## What NOT To Build Yet

- Multi-agent coordination
- Cross-user learning
- Self-modifying workflows
- Agent-to-agent communication
