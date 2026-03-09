<script setup>
import VoteButtons from './VoteButtons.vue'

const props = defineProps({
  statement: {
    type: Object,
    required: true
  },
  index: {
    type: Number,
    default: 0
  },
  selectedVote: {
    type: String,
    default: null
  }
})

const emit = defineEmits(['vote'])

function handleVote(voteValue) {
  emit('vote', props.statement.id, voteValue)
}
</script>

<template>
  <article 
    class="statement-card glass-card"
    :class="{ 'has-vote': selectedVote }"
    :style="{ animationDelay: `${index * 80}ms` }"
  >
    <div class="statement-number">
      <span class="number-label">{{ String(index + 1).padStart(2, '0') }}</span>
    </div>
    
    <p class="statement-text">{{ statement.text }}</p>
    
    <VoteButtons 
      :selectedVote="selectedVote"
      @vote="handleVote"
    />
  </article>
</template>

<style scoped>
.statement-card {
  padding: var(--space-5);
  opacity: 0;
  animation: fadeUp var(--duration-slow) var(--ease-out) forwards;
  transition: 
    border-color var(--duration-fast) var(--ease-out),
    box-shadow var(--duration-fast) var(--ease-out);
}

.statement-card.has-vote {
  border-color: var(--border-default);
}

.statement-number {
  margin-bottom: var(--space-3);
}

.number-label {
  font-family: var(--font-mono);
  font-size: var(--text-xs);
  color: var(--text-tertiary);
  background: var(--bg-primary);
  padding: var(--space-1) var(--space-2);
  border-radius: var(--radius-sm);
  letter-spacing: 0.05em;
}

.statement-text {
  font-size: var(--text-lg);
  color: var(--text-primary);
  line-height: var(--leading-relaxed);
  margin-bottom: var(--space-5);
}

@media (max-width: 640px) {
  .statement-card {
    padding: var(--space-4);
  }
  
  .statement-text {
    font-size: var(--text-base);
  }
}
</style>
