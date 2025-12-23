# Use the official Home Assistant add-on base image
FROM ghcr.io/hassio-addons/base:14.0.0

# Define the Olm version (used everywhere below)
ARG OLM_VERSION=1.3.0
ENV OLM_VERSION=${OLM_VERSION}

# Install dependencies
RUN apk add --no-cache bash curl jq

# Detect system architecture and download the correct Olm binary
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        curl -fsSL -o /usr/bin/olm https://github.com/fosrl/olm/releases/download/${OLM_VERSION}/olm_linux_amd64; \
    elif [ "$ARCH" = "aarch64" ]; then \
        curl -fsSL -o /usr/bin/olm https://github.com/fosrl/olm/releases/download/${OLM_VERSION}/olm_linux_arm64; \
    elif [ "$ARCH" = "armv7l" ]; then \
        curl -fsSL -o /usr/bin/olm https://github.com/fosrl/olm/releases/download/${OLM_VERSION}/olm_linux_arm32; \
    elif [ "$ARCH" = "armv6l" ]; then \
        curl -fsSL -o /usr/bin/olm https://github.com/fosrl/olm/releases/download/${OLM_VERSION}/olm_linux_arm32v6; \
    elif [ "$ARCH" = "riscv64" ]; then \
        curl -fsSL -o /usr/bin/olm https://github.com/fosrl/olm/releases/download/${OLM_VERSION}/olm_linux_riscv64; \
    else \
        echo "❌ ERROR: Unsupported architecture: $ARCH"; exit 1; \
    fi && \
    chmod +x /usr/bin/olm


# Copy the script into the container
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Run the script as the main process
ENTRYPOINT [ "/run.sh" ]
