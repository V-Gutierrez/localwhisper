#!/bin/bash

# LocalWhisper - Uninstall Script

echo "======================================================"
echo "🗑️  LocalWhisper - Uninstall"
echo "======================================================"
echo ""
echo "This script will remove:"
echo "  • Python virtual environment (venv/)"
echo "  • Temporary files (uploads/)"
echo "  • Whisper models cache (~/.cache/whisper/)"
echo ""

# Ask for confirmation
read -p "Do you want to continue? (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstall cancelled."
    exit 0
fi

echo ""

# Remove virtual environment
if [ -d "venv" ]; then
    echo "Removing virtual environment..."
    rm -rf venv
    echo "✓ Virtual environment removed"
else
    echo "⚠️  Virtual environment not found (venv/)"
fi

# Remove uploads
if [ -d "uploads" ]; then
    echo "Removing temporary files..."
    rm -rf uploads/*
    echo "✓ Temporary files removed"
else
    echo "⚠️  Uploads folder not found"
fi

# Remove Whisper cache
WHISPER_CACHE="$HOME/.cache/whisper"
if [ -d "$WHISPER_CACHE" ]; then
    echo ""
    echo "Whisper models cache found at: $WHISPER_CACHE"

    # Calculate size
    if command -v du &> /dev/null; then
        CACHE_SIZE=$(du -sh "$WHISPER_CACHE" | cut -f1)
        echo "Size: $CACHE_SIZE"
    fi

    echo ""
    read -p "Do you want to remove the models cache? (y/N): " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$WHISPER_CACHE"
        echo "✓ Whisper cache removed"
    else
        echo "⚠️  Cache kept (models will be reused if you reinstall)"
    fi
else
    echo "⚠️  Whisper cache not found"
fi

echo ""

# Ask about FFmpeg
if command -v ffmpeg &> /dev/null; then
    echo "FFmpeg is installed on the system."
    echo ""
    read -p "Do you want to remove FFmpeg? (y/N): " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Detect system
        if [[ "$OSTYPE" == "darwin"* ]]; then
            if command -v brew &> /dev/null; then
                echo "Removing FFmpeg via Homebrew..."
                brew uninstall ffmpeg
                echo "✓ FFmpeg removed"
            else
                echo "⚠️  Homebrew not found. Remove FFmpeg manually."
            fi
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            if command -v apt-get &> /dev/null; then
                echo "Removing FFmpeg via apt..."
                sudo apt-get remove -y ffmpeg
                sudo apt-get autoremove -y
                echo "✓ FFmpeg removed"
            elif command -v yum &> /dev/null; then
                echo "Removing FFmpeg via yum..."
                sudo yum remove -y ffmpeg
                echo "✓ FFmpeg removed"
            else
                echo "⚠️  Package manager not supported. Remove FFmpeg manually."
            fi
        fi
    else
        echo "⚠️  FFmpeg kept on system"
    fi
fi

echo ""
echo "======================================================"
echo "✅ Uninstall completed!"
echo "======================================================"
echo ""
echo "The following files were kept:"
echo "  • Source code (app.py, templates/, static/, etc.)"
echo "  • requirements.txt"
echo "  • README.md"
echo ""
echo "To completely remove LocalWhisper:"
echo "  cd .. && rm -rf localwhisper/"
echo ""
