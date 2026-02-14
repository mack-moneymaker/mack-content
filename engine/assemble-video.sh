#!/bin/bash
# Assemble frames + audio into a reel video
# Usage: ./assemble-video.sh <frames_dir> <audio_file> <output_file>

FRAMES_DIR="${1:-../output/001}"
AUDIO="${2:-../output/001/voiceover.ogg}"
OUTPUT="${3:-../output/001/reel.mp4}"

# Frame durations in seconds (matched to script timing)
# Slide 1: 0-3s, Slide 2: 3-6s, Slide 3: 6-9s, Slide 4: 9-12s, Slide 5: 12-15s, Slide 6: 15-18s, Slide 7: 18-21s
DURATIONS=(3 3 3 3 3 3 3)

# Create concat file for ffmpeg
CONCAT_FILE=$(mktemp)
for i in "${!DURATIONS[@]}"; do
  idx=$((i + 1))
  fname=$(printf "frame-%03d.png" $idx)
  echo "file '${FRAMES_DIR}/${fname}'" >> "$CONCAT_FILE"
  echo "duration ${DURATIONS[$i]}" >> "$CONCAT_FILE"
done
# Repeat last frame (ffmpeg concat demuxer quirk)
echo "file '${FRAMES_DIR}/frame-007.png'" >> "$CONCAT_FILE"

echo "=== Concat file ==="
cat "$CONCAT_FILE"
echo "==================="

# Check if audio exists
if [ -f "$AUDIO" ]; then
  echo "Assembling with audio..."
  ffmpeg -y -f concat -safe 0 -i "$CONCAT_FILE" -i "$AUDIO" \
    -c:v libx264 -pix_fmt yuv420p -r 30 \
    -c:a aac -b:a 192k \
    -shortest \
    -vf "scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2:black" \
    "$OUTPUT"
else
  echo "No audio found, assembling video only..."
  ffmpeg -y -f concat -safe 0 -i "$CONCAT_FILE" \
    -c:v libx264 -pix_fmt yuv420p -r 30 \
    -vf "scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2:black" \
    -t 21 \
    "$OUTPUT"
fi

rm "$CONCAT_FILE"

echo "✅ Video saved to $OUTPUT"
ls -lh "$OUTPUT"
