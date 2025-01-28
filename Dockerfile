# Use a CUDA base image if you want GPU support, otherwise use a smaller base
# For GPU:
# FROM nvidia/cuda:12.3.0-devel-ubuntu22.04
# For CPU:
FROM python:3.11-slim-buster

# Set working directory
WORKDIR /app

# Update system and install necessary packages in a single layer
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    git-lfs \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && git lfs install

# Install Ollama (this script may need adjustment for non-root user later)
RUN curl -s https://ollama.com/install.sh | sh

# Create Ollama user and group (adjust user/group IDs if needed for GCP)
RUN groupadd -r -g 11434 ollama && useradd -r -u 11434 -g ollama -s /bin/false -m ollama

# Create directories and set permissions
# Consider using /usr/share/ollama as per Ollama install script
RUN mkdir -p /usr/share/ollama && \
    chown -R ollama:ollama /usr/share/ollama

# Copy the script to download and set up the model
COPY setup_model.sh /app/

# Grant execute permission (do this BEFORE switching user)
RUN chmod +x /app/setup_model.sh

# Install Poetry
ENV POETRY_VERSION=1.7.1
RUN curl -sSL https://install.python-poetry.org | POETRY_HOME=/opt/poetry python3 -

# Add Poetry to PATH
ENV PATH="/opt/poetry/bin:$PATH"

# Copy pyproject.toml (you need to create this)
COPY pyproject.toml /app/

# Switch to the non-root user
USER ollama

# Environment variables for the Hugging Face model (adjust if necessary)
ENV MODEL_REPO_ID="deepseek-ai/DeepSeek-R1"
ENV MODEL_NAME="deepseek"
ENV OLLAMA_MODELS=/usr/share/ollama

# Install project dependencies and generate poetry.lock
RUN poetry install --no-interaction --no-ansi

# Run the setup script as ollama user to download and configure the model
CMD ["/app/setup_model.sh"]

# Expose the Ollama API port
EXPOSE 11434
