<script setup>
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import DisclaimerModal from '../components/DisclaimerModal.vue'

const router = useRouter()
const route = useRoute()
const showDisclaimer = ref(false)

onMounted(async () => {
  // Always show disclaimer if on /disclaimer route
  if (route.path === '/disclaimer') {
    showDisclaimer.value = true
    return
  }
  
  try {
    const response = await fetch('/api/disclaimer/status')
    const data = await response.json()
    showDisclaimer.value = !data.dismissed
  } catch (error) {
    console.error('Failed to check disclaimer status:', error)
  }
})

async function handleDisclaimerDismiss() {
  try {
    await fetch('/api/disclaimer/dismiss', { method: 'POST' })
    showDisclaimer.value = false
    
    // If on /disclaimer route, navigate to home
    if (route.path === '/disclaimer') {
      router.push('/')
    }
  } catch (error) {
    console.error('Failed to dismiss disclaimer:', error)
    // Still hide it on the frontend even if the API call fails
    showDisclaimer.value = false
    
    // Navigate to home if on disclaimer route
    if (route.path === '/disclaimer') {
      router.push('/')
    }
  }
}

function goToVoting() {
  router.push('/vote')
}

function goToAbout() {
  router.push('/about')
}

function goToAdmin() {
  router.push('/admin')
}

function goToPresentation() {
  router.push('/presentation')
}

function goToReview() {
  router.push('/review')
}

function goToReading() {
  router.push('/reading')
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
          An experiment in agentic software engineering, built over 4 evenings.
          Share your opinions on thoughtful statements with instant results.
          Vote anonymously and see how others think in real-time.
        </p>
        
        <!-- CTA Buttons -->
        <div class="button-groups">
          <!-- Primary Actions -->
          <div class="button-group">
            <button class="cta-button" @click="goToVoting">
              <span class="cta-icon">→</span>
              <span>Start Voting</span>
            </button>
            
            <button class="cta-button secondary" @click="goToAdmin">
              <span class="cta-icon">⚙</span>
              <span>Admin</span>
            </button>
          </div>

          <!-- Documentation -->
          <div class="button-group">
            <button class="cta-button secondary" @click="goToAbout">
              <span class="cta-icon">ℹ</span>
              <span>About Me</span>
            </button>
            
            <button class="cta-button secondary" @click="goToPresentation">
              <span class="cta-icon">📊</span>
              <span>Presentation</span>
            </button>
            
            <button class="cta-button secondary" @click="goToReview">
              <span class="cta-icon">📋</span>
              <span>Code Review</span>
            </button>
          </div>

          <!-- Further Reading -->
          <div class="button-group">
            <button class="cta-button secondary" @click="goToReading">
              <span class="cta-icon">📚</span>
              <span>Further Reading</span>
            </button>
          </div>
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
        
        <!-- Footer -->
        <footer class="home-footer">
          <a 
            href="https://github.com/okke/polly" 
            target="_blank" 
            rel="noopener noreferrer"
            class="github-link"
            title="View source on GitHub"
          >
            <svg class="github-icon" viewBox="0 0 24 24" fill="currentColor">
              <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/>
            </svg>
            <span>View on GitHub</span>
          </a>
        </footer>
      </div>
    </div>
    
    <!-- Disclaimer Modal -->
    <DisclaimerModal 
      v-if="showDisclaimer" 
      @dismiss="handleDisclaimerDismiss"
    />
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

.button-groups {
  display: flex;
  flex-direction: column;
  gap: var(--space-8);
  margin-top: var(--space-4);
  width: 100%;
}

.button-group {
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
  align-items: center;
}

.cta-button {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: var(--space-3);
  padding: var(--space-4) var(--space-8);
  width: 400px;
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

/* Footer */
.home-footer {
  margin-top: var(--space-8);
  padding-top: var(--space-6);
  border-top: 1px solid var(--border-subtle);
  display: flex;
  justify-content: center;
}

.github-link {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  padding: var(--space-3) var(--space-5);
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid var(--border-default);
  border-radius: var(--radius-lg);
  color: var(--text-secondary);
  text-decoration: none;
  font-size: var(--text-sm);
  font-weight: var(--font-medium);
  transition: all var(--duration-fast);
}

.github-link:hover {
  background: rgba(255, 255, 255, 0.05);
  border-color: var(--border-focus);
  color: var(--text-primary);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.github-icon {
  width: 20px;
  height: 20px;
  transition: transform var(--duration-fast);
}

.github-link:hover .github-icon {
  transform: scale(1.1);
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
