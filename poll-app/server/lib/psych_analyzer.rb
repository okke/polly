require 'openai'

# Service for generating humorous psychological analysis based on poll responses
class PsychAnalyzer
  def initialize
    api_key = ENV['OPENAI_API_KEY']
    raise 'OPENAI_API_KEY not configured' if api_key.nil? || api_key.empty?
    
    @client = OpenAI::Client.new(access_token: api_key)
  end
  
  # Analyze user's responses and generate a humorous psychological profile
  # @param poll_data [Hash] The poll with title and statements
  # @param votes [Hash] The user's votes (statement_id => vote_value)
  # @return [String] The analysis text
  def analyze(poll_data, votes)
    # Get the best available model (premium tier)
    model = get_best_model
    
    puts "[PSYCH ANALYZER] Using model: #{model}"
    puts "[PSYCH ANALYZER] Analyzing #{votes.length} responses"
    
    # Extract context if available
    context = poll_data['context'] || {}
    
    # Build the prompt
    system_prompt = build_system_prompt(context)
    user_prompt = build_user_prompt(poll_data, votes, context)
    
    # Prepare parameters for OpenAI API
    # Newer models use max_completion_tokens, older use max_tokens
    api_params = {
      model: model,
      messages: [
        { role: 'system', content: system_prompt },
        { role: 'user', content: user_prompt }
      ],
      temperature: 1.2 # High creativity for humor
    }
    
    # Use max_completion_tokens for newer models, max_tokens for older
    # Keep it short and punchy
    if model.match?(/gpt-5|gpt-4\.1/)
      api_params[:max_completion_tokens] = 300
    else
      api_params[:max_tokens] = 300
    end
    
    # Call OpenAI with error handling
    begin
      response = @client.chat(parameters: api_params)
    rescue OpenAI::Error => api_error
      puts "[PSYCH ANALYZER] OpenAI API Error: #{api_error.message}"
      # Try fallback model if the selected one fails
      if model != 'gpt-4o'
        puts "[PSYCH ANALYZER] Retrying with fallback model: gpt-4o"
        model = 'gpt-4o'
        
        # Rebuild params for fallback model
        fallback_params = {
          model: model,
          messages: [
            { role: 'system', content: system_prompt },
            { role: 'user', content: user_prompt }
          ],
          temperature: 1.2,
          max_completion_tokens: 300
        }
        
        response = @client.chat(parameters: fallback_params)
      else
        raise api_error
      end
    end
    
    puts "[PSYCH ANALYZER] Response received: #{response.class}"
    puts "[PSYCH ANALYZER] Response keys: #{response.keys.inspect}" if response.respond_to?(:keys)
    
    analysis = response.dig('choices', 0, 'message', 'content')
    
    if analysis.nil? || analysis.empty?
      puts "[PSYCH ANALYZER] ERROR: No content in response"
      puts "[PSYCH ANALYZER] Full response: #{response.inspect}"
      raise "No content in OpenAI response"
    end
    
    puts "[PSYCH ANALYZER] Generated analysis: #{analysis.length} chars"
    
    analysis
  rescue => e
    puts "[PSYCH ANALYZER] Error: #{e.message}"
    puts "[PSYCH ANALYZER] Backtrace: #{e.backtrace.first(5).join("\n")}"
    
    # Fallback to a generic message
    generate_fallback_analysis(votes)
  end
  
  private
  
  def get_best_model
    # Get available models and pick the premium one
    models = ModelDiscoveryService.list
    
    # Find premium tier model (should be gpt-5.x or similar)
    premium = models.find { |m| m[:pricing_tier] == :premium }
    
    # Fallback chain: premium -> standard -> budget -> hardcoded
    model = if premium && premium[:id]
      premium[:id]
    elsif (standard = models.find { |m| m[:pricing_tier] == :standard })
      standard[:id]
    elsif models.first
      models.first[:id]
    else
      # Ultimate fallback to a known working model
      'gpt-4o'
    end
    
    puts "[PSYCH ANALYZER] Selected model: #{model}"
    model
  end
  
  def build_system_prompt(context)
    topic = context[:topic] || context['topic'] || 'various topics'
    audience = context[:audience] || context['audience'] || 'people'
    
    <<~PROMPT
      You are a brilliant but slightly arrogant subject matter expert on #{topic}, known for your razor-sharp insights and brutally honest assessments.
      
      Your audience context: #{audience}
      
      Analyze their survey responses with a tone that is:
      - DIRECT and CONFRONTING: Call out contradictions, questionable positions, or predictable thinking
      - OVERDRAMATIC: Exaggerate their tendencies ("Oh darling, this is TEXTBOOK X behavior")
      - SNOBBY yet COMPOSED: Maintain an air of intellectual superiority while staying calm and articulate
      - WITTY and SHARP: Make clever observations that cut to the truth
      
      Format requirements:
      - Start with a profile label using **Label** (e.g., "**The Enlightened Contrarian**" or "**The Predictably Safe Thinker**")
      - Keep it SHORT: 1-2 punchy paragraphs (80-120 words max)
      - Write in second person ("you")
      - Be entertainingly harsh but not actually mean
      - Focus on their stance within #{topic}, not generic psychology
      
      Think of yourself as a brilliant, slightly insufferable expert who's amused by their responses.
      Be memorable. Be bold. Make them feel something.
    PROMPT
  end
  
  def build_user_prompt(poll_data, votes, context)
    # Format the poll and responses for analysis
    prompt = "Poll: #{poll_data['title']}\n\n"
    
    # Add context if available
    if context && !context.empty?
      prompt += "Context:\n"
      prompt += "- Topic: #{context[:topic] || context['topic']}\n" if context[:topic] || context['topic']
      prompt += "- Audience: #{context[:audience] || context['audience']}\n" if context[:audience] || context['audience']
      if context[:additional_context] || context['additional_context']
        prompt += "- Background: #{context[:additional_context] || context['additional_context']}\n"
      end
      prompt += "\n"
    end
    
    prompt += "Here are the person's responses:\n\n"
    
    poll_data['statements'].each do |statement|
      statement_id = statement['id']
      vote = votes[statement_id]
      
      next unless vote
      
      # Convert vote to readable format
      vote_text = case vote
      when 'strongly_agree' then 'Strongly Agree'
      when 'agree' then 'Agree'
      when 'disagree' then 'Disagree'
      when 'strongly_disagree' then 'Strongly Disagree'
      else vote
      end
      
      prompt += "Statement: \"#{statement['text']}\"\n"
      prompt += "Response: #{vote_text}\n\n"
    end
    
    prompt += "Now analyze them. Be sharp, be dramatic, be confronting. Make them feel seen (and maybe a little called out). Keep it under 120 words."
    
    prompt
  end
  
  def generate_fallback_analysis(votes)
    # Generate a simple fallback if the API fails
    total = votes.length
    agrees = votes.values.count { |v| v.include?('agree') }
    disagrees = votes.values.count { |v| v.include?('disagree') }
    
    if agrees > disagrees
      "**The Agreeable Optimist**\n\nYou seem to have a sunny disposition! You're the type who sees the glass as half-full, even when it's clearly just a puddle. Your tendency to agree with things suggests you're either very open-minded or you just really don't like conflict. We're going with open-minded.\n\nIn social situations, you're probably the peacemaker, nodding along to keep things smooth. Just remember: it's okay to disagree sometimes. The world needs your unique spice!"
    elsif disagrees > agrees
      "**The Skeptical Contrarian**\n\nWell, well, well... if it isn't someone who questions everything! You're like that person at a party who says \"actually...\" a lot. But you know what? The world needs critical thinkers like you to keep everyone honest.\n\nYou march to the beat of your own drum, even if that drum is playing jazz while everyone else is doing the cha-cha. Keep that independent streak, just maybe soften it with a smile occasionally!"
    else
      "**The Perfectly Balanced Enigma**\n\nYou're so balanced, you could be a yoga instructor. Half agree, half disagree – you're like a human diplomatic scale. Either you're remarkably thoughtful and nuanced, or you're indecisive. Let's go with thoughtful.\n\nYou see both sides of every issue, which makes you excellent at understanding different perspectives. Just don't get stuck in analysis paralysis. Sometimes you just gotta pick a side and go with it!"
    end
  end
end
