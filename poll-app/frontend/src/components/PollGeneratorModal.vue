<script setup>
import { ref, computed } from 'vue'

const props = defineProps({
  visible: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['close', 'accept'])

// Form state
const topic = ref('')
const tone = ref('professional')
const numQuestions = ref(5)
const audience = ref('')
const additionalContext = ref('')
const additionalInstructions = ref('')

// UI state
const isGenerating = ref(false)
const isReviewMode = ref(false)
const generatedPoll = ref(null)
const error = ref(null)

const toneOptions = [
  { value: 'professional', label: 'Professional' },
  { value: 'casual', label: 'Casual' },
  { value: 'academic', label: 'Academic' },
  { value: 'friendly', label: 'Friendly' },
  { value: 'formal', label: 'Formal' }
]

// Validation
const canGenerate = computed(() => {
  return topic.value.trim().length > 0 && 
         audience.value.trim().length > 0 &&
         !isGenerating.value
})

// Generate poll
async function handleGenerate() {
  if (!canGenerate.value) return
  
  isGenerating.value = true
  error.value = null
  
  try {
    const response = await fetch('/api/generate-poll', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        topic: topic.value.trim(),
        tone: tone.value,
        num_questions: numQuestions.value,
        audience: audience.value.trim(),
        additional_context: additionalContext.value.trim() || undefined,
        additional_instructions: additionalInstructions.value.trim() || undefined
      })
    })
    
    const result = await response.json()
    
    if (result.status === 'ok') {
      generatedPoll.value = result.poll
      isReviewMode.value = true
    } else {
      error.value = result.details || result.error || 'Failed to generate poll'
    }
  } catch (e) {
    console.error('Failed to generate poll:', e)
    error.value = 'Network error. Please check your connection and try again.'
  } finally {
    isGenerating.value = false
  }
}

// Regenerate (go back to form)
function handleRegenerate() {
  isReviewMode.value = false
  generatedPoll.value = null
  error.value = null
}

// Accept generated poll
function handleAccept() {
  if (generatedPoll.value) {
    emit('accept', generatedPoll.value)
    handleClose()
  }
}

// Close modal
function handleClose() {
  if (!isGenerating.value) {
    emit('close')
    // Reset after animation
    setTimeout(() => {
      resetForm()
    }, 300)
  }
}

// Reset form
function resetForm() {
  topic.value = ''
  tone.value = 'professional'
  numQuestions.value = 5
  audience.value = ''
  additionalContext.value = ''
  additionalInstructions.value = ''
  isReviewMode.value = false
  generatedPoll.value = null
  error.value = null
}

// Handle backdrop click
function handleBackdropClick(e) {
  if (e.target === e.currentTarget) {
    handleClose()
  }
}
</script>

