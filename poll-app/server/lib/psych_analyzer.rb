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
    
    # Build the prompt
    system_prompt = build_system_prompt
    user_prompt = build_user_prompt(poll_data, votes)
    
    # Call OpenAI
    response = @client.chat(
      parameters: {
        model: model,
        messages: [
          { role: 'system', content: system_prompt },
          { role: 'user', content: user_prompt }
        ],
        temperature: 1.2, # High creativity for humor
        max_tokens: 500
      }
    )
    
    analysis = response.dig('choices', 0, 'message', 'content')
    
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
    
    if premium
      premium[:id]
    else
      # Fallback to first available model
      models.first[:id]
    end
  end
  
  def build_system_prompt
    <<~PROMPT
      You are a witty, slightly irreverent AI psychologist analyzing someone's responses to opinion poll questions.
      
      Your job is to write a brief, humorous psychological profile based on their answers. The analysis should:
      - Be 2-3 short paragraphs (150-200 words total)
      - Have a playful, tongue-in-cheek tone (think horoscope meets psychology)
      - Make amusing observations about their personality, contradictions, or patterns
      - Include a catchy "diagnosis" or "type" label (e.g., "The Cautious Optimist", "The Contrarian Diplomat")
      - Be entertaining but not mean-spirited
      - Use humor but avoid offensive stereotypes
      
      Write in second person ("you"). Start with your diagnosis/label as a bold heading.
      
      Remember: this is meant to be fun and lighthearted, not actual psychological advice!
    PROMPT
  end
  
  def build_user_prompt(poll_data, votes)
    # Format the poll and responses for analysis
    prompt = "Poll: #{poll_data['title']}\n\n"
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
    
    prompt += "Based on these responses, give me a humorous psychological analysis!"
    
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
