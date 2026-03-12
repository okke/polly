# Polly — Agentic Code Review

**Date:** 2026-03-12
**Reviewer:** Claude Sonnet 4.6 (agentic code review)
**Scope:** Full codebase — `server/` (Ruby/Sinatra) + `frontend/` (Vue 3)

---

## Executive Summary

Polly is a real-time polling app explicitly built through AI-agent collaboration. The result is a surprisingly coherent product: clean separation of concerns, good composable patterns on the frontend, and a well-structured service layer on the backend. However, the agentic development approach has also left behind a set of recognisable artefacts — long files, scattered state, unused abstractions, and a security posture that was never revisited after the happy path worked. This review scores the project across several axes and provides a prioritised, step-by-step improvement plan.

---

## Scores at a Glance

| Dimension              | Score | Notes |
|------------------------|-------|-------|
| Architecture           | 7/10  | Clean layers, good intent |
| Code quality           | 6/10  | Some very long files, mixed patterns |
| Security               | 2/10  | API key committed, no auth, open CORS |
| Performance            | 5/10  | WebSocket good, ping too aggressive, no caching |
| Agentic code patterns  | 4/10  | Good generation UX, but agent-generated code debt |
| Testability            | 3/10  | No tests, no test infrastructure |
| Observability          | 6/10  | Batched logging good, but client-only |

---

## 1. Architecture Assessment

### What works well

- **Clear backend/frontend split.** Ruby/Sinatra handles API + WebSocket; Vue 3 handles UI. Each has its own dependency graph and build tooling. This boundary is consistently respected.
- **Service layer in Ruby.** `PollGenerator`, `PsychAnalyzer`, `PollStorage`, and `ModelDiscoveryService` are all standalone, single-responsibility classes. Any of them can be replaced or tested in isolation.
- **Vue composables pattern.** `useSocket`, `useParticipant`, `useTheme`, and `useRemoteLog` correctly encapsulate shared logic. This is idiomatic Vue 3.
- **WebSocket broadcast model.** Voting participants submit via REST; results are pushed to admin clients via WebSocket. This is architecturally sound and avoids polling.
- **Makefile as orchestration.** Simple, portable, no hidden magic.

### Structural problems

- **`server/app.rb` is 858 lines.** This is the most critical structural issue. The file is simultaneously: a Sinatra router, a WebSocket event loop, a vote aggregator, an in-memory session store, and an AI orchestration layer. Agentic code generation tends to keep appending to the "main file" because the agent always has it in context. It needs to be split.
- **In-memory vote storage with no persistence.** Votes live only in the `VOTES` hash in `app.rb`. A server restart silently destroys all votes. This is acknowledged as intentional but is a significant reliability gap even for a demo.
- **WebSocket ping every 1000ms.** `setInterval(ping, 1000)` in `useSocket.js` is extremely aggressive. It exists to force Puma's buffer to flush. The correct fix is a server-side keep-alive or chunked-encoding header, not a 1 Hz heartbeat from every client.
- **Pinia installed but unused.** `pinia` is in `package.json` and mounted in `main.js`, but no store is defined. State management is split between `localStorage`, Vue `ref()` inside views, and composables — with no single source of truth.

---

## 2. Security Assessment

These are the most urgent issues in the codebase.

### CRITICAL

**S1 — API key committed to repository**
`server/.env` contains a plaintext OpenAI API key and is tracked by git. Anyone with repository access has billable access to your OpenAI account.

```
# server/.env  ← committed to version control
OPENAI_API_KEY=sk-...
```

**S2 — No authentication for admin endpoints**
`/admin`, `/api/reset`, `/api/generate-poll`, `/api/analyze-group`, and `/api/generate-random-votes` require no credentials. The only "auth" for admin WebSocket connections is the query param `?role=admin`. Anyone on the network who guesses this URL has full admin access.

### HIGH

**S3 — CORS wildcard**
```ruby
set :allow_origin, '*'
set :allow_methods, '*'
```
This allows any origin to make credentialled requests to the API.

**S4 — No input sanitisation**
Poll titles, statement text, and topic strings from the AI are rendered with `v-html` in several components. If the LLM ever returns a string containing a `<script>` tag (or is prompt-injected to do so), it executes in the browser.

