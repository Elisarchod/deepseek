# Use a smaller base image
FROM python:3.11-slim-buster

# Set working directory
WORKDIR /app

# Install required system packages, including curl for Poetry installation
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    git-lfs \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Poetry
ENV POETRY_VERSION=1.7.1
RUN curl -sSL https://install.python-poetry.org | python3 -

# Add Poetry to PATH
ENV PATH="/root/.local/bin:$PATH"

# Copy Poetry files
COPY pyproject.toml poetry.lock /app/

# Install project dependencies with Poetry
RUN poetry install --no-interaction --no-ansi

# Install Ollama
RUN curl -s https://ollama.com/install.sh | sh

# Create Ollama user and group
RUN groupadd -r ollama && useradd -r -g ollama -s /bin/false -m ollama

# Create directories and set permissions
RUN mkdir -p /data/models && \
    chown -R ollama:ollama /data

# Copy the script to download and set up the model
COPY setup_model.sh /app/

# Grant execute permission BEFORE switching user
RUN chmod +x /app/setup_model.sh

# Switch to the non-root user
USER ollama

# Environment variables for the Hugging Face model
ENV MODEL_REPO_ID="deepseek-ai/DeepSeek-R1"
ENV MODEL_NAME="deepseek"

# Run the setup script to download and configure the model
RUN /app/setup_model.sh

# Expose the Ollama API port
EXPOSE 11434

# Start the Ollama server
CMD ["ollama", "serve"]
