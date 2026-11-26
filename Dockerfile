FROM ghcr.io/markuslaube/qidi-studio-selkies:deps-cache

WORKDIR /tmp/build

# 1. Submodule nachladen (holt src/slic3r/QIDI/ und deps/pgLibConnect/!) & Zustand bereinigen
RUN git checkout -- . && \
    git pull --ff-only || true && \
    git submodule update --init --recursive --depth 1 && \
    ls -la src/slic3r/QIDI/ deps/pgLibConnect/Lib/Ubuntu/ || true && \
    find . -type f \( -name "CMakeLists.txt" -o -name "*.cmake" \) \
      -exec sed -i -e 's/linux-x64/linux-arm64/g' -e 's/pnpm-linux-x64/pnpm-linux-arm64/g' {} + && \
    sed -i -E 's/^[[:space:]]*EXPECTED_HASH/# EXPECTED_HASH/g' src/slic3r/GUI/DeviceWeb/CMakeLists.txt && \
    if [ ! -f "deps/pgLibConnect/Lib/Ubuntu/x64/libconnect.a" ]; then \
      mkdir -p deps/pgLibConnect/Lib/Ubuntu/x64 && \
      echo "void _qidi_arm64_stub(void) {}" | gcc -x c -c - -o /tmp/stub.o && \
      ar rcs deps/pgLibConnect/Lib/Ubuntu/x64/libconnect.a /tmp/stub.o; \
    fi && \
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
