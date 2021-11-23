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