<template>
  <Transition name="modal">
    <div v-if="visible" class="modal-backdrop" @click="handleBackdropClick">
      <div class="modal-container glass-card" @click.stop>
        <!-- Header -->
        <div class="modal-header">
          <h2 class="modal-title">
            <span class="terminal-prompt">[AI]</span>
            {{ isReviewMode ? 'Review Generated Poll' : 'Generate New Poll' }}
          </h2>
          <button 
            v-if="!isGenerating" 
            class="close-button" 
            @click="handleClose"
            aria-label="Close"
          >
            ✕
          </button>
        </div>
        
        <!-- Error message -->
        <div v-if="error" class="error-banner">
          <span class="error-icon">⚠</span>
          {{ error }}
        </div>
        
        <!-- Form Mode -->
        <div v-if="!isReviewMode" class="modal-body">
          <form @submit.prevent="handleGenerate" class="generator-form">
            <!-- Topic -->
            <div class="form-field">
              <label for="topic" class="field-label">
                Topic <span class="required">*</span>
              </label>
              <input
                id="topic"
                v-model="topic"
                type="text"
                class="field-input"
                placeholder="e.g., Remote work policies, Climate change awareness"
                maxlength="200"
                required
              />
              <span class="field-hint">{{ topic.length }}/200</span>
            </div>
            
            <!-- Tone -->
            <div class="form-field">
              <label for="tone" class="field-label">
                Tone of Voice <span class="required">*</span>
              </label>
              <select id="tone" v-model="tone" class="field-select">
                <option v-for="opt in toneOptions" :key="opt.value" :value="opt.value">
                  {{ opt.label }}
                </option>
              </select>
            </div>
            
            <!-- Number of Questions -->
            <div class="form-field">
              <label for="numQuestions" class="field-label">
                Number of Statements <span class="required">*</span>
              </label>
              <div class="slider-container">
                <input
                  id="numQuestions"
                  v-model.number="numQuestions"
                  type="range"
                  min="3"
                  max="10"
                  class="field-slider"
                />
                <span class="slider-value">{{ numQuestions }}</span>
              </div>
            </div>
            
            <!-- Audience -->
            <div class="form-field">
              <label for="audience" class="field-label">
                Expected Audience <span class="required">*</span>
              </label>
              <input
                id="audience"
                v-model="audience"
                type="text"
                class="field-input"
                placeholder="e.g., University students, Corporate employees, General public"
                maxlength="200"
                required
              />
              <span class="field-hint">{{ audience.length }}/200</span>
            </div>
            
            <!-- Additional Context -->
            <div class="form-field">
              <label for="context" class="field-label">
                Additional Context <span class="optional">(optional)</span>
              </label>
              <textarea
                id="context"
                v-model="additionalContext"
                class="field-textarea"
                placeholder="Any specific aspects or angles to focus on..."
                maxlength="300"
                rows="2"
              ></textarea>
              <span class="field-hint">{{ additionalContext.length }}/300</span>
            </div>
            
            <!-- Additional Instructions -->
            <div class="form-field">
              <label for="instructions" class="field-label">
                Additional Instructions <span class="optional">(optional)</span>
              </label>
              <textarea
                id="instructions"
                v-model="additionalInstructions"
                class="field-textarea"
                placeholder="Special requirements, what to avoid, specific terminology to use..."
                maxlength="500"
                rows="3"
              ></textarea>
              <span class="field-hint">{{ additionalInstructions.length }}/500</span>
            </div>
          </form>
        </div>
        
        <!-- Review Mode -->
        <div v-else-if="generatedPoll" class="modal-body review-mode">
          <div class="generated-poll">
            <div class="poll-title-preview">
              <span class="preview-label">Title:</span>
              <h3>{{ generatedPoll.title }}</h3>
            </div>
            
            <div class="statements-preview">
              <span class="preview-label">Statements:</span>
              <div class="statement-list">
                <div 
                  v-for="(statement, index) in generatedPoll.statements" 
                  :key="statement.id"
                  class="statement-preview-item"
                >
                  <span class="statement-number">{{ index + 1 }}</span>
                  <span class="statement-text">{{ statement.text }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
        
        <!-- Footer -->
        <div class="modal-footer">
          <div v-if="!isReviewMode">
            <button 
              type="button" 
              class="btn btn-secondary" 
              @click="handleClose"
              :disabled="isGenerating"
            >
              Cancel
            </button>
            <button 
              type="submit" 
              class="btn btn-primary" 
              @click="handleGenerate"
              :disabled="!canGenerate"
            >
              <span v-if="isGenerating" class="spinner"></span>
              <span v-else>Generate Poll</span>
            </button>
          </div>
          <div v-else>
            <button 
              type="button" 
              class="btn btn-secondary" 
              @click="handleRegenerate"
            >
              ← Regenerate
            </button>
            <button 
              type="button" 
              class="btn btn-primary" 
              @click="handleAccept"
            >
              Accept & Use
            </button>
          </div>
        </div>
      </div>
    </div>
  </Transition>
</template>

<style scoped>
.modal-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.7);
  backdrop-filter: blur(8px);
  -webkit-backdrop-filter: blur(8px);
  z-index: var(--z-modal);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: var(--space-4);
  overflow-y: auto;
}

.modal-container {
  width: 100%;
  max-width: 600px;
  max-height: 90vh;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.modal-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: var(--space-5);
  border-bottom: 1px solid var(--border-default);
}

.modal-title {
  font-size: var(--text-xl);
  font-weight: var(--font-semibold);
  color: var(--text-primary);
  display: flex;
  align-items: center;
  gap: var(--space-2);
}

.terminal-prompt {
  font-family: var(--font-mono);
  color: var(--accent-primary);
  font-size: var(--text-base);
}

