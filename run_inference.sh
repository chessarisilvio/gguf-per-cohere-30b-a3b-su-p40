#!/usr/bin/env bash
set -e

# Script to start the quantized Cohere 30B A3B model on Tesla P40
# with embedding delegation to RTX 3050 (if an embedding server is already running).
#
# Usage: ./run_inference.sh
# Assumes the quantized model (e.g., cohere-30b-a3b-q4km.gguf) is present in this directory.
#
# The script uses the existing start-llama launcher with the '35b' preset as base,
# overriding the model file, port, and GPU device.

# --- Configuration ---

# Relative path to the quantized GGUF model (adjust if needed)
MODEL_PATH="./cohere-30b-a3b-q4km.gguf"

# Port for the main inference server (choose a free port, e.g., 8092)
MAIN_PORT=8092

# Port where the RTX 3050 embedding server is expected to run (sentinel)
EMBEDDING_PORT=8081

# --- Validation ---

if [ ! -f "$MODEL_PATH" ]; then
    echo "Error: Quantized model not found at '$MODEL_PATH'"
    echo "Please run quantize_model.sh first to produce the GGUF file."
    exit 1
fi

# Optional: check if embedding server on RTX 3050 is reachable.
# We assume it is already running (as per instructions).
if ! curl -s "http://127.0.0.1:${EMBEDDING_PORT}/health" > /dev/null 2>&1; then
    echo "Warning: Embedding server on RTX 3050 (port ${EMBEDDING_PORT}) does not respond to /health."
    echo "Embedding delegation may not work. Ensure the embedding server is running."
    # Continue anyway; the main server may still start.
fi

# --- Launch via start-llama ---

echo "Starting Cohere 30B A3B (Q4_K_M) on Tesla P40 (CUDA 0)..."
echo "Model: $MODEL_PATH"
echo "Main inference port: $MAIN_PORT"
echo "Embedding delegation target: RTX 3050 (port ${EMBEDDING_PORT})"
echo ""

# Use start-llama with the '35b' preset as a template, overriding key parameters.
# The preset already sets reasonable values for binary, threads, ctx, etc.
# We override: model, port, cuda device, and add useful extra args.
start-llama 35b \
    --model "$MODEL_PATH" \
    --port "$MAIN_PORT" \
    --cuda "0" \
    --ngl 99 \
    --ctx 65536 \
    --threads 6 \
    --reasoning-budget 1024 \
    --jinja true \
    --parallel 1 \
    --extra_args "--no-warmup --metrics" \
    &

# Give the server a moment to start
sleep 2

# Verify the server is responding
if curl -s "http://127.0.0.1:${MAIN_PORT}/health" | grep -q '"status":"ok"'; then
    echo "✅ Inference server is healthy on port ${MAIN_PORT}"
else
    echo "⚠️  Warning: Inference server may not be ready yet. Check logs with:"
    echo "   start-llama logs 35b   (or check ~/.claude-local/llama-35b.log)"
fi

echo ""
echo "To stop the server later, run:"
echo "   start-llama stop ${MAIN_PORT}"
echo ""
echo "Logs are available at:"
echo "   ~/.claude-local/llama-35b.log"
echo ""