<script setup>
defineProps({
  visible: {
    type: Boolean,
    default: false
  },
  analysis: {
    type: String,
    default: null
  },
  loading: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['close'])

// Function to parse markdown-style bold headers (e.g., **Title**)
function parseAnalysis(text) {
  if (!text) return { title: null, body: text }
  
  // Look for bold markdown heading at start (e.g., **The Title**)
  const match = text.match(/^\*\*(.+?)\*\*\n\n(.+)$/s)
  
  if (match) {
    return {
      title: match[1],
      body: match[2]
    }
  }
  
  return { title: null, body: text }
}
</script>

<template>
  <Transition name="overlay">
    <div v-if="visible" class="success-overlay" @click.self="emit('close')">
      <div class="success-content glass-card" :class="{ 'has-analysis': analysis || loading }">
        <!-- Close button -->
        <button class="close-button" @click="emit('close')" title="Close">×</button>
        
        <!-- Loading state -->
        <template v-if="loading">
          <div class="analysis-header">
            <div class="analysis-icon loading-icon">🧠</div>
            <div class="analysis-title-section">
              <span class="terminal-prompt">[ ANALYZING ]</span>
              <h3 class="analysis-type">Consulting the experts...</h3>
            </div>
          </div>
          
          <div class="loading-spinner-container">
            <div class="loading-spinner"></div>
            <p class="loading-text">Generating your personalized analysis</p>
          </div>
        </template>
        
        <!-- Show analysis if available -->
        <template v-else-if="analysis">
          <div class="analysis-header">
            <div class="analysis-icon">🧠</div>
            <div class="analysis-title-section">
              <span class="terminal-prompt">[ ANALYSIS ]</span>
              <h3 v-if="parseAnalysis(analysis).title" class="analysis-type">
                {{ parseAnalysis(analysis).title }}
              </h3>
            </div>
          </div>
          
          <div class="analysis-body">
            <p v-for="(paragraph, index) in parseAnalysis(analysis).body.split('\n\n')" 
               :key="index" 
               class="analysis-paragraph">
              {{ paragraph }}
            </p>
          </div>
          
          <p class="analysis-footer">
            <span class="disclaimer">🎭 For entertainment purposes only</span>
          </p>
        </template>
        
        <!-- Default success message if no analysis -->
        <template v-else>
          <div class="success-icon">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M5 13l4 4L19 7" stroke-linecap="round" stroke-linejoin="round" class="checkmark" />
            </svg>
          </div>
          
          <div class="success-text">
            <span class="terminal-prompt">[ OK ]</span>
            <span class="terminal-message">votes_recorded</span>
          </div>
          
          <p class="success-subtitle">Thanks for participating!</p>
        </template>
      </div>
    </div>
  </Transition>
</template>

<style scoped>
.success-overlay {
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

.success-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--space-4);
  padding: var(--space-8);
  text-align: center;
  max-width: 320px;
  position: relative;
}

.success-content.has-analysis {
  max-width: 600px;
  text-align: left;
  align-items: stretch;
  gap: var(--space-5);
  max-height: 85vh;
  overflow-y: auto;
}

.close-button {
  position: absolute;
  top: var(--space-4);
  right: var(--space-4);
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
  z-index: 10;
}

.close-button:hover {
  background: var(--bg-secondary);
  color: var(--text-primary);
  border-color: var(--border-focus);
  transform: scale(1.1);
}

.success-icon {
  width: 64px;
  height: 64px;
  background: var(--strongly-agree-bg);
  border: 2px solid var(--strongly-agree);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--strongly-agree);
}

.success-icon svg {
  width: 32px;
  height: 32px;
}

.checkmark {
  stroke-dasharray: 100;
  stroke-dashoffset: 100;
  animation: checkmark 0.5s var(--ease-out) 0.2s forwards;
}

@keyframes checkmark {
  to {
    stroke-dashoffset: 0;
  }
}

.success-text {
  font-family: var(--font-mono);
  font-size: var(--text-lg);
  display: flex;
  align-items: center;
  gap: var(--space-2);
}

.terminal-prompt {
  color: var(--strongly-agree);
  font-weight: var(--font-semibold);
}

.terminal-message {
  color: var(--text-secondary);
}

.success-subtitle {
  color: var(--text-tertiary);
  font-size: var(--text-sm);
}

/* Transitions */
.overlay-enter-active,
.overlay-leave-active {
  transition: 
    opacity var(--duration-normal) var(--ease-out),
    backdrop-filter var(--duration-normal) var(--ease-out);
}

.overlay-enter-active .success-content,
.overlay-leave-active .success-content {
  transition: 
    opacity var(--duration-normal) var(--ease-out),
    transform var(--duration-normal) var(--ease-spring);
}

.overlay-enter-from,
.overlay-leave-to {
  opacity: 0;
}

.overlay-enter-from .success-content,
.overlay-leave-to .success-content {
  opacity: 0;
  transform: scale(0.9);
}

/* Analysis styles */
.analysis-header {
  display: flex;
  gap: var(--space-4);
  align-items: flex-start;
  padding-bottom: var(--space-4);
  border-bottom: 1px solid var(--border-default);
}

.analysis-icon {
  font-size: 3rem;
  line-height: 1;
  flex-shrink: 0;
}

.analysis-title-section {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
}

.analysis-type {
  font-size: var(--text-xl);
  font-weight: var(--font-bold);
  color: var(--text-primary);
  margin: 0;
  line-height: 1.3;
}

.analysis-body {
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
  color: var(--text-secondary);
  line-height: 1.7;
}

.analysis-paragraph {
  margin: 0;
  font-size: var(--text-base);
}

.analysis-footer {
  display: flex;
  justify-content: center;
  padding-top: var(--space-3);
  margin-top: var(--space-3);
  border-top: 1px solid var(--border-default);
}

.disclaimer {
  font-size: var(--text-xs);
  color: var(--text-tertiary);
  font-style: italic;
}

/* Loading state styles */
.loading-spinner-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--space-4);
  padding: var(--space-8) 0;
}

.loading-spinner {
  width: 48px;
  height: 48px;
  border: 4px solid var(--border-default);
  border-top-color: var(--text-accent);
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

.loading-text {
  color: var(--text-secondary);
  font-size: var(--text-sm);
  margin: 0;
  animation: pulse 2s ease-in-out infinite;
}

@keyframes pulse {
  0%, 100% {
    opacity: 1;
  }
  50% {
    opacity: 0.5;
  }
}

.loading-icon {
  animation: bounce 2s ease-in-out infinite;
}

@keyframes bounce {
  0%, 100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-10px);
  }
}
</style>
