FROM mcr.microsoft.com/devcontainers/universal

# Install pydf
RUN apt-get update && apt-get install -y pydf

# Copy bashrc
COPY .bashrc /home/codespace/.bashrc

# Install 
USER codespace
RUN npm install -g @anthropic-ai/claude-code

