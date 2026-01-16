# SKEW OpenAI (Ruby)

Drop-in replacement for the OpenAI Ruby client with automatic cost optimization and telemetry.

## Installation

```bash
gem install skew-openai
```

Or add to your Gemfile:

```ruby
gem 'skew-openai'
```

## Usage

Change one line of code:

```ruby
# Before
require "openai"
client = OpenAI::Client.new(access_token: api_key)

# After
require "skew/openai"
client = Skew::OpenAI::Client.new(access_token: api_key)

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
When you enable policies in the SKEW dashboard:
- Automatic model downgrading for simple queries
- Retry storm suppression
- Semantic caching
- Token optimization

## Configuration

### Required
```bash
export SKEW_API_KEY=sk_live_...  # Get from dashboard.skew.ai
```

### Optional
```bash
export SKEW_PROXY_ENABLED=true  # Enable when policies require routing
export SKEW_BASE_URL=https://api.skew.ai/v1/openai  # Custom proxy URL
```

## Migration Path

1. **Install** - `gem install skew-openai`
2. **Replace require** - Change to `skew/openai`
3. **Set API key** - `export SKEW_API_KEY=sk_live_...`
4. **See savings** - Visit dashboard.skew.ai
5. **Enable policies** - When ready, `export SKEW_PROXY_ENABLED=true`

## Guarantees

✅ Drop-in replacement - works identically  
✅ No behavior changes without opt-in  
✅ Fail-safe - errors don't break your app  
✅ Reversible - remove anytime  
✅ Privacy-first - no prompts sent by default  

## License

MIT
