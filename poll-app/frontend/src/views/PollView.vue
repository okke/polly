<script setup>
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'
import axios from 'axios'
import { useParticipant } from '../composables/useParticipant.js'
import { useSocket } from '../composables/useSocket.js'
import PollHeader from '../components/PollHeader.vue'
import StatementCard from '../components/StatementCard.vue'
import SubmitButton from '../components/SubmitButton.vue'
import SuccessOverlay from '../components/SuccessOverlay.vue'

const { participantId } = useParticipant()
const { connect, disconnect } = useSocket()

const poll = ref(null)
const votes = ref({})
const isLoading = ref(true)
const isSubmitting = ref(false)
const showSuccess = ref(false)
const error = ref(null)

// Compute progress
const answeredCount = computed(() => Object.keys(votes.value).length)
const totalCount = computed(() => poll.value?.statements?.length || 0)
const allAnswered = computed(() => answeredCount.value === totalCount.value && totalCount.value > 0)

// Load previous votes from localStorage
function loadSavedVotes() {
  const saved = localStorage.getItem('polly-votes')
  if (saved) {
    try {
      votes.value = JSON.parse(saved)
    } catch (e) {
      // Invalid saved data
    }
  }
}

// Save votes to localStorage
function saveVotes() {
  localStorage.setItem('polly-votes', JSON.stringify(votes.value))
}

// Watch for vote changes and save
watch(votes, saveVotes, { deep: true })

// Fetch poll data
async function fetchPoll() {
  try {
    const response = await axios.get('/api/poll')
    poll.value = response.data
    isLoading.value = false
  } catch (e) {
    error.value = 'Failed to load poll. Is the server running?'
    isLoading.value = false
  }
}

// Handle vote selection
async function handleVote(statementId, voteValue) {
  votes.value[statementId] = voteValue
  
  // Get participant ID (should always be available now)
  const pid = participantId.value
  if (!pid) {
    console.error('No participant ID available')
    return
  }
  
  try {
    console.log(`[Vote] ${pid.substring(0,8)}... -> ${statementId}: ${voteValue}`)
    const response = await axios.post('/api/vote', {
      participant_id: pid,
      statement_id: statementId,
      vote: voteValue
    })
    console.log('[Vote] Response:', response.data)
  } catch (e) {
    console.error('Failed to submit vote:', e)
    // Show error to user
    error.value = 'Failed to submit vote. Check your connection.'
    setTimeout(() => { error.value = null }, 3000)
  }
}

// Submit all votes (for confirmation)
async function submitAllVotes() {
  if (!allAnswered.value || isSubmitting.value) return
  
  isSubmitting.value = true
  
  try {
    // Votes are already submitted individually, just show success
    showSuccess.value = true
    
    // Hide success after 3 seconds
    setTimeout(() => {
      showSuccess.value = false
    }, 3000)
  } catch (e) {
    error.value = 'Failed to submit votes'
  } finally {
    isSubmitting.value = false
  }
}

onMounted(() => {
  loadSavedVotes()
  fetchPoll()
  connect() // Connect to WebSocket for live tracking
})

onUnmounted(() => {
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
        
        <div class="statements-list stagger-children">
          <StatementCard
            v-for="(statement, index) in poll.statements"
            :key="statement.id"
            :statement="statement"
            :index="index"
            :selectedVote="votes[statement.id]"
            @vote="handleVote"
          />
        </div>
        
        <SubmitButton
          :visible="allAnswered"
          :loading="isSubmitting"
          @submit="submitAllVotes"
        />
      </template>
    </div>
    
    <SuccessOverlay :visible="showSuccess" />
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
}
</style>
