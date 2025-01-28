# Use a smaller base image, like a python slim one, to reduce image size
FROM python:3.11-slim-buster

# Set working directory to avoid absolute paths
WORKDIR /app

# Install required system packages (git-lfs is needed for large files on Hugging Face)
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    git-lfs \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages (including Ollama's requirements - see their Dockerfile)
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Install Ollama (download the binary instead of using the full image)
RUN curl -s https://ollama.com/install.sh | sh

# Create Ollama user and group (for security)
RUN groupadd -r ollama && useradd -r -g ollama -s /bin/false -m ollama

# Create directories and set permissions
RUN mkdir -p /data/models && \
    chown -R ollama:ollama /data

# Switch to the non-root user
USER ollama

# Copy the script to download and set up the model
COPY setup_model.sh /app/

# Environment variable for the Hugging Face model
ENV MODEL_REPO_ID="deepseek-ai/DeepSeek-R1"
ENV MODEL_NAME="deepseek"

# Run the setup script to download and configure the model
RUN /app/setup_model.sh

# Expose the Ollama API port
EXPOSE 11434

# Start the Ollama server
CMD ["ollama", "serve"]
