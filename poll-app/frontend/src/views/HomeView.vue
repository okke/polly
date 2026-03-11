<script setup>
import { useRouter } from 'vue-router'

const router = useRouter()

function goToVoting() {
  router.push('/vote')
}

function goToAbout() {
  router.push('/about')
}

function goToAdmin() {
  router.push('/admin')
}
</script>

<template>
  <div class="home-view">
    <!-- Background -->
    <div class="bg-gradient"></div>
    <div class="bg-grid"></div>
    
    <div class="home-container">
      <div class="hero-section">
        <!-- Logo/Title -->
        <h1 class="app-title">
          <span class="title-prefix">$</span> polly<span class="cursor">▌</span>
        </h1>
        
        <!-- Subtitle -->
        <p class="subtitle">Real-time polling made simple</p>
        
        <!-- Description -->
        <p class="description">
          Share your opinions on thoughtful statements with instant results.
          Vote anonymously and see how others think in real-time.
        </p>
        
        <!-- CTA Buttons -->
        <div class="cta-buttons">
          <button class="cta-button" @click="goToVoting">
            <span class="cta-icon">→</span>
            <span>Start Voting</span>
          </button>
          
          <button class="cta-button secondary" @click="goToAbout">
            <span class="cta-icon">ℹ</span>
            <span>About Me</span>
          </button>
          
          <button class="cta-button secondary" @click="goToAdmin">
            <span class="cta-icon">⚙</span>
            <span>Admin</span>
          </button>
        </div>
        
        <!-- Features -->
        <div class="features">
          <div class="feature">
            <span class="feature-icon">⚡</span>
            <span class="feature-text">Real-time updates</span>
          </div>
          <div class="feature">
            <span class="feature-icon">🎭</span>
            <span class="feature-text">Anonymous voting</span>
          </div>
          <div class="feature">
            <span class="feature-icon">📊</span>
            <span class="feature-text">Instant results</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.home-view {
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

.home-container {
  max-width: 600px;
  padding: var(--space-8);
  text-align: center;
}

.hero-section {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--space-6);
}

.app-title {
  font-size: clamp(3rem, 8vw, 5rem);
  font-weight: var(--font-bold);
  color: var(--text-primary);
  margin: 0;
  font-family: var(--font-mono);
  letter-spacing: -0.02em;
}

.title-prefix {
  color: var(--text-accent);
  margin-right: 0.1em;
}

.cursor {
  animation: blink 1s infinite;
  color: var(--text-accent);
}

@keyframes blink {
  0%, 50% {
    opacity: 1;
  }
  51%, 100% {
    opacity: 0;
  }
}

.subtitle {
  font-size: var(--text-2xl);
  color: var(--text-secondary);
  margin: 0;
  font-weight: var(--font-medium);
}

.description {
  font-size: var(--text-lg);
  color: var(--text-tertiary);
  line-height: 1.7;
  margin: 0;
  max-width: 500px;
}

.cta-buttons {
  display: flex;
  gap: var(--space-4);
  margin-top: var(--space-4);
  flex-wrap: wrap;
  justify-content: center;
}

.cta-button {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: var(--space-3);
  padding: var(--space-4) var(--space-8);
  min-width: 180px;
  background: linear-gradient(135deg, rgba(139, 92, 246, 0.2), rgba(59, 130, 246, 0.2));
  border: 1px solid rgba(139, 92, 246, 0.4);
  border-radius: var(--radius-xl);
  color: var(--text-primary);
  font-size: var(--text-lg);
  font-weight: var(--font-semibold);
  cursor: pointer;
  transition: all 0.3s ease;
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
}

.cta-button:hover {
  background: linear-gradient(135deg, rgba(139, 92, 246, 0.3), rgba(59, 130, 246, 0.3));
  border-color: rgba(139, 92, 246, 0.6);
  transform: translateY(-2px);
  box-shadow: 0 8px 24px rgba(139, 92, 246, 0.2);
}

.cta-button:active {
  transform: translateY(0);
}

.cta-button.secondary {
  background: var(--bg-secondary);
  border-color: var(--border-default);
}

.cta-button.secondary:hover {
  background: var(--bg-tertiary);
  border-color: var(--border-focus);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1);
}

.cta-icon {
  font-size: 1.5rem;
  transition: transform 0.3s ease;
}

.cta-button:hover .cta-icon {
  transform: translateX(4px);
}

.features {
  display: flex;
  gap: var(--space-6);
  margin-top: var(--space-4);
  flex-wrap: wrap;
  justify-content: center;
}

.feature {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--space-2);
  padding: var(--space-3);
}

.feature-icon {
  font-size: 2rem;
}

.feature-text {
  font-size: var(--text-sm);
  color: var(--text-tertiary);
  font-weight: var(--font-medium);
}

/* Responsive */
@media (max-width: 640px) {
  .features {
    gap: var(--space-4);
  }
  
  .feature {
    padding: var(--space-2);
  }
  
  .description {
    font-size: var(--text-base);
  }
}
</style>
