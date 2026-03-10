# Puma configuration
port ENV.fetch('PORT', 4567)

# Use multiple threads to prevent event loop blocking
threads 2, 8

# Log startup
on_booted do
  puts "[PUMA] Server configured with 8 max threads for WebSocket performance"
end

