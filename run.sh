#!/bin/bash

# LocalWhisper - Quick Run Script

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "❌ Virtual environment not found!"
    echo "Please run first: ./setup.sh"
    exit 1
fi

# Activate virtual environment
source venv/bin/activate

echo "======================================================"
echo "🎤 LocalWhisper"
echo "======================================================"
echo ""
echo "Starting server..."
echo "Access: http://localhost:5001"
echo ""
echo "Press Ctrl+C to stop"
echo ""

# Run the application
python app.py
