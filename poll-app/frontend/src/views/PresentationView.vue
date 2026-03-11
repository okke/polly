<script setup>
import { ref, onMounted, onUnmounted, computed, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'

const router = useRouter()
const route = useRoute()
const currentSlide = ref(0)

const slides = [
  {
    type: 'title',
    title: 'Polly',
    subtitle: 'Real-time Polling Application',
    emoji: '💬'
  },
  {
    type: 'warning',
    title: 'Experimental Project',
    content: [
      'Built as an experiment in agentic code generation',
      'AI-assisted software development',
      '⚠️ Not intended for production use'
    ]
  },
  {
    type: 'content',
    title: 'Core Functionality',
    items: [
      { icon: '⚡', text: 'Real-time voting with WebSocket updates' },
      { icon: '🎭', text: 'Anonymous participation, no login required' },
      { icon: '📊', text: 'Live results visualization with Chart.js' },
      { icon: '🔄', text: 'Multi-poll management with JSON storage' },
      { icon: '🔒', text: 'Vote finalization with psych analysis' }
    ]
  },
  {
    type: 'content',
    title: 'AI-Powered Features',
    items: [
      { icon: '🤖', text: 'Intelligent poll generation from context' },
      { icon: '🎯', text: 'Dynamic OpenAI model selection' },
      { icon: '🧠', text: 'Individual voter psychological analysis' },
      { icon: '👥', text: 'Group pattern and consensus analysis' },
      { icon: '🎭', text: 'Subject-matter expert positioning' }
    ]
  },
  {
    type: 'content',
    title: 'Admin Panel Features',
    items: [
      { icon: '📋', text: 'Switch & manage multiple polls' },
      { icon: '📈', text: 'Live participant statistics' },
      { icon: '📱', text: 'QR code generation for mobile' },
      { icon: '💾', text: 'Export results to CSV' },
      { icon: '🎲', text: 'Random vote generation (1-1000)' },
      { icon: '📊', text: 'Real-time chart visualization' }
    ]
  },
  {
    type: 'split',
    title: 'Technology Stack',
    left: {
      subtitle: 'Backend',
      items: [
        { name: 'Ruby + Sinatra 3.x', desc: 'Lightweight web framework for building simple, fast HTTP APIs' },
        { name: 'Faye-WebSocket', desc: 'Real-time bidirectional event-based communication library' },
        { name: 'Puma 6.x server', desc: 'Concurrent Ruby web server built for speed and parallelism' },
        { name: 'ruby-openai 4.x', desc: 'Ruby client library for OpenAI API integration' },
        { name: 'JSON file storage', desc: 'Simple file-based persistence for polls and metadata' }
      ]
    },
    right: {
      subtitle: 'Frontend',
      items: [
        { name: 'Vue 3 + Composition API', desc: 'Progressive JavaScript framework with modern reactive composition patterns' },
        { name: 'Vue Router 4.x', desc: 'Official routing library for building single-page applications' },
        { name: 'Pinia state management', desc: 'Intuitive, type-safe state management for Vue applications' },
        { name: 'Vite 5.x build tool', desc: 'Next-generation frontend tooling with instant hot module replacement' },
        { name: 'Chart.js + axios', desc: 'Visualization library and HTTP client for data fetching and display' }
      ]
    }
  },
  {
    type: 'architecture',
    title: 'Architecture Overview',
    layers: [
      { name: 'Frontend', tech: 'Vue 3 + Vite', color: '#42b883' },
      { name: 'WebSocket', tech: 'Real-time bidirectional', color: '#8b5cf6' },
      { name: 'API Layer', tech: 'Sinatra REST endpoints', color: '#ef4444' },
      { name: 'AI Services', tech: 'OpenAI + LLM abstraction', color: '#f59e0b' },
      { name: 'Storage', tech: 'JSON file persistence', color: '#3b82f6' }
    ]
  },
  {
    type: 'terminal',
    title: 'Getting Started',
    commands: [
      { prompt: '# Clone & navigate', cmd: 'git clone <repo> && cd poll-app' },
      { prompt: '# Install dependencies', cmd: 'make install' },
      { prompt: '# Configure environment', cmd: 'cp server/.env.example server/.env' },
      { prompt: '# Start the server', cmd: 'make start' },
      { prompt: '# Access at', cmd: 'http://localhost:4567' }
    ]
  },
  {
    type: 'terminal',
    title: 'Common Commands',
    commands: [
      { prompt: '# Start server', cmd: 'make start' },
      { prompt: '# Stop server', cmd: 'make stop' },
      { prompt: '# Dev mode with hot reload', cmd: 'make dev' },
      { prompt: '# View logs', cmd: 'make logs' },
      { prompt: '# Check status', cmd: 'make status' },
      { prompt: '# Clean artifacts', cmd: 'make clean' }
    ]
  },
  {
    type: 'content',
    title: 'AI Personality',
    subtitle: 'Psychological Analysis Features',
    items: [
      { icon: '🎓', text: 'Expert-driven (subject matter specialist)' },
      { icon: '💥', text: 'Confronting & brutally honest' },
      { icon: '🎩', text: 'Snobby yet composed tone' },
      { icon: '✂️', text: 'Concise: 80-120 words (individual)' },
      { icon: '🎯', text: 'Contextual to poll topic & audience' }
    ]
  },
  {
    type: 'cta',
    title: 'Ready to Try?',
    subtitle: 'Start exploring Polly',
    buttons: [
      { text: 'Start Voting', route: '/vote', primary: true },
      { text: 'Admin Panel', route: '/admin' },
      { text: 'About', route: '/about' }
    ]
  }
]

const totalSlides = computed(() => slides.length)
const progress = computed(() => ((currentSlide.value + 1) / totalSlides.value) * 100)

// Initialize from route parameter
function initializeSlide() {
  const slideParam = parseInt(route.params.slide)
  if (!isNaN(slideParam) && slideParam >= 0 && slideParam < totalSlides.value) {
    currentSlide.value = slideParam
  } else {
    currentSlide.value = 0
  }
}

// Update route when slide changes
function updateRoute(index) {
  if (route.params.slide !== String(index)) {
    router.replace({ name: 'presentation', params: { slide: index } })
  }
}

function nextSlide() {
  if (currentSlide.value < totalSlides.value - 1) {
    const newSlide = currentSlide.value + 1
    currentSlide.value = newSlide
    updateRoute(newSlide)
  }
}

function prevSlide() {
  if (currentSlide.value > 0) {
    const newSlide = currentSlide.value - 1
    currentSlide.value = newSlide
    updateRoute(newSlide)
  }
}

function goToSlide(index) {
  currentSlide.value = index
  updateRoute(index)
}

// Watch for route changes (browser back/forward)
watch(() => route.params.slide, (newSlide) => {
  const slideNum = parseInt(newSlide)
  if (!isNaN(slideNum) && slideNum >= 0 && slideNum < totalSlides.value) {
    currentSlide.value = slideNum
  }
})

function handleKeydown(e) {
  if (e.key === 'ArrowRight' || e.key === ' ') {
    e.preventDefault()
    nextSlide()
  } else if (e.key === 'ArrowLeft') {
    e.preventDefault()
    prevSlide()
  } else if (e.key === 'Escape') {
    router.push('/')
  } else if (e.key === 'Home') {
    e.preventDefault()
    currentSlide.value = 0
    updateRoute(0)
  } else if (e.key === 'End') {
    e.preventDefault()
    const lastSlide = totalSlides.value - 1
    currentSlide.value = lastSlide
    updateRoute(lastSlide)
  }
}

function navigateToRoute(route) {
  router.push(route)
}

function exitPresentation() {
  router.push('/')
}

onMounted(() => {
  initializeSlide()
  window.addEventListener('keydown', handleKeydown)
})

onUnmounted(() => {
  window.removeEventListener('keydown', handleKeydown)
})
</script>

<template>
  <div class="presentation-view">
    <!-- Exit button -->
    <button class="exit-btn" @click="exitPresentation" title="Exit (ESC)">
      ✕
    </button>

    <!-- Slides container -->
    <div class="slides-container">
      <transition :name="'slide'" mode="out-in">
        <div :key="currentSlide" class="slide">
          <!-- Title Slide -->
          <div v-if="slides[currentSlide].type === 'title'" class="slide-content title-slide">
            <div class="emoji-large">{{ slides[currentSlide].emoji }}</div>
            <h1 class="slide-title-large">{{ slides[currentSlide].title }}</h1>
            <p class="slide-subtitle-large">{{ slides[currentSlide].subtitle }}</p>
            <div class="hint">Press → or Space to continue</div>
          </div>

          <!-- Warning Slide -->
          <div v-else-if="slides[currentSlide].type === 'warning'" class="slide-content warning-slide">
            <h2 class="slide-title">{{ slides[currentSlide].title }}</h2>
            <div class="warning-content">
              <div v-for="(line, idx) in slides[currentSlide].content" :key="idx" class="warning-item">
                {{ line }}
              </div>
            </div>
          </div>

          <!-- Content Slide -->
          <div v-else-if="slides[currentSlide].type === 'content'" class="slide-content content-slide">
            <h2 class="slide-title">{{ slides[currentSlide].title }}</h2>
            <p v-if="slides[currentSlide].subtitle" class="slide-subtitle">{{ slides[currentSlide].subtitle }}</p>
            <ul class="content-list">
              <li v-for="(item, idx) in slides[currentSlide].items" :key="idx" class="content-item">
                <span class="item-icon">{{ item.icon }}</span>
                <span class="item-text">{{ item.text }}</span>
              </li>
            </ul>
          </div>

          <!-- Split Slide -->
          <div v-else-if="slides[currentSlide].type === 'split'" class="slide-content split-slide">
            <h2 class="slide-title">{{ slides[currentSlide].title }}</h2>
            <div class="split-columns">
              <div class="column">
                <h3 class="column-title">{{ slides[currentSlide].left.subtitle }}</h3>
                <ul class="split-list">
                  <li 
                    v-for="(item, idx) in slides[currentSlide].left.items" 
                    :key="idx"
                    class="tech-item"
                    :title="item.desc"
                  >
                    {{ item.name }}
                    <span class="tooltip-icon">ℹ️</span>
                  </li>
                </ul>
              </div>
              <div class="column-divider"></div>
              <div class="column">
                <h3 class="column-title">{{ slides[currentSlide].right.subtitle }}</h3>
                <ul class="split-list">
                  <li 
                    v-for="(item, idx) in slides[currentSlide].right.items" 
                    :key="idx"
                    class="tech-item"
                    :title="item.desc"
                  >
                    {{ item.name }}
                    <span class="tooltip-icon">ℹ️</span>
                  </li>
                </ul>
              </div>
            </div>
          </div>

          <!-- Architecture Slide -->
          <div v-else-if="slides[currentSlide].type === 'architecture'" class="slide-content architecture-slide">
            <h2 class="slide-title">{{ slides[currentSlide].title }}</h2>
            <div class="architecture-layers">
              <div 
                v-for="(layer, idx) in slides[currentSlide].layers" 
                :key="idx" 
                class="layer"
                :style="{ '--layer-color': layer.color }"
              >
                <div class="layer-name">{{ layer.name }}</div>
                <div class="layer-tech">{{ layer.tech }}</div>
              </div>
            </div>
          </div>

          <!-- Terminal Slide -->
          <div v-else-if="slides[currentSlide].type === 'terminal'" class="slide-content terminal-slide">
            <h2 class="slide-title">{{ slides[currentSlide].title }}</h2>
            <div class="terminal-window">
              <div class="terminal-header">
                <div class="terminal-buttons">
                  <span class="btn red"></span>
                  <span class="btn yellow"></span>
                  <span class="btn green"></span>
                </div>
                <span class="terminal-title">zsh</span>
              </div>
              <div class="terminal-body">
                <div v-for="(cmd, idx) in slides[currentSlide].commands" :key="idx" class="terminal-line">
                  <div class="terminal-comment">{{ cmd.prompt }}</div>
                  <div class="terminal-command">
                    <span class="prompt">$</span> {{ cmd.cmd }}
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- CTA Slide -->
          <div v-else-if="slides[currentSlide].type === 'cta'" class="slide-content cta-slide">
            <h2 class="slide-title-large">{{ slides[currentSlide].title }}</h2>
            <p class="slide-subtitle-large">{{ slides[currentSlide].subtitle }}</p>
            <div class="cta-buttons">
              <button 
                v-for="(btn, idx) in slides[currentSlide].buttons" 
                :key="idx"
                :class="['cta-btn', { primary: btn.primary }]"
                @click="navigateToRoute(btn.route)"
              >
                {{ btn.text }}
              </button>
            </div>
          </div>
        </div>
      </transition>
    </div>

    <!-- Navigation -->
    <div class="navigation">
      <button 
        class="nav-btn prev" 
        @click="prevSlide" 
        :disabled="currentSlide === 0"
        title="Previous (←)"
      >
        ←
      </button>
      
      <div class="slide-indicators">
        <button
          v-for="(slide, idx) in slides"
          :key="idx"
          class="indicator"
          :class="{ active: idx === currentSlide }"
          @click="goToSlide(idx)"
          :title="`Slide ${idx + 1}`"
        ></button>
      </div>
      
      <button 
        class="nav-btn next" 
        @click="nextSlide" 
        :disabled="currentSlide === totalSlides - 1"
        title="Next (→)"
      >
        →
      </button>
    </div>

    <!-- Progress bar -->
    <div class="progress-bar">
      <div class="progress-fill" :style="{ width: `${progress}%` }"></div>
    </div>

    <!-- Slide counter -->
    <div class="slide-counter">
      {{ currentSlide + 1 }} / {{ totalSlides }}
    </div>
  </div>
</template>

<style scoped>
.presentation-view {
  min-height: 100vh;
  min-height: 100dvh;
  background: linear-gradient(135deg, #0f0f23 0%, #1a1a2e 100%);
  color: #e2e8f0;
  position: relative;
  overflow: hidden;
}

.exit-btn {
  position: fixed;
  top: 2rem;
  right: 2rem;
  width: 3rem;
  height: 3rem;
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 50%;
  color: #e2e8f0;
  font-size: 1.5rem;
  cursor: pointer;
  transition: all 0.3s ease;
  z-index: 100;
  display: flex;
  align-items: center;
  justify-content: center;
}

.exit-btn:hover {
  background: rgba(239, 68, 68, 0.2);
  border-color: rgba(239, 68, 68, 0.5);
  transform: rotate(90deg);
}

.slides-container {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 100vh;
  min-height: 100dvh;
  padding: 4rem 2rem 8rem;
}

.slide {
  width: 100%;
  max-width: 1200px;
  margin: 0 auto;
}

.slide-content {
  background: rgba(255, 255, 255, 0.05);
  backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 2rem;
  padding: 4rem;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
}

/* Title Slide */
.title-slide {
  text-align: center;
  padding: 6rem 4rem;
}

.emoji-large {
  font-size: 8rem;
  margin-bottom: 2rem;
  animation: float 3s ease-in-out infinite;
}

@keyframes float {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-20px); }
}

