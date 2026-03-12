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
    model = params[:model] || 'gpt-4o-mini'
    
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
    response = call_openai_api(system_prompt, user_prompt, model)
    
    # Parse and validate response
    poll_data = parse_response(response)
    
    # Add statement IDs
    add_statement_ids(poll_data, num_questions)
    
    # Add generation context metadata to the poll for later use
    poll_data['context'] = {
      topic: topic,
      tone: tone,
      audience: audience,
      additional_context: additional_context,
      additional_instructions: additional_instructions
    }.compact # Remove nil values
    
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
  
  # Regenerate a poll while keeping specified statements
  def self.regenerate(params)
    poll_context = params[:poll_context] # Original generation context
    kept_statements = params[:kept_statements] || []
    total_questions = params[:total_questions] || 5
    model = params[:model] || 'gpt-4o-mini'
    
    # Validate parameters
    raise ArgumentError, 'Poll context is required' if poll_context.nil?
    raise ArgumentError, 'Total questions must be between 3 and 10' unless (3..10).include?(total_questions)
    raise ArgumentError, 'Cannot keep more statements than total questions' if kept_statements.length > total_questions
    
    # Extract context from original poll
    topic = poll_context['topic'] || poll_context[:topic]
    tone = poll_context['tone'] || poll_context[:tone] || 'professional'
    audience = poll_context['audience'] || poll_context[:audience]
    additional_context = poll_context['additional_context'] || poll_context[:additional_context]
    additional_instructions = poll_context['additional_instructions'] || poll_context[:additional_instructions]
    
    raise ArgumentError, 'Topic is required in poll context' if topic.nil? || topic.empty?
    raise ArgumentError, 'Audience is required in poll context' if audience.nil? || audience.empty?
    
    # Calculate how many new statements to generate
    num_new_statements = total_questions - kept_statements.length
    
    # Build the prompt with kept statements
    system_prompt = build_system_prompt
    user_prompt = build_regeneration_prompt(
      topic: topic,
      tone: tone,
      num_new_statements: num_new_statements,
      audience: audience,
      additional_context: additional_context,
      additional_instructions: additional_instructions,
      kept_statements: kept_statements
    )
    
    # Call OpenAI API
    response = call_openai_api(system_prompt, user_prompt, model)
    
    # Parse and validate response
    poll_data = parse_response(response)
    
    # Combine kept statements with new ones
    combined_statements = kept_statements.map { |s| { 'text' => s } } + poll_data['statements']
    
    # Ensure we have exactly the requested number
    combined_statements = combined_statements[0...total_questions]
    
    # Create final poll data
    final_poll = {
      'title' => poll_data['title'],
      'statements' => combined_statements
    }
    
    # Add statement IDs
    add_statement_ids(final_poll, total_questions)
    
    # Preserve the original context
    final_poll['context'] = {
      topic: topic,
      tone: tone,
      audience: audience,
      additional_context: additional_context,
      additional_instructions: additional_instructions
    }.compact
    
    # Return the formatted poll
    {
      status: 'ok',
      poll: final_poll,
      metadata: {
        generated_at: Time.now.utc.iso8601,
        model: response.dig('model'),
        usage: response.dig('usage'),
        kept_count: kept_statements.length,
        new_count: num_new_statements
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
      error: 'Failed to regenerate poll',
      details: e.message
    }
  end
  
  private
  
  def self.build_system_prompt
    <<~PROMPT
      You are an expert survey designer specializing in creating thought-provoking polls that spark meaningful debate and discussion.
      
      Your goal is to generate statements that:
      - Split audiences and reveal diverse perspectives
      - Challenge common assumptions and conventional thinking
      - Encourage reflection and passionate discussion
      - Avoid obvious statements that everyone would agree/disagree with
      - Are provocative but not offensive or inflammatory
      
      Technical requirements:
      - Each statement should be clear, concise, and under 120 characters
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
      - Make statements PROVOCATIVE and DIVISIVE to spark debate
      - Avoid obvious statements - aim to split the audience roughly 50/50
      - Challenge assumptions and present controversial angles
      - Each statement should make people think deeply before answering
      
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
  
  def self.build_regeneration_prompt(topic:, tone:, num_new_statements:, audience:, additional_context:, additional_instructions:, kept_statements:)
    prompt = <<~PROMPT
      Regenerate a poll with the following specifications:
      
      Topic: #{topic}
      Tone: #{tone}
      Target audience: #{audience}
    PROMPT
    
    if additional_context && !additional_context.empty?
      prompt += "\nFocus areas: #{additional_context}"
    end
    
    if additional_instructions && !additional_instructions.empty?
      prompt += "\nSpecial instructions: #{additional_instructions}"
    end
    
    # Include kept statements so AI won't generate similar ones
    if kept_statements && !kept_statements.empty?
      prompt += "\n\nThe poll already includes these statements (DO NOT generate similar statements):\n"
      kept_statements.each_with_index do |statement, idx|
        prompt += "#{idx + 1}. \"#{statement}\"\n"
      end
      prompt += "\nGenerate #{num_new_statements} NEW statements that are DIFFERENT from the ones above."
    else
      prompt += "\n\nGenerate #{num_new_statements} statements."
    end
    
    prompt += <<~PROMPT
      
      Requirements:
      - Create exactly #{num_new_statements} NEW statements
      - Each statement must be under 120 characters
      - Use #{tone} tone throughout
      - Consider the target audience: #{audience}
      - Make statements PROVOCATIVE and DIVISIVE to spark debate
      - Avoid obvious statements - aim to split the audience roughly 50/50
      - Challenge assumptions and present controversial angles
      - Each statement should make people think deeply before answering
      - IMPORTANT: Do NOT create statements similar to the existing ones listed above
      
      Respond with ONLY a JSON object with a title and the NEW statements in this exact format:
      {
        "title": "Poll Title (max 50 characters)",
        "statements": [
          { "text": "First NEW statement text" },
          { "text": "Second NEW statement text" }
        ]
      }
      
      Do not include any text before or after the JSON object.
    PROMPT
    
    prompt
  end
  
  def self.call_openai_api(system_prompt, user_prompt, model = 'gpt-4o-mini')
    api_key = ENV['OPENAI_API_KEY']
    raise 'OPENAI_API_KEY not configured' if api_key.nil? || api_key.empty? || api_key == 'your_openai_api_key_here'
    
    client = OpenAI::Client.new(access_token: api_key)
    
    puts "[POLL GEN] Calling OpenAI with model: #{model}"
    
    # JSON mode is only supported by certain models
    # gpt-4-turbo, gpt-4o, gpt-3.5-turbo-1106+, gpt-4-1106-preview+
    supports_json_mode = model.include?('turbo') || 
                         model.include?('4o') || 
                         model.include?('1106') ||
                         model.include?('gpt-5')
    
    parameters = {
      model: model,
      messages: [
        { role: 'system', content: system_prompt },
        { role: 'user', content: user_prompt }
      ],
      temperature: 1.0
    }
    
    # Only add response_format for models that support it
    if supports_json_mode
      parameters[:response_format] = { type: 'json_object' }
      puts "[POLL GEN] Using JSON mode"
    else
      puts "[POLL GEN] JSON mode not supported for #{model}, using regular mode"
    end
    
    response = client.chat(parameters: parameters)
    
    puts "[POLL GEN] Response received: #{response.class}"
    response
  end
  
  def self.parse_response(response)
    # Debug logging
    puts "[POLL GEN] Response keys: #{response.keys.inspect}"
    puts "[POLL GEN] Response: #{response.inspect[0..500]}"
    
    content = response.dig('choices', 0, 'message', 'content')
    
    if content.nil? || content.empty?
      # Check if there's an error in the response
      if response['error']
        raise "OpenAI API Error: #{response['error']['message']}"
      end
      
      puts "[POLL GEN] ERROR - Response structure: #{response.inspect}"
      raise 'No content in API response'
    end
    
    puts "[POLL GEN] Content received (first 200 chars): #{content[0..200]}"
    
    # Strip markdown code blocks if present (for models without JSON mode)
    cleaned_content = content.strip
    if cleaned_content.start_with?('```json') || cleaned_content.start_with?('```')
      cleaned_content = cleaned_content.gsub(/^```json?\n?/, '').gsub(/\n?```$/, '').strip
      puts "[POLL GEN] Stripped markdown code blocks"
    end
    
    poll_data = JSON.parse(cleaned_content)
    
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
