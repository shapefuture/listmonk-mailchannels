FROM listmonk/listmonk:latest 
 
# Install Node.js and npm 
RUN apk add --no-cache nodejs npm bash 
# Create app directory 
WORKDIR /app 
 
# Copy proxy script 
COPY proxy.js . 
 
# Install Node dependencies for proxy
RUN cd /app && npm install smtp-server mailparser 
 
# Copy startup script 
COPY start.sh . 
RUN chmod +x start.sh 
 
# Expose ports 
EXPOSE 9000 2525 
# Run startup script 
ENTRYPOINT ["/app/start.sh"] 
