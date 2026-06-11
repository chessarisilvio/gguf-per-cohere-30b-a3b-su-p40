#!/usr/bin/env bash
set -e

# Script to build BeeLLama (llama.cpp fork) with CUDA sm_61 support for Tesla P40

REPO_DIR="bee-llama-cpp"
REPO_URL="https://github.com/Anbeeld/beellama.cpp.git"

# Clone if not present
if [ ! -d "$REPO_DIR" ]; then
    echo "Cloning BeeLLama repository..."
    git clone "$REPO_URL" "$REPO_DIR"
else
    echo "BeeLLama directory already exists, updating..."
    cd "$REPO_DIR"
    git pull origin master
    cd ..
fi

cd "$REPO_DIR"

# Update submodules (if any)
git submodule update --init --recursive

# Create and enter build directory
mkdir -p build
cd build

# Set environment variables for CUDA sm_61 (Pascal, Tesla P40)
export GGML_CUDA=1
export CUDA_ARCH_LIST="61"

# Configure with CMake
echo "Configuring BeeLLama with CUDA sm_61 support..."
cmake .. -DLLAMA_CUBLAS=on -DGGML_CUDA=on -DCMAKE_BUILD_TYPE=Release

# Build
echo "Building BeeLLama..."
make -j$(nproc)

echo "Build completed successfully."
echo "Binaries are located in: $(pwd)"
echo "Example usage: ./server -m <path-to-model>.gguf"