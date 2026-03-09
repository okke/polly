<script setup>
import ResultChart from './ResultChart.vue'

const props = defineProps({
  results: {
    type: Array,
    default: () => []
  }
})
</script>

<template>
  <div class="results-grid">
    <div 
      v-for="(result, index) in results" 
      :key="result.id"
      class="result-card glass-card"
      :style="{ animationDelay: `${index * 60}ms` }"
    >
      <div class="card-header">
        <span class="statement-number font-mono">{{ String(index + 1).padStart(2, '0') }}</span>
        <span class="vote-count font-mono">n={{ result.total }}</span>
      </div>
      
      <p class="statement-text">{{ result.text }}</p>
      
      <ResultChart :votes="result.votes" :total="result.total" />
    </div>
  </div>
</template>

<style scoped>
.results-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
  gap: var(--space-4);
}

.result-card {
  padding: var(--space-5);
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
  opacity: 0;
  animation: fadeUp var(--duration-slow) var(--ease-out) forwards;
}

.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.statement-number {
  font-size: var(--text-xs);
  color: var(--text-tertiary);
  background: var(--bg-primary);
  padding: var(--space-1) var(--space-2);
  border-radius: var(--radius-sm);
}

.vote-count {
  font-size: var(--text-xs);
  color: var(--text-tertiary);
}

.statement-text {
  font-size: var(--text-base);
  color: var(--text-primary);
  line-height: var(--leading-relaxed);
}

@media (max-width: 900px) {
  .results-grid {
    grid-template-columns: 1fr;
  }
}
</style>
