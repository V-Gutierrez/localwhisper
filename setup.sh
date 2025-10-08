#!/bin/bash

# LocalWhisper - Automatic Installation Script (macOS/Linux)

set -e  # Exit on error

echo "======================================================"
echo "🎤 LocalWhisper - Automatic Setup"
echo "======================================================"
echo ""

# Detect operating system
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    echo "✓ Detected system: macOS"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
    echo "✓ Detected system: Linux"
else
    echo "⚠️  Unsupported system: $OSTYPE"
    echo "This script only works on macOS and Linux"
    exit 1
fi

echo ""

# Check Python
echo "Checking Python..."
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 not found!"
    echo "Please install Python 3.8 or higher:"
    if [[ "$OS" == "macos" ]]; then
        echo "  brew install python3"
    else
        echo "  sudo apt update && sudo apt install python3 python3-pip python3-venv"
    fi
    exit 1
fi

PYTHON_VERSION=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2)
echo "✓ Python found: $(python3 --version)"

echo ""

# Check/Install FFmpeg
echo "Checking FFmpeg..."
if ! command -v ffmpeg &> /dev/null; then
    echo "⚠️  FFmpeg not found. Attempting to install..."

    if [[ "$OS" == "macos" ]]; then
        if ! command -v brew &> /dev/null; then
            echo "❌ Homebrew not found!"
            echo "Please install Homebrew first:"
            echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            exit 1
        fi
        echo "Installing FFmpeg via Homebrew..."
        brew install ffmpeg
    else
        # Linux
        if command -v apt-get &> /dev/null; then
            echo "Installing FFmpeg via apt..."
            sudo apt-get update
            sudo apt-get install -y ffmpeg
        elif command -v yum &> /dev/null; then
            echo "Installing FFmpeg via yum..."
            sudo yum install -y ffmpeg
        else
            echo "❌ Package manager not supported!"
            echo "Please install FFmpeg manually:"
            echo "  https://ffmpeg.org/download.html"
            exit 1
        fi
    fi

    if command -v ffmpeg &> /dev/null; then
        echo "✓ FFmpeg installed successfully!"
    else
        echo "❌ Failed to install FFmpeg"
        exit 1
    fi
else
    echo "✓ FFmpeg found: $(ffmpeg -version | head -n1)"
fi

echo ""

# Create virtual environment
echo "Creating Python virtual environment..."
if [ -d "venv" ]; then
    echo "⚠️  Virtual environment already exists. Removing and recreating..."
    rm -rf venv
fi

python3 -m venv venv
echo "✓ Virtual environment created"

echo ""

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate
echo "✓ Virtual environment activated"

echo ""

# Install dependencies
echo "Installing Python dependencies..."
echo "⚠️  This may take a few minutes (PyTorch is large)..."
pip install --upgrade pip
pip install -r requirements.txt

if [ $? -eq 0 ]; then
    echo "✓ Dependencies installed successfully!"
else
    echo "❌ Error installing dependencies"
    exit 1
fi

echo ""

# Install SSL certificates (macOS only)
if [[ "$OS" == "macos" ]]; then
    echo "======================================================"
    echo "🔐 Installing SSL Certificates (macOS)"
    echo "======================================================"
    echo ""
    echo "This fixes the 'SSL: CERTIFICATE_VERIFY_FAILED' error"
    echo "when downloading Whisper models..."
    echo ""

    # Method 1: Install Certificates.command
    PYTHON_DIR="/Applications/Python ${PYTHON_VERSION}"

    if [ -d "$PYTHON_DIR" ]; then
        CERT_COMMAND="$PYTHON_DIR/Install Certificates.command"

        if [ -f "$CERT_COMMAND" ]; then
            echo "Running: $CERT_COMMAND"
            bash "$CERT_COMMAND"
            echo "✓ Certificate installation command executed"
        fi
    fi

    # Method 2: Install/upgrade certifi
    echo "Installing/upgrading certifi package..."
    pip install --upgrade certifi
    echo "✓ certifi package installed/upgraded"

    echo ""
fi

echo ""
echo "======================================================"
echo "✅ Installation completed successfully!"
echo "======================================================"
echo ""
echo "To start the application:"
echo "  ./run.sh"
echo ""
echo "Or manually:"
echo "  source venv/bin/activate"
echo "  python app.py"
echo ""
echo "Access in browser: http://localhost:5001"
echo ""
echo "To uninstall everything:"
echo "  ./uninstall.sh"
echo ""
