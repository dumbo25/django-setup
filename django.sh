#!/bin/bash
# sript to setup django
#
# run using
#    sudo bash [bash_options] django.sh [install_options]

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
# Create a separate script for Django Apps:
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
#   d) deploy script
#      d.1) security checklist
#      d.2) turn off Django debug
#      d.3) run this: manage.py check --deploy
#
# Create a seperate script to add css
#   a) add ui css
#
#   i) use systemd to start webserver
#      i.1) generate myproject.services file systemd and load and start service at boot
#   k) move the additonal script comments above elsewhere
#
# To Do List:
# ??? **************************** STOPPED HERE ******************** ???
#   h) port
#      h.1) move from http 80 (or 8000) to https 443
#      h.2) specify port in .cfg
#      h.3) can any other port work to work *e.g., 8000 >> 443 or 8443)
#
#   x) fix issues in logs
#      x.1) tail /var/log/apache2/access.log
#      x.2) tail /var/log/apache2/error.log
#      x.3) cat /var/log/syslog
#   y) run shellcheck
#   z) add install.sh and install.cfg to github 
#
# Do later or not at all:
#   l) create checkVersion function; read in version number and command to get version number ??? python3, pip3, django
#
# References:
#    deploy to production and security checklist
#      https://docs.djangoproject.com/en/3.2/howto/deployment/checklist/
#        manage.py check --deploy
#      https://learndjango.com/tutorials/django-best-practices-security
#    https://github.com/django/django/tree/main/docs/howto/deployment
#    https://mikesmithers.wordpress.com/2017/02/21/configuring-django-with-apache-on-a-raspberry-pi/
#    https://pimylifeup.com/raspberry-pi-django/
#
############################# <- 80 Characters -> ##############################


################################## Functions ###################################
function echoStartingScript {
    if [ "$StartMessageCount" -eq 0 ]
    then
    echo -e "\n${Bold}${Blue}Starting Django Setup Script ${Black}${Normal}"
    echo "  ${Bold}${Blue}setting up $Name ${Black}${Normal}"
    StartMessageCount=1
    fi
}


function echoExitingScript {
    echo -e "\n${Bold}${Blue}Exiting Django Setup Script ${Black}${Normal}"
    exit
}


function help {
    echo -e "\n$Help"
}


function changeDirectory {
    # check every directory in the passed in path ($1) to see if it exists
    #   if the directory exists cd into it
    #   otherwise exit the script
    # eliminate these checks in function
    path=$1
    if [ "$path" != "" ]
    then
        # handle default directory different than other directories
        f=${path:0:1}
        if [ "$f" = "/" ]
        then
            default=true
        else
            default=false
        fi

        # another bash oddity, quotes are not required for slash
        IFS=/ read -ra dirs <<< "$path"
        for d in "${dirs[@]}"
        do
            if [ "$d" != "" ]
            then
                if [ $default = true ]
                then
                    slash="/"
                    default=false
                else
                    slash=""
                fi

                if [ -d "$slash$d" ]
                then
                    cd "$slash$d"
                else
                    echo -e "\n  ${Bold}${Red}ERROR: Cannot cd to $slash$d, it does not exist ${Black}${Normal}"
                    echoExitingScript
                fi
            fi
        done
    fi
}

function createProjectDirectory {
    #if $DjangoProject exists delete it
    changeDirectory "$BaseDirectory"
    if [ -d "$DjangoProject" ]
    then
        echo -e "\n  ${Bold}${Blue}Directory $DjangoProject exists, removing ${Black}${Normal}"
        sudo rm -r "$DjangoProject"
    fi

    # make and move into django project directory
    echo -e "\n ${Bold}${Blue}make project directory: $DjangoProject ${Black}${Normal}"
    # changed to sudo for /var/www
    if [ $BaseDirectory = "/var/www" ]
    then
        sudo mkdir "$DjangoProject"
        sudo chmod -R 777 /var/www/
    else
        mkdir "$DjangoProject"
    fi

    echo -e "   ${Bold}${Blue}cd $BaseDirectory/$DjangoProject ${Black}${Normal}"
    changeDirectory "$BaseDirectory/$DjangoProject"
    pwd
}

