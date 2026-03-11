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
  },
  participantCount: {
    type: Number,
    default: 0
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
    <div v-if="visible" class="group-analysis-overlay" @click.self="emit('close')">
      <div class="group-analysis-content glass-card">
        <!-- Close button -->
        <button class="close-button" @click="emit('close')" title="Close">×</button>
        
        <!-- Loading state -->
        <template v-if="loading">
          <div class="analysis-header">
            <div class="analysis-icon loading-icon">🧠</div>
            <div class="analysis-title-section">
              <span class="terminal-prompt">[ GROUP ANALYSIS ]</span>
              <h3 class="analysis-type">Analyzing {{ participantCount }} participant{{ participantCount !== 1 ? 's' : '' }}...</h3>
            </div>
          </div>
          
          <div class="loading-spinner-container">
            <div class="loading-spinner"></div>
            <p class="loading-text">Our expert is examining the collective psyche</p>
          </div>
        </template>
        
        <!-- Show analysis if available -->
        <template v-else-if="analysis">
          <div class="analysis-header">
            <div class="analysis-icon">🧠</div>
            <div class="analysis-title-section">
              <span class="terminal-prompt">[ GROUP ANALYSIS ]</span>
              <div class="participant-badge">{{ participantCount }} participant{{ participantCount !== 1 ? 's' : '' }}</div>
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
            <span class="disclaimer">🎭 Collective entertainment purposes only</span>
          </p>
        </template>
      </div>
    </div>
  </Transition>
</template>

<style scoped>
.group-analysis-overlay {
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

.group-analysis-content {
  display: flex;
  flex-direction: column;
  align-items: stretch;
  gap: var(--space-5);
  padding: var(--space-8);
  text-align: left;
  max-width: 650px;
  max-height: 85vh;
  overflow-y: auto;
  position: relative;
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

/* Analysis header */
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

.terminal-prompt {
  font-family: var(--font-mono);
  font-size: var(--text-sm);
  color: var(--text-accent);
  font-weight: var(--font-semibold);
}

.participant-badge {
  display: inline-block;
  padding: var(--space-1) var(--space-2);
  background: rgba(52, 211, 153, 0.15);
  border: 1px solid rgba(52, 211, 153, 0.3);
  border-radius: var(--radius-sm);
  font-size: var(--text-xs);
  font-family: var(--font-mono);
  color: var(--accent-success);
  width: fit-content;
}

.analysis-type {
  font-size: var(--text-xl);
  font-weight: var(--font-bold);
  color: var(--text-primary);
  margin: 0;
  line-height: 1.3;
}

/* Analysis body */
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

/* Footer */
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

/* Loading state */
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

/* Transitions */
.overlay-enter-active,
.overlay-leave-active {
  transition: 
    opacity var(--duration-normal) var(--ease-out),
    backdrop-filter var(--duration-normal) var(--ease-out);
}

.overlay-enter-active .group-analysis-content,
.overlay-leave-active .group-analysis-content {
  transition: 
    opacity var(--duration-normal) var(--ease-out),
    transform var(--duration-normal) var(--ease-spring);
}

.overlay-enter-from,
.overlay-leave-to {
  opacity: 0;
}

.overlay-enter-from .group-analysis-content,
.overlay-leave-to .group-analysis-content {
  opacity: 0;
  transform: scale(0.9);
}
</style>
