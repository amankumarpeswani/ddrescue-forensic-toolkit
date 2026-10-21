#!/bin/bash
# Usage: sudo ./rescue.sh <source_device> <case_id> <examiner>
SRC="$1"
CASE="$2"
EXAMINER="$3"

# Safety check : need al three arguments
if [ -z "$SRC" ] || [ -z "$CASE" ] || [ -z "$EXAMINER" ]; then
echo "Usage: sudo $0 <source_device> <case_id> <examiner>"; exit 1
fi

DIR="case_$CASE"
mkdir -p "$DIR"
LOG="$DIR/report.txt"

echo "=== Forensic Acquisition Report ===" > "$LOG"
echo "Case ID : $CASE"                     >> "$LOG"
echo "Examiner: $EXAMINER"                >> "$LOG"
echo "Source : $SRC"                      >> "$LOG"
echo "Started : $(date)"                  >> "$LOG"

#1. Make source read-only
blockdev --setro "$SRC"
echo "[1] Source set read-only" >> "$LOG"

#2. Pass 1
echo "[2] Pass 1: ddrescue -n" >> "$LOG"
ddrescue -n "$SRC" "$DIR/image.img" "$DIR/case.map"

#3. Pass 2
echo "[3] Pass 2: ddrecue -d -r3" >> "$LOG"
ddrescue -d -r3 "$SRC" "$DIR/image.img" "$DIR/case.map"

#4. Stats
echo "[4] Rescue statistics:"  >> "$LOG"
ddrescuelog -t "$DIR/case.map" >> "$LOG" 2>&1

#5. Hash
echo "[5] SHA-256 of image:" >> "$LOG"
sha256sum "$DIR/image.img"  >> "$LOG"

#6. Verify filesystem
echo "[6] Filesystem check:"  >> "$LOG"
fsstat "$DIR/image.img" | head -20 >> "$LOG"

echo "Finished: $(date)"  >> "$LOG"
echo "Done. Report saved in $LOG"
