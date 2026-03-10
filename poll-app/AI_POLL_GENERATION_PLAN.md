# AI Poll Generation Feature Plan

## Overview
Add AI-powered poll generation to the admin panel using OpenAI API via the ruby_llm library.

## Dependencies
- **ruby_llm** (https://github.com/crmne/ruby_llm) - Ruby wrapper for LLM APIs
- OpenAI API key (user has one)

## Architecture

### 1. Frontend Changes

#### Admin Panel UI
**Location:** `frontend/src/views/AdminView.vue`

**New Components:**
- "Generate New Poll" button in header/toolbar
- Modal component: `frontend/src/components/PollGeneratorModal.vue`

**Modal Form Fields:**
1. **Topic** (text input, required)
   - Placeholder: "e.g., Remote work policies, Climate change awareness"
   - Max: 200 characters

2. **Tone of Voice** (select dropdown, required)
   - Options: Professional, Casual, Academic, Friendly, Formal
   - Default: Professional

3. **Number of Questions** (number input/slider, required)
   - Min: 3, Max: 10
   - Default: 5

4. **Expected Audience** (text input, required)
   - Placeholder: "e.g., University students, Corporate employees, General public"
   - Max: 200 characters

5. **Additional Context** (textarea, optional)
   - Placeholder: "Any specific aspects or angles to focus on..."
   - Max: 300 characters

6. **Additional Instructions** (textarea, optional)
   - Placeholder: "Special requirements, what to avoid, specific terminology to use..."
   - Max: 500 characters
   - Note: This field allows free-form instructions that will be included in the AI prompt

**UI Flow:**
1. User clicks "Generate New Poll"
2. Modal opens with 6-field form (topic, tone, questions count, audience, context, instructions)
3. User fills required fields (topic, tone, questions, audience) and optionally adds context/instructions
4. User clicks "Generate"
5. Show loading state with spinner
6. On success: Display generated poll for review
7. Review screen: Show generated statements with option to "Accept" or "Regenerate"
8. On accept: Save poll and close modal
9. On error: Show error message, allow retry

#### API Integration
**New composable:** `frontend/src/composables/useAIPollGenerator.js`
- `generatePoll(formData)` - POST to `/api/generate-poll`
- Handle loading state
- Handle errors

### 2. Backend Changes

#### Dependencies
**Update:** `server/Gemfile`
```ruby
gem 'ruby_llm', '~> 0.1.0'  # Check latest version
gem 'dotenv', '~> 2.8'      # For API key management
```

#### Environment Configuration
**Create:** `server/.env` (gitignored)
```
OPENAI_API_KEY=sk-...
```

**Update:** `server/.gitignore`
```
.env
```

#### New Endpoint
**Location:** `server/app.rb`

**Route:** `POST /api/generate-poll`

**Request Body:**
```json
{
  "topic": "Remote work policies",
  "tone": "professional",
  "num_questions": 5,
  "audience": "Corporate employees",
  "additional_context": "Focus on work-life balance",
  "additional_instructions": "Avoid questions about productivity tracking. Use inclusive language."
}
```

**Response Body (Success):**
```json
{
  "status": "ok",
  "poll": {
    "title": "Remote Work Policy Survey",
    "statements": [
      {
        "id": "s1",
        "text": "Remote work improves work-life balance"
      },
      {
        "id": "s2",
        "text": "..."
      }
    ]
  },
  "metadata": {
    "generated_at": "2026-03-10T20:15:00Z",
    "model": "gpt-4",
    "prompt_tokens": 150,
    "completion_tokens": 200
  }
}
```

**Error Response:**
```json
{
  "status": "error",
  "error": "Failed to generate poll",
  "details": "API rate limit exceeded"
}
```

#### AI Service Module
**Create:** `server/lib/poll_generator.rb`

**Responsibilities:**
1. Build prompt from form data
2. Call OpenAI via ruby_llm
3. Parse JSON response
4. Validate response format
5. Generate statement IDs

**Prompt Engineering:**
```
System prompt:
You are an expert survey designer. Create engaging, unbiased poll statements
that measure opinions effectively.

User prompt template:
Generate a poll about: {topic}
Tone: {tone}
Number of statements: {num_questions}
Target audience: {audience}
Focus areas: {additional_context}
Special instructions: {additional_instructions}

Requirements:
- Statements should be clear and concise (max 120 characters)
- Cover different aspects of the topic
- Avoid leading or biased language
- Use language appropriate for {tone} tone
- Consider the target audience: {audience}
- Follow any special instructions provided
- Format as JSON with title and statements array

Response format:
{
  "title": "Poll Title (max 50 chars)",
  "statements": [
    { "text": "Statement text here" },
    ...
  ]
}
```

### 3. File Structure

```
poll-app/
├── frontend/
│   ├── src/
│   │   ├── components/
│   │   │   └── PollGeneratorModal.vue    [NEW]
│   │   ├── composables/
│   │   │   └── useAIPollGenerator.js     [NEW]
│   │   └── views/
│   │       └── AdminView.vue             [MODIFIED]
│   └── ...
├── server/
│   ├── lib/
│   │   └── poll_generator.rb             [NEW]
│   ├── .env                              [NEW, GITIGNORED]
│   ├── .gitignore                        [MODIFIED]
│   ├── Gemfile                           [MODIFIED]
│   ├── app.rb                            [MODIFIED]
│   └── ...
└── AI_POLL_GENERATION_PLAN.md            [THIS FILE]
```

### 4. Implementation Steps

#### Phase 1: Backend Setup
1. ✅ Add ruby_llm and dotenv to Gemfile
2. ✅ Run `bundle install`
3. ✅ Create `.env` file with OPENAI_API_KEY
4. ✅ Update `.gitignore`
5. ✅ Create `lib/poll_generator.rb` module
6. ✅ Test prompt and response parsing in console
7. ✅ Add `/api/generate-poll` endpoint in app.rb
8. ✅ Test endpoint with curl/Postman

#### Phase 2: Frontend - Modal Component
1. ✅ Create PollGeneratorModal.vue
2. ✅ Design form with all 6 fields (topic, tone, questions, audience, context, instructions)
3. ✅ Add form validation (required fields + max lengths)
4. ✅ Style with existing design system (glass-card, etc.)
5. ✅ Add loading/error states

#### Phase 3: Frontend - Integration
1. ✅ Create useAIPollGenerator.js composable
2. ✅ Add "Generate New Poll" button to AdminView
3. ✅ Wire up modal open/close
4. ✅ Connect form submission to API
5. ✅ Implement review screen
6. ✅ Handle poll acceptance (save to file or database)

#### Phase 4: Polish & Testing
1. ✅ Add loading animations
2. ✅ Improve error messages
3. ✅ Test with various inputs
4. ✅ Test edge cases (API failures, malformed responses)
5. ✅ Add rate limiting protection
6. ✅ Document usage in README

### 5. Technical Considerations

#### API Cost & Rate Limiting
- OpenAI API calls cost money
- Implement client-side debouncing (prevent spam clicks)
- Server-side rate limiting (max 10 requests/hour per session?)
- Consider caching recent generations

#### Data Persistence
Current setup uses in-memory POLL constant. Options:
1. **Keep in-memory** - Admin manually updates poll.json after generation
2. **File-based** - Auto-save to poll.json (requires restart)
3. **Database** - Future enhancement for multiple polls

**Recommendation:** Start with option 1 (review before saving)

#### Error Handling
- API key missing/invalid
- Network timeouts
- Rate limits
- Invalid JSON responses
- Malformed content

#### Security
- Validate/sanitize all form inputs
- Don't log API keys
- Limit prompt length to prevent injection
- CORS already configured

### 6. ruby_llm Integration

**Basic Usage:**
```ruby
require 'ruby_llm'

# Configure
RubyLLM.configure do |config|
  config.openai_api_key = ENV['OPENAI_API_KEY']
end

# Generate
response = RubyLLM.chat(
  model: 'gpt-4',
  messages: [
    { role: 'system', content: system_prompt },
    { role: 'user', content: user_prompt }
  ],
  temperature: 0.7,
  response_format: { type: 'json_object' }
)

# Parse
poll_data = JSON.parse(response.content)
```

### 7. Future Enhancements

- **Multiple poll management** - Store and switch between different polls
- **Poll editing** - Allow manual tweaking of generated statements
- **Statement bank** - Save good statements for reuse
- **A/B testing** - Generate multiple versions
- **Multi-language support** - Generate polls in different languages
- **Export/Import** - Share poll configurations

### 8. Testing Plan

#### Manual Testing
- [ ] Generate poll with valid inputs
- [ ] Test all tone options
- [ ] Test min/max question counts
- [ ] Test with empty/invalid inputs
- [ ] Test API key missing
- [ ] Test network errors
- [ ] Test malformed API responses

#### Edge Cases
- [ ] Very long topic (200+ chars)
- [ ] Special characters in inputs
- [ ] Rapid consecutive requests
- [ ] Browser offline
- [ ] API timeout

### 9. UX Considerations

**Loading States:**
- Show progress message: "Generating poll with AI..."
- Estimate: ~3-5 seconds for generation
- Allow cancellation?

**Review Screen:**
- Show generated title prominently
- List all statements with numbers
- Highlight if any statement seems problematic
- "Regenerate" button for retry
- "Accept & Use" to save

**Error Messages:**
- User-friendly, actionable
- "Failed to generate poll. Please check your internet connection and try again."
- "API quota exceeded. Please try again later."

### 10. Rollout Strategy

1. **Development:** Build and test locally
2. **Alpha:** Share with small group for feedback
3. **Beta:** Enable for admin users only
4. **Production:** Document and announce feature

---

## Timeline Estimate

- **Phase 1 (Backend):** 2-3 hours
- **Phase 2 (Frontend Modal):** 2-3 hours  
- **Phase 3 (Integration):** 1-2 hours
- **Phase 4 (Polish):** 1-2 hours

**Total:** 6-10 hours development time

---

## Questions to Resolve

1. Should generated polls replace current poll immediately or require manual activation?
2. Do we want to keep a history of generated polls?
3. Should we allow editing generated statements before acceptance?
4. What's the max API cost budget (OpenAI charges per token)?
5. Do we need admin authentication before allowing generation?

---

## Notes

- Keep the existing manual poll.json editing workflow as backup
- Consider starting with GPT-3.5-turbo (cheaper) before GPT-4
- The ruby_llm library abstracts provider details - could switch to Claude/etc later
- Ensure .env is in .gitignore to avoid committing API key
