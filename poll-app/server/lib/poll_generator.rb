require 'openai'
require 'json'

# Service class for generating polls using OpenAI
class PollGenerator
  
  def self.generate(params)
    topic = params[:topic]
    tone = params[:tone] || 'professional'
    num_questions = params[:num_questions] || 5
    audience = params[:audience]
    additional_context = params[:additional_context]
    additional_instructions = params[:additional_instructions]
    
    # Validate required parameters
    raise ArgumentError, 'Topic is required' if topic.nil? || topic.empty?
    raise ArgumentError, 'Audience is required' if audience.nil? || audience.empty?
    raise ArgumentError, 'Number of questions must be between 3 and 10' unless (3..10).include?(num_questions)
    
    # Build the prompt
    system_prompt = build_system_prompt
    user_prompt = build_user_prompt(
      topic: topic,
      tone: tone,
      num_questions: num_questions,
      audience: audience,
      additional_context: additional_context,
      additional_instructions: additional_instructions
    )
    
    # Call OpenAI API
    response = call_openai_api(system_prompt, user_prompt)
    
    # Parse and validate response
    poll_data = parse_response(response)
    
    # Add statement IDs
    add_statement_ids(poll_data, num_questions)
    
    # Return the formatted poll
    {
      status: 'ok',
      poll: poll_data,
      metadata: {
        generated_at: Time.now.utc.iso8601,
        model: response.dig('model'),
        usage: response.dig('usage')
      }
    }
  rescue OpenAI::Error => e
    {
      status: 'error',
      error: 'OpenAI API error',
      details: e.message
    }
  rescue ArgumentError => e
    {
      status: 'error',
      error: 'Validation error',
      details: e.message
    }
  rescue => e
    {
      status: 'error',
      error: 'Failed to generate poll',
      details: e.message
    }
  end
  
  private
  
  def self.build_system_prompt
    <<~PROMPT
      You are an expert survey designer. Create engaging, unbiased poll statements that measure opinions effectively.
      
      Important guidelines:
      - Each statement should be clear, concise, and under 120 characters
      - Statements should be neutral and avoid leading language
      - Cover different aspects and perspectives of the topic
      - Use language appropriate for the specified tone and audience
      - Statements should work well with a 4-point Likert scale (Strongly Agree, Agree, Disagree, Strongly Disagree)
    PROMPT
  end
  
  def self.build_user_prompt(topic:, tone:, num_questions:, audience:, additional_context:, additional_instructions:)
    prompt = <<~PROMPT
      Generate a poll with the following specifications:
      
      Topic: #{topic}
      Tone: #{tone}
      Number of statements: #{num_questions}
      Target audience: #{audience}
    PROMPT
    
    if additional_context && !additional_context.empty?
      prompt += "\nFocus areas: #{additional_context}"
    end
    
    if additional_instructions && !additional_instructions.empty?
      prompt += "\nSpecial instructions: #{additional_instructions}"
    end
    
    prompt += <<~PROMPT
      
      Requirements:
      - Create exactly #{num_questions} statements
      - Each statement must be under 120 characters
      - Use #{tone} tone throughout
      - Consider the target audience: #{audience}
      
      Respond with ONLY a JSON object in this exact format:
      {
        "title": "Poll Title (max 50 characters)",
        "statements": [
          { "text": "First statement text" },
          { "text": "Second statement text" }
        ]
      }
      
      Do not include any text before or after the JSON object.
    PROMPT
    
    prompt
  end
  
  def self.call_openai_api(system_prompt, user_prompt)
    api_key = ENV['OPENAI_API_KEY']
    raise 'OPENAI_API_KEY not configured' if api_key.nil? || api_key.empty? || api_key == 'your_openai_api_key_here'
    
    client = OpenAI::Client.new(access_token: api_key)
    
    response = client.chat(
      parameters: {
        model: 'gpt-4o-mini', # More cost-effective than gpt-4
        messages: [
          { role: 'system', content: system_prompt },
          { role: 'user', content: user_prompt }
        ],
        temperature: 0.7,
        response_format: { type: 'json_object' }
      }
    )
    
    response
  end
  
  def self.parse_response(response)
    content = response.dig('choices', 0, 'message', 'content')
    raise 'No content in API response' if content.nil? || content.empty?
    
    poll_data = JSON.parse(content)
    
    # Validate structure
    raise 'Missing title in response' unless poll_data['title']
    raise 'Missing statements in response' unless poll_data['statements'].is_a?(Array)
    raise 'No statements generated' if poll_data['statements'].empty?
    
    # Validate statements
    poll_data['statements'].each do |statement|
      raise 'Statement missing text' unless statement['text']
      if statement['text'].length > 120
        # Truncate if too long
        statement['text'] = statement['text'][0..116] + '...'
      end
    end
    
    poll_data
  end
  
  def self.add_statement_ids(poll_data, expected_count)
    # Ensure we have exactly the requested number of statements
    if poll_data['statements'].length > expected_count
      poll_data['statements'] = poll_data['statements'][0...expected_count]
    end
    
    # Add IDs
    poll_data['statements'].each_with_index do |statement, index|
      statement['id'] = "s#{index + 1}"
    end
    
    poll_data
  end
end
