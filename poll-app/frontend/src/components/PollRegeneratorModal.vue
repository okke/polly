<script setup>
import { ref, computed, onMounted } from 'vue'

const props = defineProps({
  visible: {
    type: Boolean,
    default: false
  },
  poll: {
    type: Object,
    default: null
  }
})

const emit = defineEmits(['close', 'regenerated'])

// Form state
const totalQuestions = ref(5)
const selectedStatements = ref([])
const model = ref('gpt-4o-mini')

// UI state
const isRegenerating = ref(false)
const error = ref(null)
const models = ref([])
const isLoadingModels = ref(true)
const showModelDropdown = ref(false)

// Computed
const pollContext = computed(() => props.poll?.context || {})
const currentStatements = computed(() => props.poll?.statements || [])
const keptCount = computed(() => selectedStatements.value.length)
const newCount = computed(() => Math.max(0, totalQuestions.value - keptCount.value))
const canRegenerate = computed(() => {
  return totalQuestions.value >= 3 && 
         totalQuestions.value <= 10 && 
         keptCount.value < totalQuestions.value
})

const selectedModel = computed(() => {
  return models.value.find(m => m.id === model.value)
})

// Fetch available models
async function fetchModels() {
  try {
    const response = await fetch('/api/models')
    const result = await response.json()
    
    if (result.status === 'ok' && result.models) {
      models.value = result.models
      
      // Set default to first model if available
      if (models.value.length > 0 && !model.value) {
        model.value = models.value[0].id
      }
    }
  } catch (err) {
    console.error('Failed to fetch models:', err)
  } finally {
    isLoadingModels.value = false
  }
}

// Toggle statement selection
function toggleStatement(statement) {
  const text = statement.text
  const index = selectedStatements.value.indexOf(text)
  
  if (index === -1) {
    selectedStatements.value.push(text)
  } else {
    selectedStatements.value.splice(index, 1)
  }
}

function isSelected(statement) {
  return selectedStatements.value.includes(statement.text)
}

// Select all / none
function selectAll() {
  selectedStatements.value = currentStatements.value.map(s => s.text)
}

function selectNone() {
  selectedStatements.value = []
}

// Regenerate poll
async function regenerate() {
  if (!canRegenerate.value) return
  
  isRegenerating.value = true
  error.value = null
  
  try {
    const response = await fetch(`/api/polls/${props.poll.id}/regenerate`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        kept_statements: selectedStatements.value,
        total_questions: totalQuestions.value,
        model: model.value
      })
    })
    
    const result = await response.json()
    
    if (result.status === 'ok') {
      emit('regenerated', result)
      close()
    } else {
      error.value = result.details || result.error || 'Failed to regenerate poll'
    }
  } catch (err) {
    console.error('Regeneration error:', err)
    error.value = 'Network error. Please try again.'
  } finally {
    isRegenerating.value = false
  }
}

function close() {
  emit('close')
  // Reset state
  setTimeout(() => {
    selectedStatements.value = []
    totalQuestions.value = props.poll?.statements?.length || 5
    error.value = null
  }, 300)
}

function toggleModelDropdown() {
  showModelDropdown.value = !showModelDropdown.value
}

// Initialize
onMounted(() => {
  fetchModels()
  if (props.poll?.statements) {
    totalQuestions.value = props.poll.statements.length
  }
})
</script>

