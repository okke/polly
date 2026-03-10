<script setup>
import { ref, computed, onMounted, onUnmounted, watch, nextTick } from 'vue'
import axios from 'axios'
import { useParticipant } from '../composables/useParticipant.js'
import { useSocket } from '../composables/useSocket.js'
import PollHeader from '../components/PollHeader.vue'
import StatementCard from '../components/StatementCard.vue'
import SubmitButton from '../components/SubmitButton.vue'
import SuccessOverlay from '../components/SuccessOverlay.vue'

const { participantId, resetId } = useParticipant()
const { connect, disconnect, on, isConnected } = useSocket()

const poll = ref(null)
const votes = ref({})
const isLoading = ref(true)
const isSubmitting = ref(false)
const showSuccess = ref(false)
const error = ref(null)
const renderKey = ref(0) // Key to force clean re-render
const isFinalized = ref(false) // Track if votes are finalized
const psychAnalysis = ref(null) // Store psychological analysis

// Compute progress
const answeredCount = computed(() => Object.keys(votes.value).length)
const totalCount = computed(() => poll.value?.statements?.length || 0)
const allAnswered = computed(() => answeredCount.value === totalCount.value && totalCount.value > 0)

// Load previous votes from localStorage
function loadSavedVotes() {
  const saved = localStorage.getItem('polly-votes')
  if (saved) {
    try {
      const savedData = JSON.parse(saved)
      // Check if this is the new format with poll ID
      const savedPollId = savedData.pollId
      const currentPollId = poll.value?.id
      
      if (savedPollId && currentPollId && savedPollId === currentPollId) {
        // Poll IDs match, load the votes and finalized state
        votes.value = savedData.votes || {}
        isFinalized.value = savedData.finalized || false
        console.log('[Poll] Loaded saved votes for poll:', currentPollId, 'Finalized:', isFinalized.value)
      } else if (savedPollId && currentPollId && savedPollId !== currentPollId) {
        // Different poll, clear storage
        console.log('[Poll] Poll changed, clearing old votes')
        localStorage.removeItem('polly-votes')
        votes.value = {}
        isFinalized.value = false
      } else if (!savedPollId) {
        // Old format without poll ID, try to load anyway (legacy support)
        votes.value = savedData
        isFinalized.value = false
        console.log('[Poll] Loaded legacy votes (no poll ID)')
      }
    } catch (e) {
      // Invalid saved data
      console.error('[Poll] Failed to parse saved votes:', e)
      localStorage.removeItem('polly-votes')
    }
  }
}

// Save votes to localStorage (debounced to avoid blocking on every change)
let saveTimeout = null
function saveVotes() {
  // Debounce: wait 100ms after last change before saving
  if (saveTimeout) clearTimeout(saveTimeout)
  saveTimeout = setTimeout(() => {
    try {
      const currentPollId = poll.value?.id
      const dataToSave = {
        pollId: currentPollId,
        votes: votes.value,
        finalized: isFinalized.value
      }
      localStorage.setItem('polly-votes', JSON.stringify(dataToSave))
    } catch (e) {
      console.error('Failed to save votes:', e)
    }
  }, 100)
}

// Watch for vote changes and save (shallow watch is fine, votes object is replaced)
watch(votes, saveVotes, { deep: true })
// Also watch finalized state
watch(isFinalized, saveVotes)

// Fetch poll data
async function fetchPoll() {
  console.log('[Poll] Fetching poll data from /api/poll...')
  try {
    const response = await axios.get('/api/poll')
    console.log('[Poll] Poll data received:', response.data)
    poll.value = response.data
    isLoading.value = false
    
    // Load saved votes AFTER we have the poll data (to check poll ID)
    loadSavedVotes()
    console.log('[Poll] Poll loaded successfully:', poll.value?.title)
  } catch (e) {
    console.error('[Poll] Failed to fetch poll:', e)
    console.error('[Poll] Error details:', {
      message: e.message,
      response: e.response?.data,
      status: e.response?.status
    })
    error.value = `Failed to load poll: ${e.message}. Please check your connection.`
    isLoading.value = false
  }
}

