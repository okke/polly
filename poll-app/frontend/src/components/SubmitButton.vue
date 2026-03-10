<script setup>
const props = defineProps({
  visible: {
    type: Boolean,
    default: false
  },
  loading: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['submit'])

function handleClick() {
  if (!props.loading) {
    emit('submit')
  }
}
</script>

<template>
  <Transition name="submit">
    <div v-if="visible" class="submit-container">
      <button 
        class="submit-button"
        :class="{ loading }"
        :disabled="loading"
        @click="handleClick"
      >
        <span v-if="!loading" class="button-content">
          <span class="button-text">Finalize Votes</span>
          <span class="button-icon">→</span>
        </span>
        <span v-else class="loading-content">
          <span class="spinner"></span>
          <span>Finalizing...</span>
        </span>
      </button>
      
      <span class="hint terminal-text">
        press <kbd>Enter</kbd> to finalize
      </span>
    </div>
  </Transition>
</template>

<style scoped>
.submit-container {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  padding: var(--space-4);
  background: linear-gradient(to top, var(--bg-primary) 60%, transparent);
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--space-2);
  z-index: var(--z-sticky);
}

.submit-button {
  display: flex;
  align-items: center;
  justify-content: center;
  min-width: 200px;
  padding: var(--space-4) var(--space-8);
  background: var(--accent-primary);
  color: white;
  font-size: var(--text-base);
  font-weight: var(--font-semibold);
  border-radius: var(--radius-xl);
  cursor: pointer;
  transition: 
    transform var(--duration-fast) var(--ease-out),
    box-shadow var(--duration-fast) var(--ease-out),
    background var(--duration-fast) var(--ease-out);
  animation: pulseGlow 2s var(--ease-in-out) infinite;
}

.submit-button:hover:not(:disabled) {
  transform: translateY(-2px);
  background: var(--accent-primary-hover);
  box-shadow: 0 8px 30px rgba(10, 132, 255, 0.4);
}

.submit-button:active:not(:disabled) {
  transform: translateY(0);
}

.submit-button:disabled {
  cursor: not-allowed;
  animation: none;
}

.button-content {
  display: flex;
  align-items: center;
  gap: var(--space-2);
}

.button-icon {
  font-size: var(--text-lg);
  transition: transform var(--duration-fast) var(--ease-out);
}

.submit-button:hover .button-icon {
  transform: translateX(4px);
}

.loading-content {
  display: flex;
  align-items: center;
  gap: var(--space-2);
}

.spinner {
  width: 16px;
  height: 16px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-top-color: white;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

.hint {
  font-size: var(--text-xs);
  color: var(--text-tertiary);
}

.hint kbd {
  background: var(--bg-elevated);
  padding: var(--space-1) var(--space-2);
  border-radius: var(--radius-sm);
  font-family: var(--font-mono);
  border: 1px solid var(--border-subtle);
}

/* Transition */
.submit-enter-active,
.submit-leave-active {
  transition: 
    opacity var(--duration-normal) var(--ease-out),
    transform var(--duration-normal) var(--ease-out);
}

.submit-enter-from,
.submit-leave-to {
  opacity: 0;
  transform: translateY(20px);
}

@media (max-width: 640px) {
  .submit-button {
    width: 100%;
    max-width: 300px;
  }
  
  .hint {
    display: none;
  }
}
</style>