<template>
  <Teleport to="body">
    <Transition name="modal">
      <div v-if="visible" class="modal-overlay" @click="close">
        <div class="modal-container" @click.stop>
          <div class="modal-header">
            <h2 class="modal-title">🔄 Regenerate Poll</h2>
            <button class="close-button" @click="close" title="Close">✕</button>
          </div>
          
          <div class="modal-body">
            <!-- Poll Context Info -->
            <div class="context-info">
              <h3 class="section-title">Original Context</h3>
              <div class="context-grid">
                <div class="context-item">
                  <span class="context-label">Topic:</span>
                  <span class="context-value">{{ pollContext.topic }}</span>
                </div>
                <div class="context-item">
                  <span class="context-label">Tone:</span>
                  <span class="context-value">{{ pollContext.tone }}</span>
                </div>
                <div class="context-item">
                  <span class="context-label">Audience:</span>
                  <span class="context-value">{{ pollContext.audience }}</span>
                </div>
              </div>
              <p class="context-note">
                ℹ️ The regenerated poll will maintain the same context
              </p>
            </div>

            <!-- Statement Selection -->
            <div class="statements-section">
              <div class="section-header">
                <h3 class="section-title">Select Statements to Keep</h3>
                <div class="selection-buttons">
                  <button class="select-btn" @click="selectAll">All</button>
                  <button class="select-btn" @click="selectNone">None</button>
                </div>
              </div>
              
              <div class="statements-list">
                <div 
                  v-for="(statement, idx) in currentStatements" 
                  :key="statement.id"
                  class="statement-item"
                  :class="{ selected: isSelected(statement) }"
                  @click="toggleStatement(statement)"
                >
                  <div class="checkbox">
                    <span v-if="isSelected(statement)" class="checkmark">✓</span>
                  </div>
                  <div class="statement-text">{{ statement.text }}</div>
                </div>
              </div>
            </div>

            <!-- Configuration -->
            <div class="config-section">
              <h3 class="section-title">Configuration</h3>
              
              <div class="config-grid">
                <!-- Total Questions -->
                <div class="form-group">
                  <label class="label">Total Statements</label>
                  <input 
                    v-model.number="totalQuestions"
                    type="number"
                    min="3"
                    max="10"
                    class="input-number"
                  />
                </div>

                <!-- Model Selection -->
                <div class="form-group">
                  <label class="label">AI Model</label>
                  <div class="custom-select" @click="toggleModelDropdown">
                    <div class="select-trigger">
                      <div class="select-content">
                        <span v-if="selectedModel" class="model-name">{{ selectedModel.name }}</span>
                        <span v-else-if="isLoadingModels" class="model-name">Loading...</span>
                        <span v-else class="model-name">Select model</span>
                      </div>
                      <span class="select-arrow">▼</span>
                    </div>
                    
                    <Transition name="dropdown">
                      <div v-if="showModelDropdown" class="select-dropdown">
                        <div 
                          v-for="m in models" 
                          :key="m.id"
                          class="select-option"
                          :class="{ selected: m.id === model }"
                          @click.stop="model = m.id; showModelDropdown = false"
                        >
                          <div class="option-content">
                            <span class="option-name">{{ m.name }}</span>
                            <span class="option-tier">{{ m.tier }}</span>
                          </div>
                        </div>
                      </div>
                    </Transition>
                  </div>
                </div>
              </div>

              <!-- Summary -->
              <div class="summary">
                <div class="summary-item">
                  <span class="summary-label">Keeping:</span>
                  <span class="summary-value keep">{{ keptCount }}</span>
                </div>
                <div class="summary-item">
                  <span class="summary-label">Generating:</span>
                  <span class="summary-value new">{{ newCount }}</span>
                </div>
                <div class="summary-item">
                  <span class="summary-label">Total:</span>
                  <span class="summary-value total">{{ totalQuestions }}</span>
                </div>
              </div>
            </div>

            <!-- Error Display -->
            <div v-if="error" class="error-message">
              {{ error }}
            </div>

            <!-- Warning -->
            <div class="warning-box">
              ⚠️ Regenerating will reset all votes for this poll
            </div>
          </div>

          <div class="modal-footer">
            <button class="button secondary" @click="close" :disabled="isRegenerating">
              Cancel
            </button>
            <button 
              class="button primary" 
              @click="regenerate"
              :disabled="!canRegenerate || isRegenerating"
            >
              <span v-if="isRegenerating" class="spinner"></span>
              <span v-else>{{ newCount > 0 ? `Generate ${newCount} New` : 'Save Changes' }}</span>
            </button>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<style scoped>
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.7);
  backdrop-filter: blur(8px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
  padding: var(--space-4);
}

.modal-container {
  background: var(--bg-elevated);
  border-radius: var(--radius-xl);
  border: 1px solid var(--border-default);
  max-width: 700px;
  width: 100%;
  max-height: 90vh;
  display: flex;
  flex-direction: column;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.5);
}