// Handle vote selection
async function handleVote(statementId, voteValue) {
  // Don't allow changes if finalized
  if (isFinalized.value) {
    console.log('[Vote] Votes are finalized, change blocked')
    error.value = 'Your votes are finalized. They can only be changed if the poll is reset.'
    setTimeout(() => { error.value = null }, 3000)
    return
  }
  
  votes.value[statementId] = voteValue
  
  // Get participant ID (should always be available now)
  const pid = participantId.value
  if (!pid) {
    console.error('[Vote] No participant ID available')
    error.value = 'Error: No participant ID. Please refresh the page.'
    return
  }
  
  try {
    console.log(`[Vote] Submitting: ${pid.substring(0,8)}... -> ${statementId}: ${voteValue}`)
    const response = await axios.post('/api/vote', {
      participant_id: pid,
      statement_id: statementId,
      vote: voteValue
    })
    console.log('[Vote] Success:', response.data)
  } catch (e) {
    console.error('[Vote] Failed to submit:', e)
    console.error('[Vote] Error details:', {
      message: e.message,
      response: e.response?.data,
      status: e.response?.status
    })
    // Show error to user
    error.value = `Failed to submit vote: ${e.message}. Your vote is saved locally.`
    setTimeout(() => { error.value = null }, 5000)
  }
}

// Finalize votes (lock them in)
async function finalizeVotes() {
  if (!allAnswered.value || isSubmitting.value || isFinalized.value) return
  
  isSubmitting.value = true
  
  try {
    // Mark as finalized
    isFinalized.value = true
    console.log('[Poll] Votes finalized, requesting psychological analysis...')
    
    // Request psychological analysis
    try {
      const response = await axios.post('/api/analyze', {
        poll: poll.value,
        votes: votes.value
      })
      
      if (response.data.status === 'ok') {
        psychAnalysis.value = response.data.analysis
        console.log('[Poll] Received psychological analysis')
      }
    } catch (analysisError) {
      console.error('[Poll] Failed to get analysis:', analysisError)
      // Don't fail the finalization if analysis fails
      psychAnalysis.value = null
    }
    
    // Show success with analysis
    showSuccess.value = true
    
    // Hide success after longer time to read analysis
    setTimeout(() => {
      showSuccess.value = false
    }, 15000) // 15 seconds to read the analysis
  } catch (e) {
    error.value = 'Failed to finalize votes'
    isFinalized.value = false
  } finally {
    isSubmitting.value = false
  }
}

// Handle reset from server
async function handleReset() {
  console.log('[Poll] Reset received from server')
  
  try {
    // Clear votes (reactive update)
    votes.value = {}
    isFinalized.value = false
    psychAnalysis.value = null
    psychAnalysis.value = null
    
    // Wait for Vue to process
    await nextTick()
    
    // Force clean re-render to prevent animation glitches
    renderKey.value++
    
    // Wait for re-render
    await nextTick()
    
    // Clean up storage
    try {
      localStorage.removeItem('polly-votes')
      resetId()
    } catch (storageError) {
      console.error('[Poll] Error cleaning storage:', storageError)
    }
    
    // Hide success message if showing
    showSuccess.value = false
    
    console.log('[Poll] All data cleared')
  } catch (e) {
    console.error('[Poll] Error during reset:', e)
  }
}

// Handle user clicking reset button
async function handleUserReset() {
  // Don't allow clearing if finalized
  if (isFinalized.value) {
    console.log('[Poll] Votes are finalized, clear blocked')
    error.value = 'Your votes are finalized. They can only be changed if the poll is reset by the admin.'
    setTimeout(() => { error.value = null }, 3000)
    return
  }
  
  if (!confirm('Are you sure you want to clear all your votes? This cannot be undone.')) {
    return
  }
  
  // Wait for browser to finish closing the confirm dialog and settle layout
  await new Promise(resolve => {
    requestAnimationFrame(() => {
      requestAnimationFrame(resolve)
    })
  })
  
  const pid = participantId.value
  if (!pid) {
    console.error('No participant ID available')
    return
  }
  
  try {
    console.log('[Poll] User requesting vote reset')
    await axios.post('/api/participant/reset', {
      participant_id: pid
    })
    
    console.log('[Poll] Server reset successful, clearing local state')
    
    // Clear votes first
    votes.value = {}
    
    // Wait for Vue to process the reactive update
    await nextTick()
    
    // Then force re-render
    renderKey.value++
    
    // Wait for re-render to complete
    await nextTick()
    
    // Finally clean up storage
    try {
      localStorage.removeItem('polly-votes')
      resetId()
    } catch (storageError) {
      console.error('[Poll] Error cleaning storage:', storageError)
      // Continue anyway - main reset succeeded
    }
    
    // Hide success message if showing
    showSuccess.value = false
    
    console.log('[Poll] Vote reset successful')
  } catch (e) {
    console.error('[Poll] Failed to reset votes:', e)
    error.value = 'Failed to reset votes. Check your connection.'
    setTimeout(() => { error.value = null }, 3000)
  }
}

