import { ref } from 'vue'
import axios from 'axios'

const socket = ref(null)
const isConnected = ref(false)
const lastMessage = ref(null)
let heartbeatTimer = null
let lastConnectAttempt = 0
let currentRole = 'participant'

// Event handlers stored globally to persist across component instances
const eventHandlers = new Map()

// Batch logging to avoid overwhelming browser with HTTP requests
const wsLogQueue = []
let wsLogTimer = null
const WS_LOG_BATCH_INTERVAL = 500 // ms
const WS_LOG_MAX_BATCH = 20

function flushWSLogs() {
  if (wsLogQueue.length === 0 || currentRole !== 'admin') return
  
  const batch = wsLogQueue.splice(0, WS_LOG_MAX_BATCH)
  
  axios.post('/api/log', {
    level: 'INFO',
    message: `[WS BATCH] ${batch.length} entries`,
    data: { logs: batch }
  }).catch(() => {})
  
  if (wsLogQueue.length > 0) {
    wsLogTimer = setTimeout(flushWSLogs, 0)
  } else {
    wsLogTimer = null
  }
}

function scheduleWSLog() {
  if (!wsLogTimer) {
    wsLogTimer = setTimeout(flushWSLogs, WS_LOG_BATCH_INTERVAL)
  }
  if (wsLogQueue.length >= WS_LOG_MAX_BATCH) {
    clearTimeout(wsLogTimer)
    flushWSLogs()
  }
}

// Remote logging helper for admin mode (batched, non-blocking)
function remoteLog(message, data = null) {
  if (currentRole !== 'admin') return
  
  wsLogQueue.push({
    message: `[WS] ${message}`,
    data,
    timestamp: new Date().toISOString()
  })
  
  scheduleWSLog()
}

function createSocket() {
  // Debounce - don't create socket if we tried recently (within 1 second)
  const now = Date.now()
  if (now - lastConnectAttempt < 1000) {
    return
  }
  lastConnectAttempt = now
  
  // If socket exists and is open or connecting, don't create new one
  if (socket.value) {
    const state = socket.value.readyState
    if (state === WebSocket.OPEN || state === WebSocket.CONNECTING) {
      return
    }
    // Clean up closed socket
    try {
      socket.value.onopen = null
      socket.value.onclose = null
      socket.value.onerror = null
      socket.value.onmessage = null
    } catch (e) {
      // ignore
    }
    socket.value = null
  }
  
  const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:'
  const host = window.location.host
  const roleParam = currentRole === 'admin' ? '?role=admin' : ''
  const wsUrl = `${protocol}//${host}/ws${roleParam}`
  
  console.log('[WS] Creating new connection to:', wsUrl)
  
  try {
    const ws = new WebSocket(wsUrl)
    
    ws.onopen = () => {
      isConnected.value = true
      console.log('[WS] Connected')
      remoteLog('WebSocket connected', { url: wsUrl })
    }
    
    ws.onclose = () => {
      isConnected.value = false
      console.log('[WS] Disconnected')
      remoteLog('WebSocket disconnected')
      // Try to reconnect quickly if page is visible
      if (document.visibilityState === 'visible') {
        setTimeout(() => {
          if (!socket.value || socket.value.readyState === WebSocket.CLOSED) {
            console.log('[WS] Auto-reconnecting after disconnect...')
            createSocket()
          }
        }, 500)
      }
    }
    
    ws.onerror = (error) => {
      console.error('[WS] Error:', error)
    }
    
    ws.onmessage = (event) => {
      try {
        const data = JSON.parse(event.data)
        console.log(`[WS] Message received: ${data.type}`)
        
        lastMessage.value = data
        
        // Emit to registered handlers
        const handlers = eventHandlers.get(data.type)
        if (handlers) {
          console.log(`[WS] Calling ${handlers.size} handler(s) for ${data.type}`)
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

// Heartbeat - ensures connection is alive, runs every 5 seconds
function checkConnection() {
  if (document.visibilityState !== 'visible') {
    return // Don't check when page is hidden
  }
  
  const ws = socket.value
  
  // No socket or socket is closed - reconnect
  if (!ws || ws.readyState === WebSocket.CLOSED) {
    console.log('[WS] Heartbeat: no active connection, creating socket')
    createSocket()
    return
  }
  
  // Socket is closing - wait for it to finish
  if (ws.readyState === WebSocket.CLOSING) {
    return
  }
  
  // Socket is connecting or open - all good
}

function startHeartbeat() {
  if (heartbeatTimer) return
  
  // Connect immediately
  createSocket()
  
  // Then check every 5 seconds (less aggressive)
  heartbeatTimer = setInterval(checkConnection, 5000)
}

function stopHeartbeat() {
  if (heartbeatTimer) {
    clearInterval(heartbeatTimer)
    heartbeatTimer = null
  }
}

export function useSocket() {
  function connect(role = 'participant') {
    currentRole = role
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
    console.log('[WS] Registered handler for', eventType)
    
    // Return unsubscribe function
    return () => {
      eventHandlers.get(eventType).delete(handler)
    }
  }
  
  function send(type, data) {
    if (socket.value && socket.value.readyState === WebSocket.OPEN) {
      const message = JSON.stringify({ type, data })
      socket.value.send(message)
      console.log(`[WS] Sent: ${type}`)
    } else {
      console.warn(`[WS] Cannot send ${type} - socket not open`)
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
