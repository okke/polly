<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
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
const showQRModal = ref(false)

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

function openQRModal() {
  showQRModal.value = true
}

function closeQRModal() {
  showQRModal.value = false
}

function handleKeydown(e) {
  if (e.key === 'Escape' && showQRModal.value) {
    closeQRModal()
  }
}

onMounted(() => {
  window.addEventListener('keydown', handleKeydown)
})

onUnmounted(() => {
  window.removeEventListener('keydown', handleKeydown)
})
</script>

<template>
  <div class="connection-panel glass-card">
    <h2 class="panel-title">
      <span class="title-icon">⬡</span>
      JOIN
    </h2>
    
    <!-- QR Code -->
    <div class="qr-container">
      <div class="qr-frame" @click="openQRModal" title="Click to enlarge">
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

    <!-- Large QR Code Modal -->
    <Teleport to="body">
      <Transition name="modal">
        <div v-if="showQRModal" class="qr-modal-overlay" @click="closeQRModal">
          <div class="qr-modal" @click.stop>
            <button class="qr-modal-close" @click="closeQRModal" title="Close (ESC)">
              ✕
            </button>
            
            <div class="qr-modal-content">
              <h3 class="qr-modal-title">Scan to Join</h3>
              <p class="qr-modal-url">{{ joinUrl }}</p>
              
              <div class="qr-modal-frame">
                <div class="qr-corner tl"></div>
                <div class="qr-corner tr"></div>
                <div class="qr-corner bl"></div>
                <div class="qr-corner br"></div>
                
                <QRCodeVue 
                  :value="joinUrl"
                  :size="400"
                  level="M"
                  render-as="svg"
                  :margin="2"
                  class="qr-code-large"
                />
              </div>
              
              <p class="qr-modal-hint">Click outside to close</p>
            </div>
          </div>
        </div>
      </Transition>
    </Teleport>
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
  cursor: pointer;
  transition: transform var(--duration-fast) var(--ease-out);
}

.qr-frame:hover {
  transform: scale(1.02);
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

/* QR Modal */
.qr-modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.85);
  backdrop-filter: blur(10px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 10000;
  padding: var(--space-4);
}

.qr-modal {
  background: var(--bg-elevated);
  border-radius: var(--radius-xl);
  border: 1px solid var(--border-default);
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.5);
  position: relative;
  max-width: 600px;
  width: 100%;
}

.qr-modal-close {
  position: absolute;
  top: var(--space-4);
  right: var(--space-4);
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
  color: var(--text-primary);
  font-size: 1.25rem;
  cursor: pointer;
  transition: all var(--duration-fast) var(--ease-out);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1;
}

.qr-modal-close:hover {
  background: rgba(239, 68, 68, 0.2);
  border-color: rgba(239, 68, 68, 0.5);
  transform: rotate(90deg);
}

.qr-modal-content {
  padding: var(--space-8);
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--space-5);
}

.qr-modal-title {
  font-size: var(--text-2xl);
  font-weight: var(--font-bold);
  color: var(--text-primary);
  margin: 0;
}

.qr-modal-url {
  font-family: var(--font-mono);
  font-size: var(--text-sm);
  color: var(--text-secondary);
  background: var(--bg-primary);
  padding: var(--space-2) var(--space-4);
  border-radius: var(--radius-md);
  border: 1px solid var(--border-subtle);
  margin: 0;
}

.qr-modal-frame {
  position: relative;
  padding: var(--space-6);
  background: white;
  border-radius: var(--radius-xl);
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
}

.qr-code-large {
  display: block;
}

.qr-modal-hint {
  font-size: var(--text-sm);
  color: var(--text-tertiary);
  margin: 0;
  font-style: italic;
}

/* Modal transitions */
.modal-enter-active,
.modal-leave-active {
  transition: opacity var(--duration-medium) var(--ease-out);
}

.modal-enter-active .qr-modal,
.modal-leave-active .qr-modal {
  transition: transform var(--duration-medium) var(--ease-out);
}

.modal-enter-from,
.modal-leave-to {
  opacity: 0;
}

.modal-enter-from .qr-modal,
.modal-leave-to .qr-modal {
  transform: scale(0.9);
}

@media (max-width: 640px) {
  .qr-modal-content {
    padding: var(--space-6);
  }
  
  .qr-modal-frame {
    padding: var(--space-4);
  }
  
  .qr-modal-close {
    top: var(--space-2);
    right: var(--space-2);
  }
}
</style>
