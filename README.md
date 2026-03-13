# 💬 Polly - Real-time Polling Application

> **⚠️ Experimental Project Notice**  
> This project is an **experiment in agentic code generation** and AI-assisted software development. It was built primarily through AI agent collaboration and is **not intended for production use**. Use at your own risk.

A real-time polling application with AI-powered poll generation, anonymous voting, and live results visualization. Built with Ruby/Sinatra backend and Vue 3 frontend.

## 🎯 Features

### Core Functionality
- **Real-time Voting**: WebSocket-based live updates for instant feedback
- **Anonymous Participation**: No login required, participants identified by session
- **Live Results**: Real-time visualization of voting patterns with Chart.js
- **Multi-Poll Management**: Create, switch between, and manage multiple polls
- **Vote Finalization**: Lock in your votes with optional psychological analysis

### AI-Powered Features
- **Intelligent Poll Generation**: AI creates contextual polls based on topic, audience, and tone
- **Dynamic Model Selection**: Automatically discovers and filters available OpenAI models
- **Psychological Analysis**: 
  - Individual voter analysis with confronting, expert-driven insights
  - Group analysis revealing collective patterns and consensus
  - Subject-matter expertise tailored to poll context
- **Contextual Understanding**: AI considers topic, audience, and tone for relevant analysis

### Admin Panel
- **Poll Management**: Switch between polls, delete old polls, activate different surveys
- **Live Statistics**: Monitor participant count, connected clients, and voting progress
- **QR Code Sharing**: Generate QR codes for easy mobile access
- **Data Export**: Export results to CSV for further analysis
- **Random Vote Generation**: Test with simulated participants (1-1000 voters)
- **Visual Results**: Horizontal bar charts with percentage breakdowns

### User Interface
- **Modern Design**: Glass-morphism effects, terminal-inspired styling, smooth animations
- **Responsive Layout**: Works seamlessly on desktop, tablet, and mobile
- **Dark Theme**: Easy-to-read interface optimized for extended use
- **macOS-Inspired**: Clean, professional aesthetic with subtle gradients
- **Custom Modals**: Polished confirmation dialogs and input forms
- **Smart Routing**: Dedicated pages for voting, admin, about, and home

## 🏗️ Architecture

### Technology Stack

#### Backend (`server/`)
- **Framework**: Sinatra 3.x (lightweight Ruby web framework)
- **WebSocket**: Faye-WebSocket for real-time bidirectional communication
- **Server**: Puma 6.x (concurrent Ruby web server)
- **AI Integration**: 
  - `ruby-openai` 4.x for OpenAI API access
  - `ruby_llm` 1.13.x for LLM abstraction
- **Data Storage**: JSON-based file storage for polls and metadata
- **Environment**: dotenv for configuration management

#### Frontend (`frontend/`)
- **Framework**: Vue 3 with Composition API
- **Routing**: Vue Router 4.x for SPA navigation
- **State Management**: Pinia 2.x for reactive state
- **Build Tool**: Vite 5.x for fast development and optimized builds
- **HTTP Client**: Axios for REST API communication
- **Charts**: Chart.js + vue-chartjs for data visualization
- **QR Codes**: qrcode.vue for generating scan-able codes
- **Utilities**: @vueuse/core for Vue composables

### Project Structure

