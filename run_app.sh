#!/bin/bash

# Configuration
# Replace this with your actual key or set it as an environment variable
GEMINI_KEY="${GEMINI_API_KEY:-your_actual_key_here}"

if [ "$GEMINI_KEY" == "your_actual_key_here" ]; then
    echo "Warning: Using placeholder key. Set GEMINI_API_KEY env var for security."
fi

flutter run --dart-define=GEMINI_API_KEY="$GEMINI_KEY" "$@"
