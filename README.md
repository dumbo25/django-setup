# django-setup
Bash shell script to setup django on a Raspberry Pi

## Required Operating System
Latest version of Raspberry Pi OS

## Django installation 
Login to Raspberry Pi

Run wget and pull the raw versions django.sh and django.cfg to the Raspberry Pi
```
wget https://raw.githubusercontent.com/dumbo25/django-setup/main/django.sh
wget https://raw.githubusercontent.com/dumbo25/django-setup/main/django.cfg
```

Run 
```
bash djamgo.sh -h
```
which shows helps

Help shows the parameters to edit in the cfg file, and the options to use with the script. Make your changes to django.cfg

To install and setup django run the command:
```
bash djamgo.sh
```

## See your website
Everything should install correctly. To see your website, do the following:
```
bash server.sh
```
And it will tell you the URL to use to see your website on your laptop
