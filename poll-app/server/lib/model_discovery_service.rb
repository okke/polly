require 'openai'
require 'ruby_llm'

# Service for discovering available OpenAI models
# Implements server-side caching and metadata enrichment from RubyLLM
class ModelDiscoveryService
  CACHE_TTL = 900 # 15 minutes
  
  # In-memory cache since we don't have Redis in this simple app
  @@cache = nil
  @@cache_timestamp = nil
  
  # Discover and return available OpenAI models with metadata
  def self.list
    # Check cache
    if cache_valid?
      puts "[MODEL DISCOVERY] Returning cached models"
      return @@cache
    end
    
    # Fetch fresh data
    puts "[MODEL DISCOVERY] Fetching models from OpenAI API"
    models = fetch_models
    
    # Update cache
    @@cache = models
    @@cache_timestamp = Time.now
    
    models
  rescue => e
    puts "[MODEL DISCOVERY] Error: #{e.message}"
    
    # Return stale cache if available
    if @@cache
      puts "[MODEL DISCOVERY] Returning stale cache due to error"
      return @@cache
    end
    
    # Fallback to hardcoded models
    fallback_models
  end
  
  private
  
  def self.cache_valid?
    return false unless @@cache && @@cache_timestamp
    
    age = Time.now - @@cache_timestamp
    age < CACHE_TTL
  end
  
  def self.fetch_models
    api_key = ENV['OPENAI_API_KEY']
    raise 'OPENAI_API_KEY not configured' if api_key.nil? || api_key.empty? || api_key == 'your_openai_api_key_here'
    
    client = OpenAI::Client.new(access_token: api_key)
    
    # Fetch models from OpenAI
    response = client.models.list
    all_models = response['data']
    
    puts "[MODEL DISCOVERY] Fetched #{all_models.length} total models from OpenAI"
    
    # Filter to OpenAI models (owned by: openai, system, or openai-internal)
    # These are all legitimate OpenAI models vs. fine-tuned or organization-specific models
    openai_owners = ['openai', 'system', 'openai-internal']
    openai_models = all_models.select { |m| openai_owners.include?(m['owned_by']) }
    
    non_openai = all_models.reject { |m| openai_owners.include?(m['owned_by']) }
    if non_openai.any?
      puts "[MODEL DISCOVERY] Filtered out #{non_openai.length} non-OpenAI models (fine-tuned/custom):"
      non_openai.each { |m| puts "  - #{m['id']} (owned by: #{m['owned_by']})" }
    end
    
    puts "[MODEL DISCOVERY] #{openai_models.length} OpenAI models found:"
    # Group by owner for cleaner logging
    owner_groups = openai_models.group_by { |m| m['owned_by'] }
    owner_groups.each do |owner, models|
      puts "  [#{owner}] #{models.length} models:"
      models.each { |m| puts "    - #{m['id']}" }
    end
    
    # Get RubyLLM registry for metadata enrichment
    registry = get_rubyllm_registry
    
    # Enrich with metadata and filter for chat models only
    enriched = openai_models.map do |model|
      model_id = model['id']
      metadata = registry[model_id]
      
      {
        id: model_id,
        name: format_model_name(model_id),
        family: metadata&.dig(:family),
        context_window: metadata&.dig(:context_window),
        pricing_tier: infer_pricing_tier(model_id),
        created: model['created']
      }
    end
    
    # Filter and sort
    chat_models = enriched.select { |m| is_chat_model?(m[:id]) }
    non_chat = enriched.reject { |m| is_chat_model?(m[:id]) }
    
    if non_chat.any?
      puts "[MODEL DISCOVERY] Filtered out #{non_chat.length} non-chat models:"
      non_chat.each { |m| puts "  - #{m[:id]}" }
    end
    
    # Keep only latest versions of each model family
    deduplicated = deduplicate_models(chat_models)
    
    # Keep only the latest model from each pricing tier
    latest_per_tier = keep_latest_per_tier(deduplicated)
    
    sorted_models = sort_models(latest_per_tier)
    
    puts "[MODEL DISCOVERY] Final #{sorted_models.length} chat models (sorted):"
    sorted_models.each_with_index do |m, i| 
      tier_emoji = { premium: '💎', standard: '⭐', budget: '💚' }[m[:pricing_tier]] || '📦'
      puts "  #{i + 1}. #{tier_emoji} #{m[:id]} (#{m[:name]})"
    end
    
    sorted_models
  end
  
  def self.get_rubyllm_registry
    # Get OpenAI models from RubyLLM registry
    registry = {}
    
    begin
      openai_registry_models = RubyLLM.models.select { |m| m.provider == :openai }
      puts "[MODEL DISCOVERY] RubyLLM registry has #{openai_registry_models.length} OpenAI models"
      
      openai_registry_models.each do |model|
        registry[model.id] = {
          family: model.family,
          context_window: model.context_window
        }
        puts "  - #{model.id}: family=#{model.family}, context=#{model.context_window}"
      end
    rescue => e
      puts "[MODEL DISCOVERY] RubyLLM registry unavailable: #{e.message}"
    end
    
    if registry.empty?
      puts "[MODEL DISCOVERY] No metadata available from RubyLLM"
    end
    
    registry
  end
  
  def self.is_chat_model?(model_id)
    # Only include GPT chat models
    # Exclude specialized/non-chat models
    return false unless model_id.start_with?('gpt-')
    
    # Exclude non-chat models
    excluded_patterns = [
      'instruct',    # Instruct models
      'codex',       # Code generation
      'search',      # Search-specific
      'audio',       # Audio processing
      'realtime',    # Real-time audio
      'transcribe',  # Transcription
      'tts',         # Text-to-speech
      'image',       # Image generation
      'diarize'      # Speaker diarization
    ]
    
    excluded_patterns.none? { |pattern| model_id.include?(pattern) }
  end
  
  def self.deduplicate_models(models)
    # Group by base model family (e.g., gpt-5, gpt-5-mini, gpt-4o-mini)
    # Keep only the latest version of each
    
    grouped = models.group_by { |m| extract_model_family(m[:id]) }
    
    deduped = grouped.map do |family, family_models|
      # Sort by specificity - prefer dated versions, then -latest, then base
      sorted = family_models.sort_by do |m|
        id = m[:id]
        
        # Prefer specific dates (2026-03-05) over -latest over base model
        if id.match?(/\d{4}-\d{2}-\d{2}/)
          date_str = id.match(/(\d{4}-\d{2}-\d{2})/)[1]
          [0, date_str] # Highest priority
        elsif id.include?('-latest')
          [1, id] # Second priority
        else
          [2, id] # Keep base models last
        end
      end.reverse # Reverse to get newest first
      
      kept = sorted.first
      
      if family_models.length > 1
        puts "[MODEL DISCOVERY] Keeping #{kept[:id]} from #{family} family (#{family_models.length} versions)"
        family_models.reject { |m| m[:id] == kept[:id] }.each do |m|
          puts "  - Skipped: #{m[:id]}"
        end
      end
      
      kept
    end
    
    deduped
  end
  
  def self.extract_model_family(model_id)
    # Extract base family name
    # gpt-5-2025-08-07 -> gpt-5
    # gpt-5-mini-2025-08-07 -> gpt-5-mini
    # gpt-4o-mini -> gpt-4o-mini
    # gpt-5.4-pro-2026-03-05 -> gpt-5.4-pro
    
    parts = model_id.split('-')
    
    # Start with gpt-X or gpt-X.Y
    base = [parts[0], parts[1]].join('-')
    
    # Add variant if it's mini/pro/nano/turbo (not dates or -latest)
    if parts[2] && !parts[2].match?(/\d{4}/) && parts[2] != 'latest' && parts[2] != 'preview'
      base += "-#{parts[2]}"
    end
    
    base
  end
  
  def self.keep_latest_per_tier(models)
    # Group by pricing tier and keep only the latest model from each
    grouped = models.group_by { |m| m[:pricing_tier] }
    
    latest_models = grouped.map do |tier, tier_models|
      # Sort by generation/version to find the latest
      sorted = tier_models.sort_by do |m|
        id = m[:id]
        
        # Extract generation - higher is better
        generation = if id.match(/gpt-(\d+\.?\d*)/)
          id.match(/gpt-(\d+\.?\d*)/)[1].to_f
        else
          0.0
        end
        
        # Prefer models with dates or -latest suffix
        has_date = id.match?(/\d{4}-\d{2}-\d{2}/) ? 1 : 0
        is_latest = id.include?('-latest') ? 1 : 0
        
        # Sort: higher generation first, then dated, then -latest
        [-generation, -has_date, -is_latest]
      end
      
      kept = sorted.first
      
      puts "[MODEL DISCOVERY] Keeping only latest #{tier} model: #{kept[:id]} (from #{tier_models.length} options)"
      tier_models.reject { |m| m[:id] == kept[:id] }.each do |m|
        puts "  - Excluded: #{m[:id]}"
      end
      
      kept
    end
    
    latest_models
  end
  
  def self.format_model_name(model_id)
    # Convert model ID to display name
    # gpt-5 -> GPT-5
    # gpt-5-mini -> GPT-5 Mini
    # gpt-4o -> GPT-4o
    
    parts = model_id.split('-')
    return model_id unless parts[0] == 'gpt'
    
    name_parts = []
    name_parts << 'GPT'
    name_parts << parts[1].upcase if parts[1]
    
    # Handle suffixes
    if parts[2]
      suffix = parts[2]
      name_parts << (suffix == 'mini' ? 'Mini' : suffix)
    end
    
    name_parts.join('-')
  end
  
  def self.infer_pricing_tier(model_id)
    # Infer pricing tier based on model ID patterns
    return :premium if model_id.include?('gpt-5') && !model_id.include?('mini')
    return :budget if model_id.include?('mini')
    return :standard
  end
  
  def self.sort_models(models)
    # Sort by: 
    # 1. Generation (5 > 4)
    # 2. Within generation: full models before mini
    # 3. Within tier: by name
    
    models.sort_by do |m|
      id = m[:id]
      
      # Extract generation number
      generation = if id.include?('gpt-5')
        5
      elsif id.include?('gpt-4')
        4
      elsif id.include?('gpt-3')
        3
      else
        0
      end
      
      # Is it a mini variant?
      is_mini = id.include?('mini') ? 1 : 0
      
      # Put newer generations first, full models before mini within generation
      [-generation, is_mini, id]
    end
  end
  
  def self.fallback_models
    # Hardcoded fallback in case API is unavailable
    puts "[MODEL DISCOVERY] Using fallback models"
    [
      {
        id: 'gpt-5',
        name: 'GPT-5',
        family: 'gpt-5',
        context_window: 200000,
        pricing_tier: :premium,
        created: nil
      },
      {
        id: 'gpt-5-mini',
        name: 'GPT-5-Mini',
        family: 'gpt-5',
        context_window: 128000,
        pricing_tier: :budget,
        created: nil
      },
      {
        id: 'gpt-4o',
        name: 'GPT-4o',
        family: 'gpt-4',
        context_window: 128000,
        pricing_tier: :standard,
        created: nil
      }
    ]
  end
end
