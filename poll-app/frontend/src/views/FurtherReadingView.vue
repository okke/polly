<script setup>
import { useRouter } from 'vue-router'

const router = useRouter()

function goHome() {
  router.push('/')
}

const readings = [
  {
    id: 1,
    title: 'Software 3.0',
    author: 'Andrej Karpathy',
    link: 'https://www.latent.space/p/software-3-0',
    description: 'Proposes three generations of software development: traditional programming (1.0), machine learning models (2.0), and natural language prompts to AI systems (3.0). Natural language becomes a programming interface where AI models act as universal interpreters.',
    tags: ['Conceptual Framework', 'Evolution']
  },
  {
    id: 2,
    title: 'Agentic Engineering',
    author: 'Andrej Karpathy',
    link: 'https://www.businessinsider.com/agentic-engineering-andrej-karpathy-vibe-coding-2026-2',
    description: 'Distinguishes between "vibe coding" (casual prompting) and "agentic engineering" (autonomous agents executing development loops). AI agents operate as autonomous collaborators rather than passive assistants, with developers defining goals and guiding architecture.',
    tags: ['Conceptual Framework', 'Autonomy']
  },
  {
    id: 3,
    title: 'Agentic Software Engineering: Foundational Pillars and a Research Roadmap',
    author: 'Multiple academic researchers',
    link: 'https://www.researchgate.net/publication/395355277_Agentic_Software_Engineering_Foundational_Pillars_and_a_Research_Roadmap',
    description: 'Proposes a research framework for agent-driven software development (SE 3.0) with Human Command Environment, Agent Execution Environment, and feedback systems. Outlines a roadmap for future research in agent-based development.',
    tags: ['Research', 'Framework']
  },
  {
    id: 4,
    title: 'Agentic Engineering Patterns',
    author: 'Simon Willison',
    link: 'https://simonwillison.net/2026/02/23/agentic-engineering-patterns/',
    description: 'Explores practical patterns for working with coding agents, focusing on strong test suites, iterative agent loops, and tightly constrained environments. Key insight: when generating code becomes cheap, validation becomes the bottleneck.',
    tags: ['Practical', 'Patterns', 'Testing']
  },
  {
    id: 5,
    title: 'Agentic Engineering vs Vibe Coding',
    author: 'Martin Fowler',
    link: 'https://martinfowler.com/articles/agentic-engineering.html',
    description: 'Nuanced analysis distinguishing vibe coding (non-experts generating code) from agentic engineering (professionals orchestrating AI agents). Argues that experienced engineers become more valuable because system architecture, validation, and testing remain complex.',
    tags: ['Analysis', 'Professional Practice']
  },
  {
    id: 6,
    title: 'LLM Predictions for 2026',
    author: 'Simon Willison',
    link: 'https://simonwillison.net/2026/01/08/llm-predictions/',
    description: 'Predicts the emergence of asynchronous coding agents, automated development pipelines, and AI-assisted research. Developers increasingly supervise systems that write code, run experiments, evaluate results, and propose improvements.',
    tags: ['Predictions', 'Future Trends']
  },
  {
    id: 7,
    title: 'Agentic Design Patterns: A System-Theoretic Framework',
    author: 'Academic research team',
    link: 'https://arxiv.org/abs/2601.19752',
    description: 'Formalizes agentic system architecture with five functional subsystems: reasoning, perception, action execution, learning, and communication. Connects ideas from control theory, distributed systems, and AI research.',
    tags: ['Research', 'Architecture', 'Theory']
  },
  {
    id: 8,
    title: 'Configuring Agentic AI Coding Tools',
    author: 'Academic research team',
    link: 'https://arxiv.org/abs/2602.14690',
    description: 'Analyzes thousands of repositories using AI coding agents, discovering the emergence of AGENTS.md configuration files defining agent instructions, tool permissions, development workflows, and evaluation rules.',
    tags: ['Research', 'Configuration', 'Best Practices']
  },
  {
    id: 9,
    title: 'Why Agentic Pull Requests Get Rejected',
    author: 'Academic research team',
    link: 'https://arxiv.org/abs/2602.04226',
    description: 'Studies AI-generated pull requests, finding they are accepted less frequently due to incorrect assumptions, incomplete reasoning, and tool misuse. Highlights the critical importance of human oversight in the development process.',
    tags: ['Research', 'Quality', 'Human Oversight']
  },
  {
    id: 10,
    title: 'WINK: Recovering from Misbehaviors in Coding Agents',
    author: 'Academic research team',
    link: 'https://arxiv.org/abs/2602.17037',
    description: 'Focuses on improving reliability by addressing common failure modes: specification drift, reasoning errors, tool misuse, and environment inconsistencies. Proposes framework for detecting failures and guiding agents toward correct behavior.',
    tags: ['Research', 'Reliability', 'Error Recovery']
  }
]
</script>

