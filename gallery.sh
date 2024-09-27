#!/usr/bin/env bash

# This script cycles through the styles, run thqm and takes a screenshot
# Requires thqm, jq and chromium

function get_ip() {
  # get local ip
  ip -f inet -j address | jq -r '.[] | select(.ifname=="wlan0").addr_info.[0].local'

}

function thqm_screenshot() {
  local style_dir="$1"
  local style_name
  style_name="$(basename "$style_dir")"
  local entries="Entry 1\nEntry 2\nEntry 3"

  # handle styles which interpret the entries differently
  case $style_name in
  "fa-grid") entries="fas fa-volume-mute\nfas fa-volume-up\nfas fa-volume-down" ;;
  esac

  # run thqm in background
  printf "%b" "$entries" | thqm --style-dir "$style_dir" --title "Style: $style_name" &
  # get pid of background process
  pid=$!
  # take screenshot
  address="http://$(get_ip):8000"
  chromium --headless=new --screenshot="${SCREENSHOT_DIR}/${style_name}.png" "$address"
  kill $pid
}

SCREENSHOT_DIR="gallery"

for style in styles/*; do
  mkdir -p "$SCREENSHOT_DIR"
  echo "$style"
  thqm_screenshot "$style"
done
