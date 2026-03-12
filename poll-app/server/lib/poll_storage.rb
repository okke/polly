require 'json'
require 'fileutils'
require 'securerandom'

# Service class for managing poll persistence using JSON files
class PollStorage
  DATA_DIR = File.join(__dir__, '..', 'data', 'polls')
  CURRENT_POLL_FILE = File.join(DATA_DIR, '.current_poll_id')
  
  def self.initialize_storage
    FileUtils.mkdir_p(DATA_DIR) unless Dir.exist?(DATA_DIR)
  end
  
  # Save a poll to a JSON file
  # Returns the poll_id
  def self.save_poll(poll_data)
    initialize_storage
    
    poll_id = poll_data[:id] || generate_poll_id
    poll_data[:id] = poll_id
    poll_data[:created_at] ||= Time.now.utc.iso8601
    poll_data[:updated_at] = Time.now.utc.iso8601
    
    file_path = poll_file_path(poll_id)
    File.write(file_path, JSON.pretty_generate(poll_data))
    
    puts "[POLL STORAGE] Saved poll: #{poll_id}"
    poll_id
  end
  
  # Update an existing poll
  def self.update_poll(poll_id, poll_data)
    poll_data[:id] = poll_id
    poll_data[:updated_at] = Time.now.utc.iso8601
    
    file_path = poll_file_path(poll_id)
    File.write(file_path, JSON.pretty_generate(poll_data))
    
    puts "[POLL STORAGE] Updated poll: #{poll_id}"
    poll_id
  end
  
  # Load a specific poll by ID
  def self.load_poll(poll_id)
    file_path = poll_file_path(poll_id)
    
    unless File.exist?(file_path)
      puts "[POLL STORAGE] Poll not found: #{poll_id}"
      return nil
    end
    
    data = JSON.parse(File.read(file_path), symbolize_names: true)
    puts "[POLL STORAGE] Loaded poll: #{poll_id}"
    data
  end
  
  # List all available polls
  def self.list_polls
    initialize_storage
    
    poll_files = Dir.glob(File.join(DATA_DIR, '*.json'))
                   .reject { |f| f.end_with?('.current_poll_id') }
    
    polls = poll_files.map do |file|
      data = JSON.parse(File.read(file), symbolize_names: true)
      {
        id: data[:id],
        title: data[:title],
        created_at: data[:created_at],
        updated_at: data[:updated_at],
        statement_count: data[:statements]&.size || 0
      }
    end
    
    # Sort by created_at, newest first
    polls.sort_by { |p| p[:created_at] }.reverse
  end
  
  # Delete a poll
  def self.delete_poll(poll_id)
    file_path = poll_file_path(poll_id)
    
    unless File.exist?(file_path)
      puts "[POLL STORAGE] Poll not found for deletion: #{poll_id}"
      return false
    end
    
    File.delete(file_path)
    
    # If this was the current poll, clear it
    if current_poll_id == poll_id
      set_current_poll_id(nil)
    end
    
    puts "[POLL STORAGE] Deleted poll: #{poll_id}"
    true
  end
  
  # Get the current active poll ID
  def self.current_poll_id
    return nil unless File.exist?(CURRENT_POLL_FILE)
    
    poll_id = File.read(CURRENT_POLL_FILE).strip
    poll_id.empty? ? nil : poll_id
  end
  
  # Set the current active poll ID
  def self.set_current_poll_id(poll_id)
    initialize_storage
    
    if poll_id.nil?
      File.delete(CURRENT_POLL_FILE) if File.exist?(CURRENT_POLL_FILE)
      puts "[POLL STORAGE] Cleared current poll"
    else
      File.write(CURRENT_POLL_FILE, poll_id)
      puts "[POLL STORAGE] Set current poll: #{poll_id}"
    end
  end
  
  # Load the current active poll
  def self.load_current_poll
    poll_id = current_poll_id
    return nil if poll_id.nil?
    
    load_poll(poll_id)
  end
  
  private
  
  def self.generate_poll_id
    "poll_#{Time.now.to_i}_#{SecureRandom.hex(4)}"
  end
  
  def self.poll_file_path(poll_id)
    File.join(DATA_DIR, "#{poll_id}.json")
  end
end