```
poll-app/
├── server/                   # Ruby/Sinatra backend
│   ├── app.rb               # Main application & API routes
│   ├── config.ru            # Rack configuration
│   ├── puma.rb              # Puma server config
│   ├── lib/                 # Core modules
│   │   ├── poll_generator.rb           # AI poll generation
│   │   ├── psych_analyzer.rb           # Psychological analysis
│   │   ├── poll_storage.rb             # JSON data persistence
│   │   └── model_discovery_service.rb  # OpenAI model detection
│   └── data/                # Poll storage directory
│       └── polls/           # Individual poll JSON files
│
├── frontend/                # Vue 3 frontend
│   ├── src/
│   │   ├── views/          # Page components
│   │   │   ├── HomeView.vue      # Landing page
│   │   │   ├── PollView.vue      # Voting interface
│   │   │   ├── AdminView.vue     # Admin dashboard
│   │   │   └── AboutView.vue     # About page
│   │   ├── components/     # Reusable components
│   │   │   ├── StatementCard.vue        # Individual voting card
│   │   │   ├── ResultsGrid.vue          # Results visualization
│   │   │   ├── ControlBar.vue           # Admin controls
│   │   │   ├── PollGeneratorModal.vue   # AI poll creation
│   │   │   ├── GroupAnalysisModal.vue   # Group insights
│   │   │   ├── RandomVotesModal.vue     # Test data generator
│   │   │   ├── SuccessOverlay.vue       # Individual analysis
│   │   │   └── DeleteConfirmModal.vue   # Poll deletion
│   │   ├── composables/    # Vue composables
│   │   │   ├── useSocket.js       # WebSocket connection
│   │   │   ├── useTheme.js        # Dark mode toggle
│   │   │   └── useRemoteLog.js    # Backend logging
│   │   ├── styles/         # Global styles
│   │   ├── router.js       # Route definitions
│   │   └── main.js         # Vue app entry point
│   └── public/             # Static assets
│
├── scripts/                # Utility scripts
│   ├── open_port.sh       # macOS firewall management
│   └── close_port.sh      # Port cleanup
│
├── Makefile               # Build and run commands
├── LICENSE                # MIT License
└── README.md              # This file
```

### API Endpoints

#### Poll Management
- `GET /api/poll` - Get current active poll
- `GET /api/polls` - List all polls
- `POST /api/polls/:id/activate` - Activate a specific poll
- `PUT /api/poll` - Update/create poll
- `DELETE /api/polls/:id` - Delete a poll

#### Voting
- `GET /api/results` - Get current voting results
- `POST /api/vote` - Submit a vote
- `POST /api/reset` - Clear all votes (admin)

#### AI Features
- `GET /api/models` - List available OpenAI models
- `POST /api/generate-poll` - Generate AI-powered poll
- `POST /api/analyze` - Individual psychological analysis
- `POST /api/analyze-group` - Group voting pattern analysis

#### Testing & Utilities
- `POST /api/generate-random-votes` - Generate test votes (1-1000)
- `GET /api/export` - Export results as CSV
- `GET /api/info` - Server and connection information

#### WebSocket Events
- `init` - Initial state on connection
- `results_update` - Live voting updates
- `reset` - Vote reset notification
- `poll_update` - Poll change notification

## 🚀 Getting Started

### Prerequisites

- **Ruby** 3.x or later
- **Node.js** 18.x or later
- **Bundler** (Ruby dependency manager)
- **OpenAI API Key** (for AI features)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd polly
   ```

2. **Install dependencies**
   ```bash
   cd poll-app
   make install
   ```
   This installs both Ruby gems and Node packages.

3. **Configure environment**
   ```bash
   cp poll-app/server/.env.example poll-app/server/.env
   # Edit poll-app/server/.env and add your OpenAI API key:
   # OPENAI_API_KEY=sk-...
   ```

4. **Start the server**
   ```bash
   make start
   ```
   The application will be available at:
   - **Home**: http://localhost:4567
   - **Voting**: http://localhost:4567/vote
   - **Admin**: http://localhost:4567/admin
   - **About**: http://localhost:4567/about

### Development Workflow

```bash
# All commands should be run from the poll-app/ directory
cd poll-app

# Start backend and build frontend for production
make start

# Stop the server
make stop

# Restart the server
make restart

# Check server status
make status

# View server logs
make logs

# Start frontend dev server with hot reload
make dev

# Build frontend for production (standalone)
make build

# Clean build artifacts
make clean

# Show help with all available commands
make help
```

### Network Access (macOS)

To allow other devices on your local network to connect:

```bash
# Open firewall for port 4567
sudo make firewall-open

