<script setup>
import { useRouter } from 'vue-router'

const router = useRouter()

function goBack() {
  router.push('/')
}
</script>

<template>
  <div class="about-view">
    <!-- Background -->
    <div class="bg-gradient"></div>
    <div class="bg-grid"></div>
    
    <div class="about-container">
      <!-- Back button -->
      <button class="back-button" @click="goBack">
        <span class="back-icon">←</span>
        <span>Back</span>
      </button>
      
      <!-- Content -->
      <div class="about-content glass-card">
        <h1 class="about-title">
          <span class="title-prefix">@</span>oftewel
        </h1>
        
        <div class="image-container">
          <img 
            src="/assets/me.png" 
            alt="About" 
            class="about-image"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.about-view {
  min-height: 100vh;
  min-height: 100dvh;
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
}

.bg-gradient {
  position: fixed;
  inset: 0;
  background: 
    radial-gradient(ellipse at top right, rgba(139, 92, 246, 0.05) 0%, transparent 50%),
    radial-gradient(ellipse at bottom left, rgba(59, 130, 246, 0.05) 0%, transparent 50%),
    var(--bg-primary);
  z-index: -2;
}

.bg-grid {
  position: fixed;
  inset: 0;
  background-image: 
    linear-gradient(var(--border-subtle) 1px, transparent 1px),
    linear-gradient(90deg, var(--border-subtle) 1px, transparent 1px);
  background-size: 50px 50px;
  opacity: 0.5;
  z-index: -1;
  pointer-events: none;
}

.about-container {
  width: 100%;
  max-width: 1400px;
  padding: var(--space-6);
  display: flex;
  flex-direction: column;
  gap: var(--space-6);
}

.back-button {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  padding: var(--space-2) var(--space-4);
  background: var(--bg-secondary);
  border: 1px solid var(--border-default);
  border-radius: var(--radius-lg);
  color: var(--text-secondary);
  font-size: var(--text-sm);
  font-weight: var(--font-medium);
  cursor: pointer;
  transition: all 0.2s ease;
  width: fit-content;
}

.back-button:hover {
  background: var(--bg-tertiary);
  border-color: var(--border-focus);
  color: var(--text-primary);
}

.back-icon {
  font-size: 1.2rem;
  transition: transform 0.2s ease;
}

.back-button:hover .back-icon {
  transform: translateX(-4px);
}

.about-content {
  padding: var(--space-6);
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--space-6);
  background: transparent;
  border: none;
  box-shadow: none;
}

.about-title {
  font-size: var(--text-3xl);
  font-weight: var(--font-bold);
  color: var(--text-primary);
  margin: 0;
  font-family: var(--font-mono);
  letter-spacing: -0.02em;
}

.title-prefix {
  color: var(--text-accent);
  margin-right: 0.3em;
}

.image-container {
  display: flex;
  justify-content: center;
  align-items: center;
  width: 100%;
  max-height: calc(100vh - 200px);
}

.about-image {
  width: 100%;
  height: auto;
  max-height: calc(100vh - 200px);
  object-fit: contain;
  border-radius: var(--radius-lg);
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
  transition: transform 0.3s ease;
}

.about-image:hover {
  transform: scale(1.01);
}

/* Responsive */
@media (max-width: 640px) {
  .about-container {
    padding: var(--space-4);
  }
  
  .about-content {
    padding: var(--space-6);
  }
  
  .about-title {
    font-size: var(--text-2xl);
  }
}
</style>
