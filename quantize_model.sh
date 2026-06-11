#!/usr/bin/env bash
set -e

# Script to quantize a GGUF model using BeeLLama (llama.cpp fork) for Tesla P40
# Usage: ./quantize_model.sh <input_model.gguf> [output_model.gguf] [quant_type]
#   If output_model is not provided, it will be <input_model>_q4km.gguf
#   If quant_type is not provided, it defaults to q4_k_m

# Check arguments
if [ $# -lt 1 ]; then
    echo "Usage: $0 <input_model.gguf> [output_model.gguf] [quant_type]"
    echo "Example: $0 cohere-30b-a3b.gguf cohere-30b-a3b-q4km.gguf q4_k_m"
    exit 1
fi

INPUT_MODEL="$1"
OUTPUT_MODEL="${2:-${INPUT_MODEL%.gguf}_q4km.gguf}"
QUANT_TYPE="${3:-q4_k_m}"

# Check if input model exists
if [ ! -f "$INPUT_MODEL" ]; then
    echo "Error: Input model '$INPUT_MODEL' not found."
    exit 1
fi

# Path to BeeLLama build directory (relative to script location)
BEE_LLAMA_DIR="bee-llama-cpp"
BUILD_DIR="$BEE_LLAMA_DIR/build"
QUANTIZE_BIN="$BUILD_DIR/bin/quantize"

# Check if BeeLLama is built and quantize binary exists
if [ ! -f "$QUANTIZE_BIN" ]; then
    echo "Error: BeeLLama quantize binary not found at '$QUANTIZE_BIN'."
    echo "Please build BeeLLama first using build_llama.sh"
    exit 1
fi

# Run quantization
echo "Quantizing model:"
echo "  Input:  $INPUT_MODEL"
echo "  Output: $OUTPUT_MODEL"
echo "  Type:   $QUANT_TYPE"
echo ""

"$QUANTIZE_BIN" "$INPUT_MODEL" "$OUTPUT_MODEL" "$QUANT_TYPE"

echo ""
echo "Quantization completed successfully."
echo "Quantized model saved to: $OUTPUT_MODEL"