.close-button {
  width: 32px;
  height: 32px;
  border: none;
  background: var(--bg-secondary);
  color: var(--text-secondary);
  border-radius: var(--radius-md);
  font-size: var(--text-lg);
  cursor: pointer;
  transition: all 0.2s ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.close-button:hover {
  background: var(--bg-tertiary);
  color: var(--text-primary);
}

.error-banner {
  background: rgba(255, 59, 48, 0.1);
  border: 1px solid rgba(255, 59, 48, 0.3);
  color: #ff3b30;
  padding: var(--space-3);
  margin: var(--space-4) var(--space-5) 0;
  border-radius: var(--radius-md);
  display: flex;
  align-items: center;
  gap: var(--space-2);
  font-size: var(--text-sm);
}

.error-icon {
  font-size: var(--text-lg);
}

.modal-body {
  flex: 1;
  overflow-y: auto;
  padding: var(--space-5);
}

.generator-form {
  display: flex;
  flex-direction: column;
  gap: var(--space-5);
}

.form-field {
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
}

.field-label {
  font-size: var(--text-sm);
  font-weight: var(--font-medium);
  color: var(--text-primary);
}

.required {
  color: var(--accent-primary);
}

.optional {
  color: var(--text-tertiary);
  font-weight: var(--font-normal);
}

.field-input,
.field-select,
.field-textarea {
  width: 100%;
  padding: var(--space-3);
  background: var(--bg-secondary);
  border: 1px solid var(--border-default);
  border-radius: var(--radius-md);
  color: var(--text-primary);
  font-size: var(--text-base);
  font-family: var(--font-system);
  transition: border-color 0.2s ease;
}

.field-input:focus,
.field-select:focus,
.field-textarea:focus {
  outline: none;
  border-color: var(--accent-primary);
}

.field-textarea {
  resize: vertical;
  min-height: 60px;
}

.field-hint {
  font-size: var(--text-xs);
  color: var(--text-tertiary);
  text-align: right;
}

.slider-container {
  display: flex;
  align-items: center;
  gap: var(--space-3);
}

.field-slider {
  flex: 1;
  height: 6px;
  background: var(--bg-secondary);
  border-radius: var(--radius-full);
  outline: none;
  -webkit-appearance: none;
}

.field-slider::-webkit-slider-thumb {
  -webkit-appearance: none;
  appearance: none;
  width: 20px;
  height: 20px;
  background: var(--accent-primary);
  border-radius: 50%;
  cursor: pointer;
  transition: transform 0.2s ease;
}

.field-slider::-webkit-slider-thumb:hover {
  transform: scale(1.2);
}

.field-slider::-moz-range-thumb {
  width: 20px;
  height: 20px;
  background: var(--accent-primary);
  border-radius: 50%;
  cursor: pointer;
  border: none;
  transition: transform 0.2s ease;
}

.field-slider::-moz-range-thumb:hover {
  transform: scale(1.2);
}

.slider-value {
  min-width: 32px;
  text-align: center;
  font-weight: var(--font-semibold);
  color: var(--text-primary);
  font-family: var(--font-mono);
}

.review-mode {
  padding: var(--space-6);
}

.generated-poll {
  display: flex;
  flex-direction: column;
  gap: var(--space-6);
}

.poll-title-preview,
.statements-preview {
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
}

.preview-label {
  font-size: var(--text-xs);
  font-weight: var(--font-medium);
  color: var(--text-tertiary);
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.poll-title-preview h3 {
  font-size: var(--text-2xl);
  color: var(--text-primary);
  font-weight: var(--font-semibold);
}

.statement-list {
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
}

.statement-preview-item {
  display: flex;
  gap: var(--space-3);
  padding: var(--space-4);
  background: var(--bg-secondary);
  border: 1px solid var(--border-default);
  border-radius: var(--radius-md);
  align-items: flex-start;
}

.statement-number {
  flex-shrink: 0;
  width: 24px;
  height: 24px;
  background: var(--accent-primary);
  color: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: var(--text-xs);
  font-weight: var(--font-semibold);
  font-family: var(--font-mono);
}

.statement-text {
  flex: 1;
  color: var(--text-primary);
  line-height: var(--leading-relaxed);
}

.modal-footer {
  padding: var(--space-5);
  border-top: 1px solid var(--border-default);
  display: flex;
  justify-content: flex-end;
}

.modal-footer > div {
  display: flex;
  gap: var(--space-3);
}

.btn {
  padding: var(--space-3) var(--space-5);
  border-radius: var(--radius-md);
  font-size: var(--text-base);
  font-weight: var(--font-medium);
  cursor: pointer;
  transition: all 0.2s ease;
  border: none;
  display: flex;
  align-items: center;
  gap: var(--space-2);
  min-width: 120px;
  justify-content: center;
}

.btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-secondary {
  background: var(--bg-secondary);
  color: var(--text-primary);
  border: 1px solid var(--border-default);
}

.btn-secondary:hover:not(:disabled) {
  background: var(--bg-tertiary);
}

.btn-primary {
  background: var(--accent-primary);
  color: white;
}

.btn-primary:hover:not(:disabled) {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(10, 132, 255, 0.3);
}

.spinner {
  width: 16px;
  height: 16px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-top-color: white;
  border-radius: 50%;
  animation: spin 0.6s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

/* Modal transitions */
.modal-enter-active,
.modal-leave-active {
  transition: opacity 0.3s ease;
}

.modal-enter-active .modal-container,
.modal-leave-active .modal-container {
  transition: transform 0.3s ease, opacity 0.3s ease;
}

.modal-enter-from,
.modal-leave-to {
  opacity: 0;
}

.modal-enter-from .modal-container {
  transform: scale(0.95);
  opacity: 0;
}

.modal-leave-to .modal-container {
  transform: scale(0.95);
  opacity: 0;
}

/* Scrollbar styling */
.modal-body::-webkit-scrollbar {
  width: 8px;
}

.modal-body::-webkit-scrollbar-track {
  background: var(--bg-secondary);
  border-radius: var(--radius-full);
}

.modal-body::-webkit-scrollbar-thumb {
  background: var(--border-default);
  border-radius: var(--radius-full);
}

.modal-body::-webkit-scrollbar-thumb:hover {
  background: var(--text-tertiary);
}
</style>
