# Use an official Python runtime as the base image
FROM python:3.11-slim

# Set the working directory inside the container
WORKDIR /app

# Install Ollama
RUN curl -fsSL https://ollama.com/install.sh | sh

# Copy the current directory contents into the container at /app
COPY . .

# Install any needed packages specified in pyproject.toml and poetry.lock
RUN pip install poetry
RUN poetry export -f requirements.txt --output requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Make port 8080 available to the world outside this container
EXPOSE 8080

# Define environment variable (if needed)
# ENV NAME World

# Run your application using Uvicorn (or your preferred server)
# (Only if you have a main.py with application code)
# CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]

# Or, if you just want to run Ollama, you might start it as a background process:
CMD ["ollama", "serve"]
