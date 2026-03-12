<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { marked } from 'marked'

const router = useRouter()
const markdownContent = ref('')
const htmlContent = ref('')
const loading = ref(true)
const error = ref(null)

onMounted(async () => {
  try {
    const response = await fetch('/review.md')
    if (!response.ok) {
      throw new Error(`Failed to load review: ${response.statusText}`)
    }
    markdownContent.value = await response.text()
    
    // Configure marked options
    marked.setOptions({
      breaks: true,
      gfm: true,
      headerIds: true,
      mangle: false
    })
    
    htmlContent.value = marked.parse(markdownContent.value)
    loading.value = false
  } catch (err) {
    error.value = err.message
    loading.value = false
  }
})

function goBack() {
  router.push('/review')
}

function goHome() {
  router.push('/')
}
</script>

<template>
  <div class="review-full-view">
    <div class="bg-gradient"></div>
    
    <!-- Fixed Header -->
    <header class="fixed-header">
      <div class="header-content">
        <div class="header-left">
          <button class="nav-btn" @click="goBack" title="Back to Review Summary">
            ← Summary
          </button>
          <button class="nav-btn" @click="goHome" title="Home">
            🏠 Home
          </button>
        </div>
        <h1 class="header-title">
          <span class="title-icon">📄</span>
          Complete Code Review
        </h1>
      </div>
    </header>

    <div class="content-wrapper">
      <!-- Loading State -->
      <div v-if="loading" class="loading-state">
        <div class="spinner"></div>
        <p>Loading review document...</p>
      </div>

      <!-- Error State -->
      <div v-else-if="error" class="error-state glass-card">
        <div class="error-icon">⚠️</div>
        <h2>Failed to Load Review</h2>
        <p>{{ error }}</p>
        <button class="retry-btn" @click="goBack">← Back to Summary</button>
      </div>

      <!-- Markdown Content -->
      <article v-else class="markdown-container glass-card">
        <div class="markdown-content" v-html="htmlContent"></div>
      </article>
    </div>
  </div>
</template>

<style scoped>
.review-full-view {
  min-height: 100vh;
  min-height: 100dvh;
  position: relative;
  background: var(--bg-primary);
  padding-top: 5rem;
}

.bg-gradient {
  position: fixed;
  inset: 0;
  background: 
    radial-gradient(ellipse at top right, rgba(139, 92, 246, 0.05) 0%, transparent 50%),
    radial-gradient(ellipse at bottom left, rgba(59, 130, 246, 0.05) 0%, transparent 50%),
    var(--bg-primary);
  z-index: -1;
}

/* Fixed Header */
.fixed-header {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 100;
  background: rgba(17, 24, 39, 0.95);
  backdrop-filter: blur(20px);
  border-bottom: 1px solid var(--border-default);
  padding: var(--space-4) var(--space-4);
}

.header-content {
  max-width: 1000px;
  margin: 0 auto;
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: var(--space-4);
}

.header-left {
  display: flex;
  gap: var(--space-2);
}

.nav-btn {
  padding: var(--space-2) var(--space-4);
  background: var(--bg-secondary);
  border: 1px solid var(--border-default);
  border-radius: var(--radius-lg);
  color: var(--text-secondary);
  font-size: var(--text-sm);
  cursor: pointer;
  transition: all var(--duration-fast);
  white-space: nowrap;
}

.nav-btn:hover {
  background: var(--bg-elevated);
  color: var(--text-primary);
  border-color: var(--accent-primary);
}

.header-title {
  font-size: var(--text-xl);
  font-weight: var(--font-semibold);
  color: var(--text-primary);
  margin: 0;
  display: flex;
  align-items: center;
  gap: var(--space-2);
}

.title-icon {
  font-size: 1.5rem;
}

/* Content */
.content-wrapper {
  max-width: 1000px;
  margin: 0 auto;
  padding: var(--space-6) var(--space-4);
}

/* Loading State */
.loading-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: var(--space-4);
  padding: var(--space-8);
  color: var(--text-secondary);
}

.spinner {
  width: 40px;
  height: 40px;
  border: 3px solid var(--border-default);
  border-top-color: var(--accent-primary);
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

/* Error State */
.error-state {
  padding: var(--space-8);
  text-align: center;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--space-4);
}

.error-icon {
  font-size: 3rem;
}

.error-state h2 {
  margin: 0;
  color: var(--text-primary);
  font-size: var(--text-xl);
}

.error-state p {
  margin: 0;
  color: var(--text-secondary);
}

.retry-btn {
  padding: var(--space-3) var(--space-5);
  background: var(--accent-primary);
  border: none;
  border-radius: var(--radius-lg);
  color: white;
  font-size: var(--text-sm);
  font-weight: var(--font-semibold);
  cursor: pointer;
  transition: all var(--duration-fast);
}

.retry-btn:hover {
  background: rgba(139, 92, 246, 0.8);
}

/* Markdown Container */
.glass-card {
  background: rgba(255, 255, 255, 0.05);
  backdrop-filter: blur(20px);
  border: 1px solid var(--border-default);
  border-radius: var(--radius-xl);
}

