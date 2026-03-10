<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import axios from 'axios'
import { useSocket } from '../composables/useSocket.js'
import { useTheme } from '../composables/useTheme.js'
import ConnectionPanel from '../components/ConnectionPanel.vue'
import ResultsGrid from '../components/ResultsGrid.vue'
import ControlBar from '../components/ControlBar.vue'

const { connect, disconnect, on, isConnected } = useSocket()
const { isDark, toggleTheme } = useTheme()

const poll = ref(null)
const results = ref({})
const participantCount = ref(0)
const serverInfo = ref(null)
const connectedClients = ref(0)
const isLoading = ref(true)
const error = ref(null)
const lastUpdate = ref(null)

// Computed poll results with statement info
const pollResults = computed(() => {
  if (!poll.value || !results.value) return []
  
  return poll.value.statements.map(statement => {
    const votes = results.value[statement.id] || {
      strongly_agree: 0,
      agree: 0,
      disagree: 0,
      strongly_disagree: 0
    }
    
    const total = Object.values(votes).reduce((sum, v) => sum + v, 0)
    
    return {
      ...statement,
      votes,
      total
    }
  })
})

// Total votes across all statements
const totalVotes = computed(() => {
  return pollResults.value.reduce((sum, r) => sum + r.total, 0)
})

// Fetch initial data
async function fetchData() {
  try {
    const [pollRes, resultsRes, infoRes] = await Promise.all([
      axios.get('/api/poll'),
      axios.get('/api/results'),
      axios.get('/api/info')
    ])
    
    poll.value = pollRes.data
    results.value = resultsRes.data.results
    participantCount.value = resultsRes.data.participant_count
    serverInfo.value = infoRes.data
    connectedClients.value = infoRes.data.connected_clients || 0
    lastUpdate.value = new Date().toISOString()
    isLoading.value = false
  } catch (e) {
    error.value = 'Failed to load data. Is the server running?'
    isLoading.value = false
  }
}

// Handle realtime updates with timing instrumentation
function handleResultsUpdate(data, source = 'websocket') {
  const now = performance.now()
  const serverTime = data.timestamp ? new Date(data.timestamp).getTime() : null
  const clientTime = Date.now()
  const latency = serverTime ? clientTime - serverTime : 'N/A'
  
  console.log(`[Admin] Update from ${source}:`, {
    latency: `${latency}ms`,
    participants: data.participant_count,
    connections: data.connected_clients,
    timestamp: data.timestamp
  })
  
  results.value = data.results
  participantCount.value = data.participant_count
  if (data.connected_clients !== undefined) {
    connectedClients.value = data.connected_clients
  }
  lastUpdate.value = data.timestamp || new Date().toISOString()
  
  console.log(`[Admin] State updated in ${(performance.now() - now).toFixed(1)}ms`)
}

// Export results
async function exportResults() {
  window.location.href = '/api/export'
}

// Reset votes
async function resetVotes() {
  if (!confirm('Are you sure you want to reset all votes? This cannot be undone.')) {
    return
  }
  
  try {
    await axios.post('/api/reset')
  } catch (e) {
    alert('Failed to reset votes')
  }
}

let unsubscribeResults = null
let unsubscribeInit = null
let unsubscribeReset = null

// Handle reset from server (when another admin resets)
function handleServerReset() {
  console.log('[Admin] Reset broadcast received from server')
  // Results update will follow automatically, no action needed
}

onMounted(async () => {
  await fetchData()
  connect('admin')  // Connect as admin to receive broadcasts
  
  // Register handlers (init is sent on WebSocket connect, so it handles reconnect data too)
  unsubscribeResults = on('results_update', (data) => handleResultsUpdate(data, 'results_update'))
  unsubscribeInit = on('init', (data) => handleResultsUpdate(data, 'init'))
  unsubscribeReset = on('reset', handleServerReset)
})

onUnmounted(() => {
  if (unsubscribeResults) unsubscribeResults()
  if (unsubscribeInit) unsubscribeInit()
  if (unsubscribeReset) unsubscribeReset()
  disconnect()
})
</script>

