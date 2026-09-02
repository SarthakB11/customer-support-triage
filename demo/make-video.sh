#!/usr/bin/env bash
# Stitch demo/frames/*.png (Studio screenshots, 3s each) + demo/terminal.mp4 (curl call) into demo/demo.mp4.
# Needs ffmpeg. Terminal clip: `asciinema rec demo/terminal.cast` then `agg demo/terminal.cast demo/terminal.gif`
# and `ffmpeg -i demo/terminal.gif demo/terminal.mp4`; or record the terminal with any screen recorder.
set -euo pipefail
cd "$(dirname "$0")"
ls frames/*.png >/dev/null 2>&1 || { echo "no frames in demo/frames" >&2; exit 1; }
: > list.txt
for f in $(ls frames/*.png | sort); do printf "file '%s'\nduration 3\n" "$f" >> list.txt; done
last="$(ls frames/*.png | sort | tail -1)"; printf "file '%s'\n" "$last" >> list.txt
ffmpeg -y -f concat -safe 0 -i list.txt -vf "scale=1280:-2,format=yuv420p" -r 30 slides.mp4
if [[ -f terminal.mp4 ]]; then
  printf "file 'slides.mp4'\nfile 'terminal.mp4'\n" > join.txt
  ffmpeg -y -f concat -safe 0 -i join.txt -c copy demo.mp4 || ffmpeg -y -i slides.mp4 -i terminal.mp4 \
    -filter_complex "[0:v]scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:-1:-1[a];[1:v]scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:-1:-1[b];[a][b]concat=n=2:v=1:a=0" demo.mp4
else
  mv slides.mp4 demo.mp4
fi
rm -f list.txt join.txt slides.mp4
echo "wrote demo/demo.mp4"
