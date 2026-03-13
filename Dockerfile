FROM listmonk/listmonk:latest 
 
# Install Node.js and npm 
RUN apk add --no-cache nodejs npm bash 
# Create app directory 
WORKDIR /app 
 
# Copy proxy script 
COPY proxy.js . 
 
# Install Node dependencies for proxy 
RUN npm init -y && npm install smtp-server mailparser 
 
# Copy startup script 
COPY start.sh . 
RUN chmod +x start.sh 

# Create minimal config.toml for Listmonk
RUN cat > /app/config.toml << 'EOF'
[app]
address = "0.0.0.0:9000"

[db]
host = "${DB_HOST:-localhost}"
port = 5432
user = "${DB_USER:-listmonk}"
password = "${DB_PASSWORD:-listmonk}"
database = "${DB_NAME:-listmonk}"
ssl_mode = "require"
max_conns = 10

[smtp]
host = "${SMTP_HOST:-localhost}"
port = 2525
auth_protocol = "none"
max_conns = 10
EOF
 
# Expose ports 
EXPOSE 9000 2525 
 
# Run startup script 
ENTRYPOINT ["/app/start.sh"] 
