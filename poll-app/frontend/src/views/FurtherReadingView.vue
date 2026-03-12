<script setup>
import { useRouter } from 'vue-router'

const router = useRouter()

function goHome() {
  router.push('/')
}

const readings = [
  {
    id: 1,
    title: 'Software 2.0',
    author: 'Andrej Karpathy',
    link: 'https://karpathy.medium.com/software-2-0-a64152b37c35',
    description: 'Introduced the concept of Software 2.0, a shift where machine learning models replace traditional hand-written algorithms. Describes two paradigms: Software 1.0 (traditional explicit programming) and Software 2.0 (behavior learned through training neural networks). Laid the groundwork for discussions about AI-generated code.',
    tags: ['Foundational', 'Neural Networks']
  },
  {
    id: 2,
    title: 'Software Is Changing (Again)',
    author: 'Andrej Karpathy',
    link: 'https://www.youtube.com/watch?v=LCEmiRjPEtQ',
    description: 'Presentation explaining how deep learning and language models are transforming software development. Discusses the increasing importance of neural network systems, emergence of AI-assisted coding tools, and the possibility that natural language becomes a programming interface.',
    tags: ['Presentation', 'AI Tools']
  },
  {
    id: 3,
    title: 'Agentic Engineering Patterns',
    author: 'Simon Willison',
    link: 'https://simonwillison.net/2026/Feb/23/agentic-engineering-patterns/',
    description: 'Explores practical patterns for working with coding agents and AI-driven workflows. Argues that AI tools reduce code generation costs, shifting the bottleneck to validation and testing. Emphasizes iterative development loops, strict testing discipline, and constrained execution environments.',
    tags: ['Practical', 'Patterns', 'Testing']
  },
  {
    id: 4,
    title: 'Code Is Cheap',
    author: 'Simon Willison',
    link: 'https://simonwillison.net/guides/agentic-engineering-patterns/code-is-cheap/',
    description: 'Highlights the central insight: when code generation costs approach zero, the real challenge becomes ensuring correctness and reliability. Explains why testing, architecture, design decisions, and validation workflows are now more important than ever.',
    tags: ['Philosophy', 'Validation']
  },
  {
    id: 5,
    title: 'First Run the Tests',
    author: 'Simon Willison',
    link: 'https://simonwillison.net/guides/agentic-engineering-patterns/first-run-the-tests/',
    description: 'Explains why automated tests are essential when working with AI coding agents. Without robust testing, errors and regressions quickly accumulate. Emphasizes comprehensive automated tests, reproducible development environments, and strong feedback loops.',
    tags: ['Testing', 'Best Practices']
  },
  {
    id: 6,
    title: 'Agentic Software Engineering: Foundational Pillars and a Research Roadmap',
    author: 'Multiple researchers',
    link: 'https://arxiv.org/abs/2509.06216',
    description: 'Academic paper proposing a structured research agenda for agent-driven development. Introduces architecture with human command environment, agent execution environment, and automated evaluation mechanisms. Describes a future where AI agents carry out development tasks while humans define goals.',
    tags: ['Research', 'Framework']
  },
  {
    id: 7,
    title: 'Agentic Design Patterns: A System-Theoretic Framework',
    author: 'Multiple researchers',
    link: 'https://arxiv.org/abs/2601.19752',
    description: 'Formalizes autonomous agent system design with interacting subsystems: reasoning, perception, execution, learning, and communication. Framework draws from distributed systems, control theory, and artificial intelligence.',
    tags: ['Research', 'Architecture', 'Theory']
  },
  {
    id: 8,
    title: 'Configuring Agentic AI Coding Tools',
    author: 'Multiple researchers',
    link: 'https://arxiv.org/abs/2602.14690',
    description: 'Analyzes thousands of open-source repositories using AI coding agents. Discovered growing pattern of AGENTS.md configuration files defining agent permissions, development workflows, tool access, and evaluation strategies. Suggests configuring AI agents may become standard practice.',
    tags: ['Research', 'Configuration', 'Best Practices']
  },
  {
    id: 9,
    title: 'Why Agentic Pull Requests Get Rejected',
    author: 'Multiple researchers',
    link: 'https://arxiv.org/abs/2602.04226',
    description: 'Investigates AI-generated pull requests, finding they are often rejected due to incorrect assumptions about the codebase, incomplete reasoning about system behavior, and improper tool usage. Highlights the continued importance of human review and engineering judgment.',
    tags: ['Research', 'Quality', 'Human Oversight']
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
            Agentic Software Engineering
          </h1>
          <p class="reading-subtitle">Influential Essays, Articles, and Research (2017–2026)</p>
        </div>
      </header>

      <!-- Introduction Card -->
      <div class="intro-card glass-card">
        <h2 class="intro-title">Introduction</h2>
        <div class="intro-content">
          <p>
            Recent advances in large language models and AI tooling have sparked an intense debate within the 
            software engineering community about the future of programming.
          </p>
          <p>
            Many researchers and practitioners argue that we are moving toward a new paradigm often described as 
            <strong>agentic software engineering</strong>. In this paradigm:
          </p>
          <ul class="shift-list">
            <li>AI systems generate large portions of software</li>
            <li>Autonomous agents perform development tasks</li>
            <li>Developers supervise, guide, and validate outcomes rather than writing every line manually</li>
          </ul>
          <p>
            This collection provides an overview of several <strong>influential essays, talks, and research papers</strong> 
            that have shaped the discussion around the future of programming and the emergence of agent-based software development.
          </p>
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
        <h3 class="section-title">Conclusion</h3>
        <div class="conclusion-content">
          <p>
            The essays and research papers described here illustrate a significant shift in how software is created.
          </p>
          <p>
            Traditional programming workflows focus on developers writing code manually. In contrast, emerging 
            agentic workflows emphasize:
          </p>
          <ul class="conclusion-list">
            <li><strong>Describing goals</strong> rather than implementation details</li>
            <li><strong>Orchestrating autonomous agents</strong> to perform development tasks</li>
            <li><strong>Validating generated implementations</strong> through rigorous testing</li>
            <li><strong>Supervising iterative development processes</strong> with human oversight</li>
          </ul>
          <p class="conclusion-note">
            Rather than eliminating programmers, these developments appear to change the role of software engineers, 
            emphasizing architecture, system design, and evaluation of AI-generated solutions. As AI systems continue 
            to improve, understanding and mastering these new workflows will likely become an important skill for 
            modern software engineers.
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

/* Section Title */
.section-title {
  font-size: var(--text-xl);
  font-weight: var(--font-semibold);
  color: var(--text-primary);
  margin: 0 0 var(--space-6);
  text-align: center;
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
}
</style>
