<script setup>
import { computed } from 'vue'

const props = defineProps({
  isDark: {
    type: Boolean,
    default: true
  },
  lastUpdate: {
    type: String,
    default: null
  }
})

const emit = defineEmits(['export', 'reset', 'toggleTheme'])

const formattedTime = computed(() => {
  if (!props.lastUpdate) return '--:--:--'
  
  try {
    const date = new Date(props.lastUpdate)
    return date.toLocaleTimeString('en-US', { 
      hour12: false,
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit'
    })
  } catch {
    return '--:--:--'
  }
})
</script>

<template>
  <div class="control-bar glass-card">
    <h2 class="panel-title">
      <span class="title-icon">⚙</span>
      Controls
    </h2>
    
    <!-- Last update -->
    <div class="update-info">
      <span class="update-label">Last update</span>
      <span class="update-time font-mono">
        <span class="live-dot"></span>
        {{ formattedTime }}
      </span>
    </div>
    
    <!-- Actions -->
    <div class="actions">
      <button class="action-btn" @click="emit('export')">
        <span class="btn-icon">↓</span>
        <span class="btn-text">Export CSV</span>
      </button>
      
      <button class="action-btn danger" @click="emit('reset')">
        <span class="btn-icon">⟲</span>
        <span class="btn-text">Reset Votes</span>
      </button>
    </div>
    
    <!-- Theme toggle -->
    <div class="theme-toggle">
      <span class="toggle-label">Theme</span>
      <button class="toggle-btn" @click="emit('toggleTheme')">
        <span class="toggle-option" :class="{ active: isDark }">Dark</span>
        <span class="toggle-option" :class="{ active: !isDark }">Light</span>
        <span class="toggle-indicator" :class="{ light: !isDark }"></span>
      </button>
    </div>
  </div>
</template>

<style scoped>
.control-bar {
  padding: var(--space-5);
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
}

.panel-title {
  font-size: var(--text-sm);
  font-weight: var(--font-semibold);
  color: var(--text-secondary);
  text-transform: uppercase;
  letter-spacing: 0.05em;
  display: flex;
  align-items: center;
  gap: var(--space-2);
}

.title-icon {
  color: var(--text-accent);
}

/* Update info */
.update-info {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: var(--space-3);
  background: var(--bg-primary);
  border-radius: var(--radius-md);
  border: 1px solid var(--border-subtle);
}

.update-label {
  font-size: var(--text-xs);
  color: var(--text-tertiary);
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.update-time {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  font-size: var(--text-sm);
  color: var(--text-secondary);
}

.live-dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: var(--accent-success);
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.4; }
}

/* Actions */
.actions {
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
}

.action-btn {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  padding: var(--space-3);
  background: var(--bg-primary);
  border: 1px solid var(--border-subtle);
  border-radius: var(--radius-md);
  font-size: var(--text-sm);
  color: var(--text-secondary);
  transition: 
    background var(--duration-fast) var(--ease-out),
    border-color var(--duration-fast) var(--ease-out),
    color var(--duration-fast) var(--ease-out);
}

.action-btn:hover {
  background: var(--bg-elevated);
  border-color: var(--border-default);
  color: var(--text-primary);
}

.action-btn.danger:hover {
  border-color: var(--accent-error);
  color: var(--accent-error);
}

.btn-icon {
  font-size: var(--text-base);
}

/* Theme toggle */
.theme-toggle {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.toggle-label {
  font-size: var(--text-xs);
  color: var(--text-tertiary);
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.toggle-btn {
  position: relative;
  display: flex;
  background: var(--bg-primary);
  border: 1px solid var(--border-subtle);
  border-radius: var(--radius-md);
  padding: 2px;
  overflow: hidden;
}

.toggle-option {
  position: relative;
  z-index: 1;
  padding: var(--space-2) var(--space-3);
  font-size: var(--text-xs);
  font-weight: var(--font-medium);
  color: var(--text-tertiary);
  transition: color var(--duration-fast) var(--ease-out);
}

.toggle-option.active {
  color: var(--text-primary);
}

.toggle-indicator {
  position: absolute;
  top: 2px;
  left: 2px;
  width: calc(50% - 2px);
  height: calc(100% - 4px);
  background: var(--bg-elevated);
  border-radius: var(--radius-sm);
  transition: transform var(--duration-fast) var(--ease-out);
}

.toggle-indicator.light {
  transform: translateX(100%);
}
</style>
