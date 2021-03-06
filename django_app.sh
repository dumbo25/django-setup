#!/bin/bash
# sript to setup one django app
#
# run using
#    sudo bash [bash_options] django_app.sh [install_options]

############################# <- 80 Characters -> ##############################
#
# This style of commenting is called a garden bed and it is frowned upon by
# those who know better. But, I like it. I use a garden bed at the top to track
# my to do list as I work on the code, and then mark the completed To Dos.
#
# Within the code, To Dos include a comment with ???, which makes it easy to
# find
#
# Once the To Do list is more-or-less complete, I move the completed items into
# comments, docstrings or help within the code. Next, I remove the completed
# items.
#
# To Do List:
#   a) create a shell script for apps
#      a.1) need to add urls.py to each app
#       nano /home/pi/newt_site/urls.py or is it newt_site/newt_site
#      a.2) app.urls
#      a.3) get beyond rocket ship django demo page
#   b) use django apps checklist
#   c) get static pages to work 
#      c.1) https://djangoforbeginners.com/hello-world/)
#           better than above: https://learndjango.com/tutorials/hello-world-5-different-ways
#           python manage.py startapp pages
#           # nano pages/views.py
#           from django.http import HttpResponse
#           def homePageView(request):
#               return HttpResponse("Hello, World!")
#      c.2) do a hello world static page, instead of rocketship
#      c.3) ensure static files work
#      c.4) turn off django debug
#   d) the app script can add multiple apps
#   e) must enable static pages
#   f) must create hello world static page
#   g) must work in both venv and no-venv
#
#   w) test all options
#   x) install from scratch 
#   y) run shellcheck
#   z) check into github
#
# Do later or not at all:
#
# References:
#   Django for Beginners, CHapter Hello World App, https://djangoforbeginners.com/hello-world/
############################# <- 80 Characters -> ##############################

################################## Functions ###################################
function echoStartingScript {
    if [ "$StartMessageCount" -eq 0 ]
    then
    echo -e "\n${Bold}${Blue}Starting Script to add a Django App ${Black}${Normal}"
    echo "  ${Bold}${Blue}setting up $Name ${Black}${Normal}"
    StartMessageCount=1
    fi
}

function echoExitingScript {
    echo -e "\n${Bold}${Blue}Exiting Script to add a Django App ${Black}${Normal}"
    exit
}


function help {
    echo -e "\n$Help"
}

# check if app ($1) is in the django project settings file
isAppInSettings() {
    if [ ! -f $SettingsFile ]
    then
        echo -e "\n${Bold}${Red}Exiting Script to add a Django App ${Black}${Normal}"
        echo -e "${Bold}${Red}$SettingsFile does not exist ${Black}${Normal}"
        exit 1
    else
       Result=$(cat $SettingsFile | grep $1)
    fi
}

# if app ($1) is not in INSTALLED_APPS, then add to the django project settings file
addAppToSettings() {
    isAppInSettings $1
    if [ "$Result" = "" ]
    then
        echo "Adding $1 to $SettingsFile"
        sed -i -e '1h;2,$H;$!d;g' -re "s/(INSTALLED_APPS\s?=\s?\[[\n '._a-zA-Z,]*)/\1    '$1',\n/g" $SettingsFile

        # was it added?
        isAppInSettings $1
        if [ "$Result" = "" ]
        then
            echo -e "\n${Bold}${Red}Exiting Script to add a Django App ${Black}${Normal}"
            echo -e "${Bold}${Red}Failed to add $1 to $SettingsFile ${Black}${Normal}"
            exit 1
        fi
    fi
}


############################### Global Variables ###############################
# change colors and styles on terminal output
Bold=$(tput bold)
Normal=$(tput sgr0)
Red=$(tput setaf 1)
Green=$(tput setaf 2)
Blue=$(tput setaf 4)
Black=$(tput sgr0)

StartMessageCount=0

# Options
Clear=true
Update=true
VirtualEnv=true

# Import configuration file for this script
# The config file contains all the apps to install, all the modules to pip3,
# all the files to get, the final path for each, and any permissions required.
# It is basically just a collection of global variables telling the script what
# to do.
if [ -f django.cfg ]
then
    . django.cfg
else
    echoStartingScript
    echo -e "\n  ${Red}ERROR: The Django setup script requires $HomeDirectory/django.cfg${Black}"
    echo -e "\n    ${Red}Please wget django.cfg from github or create one.${Black}"
    echoExitingScript
fi


########################## Start of Install Script  ###########################
# Process command line options
# All options must be listed in order following the : between the quotes on the
# following line:
while getopts ":chuv" option
do
    case $option in
        c) # disable clear after update and upgrade
            Clear=false
            ;;
        h) # display Help
            help
            exit;;
        u) # skip update and upgrade steps
            Update=false
            ;;
        v) # do not add or run from virtual env
            VirtualEnv=false
            VirtualDirectory=""
            NoVirtualEnvDjangoDirectory="$HomeDirectory/.local/bin/"
            ;;
        *) # handle invalid options
            echoStartingScript
            echo -e "\n  ${Bold}${Red}ERROR: Invalid option ${Black}${Normal}"
            echo -e "\n  ${Bold}${Blue}To see valid options, run using: ${Black}${Normal}"
            echo -e "\n    \$ sudo bash ${0##*/} -h ${Black}"
            echoExitingScript
    esac
done


# Exit if running as sudo or root
if [ "$EUID" -eq 0 ]
then
    echo -e "\n  ${Bold}${Red}ERROR: Must NOT run as root or sudo ${Black}${Normal}"
    echo -e "\n  ${Bold}${Red}To see valid options, run using: ${Black}${Normal}"
    echo -e "\n    ${Red}\$ bash ${0##*/} ${Black}"
    echoExitingScript
