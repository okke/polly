<script setup>
import { ref, computed } from 'vue'
import axios from 'axios'

const props = defineProps({
  visible: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['close', 'generated'])

// Form state
const participantCount = ref(10)
const isGenerating = ref(false)
const error = ref(null)

// Validation
const canGenerate = computed(() => {
  const count = parseInt(participantCount.value)
  return count >= 1 && count <= 1000 && !isGenerating.value
})

// Generate random votes
async function handleGenerate() {
  if (!canGenerate.value) return
  
  isGenerating.value = true
  error.value = null
  
  try {
    const response = await axios.post('/api/generate-random-votes', {
      count: parseInt(participantCount.value)
    })
    
    if (response.data.status === 'ok') {
      emit('generated', {
        count: participantCount.value,
        totalParticipants: response.data.total_participants
      })
      handleClose()
    } else {
      throw new Error(response.data.error || 'Failed to generate random votes')
    }
  } catch (e) {
    console.error('Failed to generate random votes:', e)
    error.value = e.response?.data?.error || e.message || 'Failed to generate random votes'
  } finally {
    isGenerating.value = false
  }
}

// Close modal
function handleClose() {
  if (isGenerating.value) return
  
  // Reset form
  participantCount.value = 10
  error.value = null
  
  emit('close')
}

// Handle enter key
function handleKeyDown(e) {
  if (e.key === 'Enter' && canGenerate.value) {
    handleGenerate()
  }
}
</script>

<template>
  <Transition name="modal">
    <div v-if="visible" class="modal-overlay" @click.self="handleClose">
      <div class="modal-content glass-card">
        <!-- Header -->
        <div class="modal-header">
          <div class="header-content">
            <div class="icon-badge test-icon">🎲</div>
            <div>
              <h2 class="modal-title">Generate Random Votes</h2>
              <p class="modal-subtitle">Simulate participant voting for testing</p>
            </div>
          </div>
          <button class="close-btn" @click="handleClose" title="Close">×</button>
        </div>
        
        <!-- Body -->
        <div class="modal-body">
          <!-- Error message -->
          <div v-if="error" class="error-message">
            <span class="error-icon">⚠️</span>
            <span>{{ error }}</span>
          </div>
          
          <!-- Form -->
          <div class="form-group">
            <label for="participant-count" class="form-label">
              Number of Participants
              <span class="label-hint">(1-1000)</span>
            </label>
            <input
              id="participant-count"
              v-model="participantCount"
              type="number"
              min="1"
              max="1000"
              class="form-input"
              placeholder="Enter number of participants"
              :disabled="isGenerating"
              @keydown="handleKeyDown"
              autofocus
            />
            <p class="form-help">
              Random votes will be generated for each statement in the current poll.
            </p>
          </div>
        </div>
        
        <!-- Footer -->
        <div class="modal-footer">
          <button class="btn btn-secondary" @click="handleClose" :disabled="isGenerating">
            Cancel
          </button>
          <button 
            class="btn btn-primary" 
            @click="handleGenerate"
            :disabled="!canGenerate"
          >
            <span v-if="isGenerating" class="btn-spinner"></span>
            <span v-else class="btn-icon">🎲</span>
            <span>{{ isGenerating ? 'Generating...' : 'Generate Votes' }}</span>
          </button>
        </div>
      </div>
    </div>
  </Transition>
</template>

<style scoped>
.modal-overlay {
  position: fixed;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(0, 0, 0, 0.6);
  backdrop-filter: blur(8px);
  -webkit-backdrop-filter: blur(8px);
  z-index: var(--z-modal);
  padding: var(--space-4);
}

.modal-content {
  width: 100%;
  max-width: 500px;
  max-height: 90vh;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
}

/* Header */
.modal-header {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: var(--space-4);
  padding: var(--space-6);
  border-bottom: 1px solid var(--border-default);
}

.header-content {
  display: flex;
  align-items: flex-start;
  gap: var(--space-4);
  flex: 1;
}

.icon-badge {
  width: 48px;
  height: 48px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: var(--radius-lg);
  font-size: 1.5rem;
  flex-shrink: 0;
}

.test-icon {
  background: linear-gradient(135deg, rgba(251, 191, 36, 0.15), rgba(245, 158, 11, 0.15));
  border: 1px solid rgba(251, 191, 36, 0.3);
}

.modal-title {
  font-size: var(--text-xl);
  font-weight: var(--font-bold);
  color: var(--text-primary);
  margin: 0;
  line-height: 1.3;
}

.modal-subtitle {
  font-size: var(--text-sm);
  color: var(--text-secondary);
  margin: var(--space-1) 0 0 0;
}

.close-btn {
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--bg-tertiary);
  border: 1px solid var(--border-default);
  border-radius: 50%;
  color: var(--text-secondary);
  font-size: 1.5rem;
  line-height: 1;
  cursor: pointer;
  transition: all 0.2s ease;
  flex-shrink: 0;
}