<template>
  <div class="admin-view">
    <!-- Background -->
    <div class="bg-gradient"></div>
    <div class="bg-grid"></div>
    
    <div class="admin-container">
      <!-- Header -->
      <header class="admin-header">
        <div class="header-left">
          <h1 class="title">
            <span class="title-prefix">$</span> polly<span class="cursor">▌</span>
          </h1>
          <span class="subtitle terminal-text">admin_dashboard</span>
        </div>
        
        <div class="header-right">
          <div class="connection-status" :class="{ connected: isConnected }">
            <span class="status-dot"></span>
            <span class="status-text">{{ isConnected ? 'live' : 'offline' }}</span>
          </div>
        </div>
      </header>
      
      <!-- Loading state -->
      <div v-if="isLoading" class="loading-state">
        <div class="loading-spinner"></div>
        <span class="terminal-text">loading<span class="cursor">▌</span></span>
      </div>
      
      <!-- Error state -->
      <div v-else-if="error" class="error-state glass-card p-6">
        <span class="terminal-text">[ERROR]</span>
        <p>{{ error }}</p>
      </div>
      
      <!-- Main content -->
      <template v-else>
        <div class="admin-layout">
          <!-- Sidebar -->
          <aside class="sidebar">
            <ConnectionPanel 
              :serverInfo="serverInfo"
              :participantCount="participantCount"
              :connectedClients="connectedClients"
            />
            
            <ControlBar 
              :isDark="isDark"
              :lastUpdate="lastUpdate"
              @export="exportResults"
              @reset="resetVotes"
              @toggleTheme="toggleTheme"
            />
          </aside>
          
          <!-- Main content -->
          <main class="main-content">
            <div class="stats-bar">
              <div class="stat">
                <span class="stat-value font-mono">{{ participantCount }}</span>
                <span class="stat-label">participants</span>
              </div>
              <div class="stat">
                <span class="stat-value font-mono">{{ totalVotes }}</span>
                <span class="stat-label">total votes</span>
              </div>
              <div class="stat">
                <span class="stat-value font-mono">{{ poll?.statements?.length || 0 }}</span>
                <span class="stat-label">statements</span>
              </div>
            </div>
            
            <ResultsGrid :results="pollResults" />
          </main>
        </div>
      </template>
    </div>
  </div>
</template>

<style scoped>
.admin-view {
  min-height: 100vh;
  min-height: 100dvh;
  position: relative;
}

.bg-gradient {
  position: fixed;
  inset: 0;
  background: 
    radial-gradient(ellipse at top right, rgba(0, 255, 159, 0.03) 0%, transparent 50%),
    radial-gradient(ellipse at bottom left, rgba(10, 132, 255, 0.03) 0%, transparent 50%),
    var(--bg-primary);
  z-index: -2;
}

.bg-grid {
  position: fixed;
  inset: 0;
  background-image: 
    linear-gradient(var(--border-subtle) 1px, transparent 1px),
    linear-gradient(90deg, var(--border-subtle) 1px, transparent 1px);
  background-size: 50px 50px;
  opacity: 0.5;
  z-index: -1;
  pointer-events: none;
}

.admin-container {
  max-width: var(--container-xl);
  margin: 0 auto;
  padding: var(--space-4);
}

/* Header */
.admin-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: var(--space-4) 0;
  margin-bottom: var(--space-6);
  border-bottom: 1px solid var(--border-subtle);
}

.header-left {
  display: flex;
  align-items: baseline;
  gap: var(--space-4);
}

.title {
  font-size: var(--text-2xl);
  font-weight: var(--font-bold);
  font-family: var(--font-mono);
  display: flex;
  align-items: center;
  gap: var(--space-1);
}

.title-prefix {
  color: var(--text-tertiary);
}

.cursor {
  color: var(--text-accent);
  animation: blink 1s step-end infinite;
  font-weight: var(--font-normal);
}

.subtitle {
  font-size: var(--text-sm);
  color: var(--text-tertiary);
}

.terminal-text {
  font-family: var(--font-mono);
}

.connection-status {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  font-family: var(--font-mono);
  font-size: var(--text-sm);
  color: var(--text-tertiary);
}

.status-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: var(--accent-error);
  transition: background var(--duration-fast) var(--ease-out);
}

.connection-status.connected .status-dot {
  background: var(--accent-success);
  box-shadow: 0 0 8px var(--accent-success);
}

.connection-status.connected .status-text {
  color: var(--accent-success);
}

/* Layout */
.admin-layout {
  display: grid;
  grid-template-columns: 320px 1fr;
  gap: var(--space-6);
}

.sidebar {
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
}

.main-content {
  display: flex;
  flex-direction: column;
  gap: var(--space-6);
}

/* Stats bar */
.stats-bar {
  display: flex;
  gap: var(--space-6);
}

.stat {
  display: flex;
  flex-direction: column;
  gap: var(--space-1);
}

.stat-value {
  font-size: var(--text-3xl);
  font-weight: var(--font-bold);
  color: var(--text-primary);
}

.stat-label {
  font-size: var(--text-sm);
  color: var(--text-tertiary);
  text-transform: lowercase;
}

/* Loading */
.loading-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 60vh;
  gap: var(--space-4);
}

.loading-spinner {
  width: 40px;
  height: 40px;
  border: 3px solid var(--border-default);
  border-top-color: var(--text-accent);
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

.error-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--space-3);
  text-align: center;
  margin-top: var(--space-16);
}

/* Responsive */
@media (max-width: 1024px) {
  .admin-layout {
    grid-template-columns: 1fr;
  }
  
  .sidebar {
    flex-direction: row;
    flex-wrap: wrap;
  }
  
  .sidebar > * {
    flex: 1;
    min-width: 280px;
  }
}

@media (max-width: 640px) {
  .admin-header {
    flex-direction: column;
    align-items: flex-start;
    gap: var(--space-3);
  }
  
  .stats-bar {
    flex-wrap: wrap;
  }
  
  .stat-value {
    font-size: var(--text-2xl);
  }
}
</style>
