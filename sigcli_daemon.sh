#!/bin/bash

OUTFILE="$HOME/.local/share/signal-cli/cutemafia/cutemafia_out.json"
[ ! -d "$(dirname "$OUTFILE")" ] && mkdir "$(dirname "$OUTFILE")"

signal-cli --output json daemon --dbus --receive-mode on-start > "$OUTFILE"
