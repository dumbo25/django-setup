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
# Create a deploy script (move to a new scipt)
#   a) deploy script
#      a.1) security checklist
#      a.2) turn off Django debug
#      a.3) run this: manage.py check --deploy
#      a.4) use systemd to start webserver
#           generate myproject.services file systemd and load and start service at boot
#
# To Do List:
# Create a seperate script to add css (move to a new script)
#   a) add ui css
#
#
#   w) tesr all options
#   x) install from scratch 
#   y) run shellccheck
#   z) check into github
#
# Do later or not at all:
#
# References:
#
############################# <- 80 Characters -> ##############################

################################## Functions ###################################
