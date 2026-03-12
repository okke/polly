<script setup>
import { useRouter } from 'vue-router'

const router = useRouter()

function viewFullReview() {
  router.push('/review/full')
}

function goHome() {
  router.push('/')
}
</script>

<template>
  <div class="review-view">
    <div class="bg-gradient"></div>
    
    <div class="review-container">
      <!-- Header -->
      <header class="review-header">
        <button class="back-btn" @click="goHome" title="Back to Home">
          ← Home
        </button>
        <h1 class="review-title">
          <span class="title-icon">📋</span>
          Code Review
        </h1>
      </header>

      <!-- Abstract Card -->
      <div class="abstract-card glass-card">
        <div class="card-header">
          <h2 class="card-title">Executive Summary</h2>
          <div class="review-meta">
            <span class="meta-item">
              <span class="meta-label">Date:</span>
              <span class="meta-value">2026-03-12</span>
            </span>
            <span class="meta-item">
              <span class="meta-label">Reviewer:</span>
              <span class="meta-value">Claude Sonnet 4.6</span>
            </span>
          </div>
        </div>

        <div class="summary-text">
          <p>
            Polly is a real-time polling app explicitly built through <strong>AI-agent collaboration</strong>. 
            The result is a surprisingly coherent product: clean separation of concerns, good composable 
            patterns on the frontend, and a well-structured service layer on the backend.
          </p>
          <p>
            However, the agentic development approach has also left behind a set of recognisable artefacts — 
            long files, scattered state, unused abstractions, and a security posture that was never revisited 
            after the happy path worked.
          </p>
        </div>

        <!-- Scores Grid -->
        <div class="scores-section">
          <h3 class="section-subtitle">Scores at a Glance</h3>
          <div class="scores-grid">
            <div class="score-card architecture">
              <div class="score-label">Architecture</div>
              <div class="score-value">7/10</div>
              <div class="score-note">Clean layers, good intent</div>
            </div>
            <div class="score-card quality">
              <div class="score-label">Code Quality</div>
              <div class="score-value">6/10</div>
              <div class="score-note">Some long files, mixed patterns</div>
            </div>
            <div class="score-card security">
              <div class="score-label">Security</div>
              <div class="score-value">2/10</div>
              <div class="score-note">API key committed, no auth</div>
            </div>
            <div class="score-card performance">
              <div class="score-label">Performance</div>
              <div class="score-value">5/10</div>
              <div class="score-note">Good WebSocket, aggressive ping</div>
            </div>
            <div class="score-card agentic">
              <div class="score-label">Agentic Patterns</div>
              <div class="score-value">4/10</div>
              <div class="score-note">Good UX, code debt</div>
            </div>
            <div class="score-card testability">
              <div class="score-label">Testability</div>
              <div class="score-value">3/10</div>
              <div class="score-note">No tests, no infrastructure</div>
            </div>
          </div>
        </div>

        <!-- Key Findings -->
        <div class="findings-section">
          <h3 class="section-subtitle">Key Findings</h3>
          
          <div class="finding-group">
            <h4 class="finding-title">✅ What Works Well</h4>
            <ul class="finding-list positive">
              <li>Clear backend/frontend separation with respected boundaries</li>
              <li>Well-designed service layer (PollGenerator, PsychAnalyzer, PollStorage)</li>
              <li>Idiomatic Vue 3 composables pattern</li>
              <li>Sound WebSocket broadcast architecture</li>
              <li>Simple, portable Makefile orchestration</li>
              <li>Sophisticated AI prompt engineering with temperature tuning</li>
            </ul>
          </div>

          <div class="finding-group">
            <h4 class="finding-title">⚠️ Critical Issues</h4>
            <ul class="finding-list critical">
              <li><strong>Security:</strong> API key committed to repository (live incident)</li>
              <li><strong>Security:</strong> No authentication for admin endpoints</li>
              <li><strong>Architecture:</strong> server/app.rb is 858 lines (should be split)</li>
              <li><strong>Security:</strong> CORS wildcard allows any origin</li>
              <li><strong>Performance:</strong> 1 Hz WebSocket ping is too aggressive</li>
            </ul>
          </div>

          <div class="finding-group">
            <h4 class="finding-title">🤖 Agentic Development Observations</h4>
            <ul class="finding-list agentic">
              <li><strong>Main file gravity:</strong> Agent kept appending to app.rb instead of creating new files</li>
              <li><strong>Security blind spot:</strong> Cross-cutting concerns like security never revisited</li>
              <li><strong>Pattern divergence:</strong> Modals and error handling re-implemented per generation session</li>
              <li><strong>Unused dependencies:</strong> Pinia installed but no stores created</li>
              <li><strong>Missing tests:</strong> Agent focused on features, not verification</li>
              <li><strong>Magic numbers:</strong> Constants inlined and never extracted</li>
            </ul>
          </div>
        </div>

        <!-- CTA -->
        <div class="cta-section">
          <button class="full-review-btn" @click="viewFullReview">
            <span class="btn-icon">📄</span>
            <span>View Complete Review (Markdown)</span>
            <span class="btn-arrow">→</span>
          </button>
          <p class="cta-note">
            Detailed analysis with 13-step improvement plan
          </p>
        </div>
      </div>

      <!-- Quick Stats -->
      <div class="stats-grid">
        <div class="stat-card">
          <div class="stat-value">858</div>
          <div class="stat-label">Lines in app.rb</div>
          <div class="stat-problem">Should be &lt; 300</div>
        </div>
        <div class="stat-card">
          <div class="stat-value">0</div>
          <div class="stat-label">Test Coverage</div>
          <div class="stat-problem">Target: 60%</div>
        </div>
        <div class="stat-card">
          <div class="stat-value">13</div>
          <div class="stat-label">Improvement Steps</div>
          <div class="stat-problem">Prioritized plan</div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.review-view {
  min-height: 100vh;
  min-height: 100dvh;
  position: relative;
  background: var(--bg-primary);
  padding: var(--space-6) var(--space-4);
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

.review-container {
  max-width: 900px;
  margin: 0 auto;
  display: flex;
  flex-direction: column;
  gap: var(--space-6);
}

/* Header */
.review-header {
  display: flex;
  align-items: center;
  gap: var(--space-4);
}

.back-btn {
  padding: var(--space-2) var(--space-4);
  background: var(--bg-secondary);
  border: 1px solid var(--border-default);
  border-radius: var(--radius-lg);
  color: var(--text-secondary);
  font-size: var(--text-sm);
  cursor: pointer;
  transition: all var(--duration-fast);
}

.back-btn:hover {
  background: var(--bg-elevated);
  color: var(--text-primary);
  border-color: var(--accent-primary);
}

.review-title {
  font-size: var(--text-3xl);
  font-weight: var(--font-bold);
  color: var(--text-primary);
  margin: 0;
  display: flex;
  align-items: center;
  gap: var(--space-3);
}

.title-icon {
  font-size: 2.5rem;
}

/* Abstract Card */
.abstract-card {
  padding: var(--space-8);
  display: flex;
  flex-direction: column;
  gap: var(--space-6);
}

.glass-card {
  background: rgba(255, 255, 255, 0.05);
  backdrop-filter: blur(20px);
  border: 1px solid var(--border-default);
  border-radius: var(--radius-xl);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  flex-wrap: wrap;
  gap: var(--space-4);
  padding-bottom: var(--space-4);
  border-bottom: 1px solid var(--border-subtle);
}

.card-title {
  font-size: var(--text-2xl);
  font-weight: var(--font-bold);
  color: var(--text-primary);
  margin: 0;
}

.review-meta {
  display: flex;
  gap: var(--space-4);
  flex-wrap: wrap;
}

.meta-item {
  display: flex;
  gap: var(--space-2);
  font-size: var(--text-sm);
}

.meta-label {
  color: var(--text-tertiary);
}

.meta-value {
  color: var(--text-primary);
  font-family: var(--font-mono);
}

.summary-text {
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
}

.summary-text p {
  margin: 0;
  line-height: 1.7;
  color: var(--text-secondary);
  font-size: var(--text-base);
}

.summary-text strong {
  color: var(--text-primary);
  font-weight: var(--font-semibold);
}

/* Scores Section */
.scores-section {
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
}

.section-subtitle {
  font-size: var(--text-lg);
  font-weight: var(--font-semibold);
  color: var(--text-primary);
  margin: 0;
}

.scores-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
  gap: var(--space-3);
}

