#!/bin/bash

# Campus Skill Exchange Run Helper
# This script manages the GEMINI_API_KEY and runs the app.

ENV_FILE=".env.local"

if [ -f "$ENV_FILE" ]; then
    # Load from .env.local if it exists
    source "$ENV_FILE"
fi

# Fallback to environment variable or prompt
if [ -z "$GEMINI_API_KEY" ]; then
    echo "🔑 Gemini API Key not found."
    echo "You can set it in a file named .env.local (GEMINI_API_KEY=xxx) or enter it now."
    read -p "Enter Gemini API Key: " INPUT_KEY
    GEMINI_API_KEY="$INPUT_KEY"
    
    # Ask to save for next time
    read -p "Save this key to .env.local? (y/n): " SAVE_KEY
    if [ "$SAVE_KEY" == "y" ]; then
        echo "GEMINI_API_KEY=$GEMINI_API_KEY" > "$ENV_FILE"
        echo "✅ Key saved to $ENV_FILE (This file is git-ignored)."
    fi
fi

if [ -z "$GEMINI_API_KEY" ]; then
    echo "❌ Error: GEMINI_API_KEY is required to run AI features."
    exit 1
fi

echo "🚀 Launching Campus Skill Exchange..."
flutter run --dart-define=GEMINI_API_KEY="$GEMINI_API_KEY" "$@"
