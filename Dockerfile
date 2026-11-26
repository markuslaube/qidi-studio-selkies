FROM ghcr.io/linuxserver/baseimage-selkies:ubuntunoble

ENV TITLE="QIDI Studio"
ENV CMAKE_POLICY_VERSION_MINIMUM="3.5"
ENV CFLAGS="-std=gnu17"
ENV CXXFLAGS="-std=gnu++17"
ENV DEBIAN_FRONTEND=noninteractive 
    
RUN apt-get update && apt-get install -y --no-install-recommends \
    git ca-certificates sudo build-essential cmake ninja-build pkg-config \
    libgtk-3-dev libwebkit2gtk-4.1-dev libglu1-mesa-dev \
    libcurl4-openssl-dev libssl-dev libglew-dev libudev-dev \
    autoconf automake libtool patchelf file wget curl \
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


# Schritt 1: Klonen & x86-Flags für ARM64 entfernen
RUN git clone --depth 1 "https://github.com/QIDITECH/QIDIStudio.git" . && \
    find . -type f \( -name "CMakeLists.txt" -o -name "*.cmake" -o -name "*.sh" \) \
      -exec sed -i -E 's/-msse[0-9.]*|-mavx[0-9.]*|-mpclmul|-mfma//g' {} + && \
    chmod +x BuildLinux.sh
RUN ./BuildLinux.sh -u
RUN ./BuildLinux.sh -d
RUN ./BuildLinux.sh -s && \
    mkdir -p /opt/qidi-studio && \
    cp -r build/package/* /opt/qidi-studio/ && \
    rm -rf /tmp/build

COPY root/ /
