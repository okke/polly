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

# WebSocket clients
CLIENTS = []

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

# Broadcast results to all connected clients
def broadcast_results
  results = calculate_results
  participant_count = VOTES.keys.length
  
  message = {
    type: 'results_update',
    data: {
      results: results,
      participant_count: participant_count,
      timestamp: Time.now.utc.iso8601
    }
  }.to_json
  
  CLIENTS.each do |client|
    client.send(message)
  end
end

# WebSocket middleware
use Rack::Config do |env|
  if Faye::WebSocket.websocket?(env)
    ws = Faye::WebSocket.new(env)

    ws.on :open do |event|
      CLIENTS << ws
      puts "[WS] Client connected. Total: #{CLIENTS.length}"
      
      # Send initial data
      ws.send({
        type: 'init',
        data: {
          results: calculate_results,
          participant_count: VOTES.keys.length
        }
      }.to_json)
    end

    ws.on :close do |event|
      CLIENTS.delete(ws)
      puts "[WS] Client disconnected. Total: #{CLIENTS.length}"
    end

    ws.rack_response
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

# Reset votes (admin only)
post '/api/reset' do
  content_type :json
  VOTES.clear
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