# Close firewall when done
sudo make firewall-close
```

Access from other devices using your local IP (shown in admin panel).

## 🧪 Testing Features

### Generate Random Votes
1. Navigate to admin panel
2. Click "🎲 Random Votes"
3. Enter number of participants (1-1000)
4. Click "Generate Votes"

### AI Poll Generation
1. Navigate to admin panel
2. Click "✨ Generate Poll"
3. Configure:
   - Topic (e.g., "Remote Work")
   - Audience (e.g., "Software Engineers")
   - Tone (Professional, Casual, Academic, etc.)
   - Number of statements (3-10)
   - AI Model (Premium/Standard/Budget)
4. Review and accept

### Group Analysis
1. Have participants vote (or use random votes)
2. Click "🧠 Analyze Group" in admin panel
3. View collective insights and patterns

## 🎨 AI Personality

The psychological analysis features use a distinctive personality:
- **Expert-driven**: Positions as subject-matter expert (not generic psychologist)
- **Confronting**: Direct, brutally honest observations
- **Snobby yet composed**: Confident, slightly arrogant tone
- **Concise**: 80-120 words for individuals, 120-160 for groups
- **Contextual**: Tailored to poll topic and audience

## 📊 Data Storage

Polls are stored as JSON files in `poll-app/server/data/polls/`:
- Each poll has a unique ID
- Metadata includes creation timestamp, statement count, and context
- Active poll ID tracked in `poll-app/server/data/current_poll.json`
- Votes stored in-memory (reset on server restart)

## 🔧 Configuration

### Server Configuration (`poll-app/server/puma.rb`)
- Default port: 4567
- Workers: 2
- Min threads: 0
- Max threads: 16
- Environment: production

### WebSocket Configuration
- Ping interval: 1000ms (critical for performance)
- Auto-reconnection on disconnect
- Role-based message routing (admin vs participant)

### AI Configuration
Model selection priority:
1. Premium tier (high capability, expensive)
2. Standard tier (balanced)
3. Budget tier (cost-effective)

Automatically filters for:
- Text generation capable
- Vision-capable models excluded
- Context window > 0

## 🚨 Known Limitations

- **In-memory votes**: All votes lost on server restart (by design)
- **No authentication**: Anyone with the URL can vote or access admin
- **Single server**: No horizontal scaling or load balancing
- **Local network**: Designed for same-network access
- **macOS firewall scripts**: Platform-specific network management
- **AI quota limits**: OpenAI API rate limits apply
- **No vote validation**: Can vote multiple times (use finalization)

## 🤖 Agentic Development

This project was built as an **experiment in AI-assisted software development**, primarily through:
- **Conversational coding**: Natural language requirements → working code
- **Iterative refinement**: Quick iterations based on feedback
- **Pattern recognition**: AI applying best practices from training data
- **Multi-file coordination**: Managing complex changes across frontend/backend
- **Design implementation**: Translating visual requirements to CSS/styling

### What Worked Well
✅ Rapid prototyping and feature iteration  
✅ Consistent code style across the project  
✅ Complex UI component generation  
✅ API endpoint creation and integration  
✅ Bug fixing and refactoring  
✅ Documentation generation  

### Challenges
⚠️ Architectural decisions best made by humans  
⚠️ Business logic edge cases require specification  
⚠️ Security considerations need explicit guidance  
⚠️ Production-readiness requires manual review  

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with AI assistance (Claude, GPT models)
- Designed for experimental and educational purposes
- Community feedback welcome, but no production support

## ⚡ Quick Reference

```bash
# All commands run from poll-app/ directory
cd poll-app

# Essential commands
make install      # First-time setup
make start        # Run the app
make stop         # Stop the app
make dev          # Frontend hot reload

# Useful during development
make status       # Is it running?
make logs         # What's happening?
make restart      # Apply changes

# Cleanup
make clean        # Remove all build artifacts
```

---

**Remember**: This is an experimental project showcasing AI-assisted development. Not suitable for production use.
