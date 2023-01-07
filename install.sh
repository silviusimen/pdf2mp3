 #!/bin/bash

 # https://askubuntu.com/questions/501910/how-to-text-to-speech-output-using-command-line

 # espeak
 sudo apt-get install espeak espeak-ng
 
 # pico
 sudo apt-get install libttspico0 libttspico-utils libttspico-data
 
 # google
 sudo apt-get -y install python3-pip sox libsox-fmt-mp3 libsox-fmt-all mp3wrap
 sudo pip install google_speech gtts

# mp3
sudo apt-get install mp3wrap
