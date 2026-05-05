#!/bin/bash

OPTI_SRC="$HOME/Optiscaler"
BACKUP_SUFFIX=".bak"
SYMLINKED_FILES=()
BACKED_UP_FILES=()
TARGET_DIR=""

log_msg() {
    echo "$1"
    if [ -n "$LOG_FILE" ]; then
        echo "$1" >> "$LOG_FILE"
    fi
}

if [ ! -d "$OPTI_SRC" ]; then
    notify-send "OptiScaler Script" "Error: '$OPTI_SRC' folder missing"
    exit 1
fi

GAME_ROOT="$(pwd)"
UE_EXE=$(find "$GAME_ROOT" -maxdepth 5 -iname "*shipping.exe" -not -path "*/Engine/*" -print -quit)

if [ -n "$UE_EXE" ]; then
    TARGET_DIR=$(dirname "$UE_EXE")
else
    for arg in "$@"; do
        if [[ "$arg" == *.exe ]] && [ -f "$arg" ]; then
            TARGET_DIR=$(dirname "$arg")
            break
        fi
    done
fi

[ -z "$TARGET_DIR" ] && TARGET_DIR="$GAME_ROOT"

LOG_FILE="$TARGET_DIR/optiscaler_wrapper.log"
echo "--- OptiScaler Launch Log: $(date) ---" > "$LOG_FILE"

log_msg "Target Directory detected: $TARGET_DIR"

log_msg "Creating symlinks..."

for file in "$OPTI_SRC"/*; do
    filename=$(basename "$file")
    target_path="$TARGET_DIR/$filename"

    if [ -e "$target_path" ]; then
        log_msg "BACKUP: Native '$target_path' found. Creating '$BACKUP_SUFFIX'"
        mv -f "$target_path" "$target_path$BACKUP_SUFFIX"
        BACKED_UP_FILES+=("$filename")
    fi

    ln -sf "$file" "$target_path"
    if [ $? -eq 0 ]; then
        log_msg "SUCCESS: Linked '$file' <- '$target_path'"
        SYMLINKED_FILES+=("$filename")
    else
        log_msg "ERROR: Failed to link '$file' <- '$target_path'"
    fi
done

log_msg "Launching game via Steam..."
"$@" &
GAME_PID=$!
sleep 2

cleanup() {
    if [ -n "$TARGET_DIR" ]; then
        log_msg "Exit detected. Starting cleanup..."

        for filename in "${SYMLINKED_FILES[@]}"; do
            target_path="$TARGET_DIR/$filename"
            if [ -e "$target_path" ]; then
                unlink "$target_path"
                log_msg "REMOVED: Symlink '$target_path'"
            fi
        done

        for filename in "${BACKED_UP_FILES[@]}"; do
            backup_path="$TARGET_DIR/$filename$BACKUP_SUFFIX"
            original_path="$TARGET_DIR/$filename"
            if [ -e "$backup_path" ]; then
                mv -f "$backup_path" "$original_path"
                log_msg "RESTORED: Original '$backup_path' -> '$original_path' from backup"
            fi
        done

        for extra_log in "OptiScaler.log" "nvngx.log"; do
            [ -f "$TARGET_DIR/$extra_log" ] && rm "$TARGET_DIR/$extra_log"
        done

        log_msg "Cleanup finished. Script exiting..."
    fi
}
trap cleanup EXIT
wait $GAME_PID
