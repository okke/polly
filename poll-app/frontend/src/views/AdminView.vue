<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import axios from 'axios'
import { useSocket } from '../composables/useSocket.js'
import { useTheme } from '../composables/useTheme.js'
import { useRemoteLog } from '../composables/useRemoteLog.js'
import ConnectionPanel from '../components/ConnectionPanel.vue'
import ResultsGrid from '../components/ResultsGrid.vue'
import ControlBar from '../components/ControlBar.vue'
import PollGeneratorModal from '../components/PollGeneratorModal.vue'
import PollSelector from '../components/PollSelector.vue'

const { connect, disconnect, on, isConnected } = useSocket()
const { isDark, toggleTheme } = useTheme()
const { info } = useRemoteLog()

const poll = ref(null)
const results = ref({})  // Object with statement results
const participantCount = ref(0)
const serverInfo = ref(null)
const connectedClients = ref(0)
const currentPollId = ref(null)
const pollSelectorRef = ref(null)
const isLoading = ref(true)
const error = ref(null)
const lastUpdate = ref(null)
const showGeneratorModal = ref(false)

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
  info('Fetching initial data from server')
  
  try {
    const [pollRes, resultsRes, infoRes, pollsRes] = await Promise.all([
      axios.get('/api/poll'),
      axios.get('/api/results'),
      axios.get('/api/info'),
      axios.get('/api/polls')
    ])
    
    poll.value = pollRes.data
    results.value = resultsRes.data.results
    participantCount.value = resultsRes.data.participant_count
    serverInfo.value = infoRes.data
    connectedClients.value = infoRes.data.connected_clients || 0
    currentPollId.value = pollsRes.data.current_poll_id
    lastUpdate.value = new Date().toISOString()
    isLoading.value = false
    
    info('Initial data loaded')
  } catch (e) {
    info('Failed to load data', { error: e.message })
    error.value = 'Failed to load data. Is the server running?'
    isLoading.value = false
  }
}

// Handle realtime updates
function handleResultsUpdate(data, source = 'websocket') {
  // Batch all reactive updates together to minimize Vue re-render cycles
  results.value = data.results
  participantCount.value = data.participant_count
  connectedClients.value = data.connected_clients !== undefined ? data.connected_clients : connectedClients.value
  lastUpdate.value = data.timestamp || new Date().toISOString()
}

// Export results
async function exportResults() {
  window.location.href = '/api/export'
}

// Open poll generator
function openPollGenerator() {
  showGeneratorModal.value = true
}

// Handle generated poll acceptance
async function handleAcceptGeneratedPoll(generatedPoll) {
  info('Admin accepted generated poll', { 
    title: generatedPoll.title, 
    statements: generatedPoll.statements.length 
  })
  
  try {
    // Update poll on server
    const response = await axios.put('/api/poll', generatedPoll)
    
    if (response.data.status === 'ok') {
      // Update local state
      poll.value = generatedPoll
      currentPollId.value = generatedPoll.id
      
      // Close modal
      showGeneratorModal.value = false
      
      info('Poll updated successfully')
      
      // Refresh poll selector to show new poll
      if (pollSelectorRef.value) {
        pollSelectorRef.value.fetchPolls()
      }
      
      // Show success message
      alert('Poll updated successfully! All votes have been reset.')
    } else {
      throw new Error(response.data.error || 'Failed to update poll')
    }
  } catch (e) {
    info('Failed to update poll', { error: e.message })
    alert(`Failed to update poll: ${e.response?.data?.details || e.message}`)
  }
}

// Reset votes
async function resetVotes() {
  if (!confirm('Are you sure you want to reset all votes? This cannot be undone.')) {
    return
  }
  
  info('Sending reset request to server')
  
  try {
    await axios.post('/api/reset')
    info('Reset request completed')
  } catch (e) {
    info('Reset request failed', { error: e.message })
    alert('Failed to reset votes')
  }
}
// Handle poll change (when user selects a different poll)
async function handlePollChanged(pollId) {
  info('Poll activated', { poll_id: pollId })
  currentPollId.value = pollId
  // Fetch updated data after poll change
  await fetchData()
}