.slide-title-large {
  font-size: 5rem;
  font-weight: 700;
  margin-bottom: 1rem;
  background: linear-gradient(135deg, #8b5cf6 0%, #3b82f6 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.slide-subtitle-large {
  font-size: 2rem;
  color: #94a3b8;
  margin-bottom: 3rem;
}

.hint {
  font-size: 1rem;
  color: #64748b;
  margin-top: 3rem;
  opacity: 0.7;
}

/* Warning Slide */
.warning-slide {
  border-color: rgba(251, 191, 36, 0.3);
  background: rgba(251, 191, 36, 0.05);
}

.warning-content {
  margin-top: 3rem;
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.warning-item {
  font-size: 1.5rem;
  padding: 1.5rem;
  background: rgba(251, 191, 36, 0.1);
  border-left: 4px solid #fbbf24;
  border-radius: 0.5rem;
}

/* Content Slide */
.slide-title {
  font-size: 3rem;
  font-weight: 700;
  margin-bottom: 1rem;
  background: linear-gradient(135deg, #8b5cf6 0%, #3b82f6 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.slide-subtitle {
  font-size: 1.5rem;
  color: #94a3b8;
  margin-bottom: 2rem;
}

.content-list {
  list-style: none;
  padding: 0;
  margin-top: 3rem;
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.content-item {
  display: flex;
  align-items: center;
  gap: 1.5rem;
  font-size: 1.3rem;
  padding: 1.5rem;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 1rem;
  border: 1px solid rgba(255, 255, 255, 0.1);
  transition: all 0.3s ease;
}

.content-item:hover {
  background: rgba(255, 255, 255, 0.1);
  transform: translateX(10px);
}

.item-icon {
  font-size: 2rem;
  min-width: 2.5rem;
  text-align: center;
}

.item-text {
  flex: 1;
}

/* Split Slide */
.split-columns {
  display: grid;
  grid-template-columns: 1fr auto 1fr;
  gap: 3rem;
  margin-top: 3rem;
}

.column-title {
  font-size: 1.8rem;
  margin-bottom: 1.5rem;
  color: #8b5cf6;
}

.split-list {
  list-style: none;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.split-list li {
  padding: 1rem;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 0.5rem;
  border-left: 3px solid #8b5cf6;
  font-size: 1.1rem;
}

.tech-item {
  position: relative;
  cursor: help;
  transition: all 0.3s ease;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.tech-item:hover {
  background: rgba(139, 92, 246, 0.15);
  border-left-color: #a78bfa;
  transform: translateX(5px);
}

.tooltip-icon {
  opacity: 0.3;
  font-size: 0.9rem;
  transition: opacity 0.3s ease;
}

.tech-item:hover .tooltip-icon {
  opacity: 0.7;
}

.column-divider {
  width: 2px;
  background: linear-gradient(to bottom, transparent, rgba(255, 255, 255, 0.2), transparent);
}

/* Architecture Slide */
.architecture-layers {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  margin-top: 3rem;
}

.layer {
  padding: 1.5rem 2rem;
  background: rgba(255, 255, 255, 0.05);
  border-left: 4px solid var(--layer-color);
  border-radius: 0.5rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  transition: all 0.3s ease;
}

.layer:hover {
  background: rgba(255, 255, 255, 0.1);
  transform: translateX(10px);
}

.layer-name {
  font-size: 1.5rem;
  font-weight: 600;
}

.layer-tech {
  font-size: 1.1rem;
  color: #94a3b8;
}

/* Terminal Slide */
.terminal-window {
  margin-top: 3rem;
  background: #1e1e1e;
  border-radius: 1rem;
  overflow: hidden;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.5);
}

.terminal-header {
  background: #323232;
  padding: 0.75rem 1rem;
  display: flex;
  align-items: center;
  gap: 1rem;
}

.terminal-buttons {
  display: flex;
  gap: 0.5rem;
}

.btn {
  width: 12px;
  height: 12px;
  border-radius: 50%;
}

.btn.red { background: #ff5f56; }
.btn.yellow { background: #ffbd2e; }
.btn.green { background: #27c93f; }

.terminal-title {
  color: #888;
  font-size: 0.9rem;
}

.terminal-body {
  padding: 2rem;
  font-family: 'Monaco', 'Menlo', monospace;
  font-size: 1rem;
}

.terminal-line {
  margin-bottom: 1.5rem;
}

.terminal-comment {
  color: #6a9955;
  margin-bottom: 0.25rem;
}

.terminal-command {
  color: #dcdcdc;
}

.prompt {
  color: #4ec9b0;
  margin-right: 0.5rem;
}

/* CTA Slide */
.cta-slide {
  text-align: center;
  padding: 6rem 4rem;
}

.cta-buttons {
  display: flex;
  gap: 1.5rem;
  justify-content: center;
  margin-top: 3rem;
  flex-wrap: wrap;
}

.cta-btn {
  padding: 1.2rem 3rem;
  font-size: 1.2rem;
  border: 2px solid rgba(255, 255, 255, 0.2);
  background: rgba(255, 255, 255, 0.05);
  color: #e2e8f0;
  border-radius: 1rem;
  cursor: pointer;
  transition: all 0.3s ease;
  font-weight: 600;
}

.cta-btn:hover {
  background: rgba(255, 255, 255, 0.1);
  transform: translateY(-2px);
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
}

.cta-btn.primary {
  background: linear-gradient(135deg, #8b5cf6 0%, #3b82f6 100%);
  border-color: transparent;
}

.cta-btn.primary:hover {
  box-shadow: 0 10px 40px rgba(139, 92, 246, 0.3);
}

/* Navigation */
.navigation {
  position: fixed;
  bottom: 4rem;
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  align-items: center;
  gap: 2rem;
  z-index: 50;
}

.nav-btn {
  width: 3rem;
  height: 3rem;
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 50%;
  color: #e2e8f0;
  font-size: 1.5rem;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.nav-btn:hover:not(:disabled) {
  background: rgba(139, 92, 246, 0.3);
  border-color: rgba(139, 92, 246, 0.5);
  transform: scale(1.1);
}

.nav-btn:disabled {
  opacity: 0.3;
  cursor: not-allowed;
}

.slide-indicators {
  display: flex;
  gap: 0.75rem;
}

.indicator {
  width: 0.75rem;
  height: 0.75rem;
  background: rgba(255, 255, 255, 0.2);
  border: none;
  border-radius: 50%;
  cursor: pointer;
  transition: all 0.3s ease;
  padding: 0;
}

.indicator:hover {
  background: rgba(255, 255, 255, 0.4);
  transform: scale(1.2);
}

.indicator.active {
  background: #8b5cf6;
  width: 2rem;
  border-radius: 1rem;
}

/* Progress bar */
.progress-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  height: 4px;
  background: rgba(255, 255, 255, 0.1);
  z-index: 100;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #8b5cf6 0%, #3b82f6 100%);
  transition: width 0.3s ease;
}

/* Slide counter */
.slide-counter {
  position: fixed;
  top: 2rem;
  left: 2rem;
  font-size: 1.2rem;
  color: #64748b;
  font-weight: 600;
  z-index: 100;
}

/* Slide transitions */
.slide-enter-active,
.slide-leave-active {
  transition: all 0.5s cubic-bezier(0.68, -0.55, 0.265, 1.55);
}

.slide-enter-from {
  opacity: 0;
  transform: translateX(100px) scale(0.9);
}

.slide-leave-to {
  opacity: 0;
  transform: translateX(-100px) scale(0.9);
}

/* Responsive */
@media (max-width: 768px) {
  .slide-content {
    padding: 2rem;
  }

  .slide-title-large {
    font-size: 3rem;
  }

  .slide-subtitle-large {
    font-size: 1.5rem;
  }

  .emoji-large {
    font-size: 5rem;
  }

  .slide-title {
    font-size: 2rem;
  }

  .content-item {
    font-size: 1rem;
  }

  .split-columns {
    grid-template-columns: 1fr;
    gap: 2rem;
  }

  .column-divider {
    display: none;
  }

  .navigation {
    bottom: 2rem;
  }

  .exit-btn {
    top: 1rem;
    right: 1rem;
    width: 2.5rem;
    height: 2.5rem;
  }

  .slide-counter {
    top: 1rem;
    left: 1rem;
    font-size: 1rem;
  }
}
</style>
