FROM ghcr.io/linuxserver/baseimage-selkies:ubuntunoble

ENV TITLE="QIDI Studio"
ENV CMAKE_POLICY_VERSION_MINIMUM="3.5"
ENV CFLAGS="-std=gnu17"

RUN apt-get update && apt-get install -y --no-install-recommends \
    git ca-certificates sudo build-essential cmake ninja-build pkg-config \
    libgtk-3-dev libwebkit2gtk-4.1-dev libglu1-mesa-dev \
    libcurl4-openssl-dev libssl-dev libglew-dev libudev-dev \
    && rm -rf /var/lib/apt/lists/*
    
WORKDIR /tmp/build
RUN git clone --depth 1 "https://github.com/QIDITECH/QIDIStudio.git" . && \
    chmod +x BuildLinux.sh && \
    ./BuildLinux.sh -u && \
    ./BuildLinux.sh -d && \
    ./BuildLinux.sh -s && \
    mkdir -p /opt/qidi-studio && \
    cp -r build/package/* /opt/qidi-studio/ && \
    rm -rf /tmp/build

COPY root/ /
