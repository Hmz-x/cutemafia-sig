#!/bin/bash

OUTFILE="$HOME/.local/share/signal-cli/cutemafia/cutemafia_out.json"
#CM_DIR="$(basename "$OUTFILE")" #CUTEMAFIA DIR

tail -f "$OUTFILE" | while IFS='' read line; do
    image="$(echo "$line" | jq '.envelope.dataMessage?.attachments[]? | [select(.contentType | startswith("image")).id]' | awk 'NR==2' | tr -d ' "')"
	
	# Run the following if an image is sent as part of the sent message
	if [ -n "$image" ]; then
		# get sourceUuid aka sender
		sender="$(echo "$line" | jq -r '.envelope.sourceUuid')"

		# Create tmp dir, create 10 new edits in there
		tmp_dir="$(mktemp -d)"
		input="$HOME/.local/share/signal-cli/attachments/$image"
		ext="$(echo "$input" | rev | cut -d '.' -f 1 | rev)"
        without_ext="$(chext.sh $input)" 

		for i in $(seq 1 10); do
			# Get output image name of created edit
			output_img="${tmp_dir}/$(basename "$without_ext")-${i}.${ext}"
			# Convert image and save as output_img
			convert-img.sh -i "$input" -r -o "$output_img"

			# Send output_img as attachment to $sender
			signal-cli --dbus send "$sender" -a "$output_img"
			signal-cli --dbus send "$sender" -m "[$i]"
		done
		rm -r "$tmp_dir"	
	fi
done

