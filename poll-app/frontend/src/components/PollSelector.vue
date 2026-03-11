<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'
import { useRemoteLog } from '../composables/useRemoteLog.js'
import DeleteConfirmModal from './DeleteConfirmModal.vue'

const { info } = useRemoteLog()

const props = defineProps({
  currentPollId: String
})

const emit = defineEmits(['pollChanged', 'pollDeleted'])

const polls = ref([])
const isLoading = ref(true)
const pollToDelete = ref(null) // Poll object to delete
const isDeleting = ref(false)

// Fetch all polls
async function fetchPolls() {
  try {
    const response = await axios.get('/api/polls')
    polls.value = response.data.polls
    isLoading.value = false
    info('Polls list loaded', { count: polls.value.length })
  } catch (error) {
    console.error('Failed to fetch polls:', error)
    info('Failed to fetch polls', { error: error.message })
    isLoading.value = false
  }
}

// Activate a poll
async function activatePoll(pollId) {
  if (pollId === props.currentPollId) return
  
  try {
    info('Activating poll', { poll_id: pollId })
    await axios.post(`/api/polls/${pollId}/activate`)
    info('Poll activated successfully')
    emit('pollChanged', pollId)
    await fetchPolls() // Refresh the list
  } catch (error) {
    console.error('Failed to activate poll:', error)
    info('Failed to activate poll', { error: error.message })
    alert('Failed to activate poll: ' + error.message)
  }
}

// Show delete confirmation modal
function showDeleteModal(poll) {
  pollToDelete.value = poll
}

// Confirm delete
async function confirmDelete() {
  if (!pollToDelete.value) return
  
  isDeleting.value = true
  
  try {
    info('Deleting poll', { poll_id: pollToDelete.value.id })
    await axios.delete(`/api/polls/${pollToDelete.value.id}`)
    info('Poll deleted successfully')
    emit('pollDeleted', pollToDelete.value.id)
    pollToDelete.value = null
    await fetchPolls() // Refresh the list
  } catch (error) {
    console.error('Failed to delete poll:', error)
    info('Failed to delete poll', { error: error.message })
    alert('Failed to delete poll: ' + error.message)
  } finally {
    isDeleting.value = false
  }
}

// Cancel delete
function cancelDelete() {
  pollToDelete.value = null
}

// Format date nicely
function formatDate(isoString) {
  if (!isoString) return 'Unknown'
  const date = new Date(isoString)
  return date.toLocaleDateString('en-US', { 
    month: 'short', 
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

onMounted(() => {
  fetchPolls()
})

// Expose refresh method
defineExpose({ fetchPolls })
</script>

<template>
  <div class="poll-selector glass-card">
    <div class="card-header">
      <h3 class="card-title terminal-text">
        <span class="title-prefix">$</span> polls
      </h3>
    </div>
    
    <div v-if="isLoading" class="loading">
      <span class="terminal-text">loading...</span>
    </div>
    
    <div v-else-if="polls.length === 0" class="empty-state">
      <span class="terminal-text dim">No polls yet</span>
      <span class="terminal-text dim">Generate one to get started</span>
    </div>
    
    <div v-else class="polls-list">
      <div
        v-for="poll in polls"
        :key="poll.id"
        class="poll-item"
        :class="{ active: poll.id === currentPollId }"
      >
        <div class="poll-content" @click="activatePoll(poll.id)">
          <div class="poll-title">{{ poll.title }}</div>
          <div class="poll-meta terminal-text">
            <span class="poll-count">{{ poll.statement_count }} questions</span>
            <span class="poll-date">{{ formatDate(poll.created_at) }}</span>
          </div>
          <div v-if="poll.id === currentPollId" class="active-indicator terminal-text">
            ● active
          </div>
        </div>
        
        <button
          class="delete-btn"
          title="Delete poll"
          @click.stop="showDeleteModal(poll)"
        >
          <span>×</span>
        </button>
      </div>
    </div>
    
    <!-- Delete Confirmation Modal (teleported to body) -->
    <Teleport to="body">
      <DeleteConfirmModal
        :visible="pollToDelete !== null"
        :pollTitle="pollToDelete?.title || ''"
        :isDeleting="isDeleting"
        @confirm="confirmDelete"
        @cancel="cancelDelete"
      />
    </Teleport>
  </div>
</template>

<style scoped>
.poll-selector {
  padding: var(--space-4);
}

.card-header {
  margin-bottom: var(--space-4);
}

.card-title {
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  margin: 0;
}

.title-prefix {
  color: var(--accent);
  margin-right: 0.25rem;
}

.loading,
.empty-state {
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
  padding: var(--space-4) 0;
  text-align: center;
}

.dim {
  opacity: 0.5;
  font-size: 0.75rem;
}

.polls-list {
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
  max-height: 800px;
  overflow-y: auto;
  padding: 2px;
  margin: -2px;
}

.poll-item {
  display: flex;
  align-items: stretch;
  gap: var(--space-2);
  background: var(--bg-secondary);
  border: 1px solid var(--border-color);
  border-radius: 6px;
  transition: all 0.2s ease;
}

.poll-item:hover {
  background: var(--bg-tertiary);
  border-color: var(--accent);
  box-shadow: 0 0 0 1px var(--accent);
}

.poll-item.active {
  background: var(--bg-tertiary);
  border-color: rgba(52, 211, 153, 0.6);
  box-shadow: 0 0 0 1px rgba(52, 211, 153, 0.6), 0 0 12px rgba(52, 211, 153, 0.2);
}

.poll-item.active:hover {
  background: var(--bg-elevated);
  border-color: rgba(52, 211, 153, 0.8);
  box-shadow: 0 0 0 1px rgba(52, 211, 153, 0.8), 0 0 16px rgba(52, 211, 153, 0.3);
}

.poll-content {
  flex: 1;
  padding: var(--space-3);
  cursor: pointer;
  min-width: 0;
}

.poll-title {
  font-size: 0.875rem;
  font-weight: 500;
  margin-bottom: var(--space-1);
  line-height: 1.3;
  word-break: break-word;
}

.poll-meta {
  display: flex;
  gap: var(--space-3);
  font-size: 0.7rem;
  opacity: 0.6;
}

.poll-count::before {
  content: '📊 ';
}

.poll-date::before {
  content: '🕐 ';
}

.active-indicator {
  margin-top: var(--space-2);
  font-size: 0.7rem;
  color: rgb(52, 211, 153);
  font-weight: 600;
}

.delete-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  background: transparent;
  border: none;
  border-left: 1px solid var(--border-color);
  border-radius: 0 6px 6px 0;
  color: var(--text-secondary);
  cursor: pointer;
  font-size: 1.25rem;
  transition: all 0.2s ease;
  flex-shrink: 0;
}

.delete-btn:hover {
  background: rgba(239, 68, 68, 0.1);
  color: rgb(239, 68, 68);
}

/* Scrollbar styling */
.polls-list::-webkit-scrollbar {
  width: 6px;
}

.polls-list::-webkit-scrollbar-track {
  background: var(--bg-secondary);
  border-radius: 3px;
}

.polls-list::-webkit-scrollbar-thumb {
  background: var(--border-color);
  border-radius: 3px;
}

.polls-list::-webkit-scrollbar-thumb:hover {
  background: var(--accent);
}
</style>
