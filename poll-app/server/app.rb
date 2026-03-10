require 'sinatra'
require 'sinatra/cors'
require 'json'
require 'securerandom'
require 'faye/websocket'
require 'socket'

# Configuration
set :bind, '0.0.0.0'
set :port, 4567
set :public_folder, File.join(File.dirname(__FILE__), '..', 'frontend', 'dist')
set :allow_origin, '*'
set :allow_methods, 'GET,POST,OPTIONS'
set :allow_headers, 'content-type'

# Prevent caching of HTML pages (fixes mobile Safari refresh issues)
before do
  if request.path == '/' || request.path == '/admin' || request.path.end_with?('.html')
    cache_control :no_cache, :no_store, :must_revalidate
    headers['Pragma'] = 'no-cache'
    headers['Expires'] = '0'
  end
end

# WebSocket clients - store as hash with role
# { ws => { role: 'admin' | 'participant' } }
CLIENTS = {}

# In-memory vote storage
VOTES = {}

# Load poll data
def load_poll
  poll_file = File.join(File.dirname(__FILE__), 'poll.json')
  JSON.parse(File.read(poll_file))
end

# Calculate results
def calculate_results
  poll = load_poll
  results = {}
  
  poll['statements'].each do |statement|
    sid = statement['id']
    results[sid] = {
      'strongly_agree' => 0,
      'agree' => 0,
      'disagree' => 0,
      'strongly_disagree' => 0
    }
  end
  
  VOTES.each do |participant_id, participant_votes|
    participant_votes.each do |statement_id, vote|
      results[statement_id][vote] += 1 if results[statement_id]
    end
  end
  
  results
end

# Get local IP address
def local_ip
  Socket.ip_address_list.detect { |intf| 
    intf.ipv4? && !intf.ipv4_loopback? && !intf.ipv4_multicast? 
  }&.ip_address || '127.0.0.1'
end

# Broadcast results to admin clients only
def broadcast_results
  results = calculate_results
  participant_count = VOTES.keys.length
  connected_clients = CLIENTS.length
  admin_clients = CLIENTS.select { |_, info| info[:role] == 'admin' }
  
  message = {
    type: 'results_update',
    data: {
      results: results,
      participant_count: participant_count,
      connected_clients: connected_clients,
      timestamp: Time.now.utc.iso8601
    }
  }.to_json
  
  puts "[BROADCAST] Sending to #{admin_clients.length} admin clients (#{connected_clients} total)"
  
  admin_clients.each do |client, _|
    begin
      client.send(message)
    rescue => e
      puts "[WS] Error sending to client: #{e.message}"
    end
  end
end

# Broadcast reset to all clients (participants and admins)
def broadcast_reset
  puts "[BROADCAST] Sending reset to all #{CLIENTS.length} clients"
  
  message = {
    type: 'reset',
    data: {
      timestamp: Time.now.utc.iso8601
    }
  }.to_json
  
  CLIENTS.each do |client, info|
    begin
      client.send(message)
      puts "[BROADCAST] Sent reset to #{info[:role]} client"
    rescue => e
      puts "[WS] Error sending reset to client: #{e.message}"
    end
  end
end

# WebSocket endpoint
# Query param: ?role=admin for admin panels
get '/ws' do
  if Faye::WebSocket.websocket?(request.env)
    role = params[:role] == 'admin' ? 'admin' : 'participant'
    
    # Ping every second to force socket buffer flushes
    # This prevents buffering delays in WebSocket message delivery
    ws = Faye::WebSocket.new(request.env, nil, { ping: 1 })

    ws.on :open do |event|
      CLIENTS[ws] = { role: role }
      admin_count = CLIENTS.count { |_, info| info[:role] == 'admin' }
      puts "[WS] #{role.upcase} connected. Total: #{CLIENTS.length} (#{admin_count} admins)"
      
      # Send initial data to the new client
      ws.send({
        type: 'init',
        data: {
          results: calculate_results,
          participant_count: VOTES.keys.length,
          connected_clients: CLIENTS.length
        }
      }.to_json)
      
      # Broadcast updated count to admin clients
      broadcast_results
    end

    ws.on :close do |event|
      role = CLIENTS[ws]&.dig(:role) || 'unknown'
      CLIENTS.delete(ws)
      admin_count = CLIENTS.count { |_, info| info[:role] == 'admin' }
      puts "[WS] #{role.upcase} disconnected. Total: #{CLIENTS.length} (#{admin_count} admins)"
      
      # Broadcast updated count to remaining admin clients
      broadcast_results
    end
    
    ws.on :error do |event|
      puts "[WS] Error: #{event.message}"
    end

    # Return async Rack response
    ws.rack_response
  else
    status 400
    "WebSocket connection required"
  end