// Handle poll deletion
async function handlePollDeleted(pollId) {
  info('Poll deleted', { poll_id: pollId })
  // Fetch updated data after poll deletion
  await fetchData()
}
let unsubscribeResults = null
let unsubscribeInit = null
let unsubscribeReset = null
let unsubscribePollUpdate = null

// Handle reset from server (when another admin resets)
function handleServerReset(data) {
  // Results update will follow automatically, no action needed
  info('Reset broadcast received from server')
}

// Handle poll update from server (when poll is updated)
function handlePollUpdate(data) {
  info('Poll update received from server', { title: data.poll?.title })
  poll.value = data.poll
  // Results will be cleared automatically by server and broadcast
}

onMounted(async () => {
  info('Admin panel mounting')
  
  await fetchData()
  
  info('Connecting WebSocket as admin')
  connect('admin')  // Connect as admin to receive broadcasts
  
  // Register handlers (init is sent on WebSocket connect, so it handles reconnect data too)
  unsubscribeResults = on('results_update', (data) => handleResultsUpdate(data, 'results_update'))
  unsubscribeInit = on('init', (data) => handleResultsUpdate(data, 'init'))
  unsubscribeReset = on('reset', handleServerReset)
  unsubscribePollUpdate = on('poll_update', handlePollUpdate)
  
  info('Admin panel mounted')
})

onUnmounted(() => {
  if (unsubscribeResults) unsubscribeResults()
  if (unsubscribeInit) unsubscribeInit()
  if (unsubscribeReset) unsubscribeReset()
  if (unsubscribePollUpdate) unsubscribePollUpdate()
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
          <button class="generate-btn" @click="openPollGenerator" title="Generate poll with AI">
            <span class="ai-icon">✨</span>
            <span>Generate Poll</span>
          </button>
          
          <div v-if="serverInfo" class="join-url-header">
            <code class="header-url">{{ serverInfo.url }}</code>
          </div>
          
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
            
            <PollSelector
              ref="pollSelectorRef"
              :currentPollId="currentPollId"
              @pollChanged="handlePollChanged"
              @pollDeleted="handlePollDeleted"
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
    
    <!-- Poll Generator Modal -->
    <PollGeneratorModal 
      :visible="showGeneratorModal"
      @close="showGeneratorModal = false"
      @accept="handleAcceptGeneratedPoll"
    />
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

.header-right {
  display: flex;
  align-items: center;
  gap: var(--space-3);
}

.generate-btn {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  padding: var(--space-2) var(--space-4);
  background: linear-gradient(135deg, rgba(139, 92, 246, 0.1), rgba(59, 130, 246, 0.1));
  border: 1px solid rgba(139, 92, 246, 0.3);
  border-radius: var(--radius-lg);
  color: var(--text-primary);
  font-size: var(--text-sm);
  font-weight: var(--font-medium);
  cursor: pointer;
  transition: all var(--duration-fast) var(--ease-out);
  backdrop-filter: blur(10px);
}

.generate-btn:hover {
  background: linear-gradient(135deg, rgba(139, 92, 246, 0.2), rgba(59, 130, 246, 0.2));
  border-color: rgba(139, 92, 246, 0.5);
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(139, 92, 246, 0.15);
}

.generate-btn:active {
  transform: translateY(0);
}

.ai-icon {
  font-size: var(--text-base);
  filter: drop-shadow(0 0 8px rgba(139, 92, 246, 0.5));
  animation: sparkle 3s ease-in-out infinite;
}

@keyframes sparkle {
  0%, 100% {
    opacity: 1;
    transform: scale(1);
  }
  50% {
    opacity: 0.7;
    transform: scale(1.1);
  }
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

.join-url-header {
  padding: var(--space-2) var(--space-3);
  background: var(--bg-secondary);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-md);
  backdrop-filter: blur(10px);
}

.header-url {
  font-family: var(--font-mono);
  font-size: var(--text-sm);
  color: var(--text-primary);
  font-weight: var(--font-medium);
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