**S5 — No rate limiting**
`/api/generate-poll` and `/api/analyze` hit OpenAI. There is no rate limiting or request queuing, making the API key trivially exhaustible.

### MEDIUM

**S6 — Participant UUID trivially replayable**
Participant IDs are UUIDs generated client-side and stored in `localStorage`. A voter can clear `localStorage` and vote again, or share their UUID with another browser tab.

**S7 — No HTTPS**
The application runs on plain HTTP. In a shared-LAN demo context this may be acceptable, but WebSocket traffic (including votes and analyses) is unencrypted.

---

## 3. Code Quality — Agentic Artefacts

Agentic code generation leaves characteristic patterns. Here is what was observed and why it happens.

### 3.1 The "Main File Gravity" problem

`app.rb` is 858 lines because the agent always reopened it to add functionality rather than creating new files. The file contains:
- Route definitions (correct location)
- WebSocket management (could be a module)
- Vote aggregation logic (should be a service)
- CORS/headers middleware (should be a middleware class)
- Server metadata extraction (should be a utility)
- Admin broadcast helpers (should be a module)

**Fix:** Extract into `lib/vote_manager.rb`, `lib/websocket_manager.rb`, and a Sinatra middleware class.

### 3.2 The "Copy-paste divergence" problem

Several admin modals (`PollGeneratorModal.vue`, `PollRegeneratorModal.vue`, `GroupAnalysisModal.vue`) share the same structural shell: a dimmed backdrop, a card, a close button, a loading state, and an error display. Each was generated independently and has subtly different implementations of the same pattern.

**Fix:** Extract a `BaseModal.vue` component and compose from it.

### 3.3 Inconsistent error handling style

Error handling in `app.rb` mixes three different styles:
```ruby
# Style 1: halt with JSON
halt 400, json({ error: '...' })

# Style 2: begin/rescue with status
status 500
json({ error: e.message })

# Style 3: rescue and return partial result
rescue => e
  puts "[ERROR] #{e.message}"
  {}
```

This is typical of agentic generation — each code block was generated in a separate context window moment. A consistent error-response helper should be extracted.

### 3.4 Hardcoded model fallbacks mixed into discovery logic

`ModelDiscoveryService` is a well-designed caching service, but it embeds hardcoded model strings as fallbacks (`gpt-4o`, `gpt-4o-mini`, etc.) inside the discovery logic. These should live in a config constant, not inline strings.

### 3.5 Magic numbers and strings

Throughout `app.rb` and the frontend:
- `1000` (ping interval) — not named
- `500` and `20` (log batch size/interval) — not named
- `1.0` and `1.2` (OpenAI temperatures) — not named
- `15 * 60` (model cache TTL) — not named

### 3.6 `AdminView.vue` — modal state proliferation

`AdminView.vue` manages visibility state for 6 modals with separate boolean refs (`showGeneratorModal`, `showRegeneratorModal`, `showGroupAnalysisModal`, `showRandomVotesModal`, etc.) and separate result/error state for each. This grows linearly with each new feature. An agentic agent will keep adding booleans because it's the path of least resistance.

**Fix:** Single `activeModal` ref with an enum value, and a modal registry pattern.

---

## 4. Performance Assessment

### Positive

- **Vue 3 + Vite.** Build toolchain is fast; production bundle will be lean.
- **WebSocket for real-time.** Avoids polling; correct choice for this use case.
- **Batched remote logging.** `useRemoteLog` batches 500ms / 20 items — sensible.
- **Model result caching.** `ModelDiscoveryService` caches for 15 minutes — correct.

### Negative

- **1 Hz WebSocket ping per client.** With 100 participants, this is 100 pings/second hitting the server for no data value. Puma's 8 thread max will saturate quickly.
- **Blocking OpenAI calls on the request thread.** `PollGenerator.generate()` and `PsychAnalyzer.analyze()` are synchronous. A slow OpenAI response (10–30s) blocks a Puma thread for that entire duration. With 8 max threads, 8 simultaneous AI requests freeze the server.
- **No HTTP caching headers.** Static assets in `frontend/dist/` are served without `Cache-Control`, so browsers re-fetch them on every load.
- **Chart re-render on every `results_update`.** `ResultChart.vue` appears to redraw the entire chart on each WebSocket event, not update it incrementally.

