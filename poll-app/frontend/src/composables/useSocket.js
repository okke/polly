import { ref, onMounted, onUnmounted } from 'vue'

const socket = ref(null)
const isConnected = ref(false)
const lastMessage = ref(null)

// Event handlers stored globally to persist across component instances
const eventHandlers = new Map()

export function useSocket() {
  function connect() {
    if (socket.value && socket.value.readyState === WebSocket.OPEN) {
      return
    }
    
    const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:'
    const host = window.location.host
    const wsUrl = `${protocol}//${host}/ws`
    
    console.log('[WS] Connecting to:', wsUrl)
    
    try {
      socket.value = new WebSocket(wsUrl)
      
      socket.value.onopen = () => {
        isConnected.value = true
        console.log('[WS] Connected')
      }
      
      socket.value.onclose = () => {
        isConnected.value = false
        console.log('[WS] Disconnected')
        
        // Auto-reconnect after 3 seconds
        setTimeout(() => {
          if (!isConnected.value) {
            console.log('[WS] Reconnecting...')
            connect()
          }
        }, 3000)
      }
      
      socket.value.onerror = (error) => {
        console.error('[WS] Error:', error)
      }
      
      socket.value.onmessage = (event) => {
        try {
          const data = JSON.parse(event.data)
          lastMessage.value = data
          
          // Emit to registered handlers
          const handlers = eventHandlers.get(data.type)
          if (handlers) {
            handlers.forEach(handler => handler(data.data))
          }
        } catch (e) {
          console.error('[WS] Failed to parse message:', e)
        }
      }
    } catch (e) {
      console.error('[WS] Failed to create WebSocket:', e)
    }
  }
  
  function disconnect() {
    if (socket.value) {
      socket.value.close()
      socket.value = null
    }
  }
  
  function on(eventType, handler) {
    if (!eventHandlers.has(eventType)) {
      eventHandlers.set(eventType, new Set())
    }
    eventHandlers.get(eventType).add(handler)
    
    // Return unsubscribe function
    return () => {
      eventHandlers.get(eventType).delete(handler)
    }
  }
  
  function send(type, data) {
    if (socket.value && socket.value.readyState === WebSocket.OPEN) {
      socket.value.send(JSON.stringify({ type, data }))
    }
  }
  
  return {
    socket,
    isConnected,
    lastMessage,
    connect,
    disconnect,
    on,
    send
  }
}
