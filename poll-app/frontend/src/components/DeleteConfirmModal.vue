<script setup>
const props = defineProps({
  visible: {
    type: Boolean,
    default: false
  },
  pollTitle: {
    type: String,
    default: ''
  },
  isDeleting: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['confirm', 'cancel'])
</script>

<template>
  <Transition name="modal">
    <div v-if="visible" class="modal-overlay" @click.self="emit('cancel')">
      <div class="modal-content glass-card">
        <!-- Header -->
        <div class="modal-header">
          <div class="icon-badge warning-icon">⚠️</div>
          <div>
            <h2 class="modal-title">Delete Poll?</h2>
            <p class="modal-subtitle">This action cannot be undone</p>
          </div>
        </div>
        
        <!-- Body -->
        <div class="modal-body">
          <p class="confirmation-text">
            Are you sure you want to delete this poll?
          </p>
          <div class="poll-preview">
            <span class="preview-label">Poll:</span>
            <span class="preview-title">{{ pollTitle }}</span>
          </div>
          <p class="warning-text">
            All associated data will be permanently removed.
          </p>
        </div>
        
        <!-- Footer -->
        <div class="modal-footer">
          <button 
            class="btn btn-secondary" 
            @click="emit('cancel')"
            :disabled="isDeleting"
          >
            Cancel
          </button>
          <button 
            class="btn btn-danger" 
            @click="emit('confirm')"
            :disabled="isDeleting"
          >
            <span v-if="isDeleting" class="btn-spinner"></span>
            <span v-else class="btn-icon">🗑</span>
            <span>{{ isDeleting ? 'Deleting...' : 'Delete Poll' }}</span>
          </button>
        </div>
      </div>
    </div>
  </Transition>
</template>

<style scoped>
.modal-overlay {
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

.modal-content {
  width: 100%;
  max-width: 450px;
  display: flex;
  flex-direction: column;
}

/* Header */
.modal-header {
  display: flex;
  align-items: flex-start;
  gap: var(--space-4);
  padding: var(--space-6);
  border-bottom: 1px solid var(--border-default);
}

.icon-badge {
  width: 48px;
  height: 48px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: var(--radius-lg);
  font-size: 1.5rem;
  flex-shrink: 0;
}

.warning-icon {
  background: linear-gradient(135deg, rgba(239, 68, 68, 0.15), rgba(220, 38, 38, 0.15));
  border: 1px solid rgba(239, 68, 68, 0.3);
}

.modal-title {
  font-size: var(--text-xl);
  font-weight: var(--font-bold);
  color: var(--text-primary);
  margin: 0;
  line-height: 1.3;
}

.modal-subtitle {
  font-size: var(--text-sm);
  color: var(--text-secondary);
  margin: var(--space-1) 0 0 0;
}

/* Body */
.modal-body {
  padding: var(--space-6);
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
}

.confirmation-text {
  font-size: var(--text-base);
  color: var(--text-primary);
  margin: 0;
  line-height: 1.6;
}

.poll-preview {
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
  padding: var(--space-4);
  background: var(--bg-secondary);
  border: 1px solid var(--border-default);
  border-radius: var(--radius-md);
}

.preview-label {
  font-size: var(--text-xs);
  color: var(--text-tertiary);
  text-transform: uppercase;
  letter-spacing: 0.05em;
  font-weight: var(--font-semibold);
}

.preview-title {
  font-size: var(--text-base);
  color: var(--text-primary);
  font-weight: var(--font-medium);
  line-height: 1.4;
}

.warning-text {
  font-size: var(--text-sm);
  color: var(--text-tertiary);
  margin: 0;
  font-style: italic;
}

/* Footer */
.modal-footer {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: var(--space-3);
  padding: var(--space-6);
  border-top: 1px solid var(--border-default);
}

.btn {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  padding: var(--space-3) var(--space-5);
  border-radius: var(--radius-lg);
  font-size: var(--text-sm);
  font-weight: var(--font-medium);
  cursor: pointer;
  transition: all 0.2s ease;
  border: 1px solid transparent;
}

.btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-secondary {
  background: var(--bg-secondary);
  border-color: var(--border-default);
  color: var(--text-secondary);
}

.btn-secondary:hover:not(:disabled) {
  background: var(--bg-tertiary);
  border-color: var(--border-focus);
  color: var(--text-primary);
}

.btn-danger {
  background: linear-gradient(135deg, rgba(239, 68, 68, 0.15), rgba(220, 38, 38, 0.15));
  border-color: rgba(239, 68, 68, 0.3);
  color: rgb(239, 68, 68);
}

.btn-danger:hover:not(:disabled) {
  background: linear-gradient(135deg, rgba(239, 68, 68, 0.2), rgba(220, 38, 38, 0.2));
  border-color: rgba(239, 68, 68, 0.5);
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(239, 68, 68, 0.2);
}

.btn-danger:active:not(:disabled) {
  transform: translateY(0);
}

.btn-icon {
  font-size: 1.1rem;
  line-height: 1;
}

.btn-spinner {
  width: 14px;
  height: 14px;
  border: 2px solid rgba(239, 68, 68, 0.3);
  border-top-color: rgb(239, 68, 68);
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

/* Transitions */
.modal-enter-active,
.modal-leave-active {
  transition: 
    opacity var(--duration-normal) var(--ease-out),
    backdrop-filter var(--duration-normal) var(--ease-out);
}

.modal-enter-active .modal-content,
.modal-leave-active .modal-content {
  transition: 
    opacity var(--duration-normal) var(--ease-out),
    transform var(--duration-normal) var(--ease-spring);
}

.modal-enter-from,
.modal-leave-to {
  opacity: 0;
}

.modal-enter-from .modal-content,
.modal-leave-to .modal-content {
  opacity: 0;
  transform: scale(0.95);
}
</style>
