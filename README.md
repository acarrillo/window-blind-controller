# Automated Window Blind Controller
An Electric Imp-powered automated window blind controller, connected to Google Calendar and Weather Underground.

This project simply opens the blinds in my dorm room according to a morning "wake up" schedule programmed in Google Calendar, and closes the blinds according to the sunset time posted in the astronomy data from the Weather Underground API. Of course, I have also bookmarked the URL calls to opening, closing, and trimming the blinds on my cellphone and laptop, so that overriding the automated control schedule is always a button press away.

**Video in action:**      
<a href="http://www.youtube.com/watch?feature=player_embedded&v=Lm1xPXeB1SU" target="_blank"><img src="http://img.youtube.com/vi/Lm1xPXeB1SU/0.jpg" 
alt="IMAGE ALT TEXT HERE" width="640" height="480" border="10" /></a>

The automated curtain opening on scheduled Calendar time is stable, but sunset closing is not. Will fix sunset closing as soon as I have time!

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

After pasting your Weather Underground API key into the `WUNDERGROUND_KEY` at the head of [windowcontroller.agent.nut](https://github.com/acarrillo/window-blind-controller/blob/master/windowcontroller.agent.nut), fill the `ZIP_CODE` field as well. You can actually use other information besides zip code to identify your location. To borrow from the [Electric Imp Weather Underground class](https://github.com/electricimp/reference/tree/master/webservices/wunderground) documentation, you can use any of the following input formats:

- **Country/City:** "Australia/Sydney"
- **US State/City:** "CA/Los_Altos"
- **Lat,Lon:** "37.776289,-122.395234"
- **Zipcode:** "94022"
- **Airport code**: "SFO"


## Setup: Electrical

The circuit below is an H bridge circuit for driving a 12v motor in forward or reverse, depending on the logic input on the two NPN base inputs from the Electric Imp. Driving both NPN inputs to the same voltage level will cause the motor to stop, and applying a logic "on" to one and "off" to the other will energize the motor in one direction or another.

![alt text](http://i.imgur.com/6yY9EK2.png "Circuit schematic")
![alt text](http://i.imgur.com/kK7122n.jpg "Breadboard")
![alt text](http://i.imgur.com/hWy6xdu.jpg "Winch")

Inspiration for H Bridge design: http://letsmakerobots.com/content/motor-driver-idea

## Setup: Mechanical

The motor is a scrap [window motor](https://www.google.com/search?site=&tbm=isch&source=hp&biw=1280&bih=635&q=window+motor&oq=window+motor&gs_l=img.3..0l10.971.2062.0.2165.12.8.0.1.1.0.216.787.2j3j1.6.0.msedr...0...1ac.1.61.img..5.7.790._NM5K_zDsE0#tbm=isch&q=car+window+motor&revid=881154322) with a custom 3d-printed winch press-fit onto its output shaft. 

Winch design:

![alt text](http://i.imgur.com/syJhmKE.png "Winch Design")
![alt text](http://i.imgur.com/SDHnLFY.jpg "Winch Closeup")

CAD files for winch: https://grabcad.com/library/splined-reel-for-winching-a-string-via-a-worm-gear-window-motor-system-1

The rigging is designed to take complete advantage of features that were already present in the manually-controlled window blind system. From the winch, the string rises, passes through a (duct-taped in place) loop that apparently used to hold a curtain-pushing stick, knots around the first loop of the near edge of the moving curtain, passes through the last loop of the curtain (which is static), and terminates at a water bottle counterweight.


![alt text](http://i.imgur.com/wPJKgsb.jpg "Winch Closeup")

