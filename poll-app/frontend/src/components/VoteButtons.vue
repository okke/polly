<script setup>
import { computed } from 'vue'

const props = defineProps({
  selectedVote: {
    type: String,
    default: null
  }
})

const emit = defineEmits(['vote'])

const voteOptions = [
  { value: 'strongly_agree', label: 'Strongly Agree', shortLabel: '++' },
  { value: 'agree', label: 'Agree', shortLabel: '+' },
  { value: 'disagree', label: 'Disagree', shortLabel: '-' },
  { value: 'strongly_disagree', label: 'Strongly Disagree', shortLabel: '--' }
]

function handleClick(value) {
  emit('vote', value)
}
</script>

<template>
  <div class="vote-buttons">
    <button
      v-for="option in voteOptions"
      :key="option.value"
      class="vote-button"
      :class="[
        option.value.replace('_', '-'),
        { selected: selectedVote === option.value, dimmed: selectedVote && selectedVote !== option.value }
      ]"
      @click="handleClick(option.value)"
      :aria-pressed="selectedVote === option.value"
    >
      <span class="vote-label">{{ option.label }}</span>
      <span class="vote-short">{{ option.shortLabel }}</span>
    </button>
  </div>
</template>

<style scoped>
.vote-buttons {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: var(--space-2);
}

.vote-button {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: var(--space-1);
  padding: var(--space-3) var(--space-2);
  background: var(--bg-elevated);
  border: 1px solid var(--border-subtle);
  border-radius: var(--radius-lg);
  cursor: pointer;
  transition: 
    transform var(--duration-fast) var(--ease-out),
    background var(--duration-fast) var(--ease-out),
    border-color var(--duration-fast) var(--ease-out),
    box-shadow var(--duration-fast) var(--ease-out),
    opacity var(--duration-fast) var(--ease-out);
}

.vote-button:hover {
  transform: translateY(-2px);
  border-color: var(--border-default);
}

.vote-button:active {
  transform: translateY(0);
}

.vote-button.dimmed {
  opacity: 0.4;
}

.vote-button.dimmed:hover {
  opacity: 0.7;
}

/* Selected states with color glow */
.vote-button.selected {
  transform: translateY(-2px);
}

.vote-button.strongly-agree.selected {
  background: var(--strongly-agree-bg);
  border-color: var(--strongly-agree);
  box-shadow: 0 4px 20px rgba(126, 231, 135, 0.25);
}

.vote-button.agree.selected {
  background: var(--agree-bg);
  border-color: var(--agree);
  box-shadow: 0 4px 20px rgba(88, 166, 255, 0.25);
}

.vote-button.disagree.selected {
  background: var(--disagree-bg);
  border-color: var(--disagree);
  box-shadow: 0 4px 20px rgba(240, 136, 62, 0.25);
}

.vote-button.strongly-disagree.selected {
  background: var(--strongly-disagree-bg);
  border-color: var(--strongly-disagree);
  box-shadow: 0 4px 20px rgba(248, 81, 73, 0.25);
}

.vote-label {
  font-size: var(--text-xs);
  font-weight: var(--font-medium);
  color: var(--text-secondary);
  transition: color var(--duration-fast) var(--ease-out);
}

.vote-short {
  font-family: var(--font-mono);
  font-size: var(--text-lg);
  font-weight: var(--font-semibold);
  color: var(--text-tertiary);
  transition: color var(--duration-fast) var(--ease-out);
}

/* Selected text colors */
.vote-button.strongly-agree.selected .vote-label,
.vote-button.strongly-agree.selected .vote-short {
  color: var(--strongly-agree);
}

.vote-button.agree.selected .vote-label,
.vote-button.agree.selected .vote-short {
  color: var(--agree);
}

.vote-button.disagree.selected .vote-label,
.vote-button.disagree.selected .vote-short {
  color: var(--disagree);
}

.vote-button.strongly-disagree.selected .vote-label,
.vote-button.strongly-disagree.selected .vote-short {
  color: var(--strongly-disagree);
}

@media (max-width: 640px) {
  .vote-buttons {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .vote-button {
    padding: var(--space-4) var(--space-3);
  }
  
  .vote-label {
    font-size: var(--text-sm);
  }
}
</style>
