#!/bin/bash

OUTFILE="$HOME/.local/share/signal-cli/cutemafia/cutemafia_out.json"
#CM_DIR="$(basename "$OUTFILE")" #CUTEMAFIA DIR

check_sender()
{
	sender="$(echo "$line" | jq -r '.envelope.sourceUuid')"
	cm_user=""

	if [ "$sender" = "ab847469-a4a3-4f29-ae6a-33c83ea17f3c" ]; then
		cm_user="beyza"
		cm_msg="FB❤️ FB😍 FB💞 ,,..still do these things for u \`.✧.~\`~.✧.\` got something u feel tho 💦💦💦🥵🥵"
	elif [ "$sender" = "5e590c88-d627-4418-b43f-d770f7e23653" ]; then
		cm_user="kerem"
		cm_msg="ASLANIM \`.✧.~\`~.✧.\`"
	fi
}

tail -f "$OUTFILE" | while IFS='' read line; do
	# Get sender message.. 
	sender_msg="$(echo "$line" | jq -r '.envelope.dataMessage?.message')"
	# check if sender msg is 1..10 and coming from cm user
	echo "$sender_msg" | grep -qE '(10|[0-9])' && check_sender
	[ -n "$cm_user" ] && echo "cm_user: $cm_user"

    image="$(echo "$line" | jq '.envelope.dataMessage?.attachments[]? | [select(.contentType | startswith("image")).id]' | awk 'NR==2' | tr -d ' "')"
	
	# Run the following if an image is sent as part of the sent message
	if [ -n "$image" ]; then
		# get sourceUuid aka sender
		# check if sender is registered CM user
		check_sender
		# if so send them their personalized message 
		[ -n "$cm_user" ] && signal-cli --dbus send "$sender" -m "$cm_msg"

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
			#signal-cli --dbus send "$sender" -a "$output_img"
			signal-cli --dbus send "$sender" -m "[$i]"
		done

		# if CM user ask if they want to upload to website
		[ -n "$cm_user" ] && signal-cli --dbus send "$sender" -m "Upload to website [1-10]?"
		#sender_msg="$(echo "$line" | jq '.envelope.dataMessage?.attachments[]? | [select(.contentType | startswith("image")).id]' | awk 'NR==2' | tr -d ' "')"

		rm -r "$tmp_dir"	
	fi
done

