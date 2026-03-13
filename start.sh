#!/bin/bash
set -e

echo "🚀 Starting Listmonk mail system..."

# Generate config.toml from environment variables at runtime
cat << EOF > /app/config.toml
[app]
address = "0.0.0.0:9000"

[db]
host = "${LISTMONK_db__host:-localhost}"
port = 5432
user = "${LISTMONK_db__user:-listmonk}"
password = "${LISTMONK_db__password:-listmonk}"
database = "${LISTMONK_db__database:-listmonk}"
ssl_mode = "${LISTMONK_db__ssl_mode:-require}"
max_conns = 10
EOF

# Run install to initialize fresh database
echo "📝 Initializing Listmonk database schema..."
(echo y; sleep 1) | /listmonk/listmonk --config /app/config.toml --install || true
sleep 2

# Start SMTP proxy in background
echo "📧 Starting SMTP bridge on localhost:2525..."
node /app/proxy.js &
PROXY_PID=$!
echo "✓ SMTP bridge PID: $PROXY_PID"

# Wait for SMTP bridge to be ready
sleep 2

# Start Listmonk in foreground (so Docker keeps running)
echo "🎯 Starting Listmonk on 0.0.0.0:9000..."
/listmonk/listmonk --config /app/config.toml

# Cleanup if Listmonk exits
kill $PROXY_PID 2>/dev/null || true
