#!/usr/bin/env bash
set -e

echo "🔹 Starting Olm inside Home Assistant OS..."

CONFIG_PATH="/data/options.json"

if [[ ! -f "$CONFIG_PATH" ]]; then
    echo "❌ ERROR: Configuration file not found at $CONFIG_PATH!"
    exit 1
fi

PANGOLIN_ENDPOINT=$(jq -r '.PANGOLIN_ENDPOINT' "$CONFIG_PATH")
CLIENT_ID=$(jq -r '.OLM_ID' "$CONFIG_PATH")
CLIENT_SECRET=$(jq -r '.OLM_SECRET' "$CONFIG_PATH")

# Read custom environment variables
CUSTOM_ENV_VARS=$(jq -r '.custom_env_vars // [] | .[]' "$CONFIG_PATH")

if [[ -z "$PANGOLIN_ENDPOINT" || -z "$CLIENT_ID" || -z "$CLIENT_SECRET" || "$PANGOLIN_ENDPOINT" == "null" ]]; then
    echo "❌ ERROR: Missing required configuration values!"
    exit 1
fi

echo "✅ Configuration Loaded:"
echo "  PANGOLIN_ENDPOINT=$PANGOLIN_ENDPOINT"
echo "  CLIENT_ID=$CLIENT_ID"
echo "  CLIENT_SECRET=${CLIENT_SECRET:0:4}*****${CLIENT_SECRET: -4}"


# Process and display custom environment variables
EXTRA_ENV=""
if [[ -n "$CUSTOM_ENV_VARS" ]]; then
    echo "✅ Custom Environment Variables:"
    while IFS= read -r env_var; do
        if [[ -n "$env_var" ]]; then
            echo "  $env_var"
            # Export the variable for the olm process
            export "$env_var"
            # Also add to the command line (for explicit passing)
            var_name="${env_var%%=*}"
            EXTRA_ENV="$EXTRA_ENV $var_name=\"${!var_name}\""
        fi
    done <<< "$CUSTOM_ENV_VARS"
fi

# 🔁 Auto-reconnect loop
while true; do
    echo "🔹 Starting Pangolin-cli..."
    # Custom variables are already exported above
    export PANGOLIN_ENDPOINT="$PANGOLIN_ENDPOINT"
    export CLIENT_ID="$CLIENT_ID"
    export CLIENT_SECRET="$CLIENT_SECRET"
    /usr/bin/pangolin up client --interface-name olm --attach

    echo "⚠️ Pangolin-cli stopped! Waiting 5 second before reconnecting..."
    sleep 5
done