.score-card {
  padding: var(--space-4);
  background: var(--bg-secondary);
  border: 1px solid var(--border-subtle);
  border-radius: var(--radius-lg);
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--space-2);
  text-align: center;
  transition: all var(--duration-fast);
}

.score-card:hover {
  transform: translateY(-2px);
  border-color: var(--accent-primary);
}

.score-label {
  font-size: var(--text-xs);
  color: var(--text-tertiary);
  text-transform: uppercase;
  letter-spacing: 0.05em;
  font-weight: var(--font-medium);
}

.score-value {
  font-size: var(--text-2xl);
  font-weight: var(--font-bold);
  font-family: var(--font-mono);
}

.score-card.architecture .score-value { color: #22c55e; }
.score-card.quality .score-value { color: #eab308; }
.score-card.security .score-value { color: #ef4444; }
.score-card.performance .score-value { color: #f97316; }
.score-card.agentic .score-value { color: #eab308; }
.score-card.testability .score-value { color: #ef4444; }

.score-note {
  font-size: var(--text-xs);
  color: var(--text-tertiary);
  line-height: 1.4;
}

/* Findings Section */
.findings-section {
  display: flex;
  flex-direction: column;
  gap: var(--space-5);
}

.finding-group {
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
}

.finding-title {
  font-size: var(--text-base);
  font-weight: var(--font-semibold);
  color: var(--text-primary);
  margin: 0;
}

.finding-list {
  list-style: none;
  padding: 0;
  margin: 0;
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
}

.finding-list li {
  padding: var(--space-3);
  background: var(--bg-secondary);
  border-radius: var(--radius-md);
  font-size: var(--text-sm);
  line-height: 1.6;
  border-left: 3px solid;
}

.finding-list.positive li {
  border-left-color: #22c55e;
  color: var(--text-secondary);
}

.finding-list.critical li {
  border-left-color: #ef4444;
  color: var(--text-secondary);
}

.finding-list.agentic li {
  border-left-color: #8b5cf6;
  color: var(--text-secondary);
}

.finding-list strong {
  color: var(--text-primary);
  font-weight: var(--font-semibold);
}

/* CTA Section */
.cta-section {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--space-3);
  padding-top: var(--space-4);
  border-top: 1px solid var(--border-subtle);
}

.full-review-btn {
  padding: var(--space-4) var(--space-6);
  background: linear-gradient(135deg, var(--accent-primary) 0%, rgba(59, 130, 246, 0.8) 100%);
  border: none;
  border-radius: var(--radius-lg);
  color: white;
  font-size: var(--text-base);
  font-weight: var(--font-semibold);
  cursor: pointer;
  transition: all var(--duration-fast);
  display: flex;
  align-items: center;
  gap: var(--space-3);
}

.full-review-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 30px rgba(139, 92, 246, 0.3);
}

.btn-icon {
  font-size: 1.25rem;
}

.btn-arrow {
  font-size: 1.25rem;
  transition: transform var(--duration-fast);
}

.full-review-btn:hover .btn-arrow {
  transform: translateX(4px);
}

.cta-note {
  margin: 0;
  font-size: var(--text-sm);
  color: var(--text-tertiary);
  font-style: italic;
}

/* Stats Grid */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: var(--space-4);
}

.stat-card {
  padding: var(--space-5);
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid var(--border-subtle);
  border-radius: var(--radius-lg);
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--space-2);
  text-align: center;
}

.stat-value {
  font-size: 3rem;
  font-weight: var(--font-bold);
  font-family: var(--font-mono);
  color: var(--accent-primary);
  line-height: 1;
}

.stat-label {
  font-size: var(--text-sm);
  color: var(--text-secondary);
  font-weight: var(--font-medium);
}

.stat-problem {
  font-size: var(--text-xs);
  color: var(--text-tertiary);
  font-style: italic;
}

/* Responsive */
@media (max-width: 768px) {
  .review-view {
    padding: var(--space-4) var(--space-3);
  }

  .abstract-card {
    padding: var(--space-5);
  }

  .review-title {
    font-size: var(--text-2xl);
  }

  .card-header {
    flex-direction: column;
  }

  .scores-grid {
    grid-template-columns: repeat(2, 1fr);
  }

  .stats-grid {
    grid-template-columns: 1fr;
  }
}
</style>