end

# API Routes

# Get poll definition
get '/api/poll' do
  content_type :json
  load_poll.to_json
end

# Submit vote
post '/api/vote' do
  content_type :json
  
  data = JSON.parse(request.body.read)
  participant_id = data['participant_id']
  statement_id = data['statement_id']
  vote = data['vote']
  
  # Validate vote value
  valid_votes = %w[strongly_agree agree disagree strongly_disagree]
  unless valid_votes.include?(vote)
    halt 400, { error: 'Invalid vote value' }.to_json
  end
  
  # Store vote
  VOTES[participant_id] ||= {}
  VOTES[participant_id][statement_id] = vote
  
  puts "[VOTE] #{participant_id[0..7]}... -> #{statement_id}: #{vote}"
  
  # Broadcast updated results
  broadcast_results
  
  { status: 'ok', timestamp: Time.now.utc.iso8601 }.to_json
end

# Get results
get '/api/results' do
  content_type :json
  {
    results: calculate_results,
    participant_count: VOTES.keys.length,
    timestamp: Time.now.utc.iso8601
  }.to_json
end

# Get server info (for admin dashboard)
get '/api/info' do
  content_type :json
  {
    ip: local_ip,
    port: settings.port,
    url: "http://#{local_ip}:#{settings.port}",
    participant_count: VOTES.keys.length,
    connected_clients: CLIENTS.length
  }.to_json
end

# Export results as CSV
get '/api/export' do
  content_type 'text/csv'
  attachment 'poll_results.csv'
  
  poll = load_poll
  results = calculate_results
  
  csv = "Statement,Strongly Agree,Agree,Disagree,Strongly Disagree,Total\n"
  
  poll['statements'].each do |statement|
    sid = statement['id']
    r = results[sid]
    total = r.values.sum
    csv += "\"#{statement['text']}\",#{r['strongly_agree']},#{r['agree']},#{r['disagree']},#{r['strongly_disagree']},#{total}\n"
  end
  
  csv
end

# Client logging (admin only)
post '/api/log' do
  content_type :json
  
  begin
    payload = JSON.parse(request.body.read)
    level = payload['level'] || 'INFO'
    message = payload['message'] || ''
    data = payload['data']
    
    # Handle batched logs
    if data && data['logs'].is_a?(Array)
      puts "\n[CLIENT #{level}] #{message} ====="
      data['logs'].each_with_index do |log_entry, idx|
        log_msg = log_entry['message'] || ''
        log_data = log_entry['data']
        client_time = log_entry['timestamp'] || ''
        
        # Extract just the time portion for readability
        time_display = client_time.split('T').last&.sub('Z', '') || client_time
        
        log_line = "  #{idx + 1}. [CLIENT@#{time_display}] #{log_msg}"
        log_line += " | #{log_data.to_json}" if log_data
        puts log_line
      end
      puts "===== End batch\n"
    else
      # Single log entry (legacy, shouldn't happen with batching)
      log_line = "[CLIENT:#{level}] #{message}"
      log_line += " | #{data.to_json}" if data
      puts log_line
    end
    
    { status: 'ok' }.to_json
  rescue => e
    puts "[LOG ERROR] Failed to process client log: #{e.message}"
    { status: 'error', message: e.message }.to_json
  end
end

# Reset votes (admin only)
post '/api/reset' do
  content_type :json
  VOTES.clear
  
  # First send reset to all clients
  broadcast_reset
  
  # Then update admin dashboards with fresh results
  broadcast_results
  
  { status: 'ok', message: 'All votes cleared' }.to_json
end

# Serve frontend (catch-all for SPA routing)
get '/*' do
  if request.path.start_with?('/api')
    halt 404, { error: 'Not found' }.to_json
  end
  
  index_path = File.join(settings.public_folder, 'index.html')
  if File.exist?(index_path)
    send_file index_path
  else
    "Frontend not built. Run 'npm run build' in the frontend directory."
  end
end