---

## 5. Agentic Coding Patterns — Assessment

The project is explicitly an experiment in agentic development. Here is an assessment of how well the AI-facing parts are implemented.

### What is done well

- **Prompt structure.** `PollGenerator` and `PsychAnalyzer` correctly separate system and user roles. The system prompt establishes context/persona; the user prompt carries the data.
- **Temperature tuning.** `1.0` for poll generation (creative diversity), `1.2` for psychological analysis (wit). This is appropriate.
- **JSON mode with fallback.** The generator tries JSON mode first, then falls back to markdown parsing. This is robust.
- **Contextual prompts.** The system prompt adapts to the poll's topic (e.g. "You are an expert in AI and software development"). This improves analysis quality significantly.
- **Generation context preserved.** The poll stores its generation parameters so `regenerate` can replay them with modifications. This is good agentic design.
- **Model tiering.** The model discovery service categorises models into premium/standard/budget and selects the best available. Graceful degradation is built in.

### What could be improved

- **No structured output schema validation.** The generator parses the LLM's JSON response but does not validate it against a schema. A malformed response (wrong field names, missing keys) produces a cryptic Ruby error rather than a user-friendly message.
- **No retry logic on transient failures.** If OpenAI returns a 429 or 500, the request fails immediately with an error. A simple exponential backoff with 3 retries would significantly improve reliability.
- **Temperature 1.2 may exceed model limits.** Some OpenAI models cap temperature at 1.0 or 2.0 depending on endpoint. This should be validated or clamped.
- **Prompt injection surface.** The poll topic and context strings from the admin UI are interpolated directly into the LLM system prompt without sanitisation. A malicious admin could craft a topic string that alters the LLM's behaviour.
- **No streaming.** Generation and analysis can take 10–30 seconds. The UI shows a spinner with no progress indication. Streaming the response would dramatically improve perceived performance.
- **Group analysis sends all raw votes.** `/api/analyze-group` sends the complete vote dataset to OpenAI in a single request. With large participant counts this could exceed context limits or become expensive.

---

## 6. Testability Assessment

There are **no tests** in this codebase — no unit tests, integration tests, or end-to-end tests. This is a common outcome of agentic development where the agent focuses on the happy path.

Key testability gaps:
- `PollGenerator` and `PsychAnalyzer` have no test doubles for the OpenAI client.
- `PollStorage` reads/writes real files — no temp dir injection.
- Vote logic in `app.rb` is not extractable without refactoring.
- Frontend composables have no Vitest setup.

---

## 7. Step-by-Step Improvement Plan

The improvements are ordered by impact and effort. Each step is independent enough to be done in a single session.

---

### Step 1 — Revoke and rotate the API key (IMMEDIATE)

**Why:** A committed API key is a live security incident.

