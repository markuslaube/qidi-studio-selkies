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
    nodejs npm \
    && rm -rf /var/lib/apt/lists/*
    
WORKDIR /tmp/build

RUN git clone --depth 1 "https://github.com/QIDITECH/QIDIStudio.git" . && \
    find . -type f \( -name "CMakeLists.txt" -o -name "*.cmake" \) \
      -exec sed -i -e 's/linux-x64/linux-arm64/g' -e 's/pnpm-linux-x64/pnpm-linux-arm64/g' {} + && \
    chmod +x BuildLinux.sh
    
RUN ./BuildLinux.sh -u && \
    ./BuildLinux.sh -d

RUN ./BuildLinux.sh -s && \
    mkdir -p /opt/qidi-studio && \
    if [ -d "build/package" ]; then \
      cp -r build/package/* /opt/qidi-studio/; \
    elif [ -d "build/install_dir" ]; then \
      cp -r build/install_dir/* /opt/qidi-studio/; \
    else \
      cp -r build/src/QIDIStudio* /opt/qidi-studio/ || cp -r build/* /opt/qidi-studio/; \
    fi && \
    rm -rf /tmp/build

COPY root/ /
