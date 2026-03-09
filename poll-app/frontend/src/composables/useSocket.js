import { ref } from 'vue'

const socket = ref(null)
const isConnected = ref(false)
const lastMessage = ref(null)
let heartbeatTimer = null

// Event handlers stored globally to persist across component instances
const eventHandlers = new Map()

function createSocket() {
  // Clean up any existing socket
  if (socket.value) {
    try {
      socket.value.onopen = null
      socket.value.onclose = null
      socket.value.onerror = null
      socket.value.onmessage = null
      socket.value.close()
    } catch (e) {
      // ignore
    }
    socket.value = null
  }
  
  const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:'
  const host = window.location.host
  const wsUrl = `${protocol}//${host}/ws`
  
  console.log('[WS] Creating new connection to:', wsUrl)
  
  try {
    const ws = new WebSocket(wsUrl)
    
    ws.onopen = () => {
      isConnected.value = true
      console.log('[WS] Connected')
    }
    
    ws.onclose = () => {
      isConnected.value = false
      console.log('[WS] Disconnected')
    }
    
    ws.onerror = (error) => {
      console.error('[WS] Error:', error)
    }
    
    ws.onmessage = (event) => {
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
    
    socket.value = ws
  } catch (e) {
    console.error('[WS] Failed to create WebSocket:', e)
  }
}

// Heartbeat - ensures connection is alive, runs every 2 seconds
function checkConnection() {
  if (document.visibilityState !== 'visible') {
    return // Don't check when page is hidden
  }
  
  const ws = socket.value
  
  // No socket or socket is closed/closing - reconnect
  if (!ws || ws.readyState === WebSocket.CLOSED || ws.readyState === WebSocket.CLOSING) {
    console.log('[WS] Heartbeat: no connection, creating new socket')
    createSocket()
    return
  }
  
  // Socket exists and is open - all good
  if (ws.readyState === WebSocket.OPEN) {
    return
  }
  
  // Socket is connecting - wait
  if (ws.readyState === WebSocket.CONNECTING) {
    return
  }
}

function startHeartbeat() {
  if (heartbeatTimer) return
  
  // Check immediately
  checkConnection()
  
  // Then check every 2 seconds
  heartbeatTimer = setInterval(checkConnection, 2000)
}

function stopHeartbeat() {
  if (heartbeatTimer) {
    clearInterval(heartbeatTimer)
    heartbeatTimer = null
  }
}

export function useSocket() {
  function connect() {
    startHeartbeat()
  }
  
  function disconnect() {
    stopHeartbeat()
    if (socket.value) {
      try {
        socket.value.onclose = null
        socket.value.close()
      } catch (e) {
        // ignore
      }
      socket.value = null
    }
    isConnected.value = false
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
