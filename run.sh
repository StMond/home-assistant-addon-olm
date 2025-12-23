#!/usr/bin/env bash
set -e

echo "🔹 Starting Olm inside Home Assistant OS..."

CONFIG_PATH="/data/options.json"

if [[ ! -f "$CONFIG_PATH" ]]; then
    echo "❌ ERROR: Configuration file not found at $CONFIG_PATH!"
    exit 1
fi

PANGOLIN_ENDPOINT=$(jq -r '.PANGOLIN_ENDPOINT' "$CONFIG_PATH")
OLM_ID=$(jq -r '.OLM_ID' "$CONFIG_PATH")
OLM_SECRET=$(jq -r '.OLM_SECRET' "$CONFIG_PATH")

# Read custom environment variables
CUSTOM_ENV_VARS=$(jq -r '.custom_env_vars // [] | .[]' "$CONFIG_PATH")



if [ -z "$PANGOLIN_ENDPOINT" ]; then
    echo "❌ ERROR: Missing required endpoint reference values!"
fi

if [    -z "$OLM_ID"  ]; then
    echo "❌ ERROR: Missing required ID configuration values!"
fi

if [    -z "$OLM_SECRET"   ]; then
    echo "❌ ERROR: Missing required Secret configuration values!"
fi

if [    "$PANGOLIN_ENDPOINT" == null    ]; then
    echo "❌ ERROR: Missing required endpoint configuration values!"
fi

if [[ -z "$PANGOLIN_ENDPOINT" || -z "$OLM_ID" || -z "$OLM_SECRET" || "$PANGOLIN_ENDPOINT" == "null" ]]; then
    echo "❌ ERROR: Missing required configuration values!"
    exit 1
fi

echo "✅ Configuration Loaded:"
echo "  PANGOLIN_ENDPOINT=$PANGOLIN_ENDPOINT"
echo "  OLM_ID=$OLM_ID"
echo "  OLM_SECRET=$OLM_SECRET"

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
    echo "🔹 Starting Olm..."
    # Custom variables are already exported above
    export PANGOLIN_ENDPOINT="$PANGOLIN_ENDPOINT"
    export OLM_ID="$OLM_ID"
    export OLM_SECRET="$OLM_SECRET"
    /usr/bin/olm

    echo "⚠️ Olm stopped! Waiting 5 second before reconnecting..."
    sleep 5
done
