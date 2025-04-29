#!/bin/bash

set -e

echo "📥 Step 1: Downloading morsify.sh to temporary location..."
curl -Lo /tmp/morsify.sh https://raw.githubusercontent.com/YOUR_USERNAME/morsify/main/morsify.sh

echo "🔒 Step 2: Moving morsify.sh to /usr/local/bin/ (requires sudo)..."
sudo mv /tmp/morsify.sh /usr/local/bin/morsify

echo "⚙️ Step 3: Setting executable permissions..."
sudo chmod +x /usr/local/bin/morsify

echo "✅ Step 4: Done! Morsify installed successfully."
echo
echo "👉 Now you can run 'morsify' from anywhere in your terminal!"
