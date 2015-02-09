# Automated Window Blind Controller
An Electric Imp-powered automated window blind controller, connected to Google Calendar and Weather Underground

This project simply opens the blinds in my dorm room according to a morning "wake up" schedule programmed in Google Calendar, and closes the blinds according to the sunset time posted in the astronomy data from the Weather Underground API. Of course, I have also bookmarked the URL calls to opening, closing, and trimming the blinds on my cellphone and laptop, so that overriding the automated control schedule is always a button press away.

Video in action:      
<a href="http://www.youtube.com/watch?feature=player_embedded&v=Lm1xPXeB1SU" target="_blank"><img src="http://img.youtube.com/vi/Lm1xPXeB1SU/0.jpg" 
alt="IMAGE ALT TEXT HERE" width="240" height="180" border="10" /></a>

## Setup: Software

The easiest way to expose one's morning schedule to the Imp agent server is to create a public Google Calendar and generate a corresponding API Key through the Google Developer Console.

### Creating a public Google Calendar

![alt text](http://i.imgur.com/eQKIOjj.png "Creating a Calendar")
![alt text](http://i.imgur.com/hhjkcMW.png "Making it public")

Once you have created the public calendar, you will need to find the Calendar ID. You can find this via the following procedure: 
![alt text](http://i.imgur.com/gNnytCq.png "Calendar settings")
![alt text](http://i.imgur.com/W75srge.png "Getting Calendar ID")

With the Calendar ID in your clipboard, paste it into the `CALENDAR_ID` field of [windowcontroller.agent.nut](https://github.com/acarrillo/window-blind-controller/blob/master/windowcontroller.agent.nut).

### Creating a Google Developer API Key
After navigating to https://console.developers.google.com/project, click on "Create Project." After agreeing to the terms of service, you will be taken to the project's dashboard. In the left sidebar, click on "APIs & auth."--> "APIs." Scroll or ctrl-f for "Calendar API, and click on the button that says "OFF" to its right in order to enable it.
![alt text](http://i.imgur.com/hWEXfDG.png "Getting Calendar ID")

Then, in the left sidebar, click on Credentials, followed by "Create new Key" at the bottom of the page under "Public API access." Select "Server key", and in the text field that follows enter the string `0.0.0.0/0`. Click Create. Finally, copy the API Key and paste it into the `GOOGLE_KEY` field at the top of [windowcontroller.agent.nut](https://github.com/acarrillo/window-blind-controller/blob/master/windowcontroller.agent.nut).

### Setting up Weather Underground

Google Calendar provides us with the wake-up times at which to open the blinds -- we then use Weather Underground to find the sunset time for our local area. To create a free Weather Underground API key, head to [http://www.wunderground.com/weather/api/](http://www.wunderground.com/weather/api/) and follow instructions for making a minimum bells-and-whistles account.

After pasting your Weather Underground API key into the `WUNDERGROUND_KEY` at the head of [windowcontroller.agent.nut](https://github.com/acarrillo/window-blind-controller/blob/master/windowcontroller.agent.nut), fill the `ZIP_CODE` field as well. You can actually use other information besides zip code to identify your location. To borrow from the Electric Imp Weather Underground documentation:


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


