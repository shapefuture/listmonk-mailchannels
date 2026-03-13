#!/bin/bash
set -e

echo "🚀 Starting Listmonk mail system..."

# Initialize Listmonk config if it doesn't exist
if [ ! -f /listmonk/config.toml ]; then
  echo "📝 Initializing Listmonk config..."
  /listmonk/listmonk --new-config --idempotent
fi

# Start SMTP proxy in background
echo "📧 Starting SMTP bridge on localhost:2525..."
node /app/proxy.js &
PROXY_PID=$!
echo "✓ SMTP bridge PID: $PROXY_PID"

# Wait for SMTP bridge to be ready
sleep 2

# Start Listmonk in foreground (so Docker keeps running)
echo "🎯 Starting Listmonk on 0.0.0.0:9000..."
/listmonk/listmonk

# Cleanup if Listmonk exits
kill $PROXY_PID 2>/dev/null || true