.markdown-container {
  padding: var(--space-8);
  margin-bottom: var(--space-8);
}

/* Markdown Content Styles */
.markdown-content {
  color: var(--text-secondary);
  line-height: 1.7;
  font-size: var(--text-base);
}

/* Typography */
.markdown-content :deep(h1),
.markdown-content :deep(h2),
.markdown-content :deep(h3),
.markdown-content :deep(h4),
.markdown-content :deep(h5),
.markdown-content :deep(h6) {
  color: var(--text-primary);
  font-weight: var(--font-bold);
  margin-top: 2em;
  margin-bottom: 0.75em;
  line-height: 1.3;
}

.markdown-content :deep(h1) {
  font-size: var(--text-3xl);
  border-bottom: 2px solid var(--border-default);
  padding-bottom: var(--space-3);
  margin-top: 0;
}

.markdown-content :deep(h2) {
  font-size: var(--text-2xl);
  border-bottom: 1px solid var(--border-subtle);
  padding-bottom: var(--space-2);
}

.markdown-content :deep(h3) {
  font-size: var(--text-xl);
}

.markdown-content :deep(h4) {
  font-size: var(--text-lg);
}

.markdown-content :deep(p) {
  margin: 1em 0;
}

.markdown-content :deep(strong) {
  color: var(--text-primary);
  font-weight: var(--font-semibold);
}

.markdown-content :deep(em) {
  font-style: italic;
  color: var(--text-secondary);
}

/* Links */
.markdown-content :deep(a) {
  color: var(--accent-primary);
  text-decoration: none;
  border-bottom: 1px solid transparent;
  transition: border-color var(--duration-fast);
}

.markdown-content :deep(a:hover) {
  border-bottom-color: var(--accent-primary);
}

/* Lists */
.markdown-content :deep(ul),
.markdown-content :deep(ol) {
  margin: 1em 0;
  padding-left: 2em;
}

.markdown-content :deep(li) {
  margin: 0.5em 0;
}

.markdown-content :deep(ul ul),
.markdown-content :deep(ol ol) {
  margin: 0.25em 0;
}

/* Code */
.markdown-content :deep(code) {
  background: var(--bg-secondary);
  padding: 0.2em 0.4em;
  border-radius: var(--radius-sm);
  font-family: var(--font-mono);
  font-size: 0.9em;
  color: var(--text-primary);
  border: 1px solid var(--border-subtle);
}

.markdown-content :deep(pre) {
  background: var(--bg-secondary);
  border: 1px solid var(--border-default);
  border-radius: var(--radius-lg);
  padding: var(--space-4);
  overflow-x: auto;
  margin: 1.5em 0;
}

.markdown-content :deep(pre code) {
  background: none;
  padding: 0;
  border: none;
  font-size: var(--text-sm);
  line-height: 1.6;
}

/* Blockquotes */
.markdown-content :deep(blockquote) {
  margin: 1.5em 0;
  padding: var(--space-4) var(--space-5);
  border-left: 4px solid var(--accent-primary);
  background: var(--bg-secondary);
  border-radius: 0 var(--radius-md) var(--radius-md) 0;
}

.markdown-content :deep(blockquote p) {
  margin: 0.5em 0;
}

/* Tables */
.markdown-content :deep(table) {
  width: 100%;
  border-collapse: collapse;
  margin: 1.5em 0;
  font-size: var(--text-sm);
}

.markdown-content :deep(table thead) {
  background: var(--bg-secondary);
  border-bottom: 2px solid var(--border-default);
}

.markdown-content :deep(table th) {
  padding: var(--space-3);
  text-align: left;
  font-weight: var(--font-semibold);
  color: var(--text-primary);
}

.markdown-content :deep(table td) {
  padding: var(--space-3);
  border-bottom: 1px solid var(--border-subtle);
}

.markdown-content :deep(table tr:hover) {
  background: rgba(255, 255, 255, 0.02);
}

/* Horizontal Rule */
.markdown-content :deep(hr) {
  border: none;
  border-top: 1px solid var(--border-default);
  margin: 2em 0;
}

/* Images */
.markdown-content :deep(img) {
  max-width: 100%;
  height: auto;
  border-radius: var(--radius-lg);
  margin: 1em 0;
}

/* Responsive */
@media (max-width: 768px) {
  .review-full-view {
    padding-top: 4.5rem;
  }

  .fixed-header {
    padding: var(--space-3);
  }

  .header-content {
    flex-direction: column;
    align-items: flex-start;
    gap: var(--space-3);
  }

  .header-title {
    font-size: var(--text-base);
  }

  .title-icon {
    font-size: 1.25rem;
  }

  .content-wrapper {
    padding: var(--space-4) var(--space-3);
  }

  .markdown-container {
    padding: var(--space-5);
  }

  .markdown-content {
    font-size: var(--text-sm);
  }

  .markdown-content :deep(table) {
    font-size: var(--text-xs);
  }

  .markdown-content :deep(pre) {
    padding: var(--space-3);
  }
}
</style>