<template>
  <div class="reading-view">
    <div class="bg-gradient"></div>
    
    <div class="reading-container">
      <!-- Header -->
      <header class="reading-header">
        <button class="back-btn" @click="goHome" title="Back to Home">
          ← Home
        </button>
        <div class="header-content">
          <h1 class="reading-title">
            <span class="title-icon">📚</span>
            Further Reading
          </h1>
          <p class="reading-subtitle">The Rise of Agentic Software Engineering</p>
        </div>
      </header>

      <!-- Introduction Card -->
      <div class="intro-card glass-card">
        <h2 class="intro-title">Influential Essays and Papers (2025–2026)</h2>
        <div class="intro-content">
          <p>
            Over the past few years, rapid advances in large language models (LLMs) have triggered a new discussion: 
            <strong>is programming as we know it ending?</strong>
          </p>
          <p>
            While software development itself is not disappearing, the <strong>role of the developer is shifting</strong>. 
            Instead of writing every line of code manually, developers increasingly:
          </p>
          <ul class="shift-list">
            <li>Describe intent</li>
            <li>Supervise AI coding agents</li>
            <li>Validate generated implementations</li>
            <li>Orchestrate autonomous development workflows</li>
          </ul>
          <p>
            This collection summarizes <strong>ten of the most influential works</strong> from leading AI researchers, 
            experienced software engineers, and academic research groups discussing this transition toward 
            <em>agentic software engineering</em>.
          </p>
        </div>
      </div>

      <!-- Evolution Timeline -->
      <div class="evolution-card glass-card">
        <h3 class="section-title">The Evolution of Programming</h3>
        <div class="timeline">
          <div class="timeline-item">
            <div class="timeline-marker era-1"></div>
            <div class="timeline-content">
              <div class="timeline-label">Traditional Programming</div>
              <div class="timeline-desc">Human developers write every line of code</div>
            </div>
          </div>
          <div class="timeline-connector"></div>
          <div class="timeline-item">
            <div class="timeline-marker era-2"></div>
            <div class="timeline-content">
              <div class="timeline-label">AI-Assisted Programming</div>
              <div class="timeline-desc">AI tools help generate and modify code</div>
            </div>
          </div>
          <div class="timeline-connector"></div>
          <div class="timeline-item">
            <div class="timeline-marker era-3"></div>
            <div class="timeline-content">
              <div class="timeline-label">Agentic Software Engineering</div>
              <div class="timeline-desc">Autonomous agents plan, implement, test, and refine software under human supervision</div>
            </div>
          </div>
        </div>
      </div>

      <!-- Reading List -->
      <div class="readings-section">
        <h3 class="section-title">Essential Reading</h3>
        <div class="readings-grid">
          <article 
            v-for="reading in readings" 
            :key="reading.id"
            class="reading-card glass-card"
          >
            <div class="card-number">{{ reading.id.toString().padStart(2, '0') }}</div>
            <h4 class="card-title">{{ reading.title }}</h4>
            <div class="card-author">by {{ reading.author }}</div>
            <p class="card-description">{{ reading.description }}</p>
            <div class="card-tags">
              <span v-for="tag in reading.tags" :key="tag" class="tag">{{ tag }}</span>
            </div>
            <a 
              :href="reading.link" 
              target="_blank" 
              rel="noopener noreferrer" 
              class="card-link"
            >
              Read Article →
            </a>
          </article>
        </div>
      </div>

      <!-- Conclusion -->
      <div class="conclusion-card glass-card">
        <h3 class="section-title">The Emerging Narrative</h3>
        <div class="conclusion-content">
          <p>
            Across these essays and research papers, a consistent narrative is emerging. Software engineering 
            is not ending—it's transforming.
          </p>
          <p>
            The developer's role is shifting toward:
          </p>
          <ul class="conclusion-list">
            <li><strong>System design</strong> and architectural thinking</li>
            <li><strong>Supervision</strong> of autonomous agents</li>
            <li><strong>Validation</strong> of generated software</li>
            <li><strong>Orchestration</strong> of complex development workflows</li>
          </ul>
          <p class="conclusion-note">
            The next decade will likely determine whether agentic systems become the dominant paradigm 
            in software development.
          </p>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.reading-view {
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

.reading-container {
  max-width: 1100px;
  margin: 0 auto;
  display: flex;
  flex-direction: column;
  gap: var(--space-6);
}

/* Header */
.reading-header {
  display: flex;
  flex-direction: column;
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
  width: fit-content;
}

.back-btn:hover {
  background: var(--bg-elevated);
  color: var(--text-primary);
  border-color: var(--accent-primary);
}

.header-content {
  text-align: center;
}

.reading-title {
  font-size: var(--text-3xl);
  font-weight: var(--font-bold);
  color: var(--text-primary);
  margin: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: var(--space-3);
}

.title-icon {
  font-size: 2.5rem;
}

.reading-subtitle {
  margin: var(--space-2) 0 0;
  font-size: var(--text-lg);
  color: var(--text-secondary);
  font-style: italic;
}

/* Glass Card Base */
.glass-card {
  background: rgba(255, 255, 255, 0.05);
  backdrop-filter: blur(20px);
  border: 1px solid var(--border-default);
  border-radius: var(--radius-xl);
  padding: var(--space-6);
}

/* Introduction Card */
.intro-card {
  padding: var(--space-8);
}

.intro-title {
  font-size: var(--text-2xl);
  font-weight: var(--font-bold);
  color: var(--text-primary);
  margin: 0 0 var(--space-5);
  text-align: center;
}

.intro-content {
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
}

.intro-content p {
  margin: 0;
  line-height: 1.7;
  color: var(--text-secondary);
  font-size: var(--text-base);
}

.intro-content strong {
  color: var(--text-primary);
  font-weight: var(--font-semibold);
}

.intro-content em {
  color: var(--accent-primary);
  font-style: italic;
}

.shift-list {
  list-style: none;
  padding: 0;
  margin: 0;
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: var(--space-3);
}

.shift-list li {
  padding: var(--space-3);
  background: var(--bg-secondary);
  border-radius: var(--radius-md);
  border-left: 3px solid var(--accent-primary);
  font-size: var(--text-sm);
  color: var(--text-secondary);
}

/* Evolution Timeline */
.evolution-card {
  padding: var(--space-8);
}

.section-title {
  font-size: var(--text-xl);
  font-weight: var(--font-semibold);
  color: var(--text-primary);
  margin: 0 0 var(--space-6);
  text-align: center;
}

.timeline {
  display: flex;
  flex-direction: column;
  gap: 0;
}

.timeline-item {
  display: flex;
  align-items: center;
  gap: var(--space-4);
}

.timeline-marker {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  flex-shrink: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: var(--font-bold);
  font-size: var(--text-sm);
  border: 3px solid;
}

.timeline-marker.era-1 {
  background: rgba(239, 68, 68, 0.1);
  border-color: #ef4444;
}

.timeline-marker.era-2 {
  background: rgba(234, 179, 8, 0.1);
  border-color: #eab308;
}

.timeline-marker.era-3 {
  background: rgba(34, 197, 94, 0.1);
  border-color: #22c55e;
}

.timeline-content {
  flex: 1;
  padding: var(--space-4);
  background: var(--bg-secondary);
  border-radius: var(--radius-md);
}

.timeline-label {
  font-weight: var(--font-semibold);
  color: var(--text-primary);
  margin-bottom: var(--space-2);
}

.timeline-desc {
  font-size: var(--text-sm);
  color: var(--text-secondary);
  line-height: 1.5;
}

.timeline-connector {
  width: 2px;
  height: 30px;
  background: var(--border-default);
  margin-left: 19px;
}

/* Reading Cards Grid */
.readings-section {
  display: flex;
  flex-direction: column;
  gap: var(--space-5);
}

.readings-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: var(--space-5);
}

