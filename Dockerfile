FROM ghcr.io/markuslaube/qidi-studio-selkies:deps-cache

WORKDIR /tmp/build

RUN git fetch --depth 1 origin main && \
    git reset --hard origin/main && \
    find . -type f \( -name "CMakeLists.txt" -o -name "*.cmake" \) \
      -exec sed -i -e 's/linux-x64/linux-arm64/g' -e 's/pnpm-linux-x64/pnpm-linux-arm64/g' {} + && \
    sed -i -E 's/^[[:space:]]*EXPECTED_HASH/# EXPECTED_HASH/g' src/slic3r/GUI/DeviceWeb/CMakeLists.txt && \
    python3 -c 'import os, re; p="src/slic3r/CMakeLists.txt"; txt=open(p, encoding="latin1").read(); \
      fix=lambda m: m.group(0) if os.path.exists("src/slic3r/"+m.group(1)) else "# "+m.group(0); \
      open(p,"w", encoding="latin1").write(re.sub(r"^[ \t]*([A-Za-z0-9_./-]+\.(?:cpp|hpp|c|h))\b.*$", fix, txt, flags=re.M))' && \
    mkdir -p src/slic3r/QIDI deps/pgLibConnect/Lib/Ubuntu/x64 && \
    python3 -c 'import os, re, glob; \
      [os.makedirs(os.path.dirname("src/slic3r/QIDI/"+m), exist_ok=True) or open("src/slic3r/QIDI/"+m, "a").close() \
       for f in glob.glob("src/**/*.*", recursive=True) if os.path.isfile(f) \
       for m in re.findall(r"#include\s+[\"<](?:\.\./)*QIDI/([^\" >]+)[\">]", open(f, encoding="latin1").read())]' && \
    printf '#pragma once\n#include <string>\n#include <vector>\nstruct NetDevice { std::string name, ip, sn, type, version; };\nstruct QIDIVersion { int major=0, minor=0, patch=0, build=0; QIDIVersion()=default; QIDIVersion(const std::string&){} std::string to_string() const { return "0.0.0.0"; } bool operator<(const QIDIVersion&) const { return false; } bool operator>(const QIDIVersion&) const { return false; } bool operator==(const QIDIVersion&) const { return true; } };\n' > src/slic3r/QIDI/QIDINetworkTypes.hpp && \
    printf '#pragma once\nclass UserPresetSyncManager { public: static UserPresetSyncManager& instance() { static UserPresetSyncManager i; return i; } void init() {} void sync() {} };\n' > src/slic3r/QIDI/UserPresetSyncManager.hpp && \
    echo "void _qidi_arm64_stub(void) {}" | gcc -x c -c - -o /tmp/stub.o && \
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
    rm -rf /tmp/build /tmp/build.log

COPY root/ /