.modal-header {
  padding: var(--space-6);
  border-bottom: 1px solid var(--border-subtle);
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.modal-title {
  font-size: var(--text-2xl);
  font-weight: var(--font-bold);
  margin: 0;
  color: var(--text-primary);
}

.close-button {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid var(--border-subtle);
  color: var(--text-secondary);
  font-size: 1.25rem;
  cursor: pointer;
  transition: all var(--duration-fast);
  display: flex;
  align-items: center;
  justify-content: center;
}

.close-button:hover {
  background: rgba(239, 68, 68, 0.1);
  border-color: rgba(239, 68, 68, 0.3);
  color: var(--accent-danger);
  transform: rotate(90deg);
}

.modal-body {
  padding: var(--space-6);
  overflow-y: auto;
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: var(--space-6);
}

.section-title {
  font-size: var(--text-lg);
  font-weight: var(--font-semibold);
  margin: 0 0 var(--space-3) 0;
  color: var(--text-primary);
}

/* Context Info */
.context-info {
  background: var(--bg-secondary);
  border: 1px solid var(--border-subtle);
  border-radius: var(--radius-lg);
  padding: var(--space-4);
}

.context-grid {
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
  margin-bottom: var(--space-3);
}

.context-item {
  display: flex;
  gap: var(--space-2);
  font-size: var(--text-sm);
}

.context-label {
  color: var(--text-tertiary);
  font-weight: var(--font-medium);
  min-width: 80px;
}

.context-value {
  color: var(--text-primary);
  font-family: var(--font-mono);
}

.context-note {
  margin: 0;
  font-size: var(--text-sm);
  color: var(--text-tertiary);
  font-style: italic;
}

/* Statements Section */
.statements-section {
  background: var(--bg-secondary);
  border: 1px solid var(--border-subtle);
  border-radius: var(--radius-lg);
  padding: var(--space-4);
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--space-3);
}

.selection-buttons {
  display: flex;
  gap: var(--space-2);
}

.select-btn {
  padding: var(--space-1) var(--space-3);
  background: var(--bg-primary);
  border: 1px solid var(--border-default);
  border-radius: var(--radius-md);
  color: var(--text-secondary);
  font-size: var(--text-sm);
  cursor: pointer;
  transition: all var(--duration-fast);
}

.select-btn:hover {
  background: var(--bg-elevated);
  color: var(--text-primary);
  border-color: var(--accent-primary);
}

.statements-list {
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
  max-height: 300px;
  overflow-y: auto;
}

.statement-item {
  display: flex;
  align-items: flex-start;
  gap: var(--space-3);
  padding: var(--space-3);
  background: var(--bg-primary);
  border: 1px solid var(--border-subtle);
  border-radius: var(--radius-md);
  cursor: pointer;
  transition: all var(--duration-fast);
}

.statement-item:hover {
  border-color: var(--accent-primary);
  background: var(--bg-elevated);
}

.statement-item.selected {
  border-color: var(--accent-primary);
  background: rgba(139, 92, 246, 0.1);
}

.checkbox {
  width: 20px;
  height: 20px;
  border: 2px solid var(--border-default);
  border-radius: 4px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  transition: all var(--duration-fast);
  margin-top: 2px;
}

.statement-item.selected .checkbox {
  background: var(--accent-primary);
  border-color: var(--accent-primary);
}

.checkmark {
  color: white;
  font-size: 14px;
  font-weight: bold;
}

.statement-text {
  flex: 1;
  color: var(--text-primary);
  font-size: var(--text-sm);
  line-height: 1.5;
}

/* Config Section */
.config-section {
  background: var(--bg-secondary);
  border: 1px solid var(--border-subtle);
  border-radius: var(--radius-lg);
  padding: var(--space-4);
}

.config-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--space-4);
  margin-bottom: var(--space-4);
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
}

.label {
  font-size: var(--text-sm);
  font-weight: var(--font-medium);
  color: var(--text-secondary);
}

.input-number {
  padding: var(--space-2) var(--space-3);
  background: var(--bg-primary);
  border: 1px solid var(--border-default);
  border-radius: var(--radius-md);
  color: var(--text-primary);
  font-size: var(--text-base);
  transition: border-color var(--duration-fast);
}

.input-number:focus {
  outline: none;
  border-color: var(--accent-primary);
}

/* Custom Select */
.custom-select {
  position: relative;
  cursor: pointer;
}

.select-trigger {
  padding: var(--space-2) var(--space-3);
  background: var(--bg-primary);
  border: 1px solid var(--border-default);
  border-radius: var(--radius-md);
  display: flex;
  justify-content: space-between;
  align-items: center;
  transition: border-color var(--duration-fast);
}

.select-trigger:hover {
  border-color: var(--accent-primary);
}

.select-content {
  flex: 1;
  text-align: left;
}

