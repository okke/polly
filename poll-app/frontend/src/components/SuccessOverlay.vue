<script setup>
defineProps({
  visible: {
    type: Boolean,
    default: false
  }
})
</script>

<template>
  <Transition name="overlay">
    <div v-if="visible" class="success-overlay">
      <div class="success-content glass-card">
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
</style>
