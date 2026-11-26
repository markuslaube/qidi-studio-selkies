FROM ghcr.io/markuslaube/qidi-studio-selkies:deps-cache

WORKDIR /tmp/build

# 1. Direkt auf deinen eigenen Fork markuslaube/QIDIStudio wechseln
RUN git remote set-url origin "https://github.com/markuslaube/QIDIStudio.git" && \
    git fetch --depth 1 origin main && \
    git reset --hard origin/main && \
    find . -type f \( -name "CMakeLists.txt" -o -name "*.cmake" \) \
      -exec sed -i -e 's/linux-x64/linux-arm64/g' -e 's/pnpm-linux-x64/pnpm-linux-arm64/g' {} + && \
    sed -i -E 's/^[[:space:]]*EXPECTED_HASH/# EXPECTED_HASH/g' src/slic3r/GUI/DeviceWeb/CMakeLists.txt && \
    python3 -c 'import glob, re; \
      funcs=set(); \
      [funcs.update(re.findall(r"\b(pg[A-Za-z0-9_]+)\s*\(", open(h, encoding="latin1").read())) for h in glob.glob("deps/pgLibConnect/Include/*.h")]; \
      open("/tmp/pg_stub.c","w").write("\n".join(f"int {f}(void) {{ return 0; }}" for f in sorted(funcs)) + "\nvoid _qidi_arm64_stub(void){}\n")' && \
    gcc -c /tmp/pg_stub.c -o /tmp/stub.o && \
    ar rcs deps/pgLibConnect/Lib/Ubuntu/x64/libconnect.a /tmp/stub.o && \
    ( ./BuildLinux.sh -s > /tmp/build.log 2>&1 || (grep -n -C 3 "error:" /tmp/build.log | tail -n 80 && exit 1) ) && \
    mkdir -p /opt/qidi-studio && \
    if [ -d "build/package" ]; then \
      cp -r build/package/* /opt/qidi-studio/; \
    elif [ -d "build/install_dir" ]; then \
      cp -r build/install_dir/* /opt/qidi-studio/; \
    else \
      cp -r build/src/QIDIStudio* /opt/qidi-studio/ || cp -r build/* /opt/qidi-studio/; \
    fi && \
    rm -rf /tmp/build /tmp/build.log /tmp/pg_stub.c /tmp/stub.o

COPY root/ /