let unsubscribeReset = null
let unsubscribePollUpdate = null

// Handle poll update from server (when poll is updated)
async function handlePollUpdate(data) {
  console.log('[Poll] Poll update received from server')
  console.log('[Poll] New poll data:', data)
  console.log('[Poll] New poll title:', data.poll?.title)
  console.log('[Poll] New poll ID:', data.poll?.id)
  console.log('[Poll] Current poll ID before update:', poll.value?.id)
  
  // Update poll data
  poll.value = data.poll
  
  // Clear votes and finalized state (they're invalid for the new poll)
  votes.value = {}
  isFinalized.value = false
  psychAnalysis.value = null
  localStorage.removeItem('polly-votes')
  
  // Reset UI
  showSuccess.value = false
  isSubmitting.value = false
  
  // Force re-render with clean state
  await nextTick()
  renderKey.value++
  
  console.log('[Poll] UI updated with new poll:', poll.value?.title)
  
  // Show notification
  error.value = 'Poll has been updated! Please vote on the new statements.'
  setTimeout(() => { error.value = null }, 5000)
}

onMounted(() => {
  console.log('[Poll] Component mounted, initializing...')
  console.log('[Poll] User Agent:', navigator.userAgent)
  console.log('[Poll] Location:', window.location.href)
  console.log('[Poll] Participant ID:', participantId.value)
  
  // Don't load saved votes here - wait until after fetchPoll()
  fetchPoll()
  
  console.log('[Poll] Connecting to WebSocket as participant...')
  try {
    connect() // Connect to WebSocket for live tracking
    console.log('[Poll] WebSocket connect() called')
  } catch (e) {
    console.error('[Poll] WebSocket connect() failed:', e)
  }
  
  // Listen for reset from server
  console.log('[Poll] Registering reset handler...')
  unsubscribeReset = on('reset', handleReset)
  
  // Listen for poll updates
  console.log('[Poll] Registering poll_update handler...')
  unsubscribePollUpdate = on('poll_update', handlePollUpdate)
  
  console.log('[Poll] Initialization complete')
})

onUnmounted(() => {
  if (unsubscribeReset) unsubscribeReset()
  if (unsubscribePollUpdate) unsubscribePollUpdate()
  disconnect()
})
</script>

<template>
  <div class="poll-view">
    <!-- Background decoration -->
    <div class="bg-gradient"></div>
    <div class="bg-noise"></div>
    
    <div class="container">
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
      
      <!-- Poll content -->
      <template v-else-if="poll">
        <PollHeader 
          :title="poll.title"
          :answered="answeredCount"
          :total="totalCount"
        />
        
        <!-- Connection status indicator (helpful for mobile debugging) -->
        <div class="connection-indicator" :class="{ connected: isConnected }">
          <span class="dot"></span>
          <span class="text">{{ isConnected ? 'Live' : 'Disconnected' }}</span>
        </div>
        
        <!-- Finalized indicator -->
        <div v-if="isFinalized" class="finalized-indicator glass-card">
          <span class="finalized-icon">🔒</span>
          <div class="finalized-content">
            <p class="finalized-title">Votes Finalized</p>
            <p class="finalized-text">Your votes are locked and cannot be changed unless the poll is reset by the admin.</p>
          </div>
        </div>
        
        <!-- Reset button -->
        <div v-if="answeredCount > 0" class="reset-container">
          <button @click="handleUserReset" class="reset-button" :disabled="isFinalized" :class="{ disabled: isFinalized }">
            <span class="reset-icon">↺</span>
            Clear my votes
          </button>
        </div>
        
        <div :key="renderKey" class="statements-list stagger-children">
          <StatementCard
            v-for="(statement, index) in poll.statements"
            :key="statement.id"
            :statement="statement"
            :index="index"
            :selectedVote="votes[statement.id]"
            :disabled="isFinalized"
            @vote="handleVote"
          />
        </div>
        
        <SubmitButton
          :visible="allAnswered && !isFinalized"
          :loading="isSubmitting"
          @submit="finalizeVotes"
        />
      </template>
    </div>
    
    <SuccessOverlay :visible="showSuccess" :analysis="psychAnalysis" />
  </div>
