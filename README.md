# Automated Window Blind Controller
An Electric Imp-powered automated window blind controller, connected to Google Calendar and Weather Underground

This project simply opens the blinds in my dorm room according to a morning "wake up" schedule programmed in Google Calendar, and closes the blinds according to the sunset time posted in the astronomy data from the Weather Underground API. Of course, I have also bookmarked the URL calls to opening, closing, and trimming the blinds on my cellphone and computer, so that overriding the automated control schedule is always a button press away.

Video in action:
<a href="http://www.youtube.com/watch?feature=player_embedded&v=Lm1xPXeB1SU" target="_blank"><img src="http://img.youtube.com/vi/Lm1xPXeB1SU/0.jpg" 
alt="IMAGE ALT TEXT HERE" width="240" height="180" border="10" /></a>

## Setup: Software

The easiest way to expose your morning schedule to the Imp agent server is to create a public Google Calendar and generate a corresponding API Key through the Google Developer Console.

### Creating a public Google Calendar

![alt text](http://i.imgur.com/eQKIOjj.png "Creating a Calendar")
![alt text](http://i.imgur.com/hhjkcMW.png "Making it public")
![alt text](http://i.imgur.com/gNnytCq.png "Calendar settings")
![alt text](http://i.imgur.com/W75srge.png "Getting Calendar ID")

### Creating a Google Developer API Key
After navigating to https://console.developers.google.com/project, click on "Create Project." After agreeing to the terms of service, you will be taken to the project's dashboard. In the left sidebar, click on "APIs & auth."--> "APIs." Scroll or ctrl-f for "Calendar API, and click on the button that says "OFF" to its right in order to enable it. (INSERT IMAGE HERE)

Then, in the left sidebar, click on Credentials, followed by "Create new Key" at the bottom of the page under "Public API access." Select "Server key", and in the text field that follows enter the string `0.0.0.0/0`. Click Create.

## Setup: Electrical

http://i.imgur.com/6yY9EK2.png
Inspiration for H Bridge design: http://letsmakerobots.com/content/motor-driver-idea

## Setup: Mechanical

Winch design:
http://i.imgur.com/syJhmKE.png
![alt text](http://i.imgur.com/W75srge.png "Getting Calendar ID")

Winch closeup:
![alt text](http://i.imgur.com/W75srge.png "Getting Calendar ID")
https://lh6.googleusercontent.com/CNk5isRVL6eV5MgXxXoXpxpikmcJTm68sV4OgdVTmmlQi8Piaeht9b3KaDMisxKFBtFtyv-_K8g=w1256-h515

CAD files for winch: https://grabcad.com/library/splined-reel-for-winching-a-string-via-a-worm-gear-window-motor-system-1


