# langmesh OpenAI (Ruby)

Drop-in replacement for the OpenAI Ruby client with automatic cost optimization and telemetry.

## Installation

```bash
gem install langmesh-openai
```

Or add to your Gemfile:

```ruby
gem 'langmesh-openai'
```

## Usage

Change one line of code:

```ruby
# Before
require "openai"
client = OpenAI::Client.new(access_token: api_key)

# After
require "langmesh/openai"
client = langmesh::OpenAI::Client.new(access_token: api_key)

# Everything works exactly the same!
response = client.chat(
  parameters: {
    model: "gpt-4o",
    messages: [{ role: "user", content: "Hello!" }]
  }
)
```

That's it. No configuration needed.

## What It Does

### Telemetry (Always On)

- Tracks token usage, cost, and latency
- Privacy-preserving (no prompts sent by default)
- Zero performance impact (async)
- Never breaks your app (fail-safe)

### Cost Optimization (Opt-In)

When you enable policies in the langmesh dashboard:

- Automatic model downgrading for simple queries
- Retry storm suppression
- Exact Cache (identical requests)
- Semantic Deduplication (high-threshold reuse)
- Semantic Answer Cache (advanced, opt-in)
- Token optimization

## Configuration

### Required

```bash
export langmesh_API_KEY=sk_live_...  # Get from dashboard.langmesh.ai
```

### Optional

```bash
export langmesh_PROXY_ENABLED=true  # Enable when policies require routing
export langmesh_BASE_URL=https://api.langmesh.ai/v1/openai  # Custom proxy URL
```

## Migration Path

1. **Install** - `gem install langmesh-openai`
2. **Replace require** - Change to `langmesh/openai`
3. **Set API key** - `export langmesh_API_KEY=sk_live_...`
4. **See savings** - Visit dashboard.langmesh.ai
5. **Enable policies** - When ready, `export langmesh_PROXY_ENABLED=true`

## Guarantees

✅ Drop-in replacement - works identically
✅ No behavior changes without opt-in
✅ Fail-safe - errors don't break your app
✅ Reversible - remove anytime
✅ Privacy-first - no prompts sent by default

## License

MIT
