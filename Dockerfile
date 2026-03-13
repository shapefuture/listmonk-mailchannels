FROM listmonk/listmonk:latest 
 
# Install Node.js and npm 
RUN apt-get update && apt-get install -y nodejs npm && rm -rf /var/lib/apt/lists/* 
 
# Create app directory 
WORKDIR /app 
 
# Copy proxy script 
COPY proxy.js . 
 
# Install Node dependencies for proxy 
RUN npm init -y && npm install smtp-server mailparser 
 
# Copy startup script 
COPY start.sh . 
RUN chmod +x start.sh 
 
# Expose ports 
EXPOSE 9000 2525 
 
# Run startup script 
ENTRYPOINT ["/app/start.sh"] 
