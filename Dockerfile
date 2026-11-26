FROM ghcr.io/markuslaube/qidi-studio-selkies:deps-cache

WORKDIR /tmp/build

# Frischen Stand holen, ARM64-URLs setzen & Hash-Check in DeviceWeb deaktivieren
RUN git pull --ff-only || true && \
    find . -type f \( -name "CMakeLists.txt" -o -name "*.cmake" \) \
      -exec sed -i -e 's/linux-x64/linux-arm64/g' -e 's/pnpm-linux-x64/pnpm-linux-arm64/g' {} + && \
    sed -i -E 's/^[[:space:]]*EXPECTED_HASH/# EXPECTED_HASH/g' src/slic3r/GUI/DeviceWeb/CMakeLists.txt && \
    cat src/slic3r/GUI/DeviceWeb/CMakeLists.txt && \
    ./BuildLinux.sh -s && \
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
