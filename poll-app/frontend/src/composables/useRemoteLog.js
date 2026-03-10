import axios from 'axios'

// Batch logging to avoid overwhelming the browser with HTTP requests
const logQueue = []
let flushTimer = null
const BATCH_INTERVAL = 500 // Send logs every 500ms
const MAX_BATCH_SIZE = 20 // Or when we have 20 logs

function flushLogs() {
  if (logQueue.length === 0) return
  
  const batch = logQueue.splice(0, MAX_BATCH_SIZE)
  
  // Send batch (fire and forget)
  axios.post('/api/log', {
    level: 'INFO',
    message: `[BATCH] ${batch.length} log entries`,
    data: { logs: batch }
  }).catch(() => {
    // Ignore errors silently
  })
  
  // Schedule next flush if queue not empty
  if (logQueue.length > 0) {
    flushTimer = setTimeout(flushLogs, 0)
  } else {
    flushTimer = null
  }
}

function scheduleBatch() {
  if (!flushTimer) {
    flushTimer = setTimeout(flushLogs, BATCH_INTERVAL)
  }
  
  // Flush immediately if queue is full
  if (logQueue.length >= MAX_BATCH_SIZE) {
    clearTimeout(flushTimer)
    flushLogs()
  }
}

// Remote logging for admin panel - sends logs to server
export function useRemoteLog() {
  function log(level, message, data = null) {
    // Always log to console
    const consoleMsg = data ? `${message}` : message
    const consoleData = data || ''
    
    if (level === 'ERROR') {
      console.error(consoleMsg, consoleData)
    } else if (level === 'WARN') {
      console.warn(consoleMsg, consoleData)
    } else {
      console.log(consoleMsg, consoleData)
    }
    
    // Add to batch queue
    logQueue.push({
      level,
      message,
      data,
      timestamp: new Date().toISOString()
    })
    
    scheduleBatch()
  }
  
  function info(message, data = null) {
    log('INFO', message, data)
  }
  
  function warn(message, data = null) {
    log('WARN', message, data)
  }
  
  function error(message, data = null) {
    log('ERROR', message, data)
  }
  
  return {
    log,
    info,
    warn,
    error
  }
}
