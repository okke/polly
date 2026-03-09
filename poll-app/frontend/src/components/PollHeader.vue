<script setup>
import { ref, onMounted } from 'vue'

const props = defineProps({
  title: {
    type: String,
    required: true
  },
  answered: {
    type: Number,
    default: 0
  },
  total: {
    type: Number,
    default: 0
  }
})

const displayedTitle = ref('')
const showCursor = ref(true)

// Typing effect on mount
onMounted(() => {
  let index = 0
  const typeInterval = setInterval(() => {
    if (index < props.title.length) {
      displayedTitle.value = props.title.substring(0, index + 1)
      index++
    } else {
      clearInterval(typeInterval)
      // Hide cursor after typing complete
      setTimeout(() => {
        showCursor.value = false
      }, 1000)
    }
  }, 50)
})
</script>

<template>
  <header class="poll-header">
    <div class="title-container">
      <h1 class="title">
        {{ displayedTitle }}<span v-if="showCursor" class="cursor">▌</span>
      </h1>
      <div class="title-underline"></div>
    </div>
    
    <div class="progress-badge terminal-badge">
      <span class="prompt">$</span>
      <span class="command">progress</span>
      <span class="output">→ {{ answered }}/{{ total }}</span>
    </div>
  </header>
</template>

<style scoped>
.poll-header {
  padding: var(--space-8) 0 var(--space-4);
  animation: fadeUp var(--duration-slow) var(--ease-out);
}

.title-container {
  position: relative;
  display: inline-block;
}

.title {
  font-size: var(--text-3xl);
  font-weight: var(--font-semibold);
  color: var(--text-primary);
  letter-spacing: -0.02em;
}

.cursor {
  color: var(--text-accent);
  animation: blink 1s step-end infinite;
  font-weight: var(--font-normal);
}

.title-underline {
  height: 3px;
  background: linear-gradient(90deg, var(--text-accent), transparent);
  border-radius: var(--radius-full);
  margin-top: var(--space-2);
  animation: fadeUp var(--duration-slow) var(--ease-out) 0.3s backwards;
}

.progress-badge {
  margin-top: var(--space-4);
  animation: fadeUp var(--duration-slow) var(--ease-out) 0.4s backwards;
}

.terminal-badge {
  display: inline-flex;
  align-items: center;
  gap: var(--space-2);
  font-family: var(--font-mono);
  font-size: var(--text-sm);
  padding: var(--space-2) var(--space-3);
  background: var(--bg-elevated);
  border-radius: var(--radius-md);
  border: 1px solid var(--border-subtle);
}

.prompt {
  color: var(--text-tertiary);
}

.command {
  color: var(--text-accent);
}

.output {
  color: var(--text-secondary);
}

@media (max-width: 640px) {
  .title {
    font-size: var(--text-2xl);
  }
}
</style>