.close-btn:hover {
  background: var(--bg-secondary);
  color: var(--text-primary);
  border-color: var(--border-focus);
  transform: scale(1.1);
}

.close-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  transform: none;
}

/* Body */
.modal-body {
  padding: var(--space-6);
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: var(--space-5);
}

.error-message {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  padding: var(--space-3);
  background: rgba(239, 68, 68, 0.1);
  border: 1px solid rgba(239, 68, 68, 0.3);
  border-radius: var(--radius-md);
  color: var(--accent-danger);
  font-size: var(--text-sm);
}

.error-icon {
  flex-shrink: 0;
}

/* Form */
.form-group {
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
}

.form-label {
  font-size: var(--text-sm);
  font-weight: var(--font-medium);
  color: var(--text-primary);
  display: flex;
  align-items: baseline;
  gap: var(--space-2);
}

.label-hint {
  font-size: var(--text-xs);
  font-weight: var(--font-normal);
  color: var(--text-tertiary);
  font-family: var(--font-mono);
}

.form-input {
  padding: var(--space-3);
  background: var(--bg-secondary);
  border: 1px solid var(--border-default);
  border-radius: var(--radius-md);
  color: var(--text-primary);
  font-size: var(--text-base);
  font-family: var(--font-mono);
  transition: all 0.2s ease;
}

.form-input:focus {
  outline: none;
  border-color: var(--border-focus);
  background: var(--bg-primary);
}

.form-input:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.form-help {
  font-size: var(--text-xs);
  color: var(--text-tertiary);
  margin: 0;
  line-height: 1.5;
}

/* Footer */
.modal-footer {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: var(--space-3);
  padding: var(--space-6);
  border-top: 1px solid var(--border-default);
}

.btn {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  padding: var(--space-3) var(--space-5);
  border-radius: var(--radius-lg);
  font-size: var(--text-sm);
  font-weight: var(--font-medium);
  cursor: pointer;
  transition: all 0.2s ease;
  border: 1px solid transparent;
}

.btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-secondary {
  background: var(--bg-secondary);
  border-color: var(--border-default);
  color: var(--text-secondary);
}

.btn-secondary:hover:not(:disabled) {
  background: var(--bg-tertiary);
  border-color: var(--border-focus);
  color: var(--text-primary);
}

.btn-primary {
  background: linear-gradient(135deg, rgba(251, 191, 36, 0.15), rgba(245, 158, 11, 0.15));
  border-color: rgba(251, 191, 36, 0.3);
  color: var(--text-primary);
}

.btn-primary:hover:not(:disabled) {
  background: linear-gradient(135deg, rgba(251, 191, 36, 0.2), rgba(245, 158, 11, 0.2));
  border-color: rgba(251, 191, 36, 0.5);
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(251, 191, 36, 0.2);
}

.btn-primary:active:not(:disabled) {
  transform: translateY(0);
}

.btn-icon {
  font-size: 1.1rem;
  line-height: 1;
}

.btn-spinner {
  width: 14px;
  height: 14px;
  border: 2px solid var(--border-default);
  border-top-color: var(--text-accent);
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

/* Transitions */
.modal-enter-active,
.modal-leave-active {
  transition: 
    opacity var(--duration-normal) var(--ease-out),
    backdrop-filter var(--duration-normal) var(--ease-out);
}

.modal-enter-active .modal-content,
.modal-leave-active .modal-content {
  transition: 
    opacity var(--duration-normal) var(--ease-out),
    transform var(--duration-normal) var(--ease-spring);
}

.modal-enter-from,
.modal-leave-to {
  opacity: 0;
}

.modal-enter-from .modal-content,
.modal-leave-to .modal-content {
  opacity: 0;
  transform: scale(0.95);
}
</style>
