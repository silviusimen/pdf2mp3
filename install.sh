#!/bin/bash

# https://askubuntu.com/questions/501910/how-to-text-to-speech-output-using-command-line

# espeak
sudo apt-get install -y espeak espeak-ng

 # pico
sudo apt-get install -y libttspico0 libttspico-utils libttspico-data

# google
sudo apt-get install -y python3-pip sox libsox-fmt-mp3 libsox-fmt-all mp3wrap
sudo apt-get install -y python3-gtts
#sudo pip install google_speech gtts

# mp3
sudo apt-get install -y mp3wrap
