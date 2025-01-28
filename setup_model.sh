#!/bin/bash
set -e

# Download the model using huggingface_hub
echo "Downloading model from Hugging Face Hub..."
python3 -c "from huggingface_hub import snapshot_download; snapshot_download(repo_id=\"$MODEL_REPO_ID\", repo_type=\"model\", local_dir=\"/data/models/$MODEL_NAME\", local_dir_use_symlinks=False)"

# Create the Modelfile
echo "Creating Modelfile for Ollama..."
cat > /data/models/$MODEL_NAME.Modelfile << EOF
# This is a generated Modelfile.
# It always points to the current version of your Hugging Face model.
# Do NOT change this file manually, regenerate with 'setup_model.sh' instead.

FROM /data/models/$MODEL_NAME
EOF

# Create the model in Ollama
echo "Creating model in Ollama..."
ollama create $MODEL_NAME -f /data/models/$MODEL_NAME.Modelfile

echo "Model setup complete!"