.model-name {
  color: var(--text-primary);
  font-size: var(--text-sm);
}

.select-arrow {
  color: var(--text-tertiary);
  font-size: 0.75rem;
  transition: transform var(--duration-fast);
}

.select-dropdown {
  position: absolute;
  top: calc(100% + 4px);
  left: 0;
  right: 0;
  background: var(--bg-elevated);
  border: 1px solid var(--border-default);
  border-radius: var(--radius-md);
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
  z-index: 100;
  max-height: 200px;
  overflow-y: auto;
}

.select-option {
  padding: var(--space-2) var(--space-3);
  cursor: pointer;
  transition: background var(--duration-fast);
}

.select-option:hover {
  background: var(--bg-secondary);
}

.select-option.selected {
  background: rgba(139, 92, 246, 0.1);
}

.option-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.option-name {
  color: var(--text-primary);
  font-size: var(--text-sm);
}

.option-tier {
  font-size: var(--text-xs);
  color: var(--text-tertiary);
  text-transform: uppercase;
}

/* Summary */
.summary {
  display: flex;
  gap: var(--space-4);
  padding: var(--space-3);
  background: var(--bg-primary);
  border-radius: var(--radius-md);
  border: 1px solid var(--border-subtle);
}

.summary-item {
  display: flex;
  align-items: center;
  gap: var(--space-2);
}

.summary-label {
  font-size: var(--text-sm);
  color: var(--text-tertiary);
}

.summary-value {
  font-size: var(--text-xl);
  font-weight: var(--font-bold);
  font-family: var(--font-mono);
}

.summary-value.keep {
  color: var(--accent-success);
}

.summary-value.new {
  color: var(--accent-primary);
}

.summary-value.total {
  color: var(--text-accent);
}

/* Warning & Error */
.warning-box {
  padding: var(--space-3);
  background: rgba(251, 191, 36, 0.1);
  border: 1px solid rgba(251, 191, 36, 0.3);
  border-radius: var(--radius-md);
  color: rgb(251, 191, 36);
  font-size: var(--text-sm);
  text-align: center;
}

.error-message {
  padding: var(--space-3);
  background: rgba(239, 68, 68, 0.1);
  border: 1px solid rgba(239, 68, 68, 0.3);
  border-radius: var(--radius-md);
  color: var(--accent-danger);
  font-size: var(--text-sm);
}

.modal-footer {
  padding: var(--space-6);
  border-top: 1px solid var(--border-subtle);
  display: flex;
  justify-content: flex-end;
  gap: var(--space-3);
}

.button {
  padding: var(--space-3) var(--space-6);
  border-radius: var(--radius-lg);
  font-size: var(--text-base);
  font-weight: var(--font-medium);
  cursor: pointer;
  transition: all var(--duration-fast);
  display: flex;
  align-items: center;
  gap: var(--space-2);
}

.button.secondary {
  background: var(--bg-secondary);
  border: 1px solid var(--border-default);
  color: var(--text-primary);
}

.button.secondary:hover:not(:disabled) {
  background: var(--bg-elevated);
  border-color: var(--accent-primary);
}

.button.primary {
  background: linear-gradient(135deg, var(--accent-primary) 0%, rgba(59, 130, 246, 0.8) 100%);
  border: none;
  color: white;
}

.button.primary:hover:not(:disabled) {
  transform: translateY(-1px);
  box-shadow: 0 10px 30px rgba(139, 92, 246, 0.3);
}

.button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.spinner {
  width: 16px;
  height: 16px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-top-color: white;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

/* Transitions */
.modal-enter-active,
.modal-leave-active {
  transition: opacity var(--duration-medium);
}

.modal-enter-active .modal-container,
.modal-leave-active .modal-container {
  transition: transform var(--duration-medium);
}

.modal-enter-from,
.modal-leave-to {
  opacity: 0;
}

.modal-enter-from .modal-container,
.modal-leave-to .modal-container {
  transform: scale(0.9);
}

.dropdown-enter-active,
.dropdown-leave-active {
  transition: all 0.2s ease;
}

.dropdown-enter-from,
.dropdown-leave-to {
  opacity: 0;
  transform: translateY(-10px);
}

/* Responsive */
@media (max-width: 640px) {
  .config-grid {
    grid-template-columns: 1fr;
  }
  
  .summary {
    flex-direction: column;
  }
}
</style>
