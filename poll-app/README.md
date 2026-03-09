# Polly - Local Network Polling App

A beautiful, macOS-inspired polling application with a nerdy twist. Run polls on your local network and let participants vote from their devices.

## Quick Start

### 1. Start the Backend Server

```bash
cd server
bundle install  # First time only
bundle exec puma config.ru -p 4567
```

### 2. Access the Application

- **Admin Dashboard**: http://localhost:4567/admin
- **Participant View**: http://localhost:4567

For LAN access, use your machine's IP address (shown in the admin dashboard).

## Development

### Frontend Development

```bash
cd frontend
npm install
npm run dev
```

The dev server runs on port 3000 and proxies API requests to the backend.

### Build Frontend

```bash
cd frontend
npm run build
```

The built files are served by the Ruby backend from `frontend/dist/`.

## Features

- **Glass morphism UI** with macOS-inspired design
- **Terminal-style elements** for a nerdy touch
- **Real-time updates** via WebSocket
- **QR code** for easy participant joining
- **Dark/Light theme** toggle
- **Export results** to CSV

## Poll Configuration

Edit `server/poll.json` to customize your poll:

```json
{
  "id": "poll1",
  "title": "Your Poll Title",
  "statements": [
    {
      "id": "s1",
      "text": "Your statement here"
    }
  ]
}
```

## Network Requirements

- All participants must be on the same WiFi network
- macOS Firewall may need to allow Ruby connections
- The server binds to `0.0.0.0` to accept LAN connections

## Tech Stack

**Frontend:**
- Vue 3 + Vite
- Custom CSS design system
- Chart.js for results
- QRCode.vue

**Backend:**
- Ruby + Sinatra
- Puma web server
- Faye WebSocket for real-time updates