1. Go to [platform.openai.com/api-keys](https://platform.openai.com/api-keys) and revoke the key currently in `server/.env`.
2. Generate a new key.
3. Add `server/.env` to `.gitignore` (verify it is not already tracked).
4. Remove `server/.env` from git history:
   ```bash
   git filter-branch --force --index-filter \
     "git rm --cached --ignore-unmatch server/.env" \
     --prune-empty --tag-name-filter cat -- --all
   ```
   Or use `git-filter-repo` (preferred).
5. Add `server/.env.example` with placeholder values and commit that instead.

---

### Step 2 — Fix CORS and add a basic admin token

**Why:** Any device on the network can reset votes or generate polls.

1. Restrict CORS to the frontend origin:
   ```ruby
   set :allow_origin, ENV.fetch('FRONTEND_ORIGIN', 'http://localhost:3000')
   ```
2. Add a simple shared-secret check for mutating admin endpoints:
   ```ruby
   def require_admin!
     token = request.env['HTTP_X_ADMIN_TOKEN']
     halt 401, json(error: 'Unauthorized') unless token == ENV['ADMIN_TOKEN']
   end
   ```
3. Add `ADMIN_TOKEN` to `.env` (a long random string).
4. Send the token from the frontend admin panel via `axios` default headers.

---

### Step 3 — Slow down the WebSocket ping

**Why:** 1 Hz heartbeat from every client wastes threads.

1. In `useSocket.js`, change the ping interval from `1000` to `30000` (30 seconds).
2. Fix the root cause: add a `Transfer-Encoding: chunked` response header in Sinatra for the WebSocket handshake so Puma flushes without being jabbed. Alternatively, set `no_cache` headers.
3. If Puma still buffers, set `PUMA_NO_KEEP_ALIVE=1` in the env or switch to a non-buffering server for WebSocket routes (e.g. Thin or Iodine).

---

### Step 4 — Extract `app.rb` into focused modules

**Why:** 858-line file is unmaintainable and blocks agentic agents from making precise edits without touching unrelated code.

Suggested extraction:
```
server/lib/
  vote_manager.rb        # VOTES hash + vote/reset logic
  websocket_manager.rb   # CLIENTS hash + broadcast helpers
  server_info.rb         # IP/port/participant count helpers
  middleware/
    cors.rb              # CORS headers
    json_errors.rb       # Consistent error response format
```

`app.rb` then becomes only route definitions, delegating to these modules.

---

### Step 5 — Add input validation with a schema

**Why:** Unvalidated LLM output and user input can cause silent failures or XSS.

1. Add the `dry-validation` or `json_schemer` gem.
2. Define a `POLL_SCHEMA` that validates: `title` (string, 3–200 chars), `statements` (array, 2–20 items), each statement has `id` (string) and `text` (string, 10–500 chars).
3. Validate all poll data before saving — both from AI generation and manual edits.
4. On the frontend, replace `v-html` with `v-text` or a sanitised markdown renderer (e.g. `marked` + `DOMPurify`).

---

### Step 6 — Add retry logic for OpenAI calls

**Why:** Transient 429/500 errors from OpenAI cause user-facing failures that a retry would silently resolve.

1. Extract a `call_openai(max_retries: 3, &block)` helper in a shared `lib/openai_client.rb`:
   ```ruby
   def call_openai(max_retries: 3, &block)
     retries = 0
     begin
       block.call
     rescue OpenAI::Error => e
       raise if retries >= max_retries
       retries += 1
       sleep(2 ** retries)
       retry
     end
   end
   ```
2. Use it in `PollGenerator` and `PsychAnalyzer`.

---

### Step 7 — Extract a `BaseModal.vue` component

**Why:** The three admin modals share identical structural HTML; divergence will grow.

1. Create `frontend/src/components/BaseModal.vue` with: backdrop, card container, title slot, close button, loading state, error display.
2. Refactor `PollGeneratorModal.vue`, `PollRegeneratorModal.vue`, and `GroupAnalysisModal.vue` to use `<BaseModal>`.
3. This reduces each modal to only its unique form fields and logic.

---

### Step 8 — Consolidate modal state in `AdminView.vue`

**Why:** 6 individual boolean refs will become 10+ as features are added.

1. Replace individual booleans with:
   ```js
   const activeModal = ref(null) // 'generator' | 'regenerator' | 'group' | 'random' | null
   ```
2. Each modal receives `:visible="activeModal === 'generator'"` and emits `@close="activeModal = null"`.
3. This makes the pattern extensible without additional state.

---

### Step 9 — Add structured output validation for AI responses

**Why:** LLM responses are unpredictable; a malformed JSON response causes a Ruby exception with no user feedback.

1. Use OpenAI's `response_format: { type: 'json_schema', json_schema: ... }` parameter (supported on gpt-4o and later) to enforce the poll structure at the API level.
2. Fall back to a manual schema check in `PollGenerator#parse_response` with descriptive error messages for each missing field.
3. Surface a user-friendly error message in the generator modal when validation fails.

---

### Step 10 — Add streaming for AI generation/analysis

**Why:** 10–30 second spinners with no feedback cause users to assume the feature is broken.

1. Add a streaming endpoint: `POST /api/generate-poll/stream` that uses OpenAI's streaming API and sends Server-Sent Events (SSE).
2. In the frontend, use `EventSource` to consume the stream and display partial results as they arrive.
3. For analysis, stream the personality profile text character by character into the success overlay.

---

### Step 11 — Add rate limiting

**Why:** Without it, a single user can exhaust the OpenAI API budget or overwhelm the server.

1. Add the `rack-attack` gem.
2. Configure:
   ```ruby
   Rack::Attack.throttle('api/generate', limit: 5, period: 60) do |req|
     req.ip if req.path.start_with?('/api/generate')
   end
   Rack::Attack.throttle('api/vote', limit: 100, period: 60) do |req|
     req.ip if req.path == '/api/vote'
   end
   ```
3. Return `429 Too Many Requests` with a `Retry-After` header.

---

### Step 12 — Add a test suite

**Why:** The app has no regression safety net. Any refactoring (including the steps above) risks breaking the happy path invisibly.

**Backend (RSpec):**
- Unit tests for `PollStorage`, `PollGenerator` (with a stubbed OpenAI client), `ModelDiscoveryService`.
- Request specs for core API routes using `rack-test`.

**Frontend (Vitest + Vue Test Utils):**
- Unit tests for `useParticipant`, `useSocket` (with a mock WebSocket).
- Component tests for `StatementCard`, `VoteButtons`, `ResultsGrid`.

**Target:** 60% line coverage on the core data-flow paths before any further feature work.

---

### Step 13 — Add HTTP caching for static assets

**Why:** Browsers re-fetch the entire frontend on every load because no cache headers are set.

1. In `app.rb`, set long-lived cache headers for the Vite build output (which uses content hashes in filenames):
   ```ruby
   set :static_cache_control, [:public, max_age: 31_536_000]
   ```
2. Set a short max-age for `index.html` itself (it has no hash):
   ```ruby
   before '/index.html' do
     response.headers['Cache-Control'] = 'no-cache'
   end
   ```

---

## Summary Table

| Step | Category       | Effort  | Impact   | Priority |
|------|----------------|---------|----------|----------|
| 1    | Security       | 30 min  | Critical | NOW      |
| 2    | Security       | 2 hrs   | High     | This week|
| 3    | Performance    | 30 min  | Medium   | This week|
| 4    | Code quality   | 4 hrs   | High     | Next     |
| 5    | Security       | 3 hrs   | High     | Next     |
| 6    | Reliability    | 1 hr    | Medium   | Next     |
| 7    | Code quality   | 2 hrs   | Medium   | Next     |
| 8    | Code quality   | 1 hr    | Low      | Later    |
| 9    | Reliability    | 2 hrs   | Medium   | Later    |
| 10   | UX             | 4 hrs   | Medium   | Later    |
| 11   | Security       | 1 hr    | Medium   | Later    |
| 12   | Testability    | 8 hrs   | High     | Later    |
| 13   | Performance    | 30 min  | Low      | Later    |

---

## Agentic Development Observations

This codebase is a clear demonstration of both the strengths and failure modes of agentic code generation.

**Strengths generated by the agent:**
- Consistent naming conventions across files generated weeks apart
- Well-structured composables that correctly follow Vue 3 idioms
- Service layer separation that most human developers skip in small projects
- Sophisticated prompt engineering (temperature tuning, model tiering, context injection)
- Good UX patterns (batched logging, modal workflows, live charts)

**Failure modes visible in the output:**
- **Gravity toward the main file:** `app.rb` grew to 858 lines because the agent reopened it for every new feature
- **No revisiting security:** Security is a cross-cutting concern that doesn't appear in a single feature request; the agent never had a prompt that said "now harden this" until it was done
- **Installed but unused dependencies:** Pinia is mounted but has no stores — the agent imported it as scaffolding and never used it
- **Divergent copies of patterns:** Modals, error handling, and fetch logic were each re-implemented from scratch per generation session
- **No tests:** Tests require a "slow down and verify" mindset that is at odds with the "ship the feature" prompts typical of agentic sessions
- **Magic numbers:** Constants were inlined at generation time and never extracted because the agent was focused on correctness, not maintainability

The improvement plan above is designed to be executed agentically — each step is scoped to a single, clearly bounded task that an agent (or a human) can complete in one session without needing global context.
