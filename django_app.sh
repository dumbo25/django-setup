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
#
############################# <- 80 Characters -> ##############################

################################## Functions ###################################
