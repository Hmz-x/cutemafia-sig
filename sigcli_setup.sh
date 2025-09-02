#!/bin/bash

PHONENUM="+13129458075"
NAME="cutemafia"

# Register device and get captcha link from URL
signal-cli -a "$PHONENUM" register

# Enter captcha to complete registration
signal-cli -a "$PHONENUM" register --captcha "$CAPTCHA"

# Verify device from code sent to VoIP messages
signal-cli verify -p $PIN $VERIFICATION_CODE

# Set name
signal-cli -a "$PHONENUM" updateAccount -n "$NAME" \
	--discoverable-by-number true --number-sharing false
signal-cli -a "$PHONENUM" updateProfile --name "$NAME"
