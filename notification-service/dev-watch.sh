#!/bin/bash
# Runs the service and restarts it whenever a file in /workspace/src changes.
#
# Polls for changes instead of using inotify: file change events from a
# Windows or macOS host folder don't reach a Linux container reliably, so an
# inotify-based watcher never notices when you save a file there.

SRC_DIR="${SRC_DIR:-/workspace/src}"
POLL_INTERVAL="${POLL_INTERVAL:-2}"
JVM_ARGUMENTS="${JVM_ARGUMENTS:--agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005}"

snapshot() {
    find "$SRC_DIR" -type f -printf '%p %T@ %s\n' | sort | md5sum
}

start_app() {
    mvn spring-boot:run -Dspring-boot.run.jvmArguments="$JVM_ARGUMENTS" &
    APP_PID=$!
}

stop_app() {
    kill "$APP_PID" 2>/dev/null
    wait "$APP_PID" 2>/dev/null
}

start_app
last=$(snapshot)

while true; do
    sleep "$POLL_INTERVAL"
    current=$(snapshot)
    if [ "$current" != "$last" ]; then
        # Give the editor a moment to finish writing before compiling
        sleep 1
        last=$(snapshot)
        echo "Files changed, restarting application..."
        stop_app
        start_app
    fi
done