fi

# pip3_install fails if errexit is enabled, not sure why
# exit on error
# set -o errexit

# exit if variable is used but not set
set -u
# set -o nounset


# Start of steps to add a Django App
SettingsFile="$BaseDirectory/$DjangoProject/p_$DjangoProject/p_$DjangoProject/settings.py"
echo "DEBUG: django_app.sh: SettingsFile = $SettingsFile"

AppName="hello"
echo "DEBUG: django_app.sh: AppName = $AppName"

# steps to getting a static page to work
if [ "$VirtualEnv" = true ]
then
    echo "DEBUG: django_app.sh: premature exit - have not started venv app yet"
    exit
else
# non-venv directories
#     /var/www/TestProject/p_TestProject
#         db.sqlite3  manage.py  p_TestProject  settings.py  static
#     /var/www/TestProject/p_TestProject/p_TestProject
#         asgi.py  __init__.py  __pycache__  settings.py  static  urls.py  wsgi.py
#     Run
#         bash /var/www/server.sh
#     or
#         cd /var/www/TestProject/p_TestProject
#         python3 manage.py runserver 192.168.1.175:8080
#
# Eliminate Django rocket ship page (Not Found reponse)
#   Shouldn't run in production with Debug = True
sed -i "s/DEBUG = True.*/DEBUG = False/" "$SettingsFile"

# Add an app called $AppName
#   need to be in correct directory
echo "DEBUG: django_app.sh: path = $BaseDirectory/$DjangoProject"
cd "$BaseDirectory/$DjangoProject/p_$DjangoProject"
if [ -d "$AppName" ]
then
    echo -e "\n  ${Bold}${Red}ERROR: $AppName has already been used ${Black}${Normal}"
    echo -e "    ${Bold}${Red}   Exiting ${Black}${Normal}"
    exit
else
    python3 manage.py startapp "$AppName"
fi

# PagesConfig is /var/www/$DjangoProject/p_$DjangoProject/$AppName/apps.py 
#   edit INSTALLED_APPS in settings.py to include AppName
addAppToSettings "$AppName.apps.PagesConfig"

# ??? Hello World! is very specific and NOT a generic solution for any App
# Change $BaseDirectory/$DjangoProject/p_$DjangoProject/$AppName/views.py
read -r -d '' ViewsPy <<- EOM
#  $BaseDirectory/$DjangoProject/p_$DjangoProject/$AppName/views.py
from django.http import HttpResponse

def homePageView(request):
    return HttpResponse("Hello, World!")
EOM
cd "$BaseDirectory/$DjangoProject/p_$DjangoProject/$AppName"
echo "$ViewsPy" >| views.py


# *********************** STOPPED HERE *********************
# Change urls.py in $AppName directory
# Change $BaseDirectory/$DjangoProject/p_$DjangoProject/$AppName/urls.py
read -r -d '' UrlsPy <<- EOM
#  $BaseDirectory/$DjangoProject/p_$DjangoProject/$AppName/urls.py
from django.urls import path
from .views import homePageView

urlpatterns = [
    path("", homePageView, name="home"),
]
EOM
cd "$BaseDirectory/$DjangoProject/p_$DjangoProject/$AppName"
echo "$UrlsPy" >| urls.py


echo "DEBUG: django_app.sh: premature exit - STOPPED HERE"
exit

# *********************** STOPPED HERE - seems like same file as above *********************
# change urls.py in project directory
# need two sed commands
cd "$BaseDirectory/$DjangoProject/p_$DjangoProject/p_$DjangoProject
# add include to import line
sed -i "s/from django\.urls import path/from django.urls import path, include  \# added include via django_app.sh/g" urls.py

sed -i -e '1h;2,$H;$!d;g' -re "s/(urlpatterns\s?=\s?\[[\n '._a-zA-Z,]*)/\1    path(\"\", include(\"$AppName.urls\")),  # added by django_app.sh\n/g" urls.py

# nano django_project/urls.py
#     # django_project/urls.py
#     from django.contrib import admin
#     from django.urls import path, include  # new ??? this doesn't seem correct! Is urlpattersn included???
# 
#     urlpatterns = [
#         path("admin/", admin.site.urls),
#         path("", include("pages.urls")),  # new
#     ]
fi

echo "DEBUG: django_app.sh: premature exit"
exit



if [ "$VirtualEnv" = true ]
then
    a_cmd="source $BaseDirectory/$DjangoProject$VirtualDirectory/bin/activate"
    b_cmd="$BaseDirectory/$DjangoProject/manage.py runserver $IP_ADDRESS:$DjangoPort"
else
    a_cmd="cd p_$DjangoProject"
    b_cmd="python3 manage.py runserver $IP_ADDRESS:$DjangoPort"
fi


# if ufw is enabled, then allow the port: $DjangoPort
c=$(sudo ufw status | grep active)
if [[ "$c" == *"inactive"* ]]
then
    echo "ufw is installed and inactive"
elif [[ "$c" == *"active"* ]]
then
    echo "ufw is installed and active"
    echo "   adding rule allow from 192.168.1.0/24 to any port $DjangoPort"
    sudo ufw allow from 192.168.1.0/24 to any port "$DjangoPort"
# else
    echo "ufw is not installed"
fi

changeDirectory "$BaseDirectory"
read -r -d '' ServerScript <<- EOM
# Run these commands:
  cd "$BaseDirectory/$DjangoProject"
  ${a_cmd}
  ${b_cmd}

# Or, run this script:
#   "bash $BaseDirectory/server.sh"
#
# Then open a browser and enter: http://$IP_ADDRESS:$DjangoPort
EOM

echo "$ServerScript" >| server.sh

echo -e "\n${Bold}${Green}$ServerScript ${Black}${Normal}"
echoExitingScript