.reading-card {
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
  transition: all var(--duration-fast);
  position: relative;
}

.reading-card:hover {
  transform: translateY(-4px);
  border-color: var(--accent-primary);
  box-shadow: 0 10px 30px rgba(139, 92, 246, 0.2);
}

.card-number {
  position: absolute;
  top: var(--space-3);
  right: var(--space-3);
  font-family: var(--font-mono);
  font-size: var(--text-xs);
  color: var(--text-tertiary);
  background: var(--bg-secondary);
  padding: var(--space-1) var(--space-2);
  border-radius: var(--radius-sm);
}

.card-title {
  font-size: var(--text-lg);
  font-weight: var(--font-bold);
  color: var(--text-primary);
  margin: 0;
  padding-right: var(--space-8);
  line-height: 1.3;
}

.card-author {
  font-size: var(--text-sm);
  color: var(--text-tertiary);
  font-style: italic;
}

.card-description {
  font-size: var(--text-sm);
  line-height: 1.6;
  color: var(--text-secondary);
  margin: 0;
  flex: 1;
}

.card-tags {
  display: flex;
  flex-wrap: wrap;
  gap: var(--space-2);
}

.tag {
  padding: var(--space-1) var(--space-2);
  background: var(--bg-secondary);
  border: 1px solid var(--border-subtle);
  border-radius: var(--radius-sm);
  font-size: var(--text-xs);
  color: var(--text-tertiary);
  font-weight: var(--font-medium);
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.card-link {
  display: inline-flex;
  align-items: center;
  gap: var(--space-2);
  padding: var(--space-3) var(--space-4);
  background: linear-gradient(135deg, var(--accent-primary) 0%, rgba(59, 130, 246, 0.8) 100%);
  color: white;
  text-decoration: none;
  border-radius: var(--radius-md);
  font-size: var(--text-sm);
  font-weight: var(--font-semibold);
  transition: all var(--duration-fast);
  width: fit-content;
}

.card-link:hover {
  transform: translateX(4px);
  box-shadow: 0 4px 12px rgba(139, 92, 246, 0.3);
}

/* Conclusion Card */
.conclusion-card {
  padding: var(--space-8);
  background: linear-gradient(135deg, rgba(139, 92, 246, 0.05) 0%, rgba(59, 130, 246, 0.05) 100%);
}

.conclusion-content {
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
}

.conclusion-content p {
  margin: 0;
  line-height: 1.7;
  color: var(--text-secondary);
  font-size: var(--text-base);
}

.conclusion-list {
  list-style: none;
  padding: 0;
  margin: 0;
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
}

.conclusion-list li {
  padding: var(--space-3);
  background: rgba(255, 255, 255, 0.05);
  border-radius: var(--radius-md);
  border-left: 3px solid #22c55e;
  font-size: var(--text-sm);
  color: var(--text-secondary);
}

.conclusion-list strong {
  color: var(--text-primary);
  font-weight: var(--font-semibold);
}

.conclusion-note {
  padding: var(--space-4);
  background: var(--bg-secondary);
  border-radius: var(--radius-md);
  border: 1px solid var(--border-default);
  font-style: italic;
  color: var(--text-secondary) !important;
}

/* Responsive */
@media (max-width: 768px) {
  .reading-view {
    padding: var(--space-4) var(--space-3);
  }

  .glass-card {
    padding: var(--space-5);
  }

  .intro-card,
  .evolution-card,
  .conclusion-card {
    padding: var(--space-5);
  }

  .reading-title {
    font-size: var(--text-2xl);
    flex-direction: column;
  }

  .shift-list {
    grid-template-columns: 1fr;
  }

  .readings-grid {
    grid-template-columns: 1fr;
  }

  .timeline-item {
    flex-direction: column;
    align-items: flex-start;
  }

  .timeline-connector {
    margin-left: 19px;
    height: 20px;
  }
}
</style>