</template>

<style scoped>
.poll-view {
  min-height: 100vh;
  min-height: 100dvh;
  padding: var(--space-6) 0 var(--space-16);
  position: relative;
  overflow-x: hidden;
}

.bg-gradient {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: 
    radial-gradient(ellipse at top left, rgba(0, 255, 159, 0.05) 0%, transparent 50%),
    radial-gradient(ellipse at bottom right, rgba(10, 132, 255, 0.05) 0%, transparent 50%),
    var(--bg-primary);
  z-index: -2;
}

.bg-noise {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  opacity: 0.03;
  background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noiseFilter'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='3' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noiseFilter)'/%3E%3C/svg%3E");
  z-index: -1;
  pointer-events: none;
}

.container {
  max-width: var(--container-sm);
  margin: 0 auto;
  padding: 0 var(--space-4);
  overflow-x: hidden;
  width: 100%;
}

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

.terminal-text {
  font-family: var(--font-mono);
  color: var(--text-accent);
}

.cursor {
  animation: blink 1s step-end infinite;
}

.error-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--space-3);
  text-align: center;
  margin-top: var(--space-16);
}

.statements-list {
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
  margin-top: var(--space-6);
  overflow-x: hidden;
  width: 100%;
}

.reset-container {
  display: flex;
  justify-content: center;
  margin-top: var(--space-4);
}

.reset-button {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  padding: var(--space-2) var(--space-4);
  background: var(--bg-secondary);
  border: 1px solid var(--border-default);
  border-radius: var(--radius-md);
  color: var(--text-secondary);
  font-size: var(--text-sm);
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
}

.reset-button:hover {
  background: var(--bg-tertiary);
  border-color: var(--border-focus);
  color: var(--text-primary);
  transform: translateY(-1px);
}

.reset-button:active {
  transform: translateY(0);
}

.reset-button.disabled,
.reset-button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  pointer-events: none;
}

.reset-icon {
  font-size: 1.2em;
  transition: transform 0.3s ease;
}

.reset-button:hover .reset-icon {
  transform: rotate(-180deg);
}

/* Connection indicator */
.connection-indicator {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: var(--space-2);
  padding: var(--space-2) var(--space-3);
  margin: var(--space-3) auto 0;
  border-radius: var(--radius-full);
  background: var(--bg-secondary);
  border: 1px solid var(--border-default);
  font-size: var(--text-xs);
  font-family: var(--font-mono);
  max-width: fit-content;
  transition: all 0.3s ease;
}

.connection-indicator.connected {
  border-color: rgba(52, 211, 153, 0.3);
  background: rgba(52, 211, 153, 0.1);
}

.connection-indicator .dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: var(--accent-error);
  transition: background 0.3s ease;
}

.connection-indicator.connected .dot {
  background: var(--accent-success);
  box-shadow: 0 0 8px var(--accent-success);
}

.connection-indicator .text {
  color: var(--text-secondary);
}

.connection-indicator.connected .text {
  color: var(--accent-success);
}

/* Finalized indicator */
.finalized-indicator {
  display: flex;
  align-items: center;
  gap: var(--space-4);
  padding: var(--space-4);
  margin: var(--space-4) auto;
  max-width: 600px;
  border: 1px solid rgba(251, 191, 36, 0.3);
  background: rgba(251, 191, 36, 0.1);
}

.finalized-icon {
  font-size: var(--text-2xl);
  flex-shrink: 0;
}

.finalized-content {
  flex: 1;
}

.finalized-title {
  font-size: var(--text-sm);
  font-weight: var(--font-semibold);
  color: var(--text-primary);
  margin-bottom: var(--space-1);
}

.finalized-text {
  font-size: var(--text-xs);
  color: var(--text-secondary);
  line-height: var(--leading-relaxed);
}
</style>
