<script setup>
import { computed, ref, watch } from 'vue'

const props = defineProps({
  votes: {
    type: Object,
    required: true
  },
  total: {
    type: Number,
    default: 0
  }
})

const voteTypes = [
  { key: 'strongly_agree', label: 'Strongly Agree', color: 'var(--strongly-agree)' },
  { key: 'agree', label: 'Agree', color: 'var(--agree)' },
  { key: 'disagree', label: 'Disagree', color: 'var(--disagree)' },
  { key: 'strongly_disagree', label: 'Strongly Disagree', color: 'var(--strongly-disagree)' }
]

const chartData = computed(() => {
  return voteTypes.map(type => {
    const count = props.votes[type.key] || 0
    const percentage = props.total > 0 ? (count / props.total) * 100 : 0
    
    return {
      ...type,
      count,
      percentage: Math.round(percentage)
    }
  })
})

// Update counts immediately (no animation for faster feedback)
const animatedCounts = ref({})

// Watch votes - shallow watch since we get a new object each time
watch(() => props.votes, (newVotes) => {
  voteTypes.forEach(type => {
    animatedCounts.value[type.key] = newVotes[type.key] || 0
  })
}, { immediate: true })
</script>

<template>
  <div class="result-chart">
    <div 
      v-for="item in chartData" 
      :key="item.key"
      class="chart-row"
    >
      <div class="row-label">
        <span class="label-text">{{ item.label }}</span>
        <span class="label-count font-mono">{{ animatedCounts[item.key] || 0 }}</span>
      </div>
      
      <div class="bar-container">
        <div 
          class="bar"
          :style="{ 
            width: `${item.percentage}%`,
            backgroundColor: item.color
          }"
        ></div>
      </div>
      
      <span class="percentage font-mono">{{ item.percentage }}%</span>
    </div>
  </div>
</template>

<style scoped>
.result-chart {
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
}

.chart-row {
  display: grid;
  grid-template-columns: 140px 1fr 50px;
  align-items: center;
  gap: var(--space-3);
}

.row-label {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--space-2);
}

.label-text {
  font-size: var(--text-sm);
  color: var(--text-secondary);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.label-count {
  font-size: var(--text-xs);
  color: var(--text-tertiary);
  min-width: 20px;
  text-align: right;
}

.bar-container {
  height: 24px;
  background: var(--bg-primary);
  border-radius: var(--radius-md);
  overflow: hidden;
  position: relative;
}

.bar {
  height: 100%;
  border-radius: var(--radius-md);
  transition: width 150ms var(--ease-out);
  min-width: 4px;
}

.percentage {
  font-size: var(--text-sm);
  color: var(--text-tertiary);
  text-align: right;
}

@media (max-width: 640px) {
  .chart-row {
    grid-template-columns: 100px 1fr 40px;
    gap: var(--space-2);
  }
  
  .label-text {
    font-size: var(--text-xs);
  }
  
  .bar-container {
    height: 20px;
  }
}
</style>
