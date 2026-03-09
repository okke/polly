<script setup>
import { ref, computed, onMounted } from 'vue'
import QRCodeVue from 'qrcode.vue'

const props = defineProps({
  serverInfo: {
    type: Object,
    default: null
  },
  participantCount: {
    type: Number,
    default: 0
  },
  connectedClients: {
    type: Number,
    default: 0
  }
})

const copied = ref(false)

const joinUrl = computed(() => props.serverInfo?.url || 'http://localhost:4567')

async function copyUrl() {
  try {
    await navigator.clipboard.writeText(joinUrl.value)
    copied.value = true
    setTimeout(() => {
      copied.value = false
    }, 2000)
  } catch (e) {
    console.error('Failed to copy:', e)
  }
}
</script>

<template>
  <div class="connection-panel glass-card">
    <h2 class="panel-title">
      <span class="title-icon">⬡</span>
      Connection
    </h2>
    
    <!-- QR Code -->
    <div class="qr-container">
      <div class="qr-frame">
        <div class="qr-corner tl"></div>
        <div class="qr-corner tr"></div>
        <div class="qr-corner bl"></div>
        <div class="qr-corner br"></div>
        
        <QRCodeVue 
          :value="joinUrl"
          :size="160"
          level="M"
          render-as="svg"
          :margin="0"
          class="qr-code"
        />
      </div>
      <span class="qr-label terminal-text">scan to join</span>
    </div>
    
    <!-- URL -->
    <div class="url-container">
      <label class="url-label">Join URL</label>
      <div class="url-box" @click="copyUrl">
        <code class="url-text">{{ joinUrl }}</code>
        <button class="copy-btn" :class="{ copied }">
          <span v-if="!copied">⌘C</span>
          <span v-else>✓</span>
        </button>
      </div>
    </div>
    
    <!-- Connection Counters -->
    <div class="counter-container">
      <div class="counter terminal-badge">
        <span class="prompt">></span>
        <span class="command">{{ connectedClients }}</span>
        <span class="output">live</span>
        <span class="cursor">▌</span>
      </div>
      <div class="counter terminal-badge secondary">
        <span class="prompt">></span>
        <span class="command">{{ participantCount }}</span>
        <span class="output">voted</span>
      </div>
    </div>
  </div>
</template>

<style scoped>
.connection-panel {
  padding: var(--space-5);
  display: flex;
  flex-direction: column;
  gap: var(--space-5);
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

/* QR Code */
.qr-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--space-3);
}

.qr-frame {
  position: relative;
  padding: var(--space-4);
  background: white;
  border-radius: var(--radius-lg);
}

.qr-corner {
  position: absolute;
  width: 16px;
  height: 16px;
  border: 3px solid var(--text-accent);
}

.qr-corner.tl {
  top: -4px;
  left: -4px;
  border-right: none;
  border-bottom: none;
  border-top-left-radius: 4px;
}

.qr-corner.tr {
  top: -4px;
  right: -4px;
  border-left: none;
  border-bottom: none;
  border-top-right-radius: 4px;
}

.qr-corner.bl {
  bottom: -4px;
  left: -4px;
  border-right: none;
  border-top: none;
  border-bottom-left-radius: 4px;
}

.qr-corner.br {
  bottom: -4px;
  right: -4px;
  border-left: none;
  border-top: none;
  border-bottom-right-radius: 4px;
}

.qr-code {
  display: block;
  animation: pixelateIn var(--duration-slow) var(--ease-out);
}

.qr-label {
  font-size: var(--text-xs);
  color: var(--text-tertiary);
}

.terminal-text {
  font-family: var(--font-mono);
}

/* URL */
.url-container {
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
}

.url-label {
  font-size: var(--text-xs);
  color: var(--text-tertiary);
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.url-box {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  background: var(--bg-primary);
  border: 1px solid var(--border-subtle);
  border-radius: var(--radius-md);
  padding: var(--space-2) var(--space-3);
  cursor: pointer;
  transition: border-color var(--duration-fast) var(--ease-out);
}

.url-box:hover {
  border-color: var(--border-default);
}

.url-text {
  flex: 1;
  font-family: var(--font-mono);
  font-size: var(--text-sm);
  color: var(--text-accent);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.copy-btn {
  font-family: var(--font-mono);
  font-size: var(--text-xs);
  color: var(--text-tertiary);
  background: var(--bg-elevated);
  padding: var(--space-1) var(--space-2);
  border-radius: var(--radius-sm);
  transition: 
    color var(--duration-fast) var(--ease-out),
    background var(--duration-fast) var(--ease-out);
}

.copy-btn:hover {
  color: var(--text-secondary);
}

.copy-btn.copied {
  color: var(--accent-success);
  background: rgba(48, 209, 88, 0.1);
}

/* Counter */
.counter-container {
  display: flex;
  justify-content: center;
}

.terminal-badge {
  display: inline-flex;
  align-items: center;
  gap: var(--space-2);
  font-family: var(--font-mono);
  font-size: var(--text-base);
  padding: var(--space-3) var(--space-4);
  background: var(--bg-primary);
  border-radius: var(--radius-lg);
  border: 1px solid var(--border-subtle);
}

.prompt {
  color: var(--text-tertiary);
}

.command {
  color: var(--text-accent);
  font-size: var(--text-xl);
  font-weight: var(--font-bold);
}

.output {
  color: var(--text-secondary);
}

.cursor {
  color: var(--text-accent);
  animation: blink 1s step-end infinite;
}
</style>