# Source: https://stackoverflow.com/questions/4023830/how-to-compare-two-strings-in-dot-separated-version-format-in-bash
# Author: Dennis Williamson
# modified to return true if >=, otherwise false
# modified to get it to work
function compareVersionStrings {
    if [[ "$1" == "$2" ]]
    then
        return 1
    fi

    # number of section in version number must be the same to compare
    #   fill empty sections in either version number with 0s
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done

    # fill empty fields in ver2 with zeros
    for ((i=${#ver2[@]}; i<${#ver1[@]}; i++))
    do
        ver2[i]=0
    done

    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi

        if ((10#${ver1[i]} >= 10#${ver2[i]}))
        then
            # as long as ver1 section is >= ver2, keep r set to 1
            r=1
        fi

        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            # if any ver1 section is less ver2, return 0
            return 0
        fi
    done

    return $r
}

function checkVersion {
    echo -e "\n   ${Bold}${Blue} check python3 version ${Black}${Normal}"

    pv=$(python3 -c 'import platform; print(platform.python_version())')

    compareVersionStrings "$pv" "$MinimumPythonVersion"
    cmp=$?
    if [ "$cmp" == "1" ]
    then
        echo "   ${Bold}${Blue} python version $pv is greater or equal to $MinimumPythonVersion ${Black}${Normal}"
    else
        echo "    ${Bold}${Red} python version $pv is less than $MinimumPythonVersion ${Black}${Normal}"
        echoExitingScript
    fi
}

function createVirtualEnv {
    if [ "$VirtualEnv" = true ]
    then
        # create virtualenv
        echo -e "\n ${Bold}${Blue}run virtualenv command and virtual env directory${Black}${Normal}"
        virtualenv "v_$DjangoProject"
        echo -e "\n   ${Bold}${Blue}ls v_$DjangoProject directory ${Black}${Normal}"
        pwd
        ls -l "v_$DjangoProject"

        #   activate venv
        echo -e "\n ${Bold}${Blue}activate virtual env ${Black}${Normal}"
        source "v_$DjangoProject/bin/activate"

        #   check if virtual env is running
        #     commented line from stackoverflow doesn't work
        #     INVENV=$(python -c 'import sys; print ("1" if hasattr(sys, "real_prefix") else "0")')
        #     but this does:
        INVENV=$( python3 -c 'import sys ; print( 0 if sys.prefix == sys.base_prefix else 1 )' )
        if [[ "$INVENV" -eq 0 ]]
        then
            echo "   ${Bold}${Red}ERROR: Virtual Environment is not running.  ${Black}${Normal}"
            echoExitingScript
        else
            echo -e "   ${Bold}${Blue}virtual env is active! ${Black}${Normal}"
        fi

        echo -e "   ${Bold}${Blue}check directory after activating virtual env${Black}${Normal}"
        pwd
        ls -l

    fi
}

function installDjango {
    # in virtual env so don't need to cd or activate it
    #   install django
    echo -e "\n ${Bold}${Blue} install django ${Black}${Normal}"
    changeDirectory "$BaseDirectory/$DjangoProject$VirtualDirectory"
    pwd

    export PATH="$HomeDirectory/.local/bin:$PATH"
    if [ "$VirtualEnv" = true ]
    then
        # export PATH="$HomeDirectory/.local/bin:$PATH"
        rm_cmd="rm $HomeDirectory/$DjangoProject$VirtualDirectory/bin/django-admin.py"
    else
        rm_cmd="rm ${NoVirtualEnvDjangoDirectory}django-admin.py"
    fi
    # install django should go after PATH is set, otherwsie a warning is given
    # the warning can be ignored, but it is better not to get the warning
    pip3 install django

    # check if minimum Django version is installed
    installedVersion="$(python3 -m django --version)"
    if [ "$(printf '%s\n' "$MinimumDjangoVersion" "$installedVersion" | sort -V | head -n1)" = "$MinimumDjangoVersion" ]
    then
        echo -e "\n   ${Bold}${Blue} Django version = $installedVersion ${Black}${Normal}"
    elif [ "$installedVersion" = "" ]
    then
        echo -e "\n  ${Bold}${Red}ERROR: minimum Django version is $MinimumDjangoVersion ${Black}${Normal}"
        echo "  ${Bold}${Red}Django does not seem to be installed ${Black}${Normal}"
        echoExitingScript
    else
        echo -e "\n  ${Bold}${Red}ERROR: minimum Django version is $MinimumDjangoVersion ${Black}${Normal}"
        echo "  ${Bold}${Red}Django installed version = $installedVersion ${Black}${Normal}"
        echoExitingScript
    fi

    # to fix the issue of django-admin.py begin deprecated in favor of django-admin
    eval "$rm_cmd"
}

#   create django project
function createDjangoProject {
    changeDirectory "$BaseDirectory/$DjangoProject"

    # above removed django-admin.py, so use django-admin
    if [ "$VirtualEnv" = true ]
    then
        echo -e "\n   ${Bold}${Blue}django-admin startproject p_$DjangoProject ${Black}${Normal}"
        django-admin startproject "p_$DjangoProject" .
    else
        echo -e "\n   ${Bold}${Blue} ${NoVirtualEnvDjangoDirectory}django-admin startproject p_$DjangoProject ${Black}${Normal}"
        # need to allow others to write
        sudo chmod -R 777 /var/www/
        sudo chmod -R 777 /var/www/TestProject
        d_cmd="${NoVirtualEnvDjangoDirectory}django-admin startproject p_$DjangoProject"
        eval "$d_cmd"
    fi

    pwd
    ls -l
}


function createDjangoApps {
    changeDirectory "$BaseDirectory/$DjangoProject"

    # if there apps to install
    if [[ ${DjangoApps[*]} ]]
    then
        echo -e "\n  ${Bold}${Blue} creating django apps ${Black}${Normal}"
        # loop through all apps
        for a in "${DjangoApps[@]}"
        do
            echo "    ${Bold}${Blue}creating app: $a ${Black}${Normal}"
            # there are two ways to create a Django app
            #    django-admin startapp <app>
            #    python3 manage.py startapp <app>
            # manage.py is automatically created in a Django project. manage.py
            # does the same thing as django-admin. Unlike django-admin, manage.py
            # also sets DJANGO_SETTINGS_MODULE environment variable so it points
            # to the project’s settings.py file.
            python3 manage.py startapp "$a"
        done
    else
        echo -e "\n   ${Bold}${Blue}no Django apps in cfg file ${Black}${Normal}"
    fi
}


function migrateDjango {
    echo -e "\n  ${Bold}${Blue} migrate django ${Black}${Normal}"
    changeDirectory "$BaseDirectory"

    if [ "$VirtualEnv" = true ]
    then
        changeDirectory "$BaseDirectory/$DjangoProject"
        ./manage.py makemigrations
        ./manage.py migrate
    else
        changeDirectory "$BaseDirectory/$DjangoProject/p_$DjangoProject"
        python3 manage.py makemigrations
        python3 manage.py migrate
    fi
}

function isVirtualEnvActive {
    # check if virtual env is running
    #   commented line from stackoverflow doesn't work
    #   INVENV=$(python -c 'import sys; print ("1" if hasattr(sys, "real_prefix") else "0")')
    #   but this does:
    INVENV=$( python3 -c 'import sys ; print( 0 if sys.prefix == sys.base_prefix else 1 )' )
    if [[ "$INVENV" -eq 0 ]]
    then
        # last command executed is return value of function
        false
    else
        true
    fi
}

function removePrevious {
    echo -e "\n  ${Bold}${Blue}remove old stuff ${Black}${Normal}"
    # exit virtual env
    if isVirtualEnvActive arg
    then
        echo -e "    ${Bold}${Blue}exiting virtual environment ${Black}${Normal}"
        deactivate
    fi

    changeDirectory "$BaseDirectory"

    if [ -d "$DjangoProject" ]
    then
        if [ -d "v_$DjangoProject" ]
        then
            echo -e "    ${Bold}${Blue}remove virtual environment ${Black}${Normal}"
            rmvirtualenv "v_$DjangoProject"
        fi

        echo -e "    ${Bold}${Blue}remove project directory ${Black}${Normal}"
        rm -rf "$DjangoProject"
    fi

    # restore default apache2 config file
    echo -e "    ${Bold}${Blue}restore default apache2 config file ${Black}${Normal}"
    sudo cp /etc/apache2/sites-enabled/000-default.conf.backup /etc/apache2/sites-enabled/000-default.conf

    # uninstall packages installed via Apt
    uninstallApt

    # uninstall pip3 packages and modules
    uninstallPip3

    echo -e "\n    ${Bold}${Blue}remove directories ${Black}${Normal}"
    if [ -d ".local" ]
    then
        rm -r .local
    fi

    if [ -d ".git" ]
    then
        rm -rf .git
    fi

    if [ -d ".gitconfig" ]
    then
        rm -rf .gitconfig
    fi

    echo -e "\n    ${Bold}${Blue}apt autoremove ${Black}${Normal}"
    sudo apt autoremove -y

    echo -e "\n    ${Bold}${Blue}remove sqlite3 database ${Black}${Normal}"
    if [ -d "db.sqlite3" ]
    then
        rm db.sqlite3
    fi

    # it is unclear why virtualenv and virtualenvwrapper related files are not
    # removed. Removing them doesn't help
    # googling didn't turn up anything
    # echo -e "\n    ${Bold}${Blue}remove directories and files not removed above ${Black}${Normal}"
    # sudo rm -rf /usr/local/lib/python3.7/dist-packages/virtualenv_clone-*
    # sudo rm -rf /usr/local/lib/python3.7/dist-packages/stevedore
    # sudo rm -rf /usr/local/lib/python3.7/dist-packages/importlib-metadata
    # sudo rm -rf /usr/local/lib/python3.7/dist-packages/virtualenvwrapper
    # sudo rm -rf /usr/local/lib/python3.7/dist-packages/virtualenv
    # sudo rm -rf /usr/local/lib/python3.7/dist-packages/importlib-metadata
}

function makePath {
    if [ ! -d "$1" ]
    then
        if [ "$1" != "" ]
        then
            echo "    ${Bold}${Blue}making path: $1 ${Black}${Normal}"
            # -p makes all parent directories if necessary
            # added sudo in moving BaseDirectory to /var/www
            sudo mkdir -p "$1"
        fi
    fi
}


function uninstallApt {
    # if there packages to install
    if [[ ${DebianPackages[*]} ]]
    then
        echo -e "\n    ${Bold}${Blue} uninstalling debian packages ${Black}${Normal}"
        # loop through all the packages
        for p in "${DebianPackages[@]}"
        do
            if [ "$p" == "python3" ]
            then
                echo "      ${Bold}${Blue} skipping: $p ${Black}${Normal}"
            else
                # if the package is not already installed
                notInstalled=$(dpkg-query -W --showformat='${Status}\n' "$p" | grep "install ok installed")
                if [ "$notInstalled" != "" ]
                then
                    echo "      ${Bold}${Blue} uninstalling package: $p ${Black}${Normal}"
                    sudo apt install "$p" -y
                fi
            fi
        done
    else
        echo -e "     ${Bold}${Blue} no raspbian packages in cfg file ${Black}${Normal}"
    fi
}

function installApt {
    # if there packages to install
    if [[ ${DebianPackages[*]} ]]
    then
        echo -e "\n  ${Bold}${Blue} installing debian packages ${Black}${Normal}"
        # loop through all the packages
        for p in "${DebianPackages[@]}"
        do
            # if the package is not already installed
            notInstalled=$(dpkg-query -W --showformat='${Status}\n' "$p" | grep "install ok installed")
            if [ "" = "$notInstalled" ]
            then
                echo "    ${Bold}${Blue} installing package: $p ${Black}${Normal}"
                sudo apt install "$p" -y
            fi
        done
    else
        echo -e "\n   ${Bold}${Blue} no raspbian packages in cfg file ${Black}${Normal}"
    fi
}

function uninstallPip3 {
    # when re-installing some of the virtualenvwrapper requirements are already met
    # I am not sure how to fix. I tried removing with sudo and both pip and pip3
    # if there packages to install. it doesn't seem to cause any issues. So, I am
    # ignoring it
    if [[ ${Pip3Packages[*]} ]]
    then
        echo -e "\n    ${Bold}${Blue}uninstalling pip3 packages ${Black}${Normal}"
        # loop through all the packages
        for p in "${Pip3Packages[@]}"
        do
            # if the package is not already installed
            notInstalled=$(pip3 list | grep "$p")
            if [ "$notInstalled" != "" ]; then
                echo "      ${Bold}${Blue}uninstalling pip3: $p ${Black}${Normal}"
                yes | sudo pip3 uninstall "$p"
            fi
        done
    else
        echo -e "\n  ${Bold}${Blue}no pip3 packages in cfg file ${Black}${Normal}"
    fi
}

function installPip3 {
    # if there packages to install
    if [[ ${Pip3Packages[*]} ]]
    then
        echo -e "\n  ${Bold}${Blue}installing pip3 packages ${Black}${Normal}"
        # loop through all the packages
        for p in "${Pip3Packages[@]}"
        do
            # if the package is not already installed
            notInstalled=$(pip3 list | grep "$p")
            if [ "$notInstalled" = "" ]; then
                echo "    ${Bold}${Blue}installing pip3: $p ${Black}${Normal}"
                yes | sudo pip3 install "$p"
            fi
        done
    else
        echo -e "\n  ${Bold}${Blue}no pip3 packages in cfg file ${Black}${Normal}"
    fi
}


function reloadServices {
    # if there are services to reload
    # if [[ ${ReloadServices[@]} ]]
    if (( ${#ReloadServices[@]} > 0 ))
    then
        echo -e "\n  ${Bold}${Blue}reloading services ${Black}${Normal}"
        # loop through all the packages
        for p in "${ReloadServices[@]}"
        do
            echo "    ${Bold}${Blue}$p ${Black}${Normal}"
            sudo systemctl reload "$p"
        done
    else
        echo -e "\n  ${Bold}${Blue}no services to reload in cfg file ${Black}${Normal}"
    fi
}


function restartServices {
    # if there are services to restart
    # if [[ ${RestartServices[@]} ]]
    if (( ${#RestartServices[@]} > 0 ))
    then
        echo -e "\n  ${Bold}${Blue}restarting services ${Black}${Normal}"
        # loop through all the packages
        for p in "${RestartServices[@]}"
        do
            echo "    ${Bold}${Blue}$p ${Black}${Normal}"
            sudo systemctl restart "$p"
        done
    else
        echo -e "\n  ${Bold}${Blue}no services to restart in cfg file ${Black}${Normal}"
    fi
}

function getSettings {
    # get settings.py
    echo -e "\n ${Bold}${Blue} get settings.py ${Black}${Normal}"
    echo -e "\n   ${Bold}${Blue} should be $BaseDirectory/$DjangoProject/p_$DjangoProject ${Black}${Normal}"
    changeDirectory "$BaseDirectory/$DjangoProject/p_$DjangoProject"

    # remove so we don't end up with a copy of wget file
    echo    "   ignore warnings aboue rm settings.py"
    rm settings.py
    wget "https://raw.githubusercontent.com/dumbo25/newt/master/settings.py"
    echo -e "\n   ${Bold}${Blue} should be $BaseDirectory/$DjangoProject/p_$DjangoProject ${Black}${Normal}"

    # edit settings.py
    var="ALLOWED_HOSTS = ['$IP_ADDRESS']"
    if [ "$VirtualEnv" = true ]
    then
        sed -i "s/ALLOWED_HOSTS.*/$var/" settings.py
    else
        sed -i "s/ALLOWED_HOSTS.*/$var/" settings.py
        cp settings.py "$BaseDirectory/$DjangoProject/p_$DjangoProject/p_$DjangoProject/settings.py"
    fi
}


function getApacheConf {
    # get 000-efault.conf
    echo -e "\n\n\n ${Bold}${Blue}apache2 was installed above, now set it up ${Black}${Normal}"
    echo -e "   ${Bold}${Blue} deactivate virtual env ${Black}${Normal}"
    deactivate

    log="\${APACHE_LOG_DIR}"
    if [ "$VirtualEnv" = true ]
    then
        static="$BaseDirectory/$DjangoProject/static"
        wsgi="$BaseDirectory/$DjangoProject/p_$DjangoProject"
        daemon="$DjangoProject python-path=$BaseDirectory/$DjangoProject python-home=$BaseDirectory/$DjangoProject$VirtualDirectory"
        alias="/$BaseDirectory/$DjangoProject/p_$DjangoProject/wsgi.py"
    else
        static="$BaseDirectory/$DjangoProject/p_$DjangoProject/p_$DjangoProject/static"
        wsgi="$BaseDirectory/$DjangoProject/p_$DjangoProject/p_$DjangoProject"
        daemon="$DjangoProject python-path=$BaseDirectory/$DjangoProject python-home=$BaseDirectory/$DjangoProject/p_$DjangoProject"
        alias="$BaseDirectory/$DjangoProject/p_$DjangoProject/p_$DjangoProject/wsgi.py"
    fi

    read -r -d '' ApacheConfig <<- EOM
<VirtualHost *:80>
        # The ServerName directive sets the request scheme, hostname and port that
        # the server uses to identify itself. This is used when creating
        # redirection URLs. In the context of virtual hosts, the ServerName
        # specifies what hostname must appear in the request's Host: header to
        # match this virtual host. For the default virtual host (this file) this
        # value is not decisive as it is used as a last resort host regardless.
        # However, you must set it for any further virtual host explicitly.
        #ServerName www.example.com

        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html

        # Available loglevels: trace8, ..., trace1, debug, info, notice, warn,
        # error, crit, alert, emerg.
        # It is also possible to configure the loglevel for particular
        # modules, e.g.
        #LogLevel info ssl:warn

        ErrorLog $log/error.log
        CustomLog $log/access.log combined

        # For most configuration files from conf-available/, which are
        # enabled or disabled at a global level, it is possible to
        # include a line for only one particular virtual host. For example the
        # following line enables the CGI configuration for this host only
        # after it has been globally disabled with "a2disconf".
        #Include conf-available/serve-cgi-bin.conf

        # make the following changes for the project newt:
        Alias /static $static
            <Directory $static>
                Require all granted
            </Directory>

            <Directory $wsgi>
                <Files wsgi.py>
                    Require all granted
                </Files>
            </Directory>

            WSGIDaemonProcess $daemon
            WSGIProcessGroup $DjangoProject
            WSGIScriptAlias / $alias

</VirtualHost>
EOM

    echo -e "   ${Bold}${Blue} make a backup and then create apache2's 000-default.conf ${Black}${Normal}"
    changeDirectory "/etc/apache2/sites-enabled"
    sudo mv /etc/apache2/sites-enabled/000-default.conf /etc/apache2/sites-enabled/000-default.conf.backup
    # the file was moved above, so just write to the config file
    # I couldn't get the file written to the final directory using sudo in one command
    echo "$ApacheConfig" >| "$BaseDirectory/000-default.conf"
    sudo cp "$BaseDirectory/000-default.conf" /etc/apache2/sites-enabled/000-default.conf
}

# GitFile is defined in install.cfg
# I treat gits like apts, egt lastest and overwrite current
function gitFiles {
    # if there are files to git
    if [[ ${GitFiles[@]} ]]
    then
        echo -e "\n  ${Bold}${Blue}gitting files ${Black}${Normal}"
        # loop through all the files
        for git in "${GitFiles[@]}"
        do
            # get filename
            # return string after last slash
            filename=${git##*/}
            # if file exists, then need to remove it before wget
            if [ -f "$filename" ]
            then
                echo "    ${Bold}${Blue}removing file: $filename ${Black}${Normal}"
                rm "$filename"
            fi
            echo "    ${Bold}${Blue}gitting file: $filename ${Black}${Normal}"
            wget "$git"
        done
    fi
}

# git clone from github
# the directory is extracted from the repository
function gitClone {
    if [ "$GitClone" == "" ]
    then
        echo -e "\n  ${Bold}${Blue}no clones to git ${Black}${Normal}"
    else
        echo -e "\n  ${Bold}${Blue}gitting clone: $GitClone ${Black}${Normal}"
        repository=$GitClone
        # remove ".git"
        repository=${repository::-4}
        # return string after last slash
        directory=${repository##*/}
        if [ -d "$directory" ]
        then
            echo "    ${Bold}${Blue}removing directory: $directory ${Black}${Normal}"
            rm -rf "$directory"
        fi
        echo -e "\n  ${Bold}${Blue}gitting clone: $GitClone ${Black}${Normal}"
        git clone "$GitClone"
    fi
}

# Bash doesn't have multidimensional tables. So, this is my hack to pretend it does
# Each enttry is a row in a table and includes: "filename;fromPath;toPath"
# So, this function moves each row using mv fomPath/filename toPath/."
function moveFiles {
    # if there are files to move
    if [[ ${MoveFiles[*]} ]]
    then
        echo -e "\n  ${Bold}${Blue}moving files ${Black}${Normal}"
        # loop through all the packages
        for f in "${MoveFiles[@]}"
        do
            IFS=';' read -ra file <<< "$f"
            # create path where file will be moved
            makePath "${file[2]}"

            # if the file exists in the fromPath
            if [ -f "${file[1]}/${file[0]}" ]
            then
                # move file fromPath to toPath
                echo "    ${Bold}${Blue}mv ${file[1]}/${file[0]} ${file[2]}/. ${Black}${Normal}"
                sudo mv "${file[1]}/${file[0]}" "${file[2]}/."
            fi
        done
    fi
}

# The script does not runs as sudo. So, This function changes ownership to the correct
# settings based on the config file. Each enttry is a row in a table and includes:
#     "path or path/filename;ownership"
function changeOwnership {
    # if there are files to move
    if [[ ${ChangeOwnership[*]} ]]
    then
        echo -e "\n  ${Bold}${Blue}changing ownership ${Black}${Normal}"
        # loop through all the entries
        for f in "${ChangeOwnership[@]}"
        do
            IFS=';' read -ra file <<< "$f"
            # if the entry is a file
            if [ -f "${file[0]}" ]
            then
                # change ownership just on the file
                echo "    ${Bold}${Blue}chown ${file[0]} to ${file[1]} ${Black}${Normal}"
                chown "${file[1]}" "${file[0]}"
            elif [ -d "${file[0]}" ]
            then
                # change ownership just on the file
                echo "    ${Bold}${Blue}chown rexcursively on ${file[0]} to ${file[1]} ${Black}${Normal}"
                chown -R "${file[1]}" "${file[0]}"
            fi
        done
    fi
}

# The script does not run as sudo.
# This function changes permissions to be correct.
# Each enttry is a row in a table and includes: "path/filename;permissions"
function changePermissions {
    # if there are files to move
    if [[ ${ChangePermissions[*]} ]]
    then
        echo -e "\n  ${Bold}${Blue}changing permissions ${Black}${Normal}"
        # loop through all the entries
        for f in "${ChangePermissions[@]}"
        do
            IFS=';' read -ra file <<< "$f"
            # if the entry is a file
            if [ -f "${file[0]}" ]
            then
                # change ownership just on the file
                echo "    ${Bold}${Blue}chmod ${file[0]} to ${file[1]} ${Black}${Normal}"
                chmod "${file[1]}" "${file[0]}"
            fi
        done
    fi
}

# Remove files and directories that are not needed
function cleanUp {
    # if there are files to move
    if [[ ${CleanUp[*]} ]]
    then
        echo -e "\n  ${Bold}${Blue}removing files and directories that are not needed ${Black}${Normal}"
        # loop through all the entries
        for f in "${CleanUp[@]}"
        do
            IFS=';' read -ra file <<< "$f"
            # if the entry is a file
            if [ -f "${file[0]}" ]
            then
                # remove file
                echo "    ${Bold}${Blue}remove ${file[0]} ${Black}${Normal}"
                rm "${file[0]}"
            elif [ -d "${file[0]}" ]
            then
                #remove directory
                echo "    ${Bold}${Blue}remove rexcursively ${file[0]} ${Black}${Normal}"
                rm -R "${file[0]}"
            fi
        done
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
    echo -e "\n  ${Red}ERROR: The Django setup script requires $BaseDirectory/django.cfg${Black}"
    echo -e "\n    ${Red}Please wget django.cfg from github or create one.${Black}"
    echoExitingScript
fi


########################### Start of Install Script  ###########################
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


# update and uphrade packages
if [ "$Update" = true ]
then
    echoStartingScript

    echo "  ${Bold}${Blue}updating ${Black}${Normal}"
    sudo apt update -y
    echo -e "\n  ${Bold}${Blue}upgrading ${Black}${Normal}"
    sudo apt upgrade -y
    echo -e "\n  ${Bold}${Blue}removing trash ${Black}${Normal}"
    sudo apt autoremove -y
    sudo apt clean

    # the above generates a lot of things that may not be relevant to the install of
    # this application. So, clear the screen and then put Starting message here.
    if [ "$Clear" = true ]
    then
        clear
        StartMessageCount=0
    fi
fi

echoStartingScript

# remove old stuff
#   the goal is to start in a known good state
removePrevious

# get IP Address of raspberry pi
IP_ADDRESS=$(hostname -I)
#   and trim trailing whitespace
IP_ADDRESS="${IP_ADDRESS%"${IP_ADDRESS##*[![:space:]]}"}"

# install required packages, which are defined in DebainPackages list in install.cfg
# install python3 and related tools
installApt

# only does python3, but should be generic and be driven by data in .cfg
#   add pip3 and django
#   might want optional parameter to check after each install
checkVersion

# install required python packages, which are defined in PipPackages list in install.cfg
installPip3

    echo -e "\n   ${Bold}${Blue} check pip3 version ${Black}${Normal}"

    s=$(pip3 --version)
    pv=$(echo $s | sed "s/^pip\s\([0-9.]*\)\s.*/\1/")

    compareVersionStrings "$pv" "$MinimumPip3Version"
    cmp=$?
    if [ "$cmp" == "1" ]
    then
        echo "   ${Bold}${Blue} python version $pv is greater or equal to $MinimumPip3Version ${Black}${Normal}"
    else
        echo "    ${Bold}${Red} python version $pv is less than $MinimumPip3Version ${Black}${Normal}"
        echoExitingScript
    fi


if [ $BaseDirectory = "/var/www" ]
then
    sudo chmod -R 777 /var/www/
fi

# create project sirectory
createProjectDirectory

createVirtualEnv

# create Django project
#   there is only one Django project, which can have multiple apps
installDjango

createDjangoProject

getSettings

# propagate changes via migration
migrateDjango

getApacheConf

if [ "$VirtualEnv" = true ]
then
    changeDirectory "$BaseDirectory/$DjangoProject"
    source "v_$DjangoProject/bin/activate"
    # create user
    echo -e "\n   ${Bold}${Blue} answer questions to create superuser ${Black}${Normal}"
    # python3 manage.py createsuperuser
    DJANGO_SUPERUSER_USERNAME=$SuperUserName \
    DJANGO_SUPERUSER_PASSWORD=$SuperUserPassword \
    DJANGO_SUPERUSER_EMAIL=$SuperUserEmail \
    python3 manage.py createsuperuser --noinput

    # get static files
    echo -e "\n   ${Bold}${Blue} get static files ${Black}${Normal}"
    python3 manage.py collectstatic
else
    # create user
    changeDirectory "$BaseDirectory/$DjangoProject/p_$DjangoProject"

    echo -e "\n   ${Bold}${Blue} answer questions to create superuser ${Black}${Normal}"
    # python3 manage.py createsuperuser
    DJANGO_SUPERUSER_USERNAME=$SuperUserName \
    DJANGO_SUPERUSER_PASSWORD=$SuperUserPassword \
    DJANGO_SUPERUSER_EMAIL=$SuperUserEmail \
    python3 manage.py createsuperuser --noinput

    # get static files
    mkdir "$BaseDirectory/$DjangoProject/p_$DjangoProject/p_$DjangoProject/static"
    echo -e "\n   ${Bold}${Blue} get static files ${Black}${Normal}"
    # python3 manage.py collectstatic --noinput
    python3 manage.py collectstatic

    changeDirectory "$BaseDirectory/$DjangoProject"
fi


# change ownership and permissions
#   cannot use: function changePermissions because it changess more than is required
echo -e "\n   ${Bold}${Blue} change ownership and permissions for db.sqlite3 ${Black}${Normal}"
changeDirectory "$BaseDirectory"
#   cannot use Django changeOwnership because it changes too much
sudo chown :www-data "$DjangoProject"
chmod g+w "$DjangoProject"
if [ "$VirtualEnv" = false ]
then
    changeDirectory "$DjangoProject/p_$DjangoProject"
fi
chmod g+w db.sqlite3
sudo chown :www-data db.sqlite3
changeDirectory "$BaseDirectory"

# reload and restart services
reloadServices
restartServices


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
    echo " adding rule allow from 192.168.1.0/24 to any port "$DjangoPort"
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
