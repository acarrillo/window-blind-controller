// Alex Carrillo (alejandro.carrillo@yale.edu)
// January 2015
// Electric Imp-powered automated window blind controller


// ============= IMPORTANT USER-SPECIFIC CONSTANTS =====================

// Create your WU key here: http://www.wunderground.com/weather/api/
const WUNDERGROUND_KEY = "<YOUR_WUNDERGROUND_KEY>";
// Create your Google Developer key here / see the README for detailed
// instructions: https://console.developers.google.com/project
const GOOGLE_KEY       = "<YOUR_GOOGLE_API_KEY>";
const CALENDAR_ID      = "<YOUR_CALENDAR_ID>"; // See Calendar Settings in Gcal
const ZIP_CODE         = "<YOUR_ZIP_CODE>"; // Note that zip code can be
                                            // replaced by other location
                                            // data; see Wunderground class
                                            // definition below

// ============== IMPORTING WEATHER UNDERGROUND CLASS ==================


// Weather Underground Forecast Agent
// Copyright (C) 2014 Electric Imp, inc.


class Wunderground {
    _apiKey = null;
    _baseUrl = "http://api.wunderground.com/api/";
    _location = null;

    /***************************************************************************
     * apiKey - your Wunderground API Key
     * Location can be any of the following:
     *  Country/City ("Australia/Sydney")
     *  US State/City ("CA/Los_Altos")
     *  Lat,Lon ("37.776289,-122.395234")
     *  Zipcode ("94022")
     *  Airport code ("SFO")
     **************************************************************************/
    constructor(apiKey, location) {
        this._apiKey = apiKey;
        this._location = location;
    }

    function getSunriseSunset(cb = null) {
        local request = http.get(_buildUrl("astronomy"), {});

        if (cb == null) {
            local resp = request.sendsync();
            if (resp.statuscode != 200) {
                server.log(format("Error fetching sunrise/sunset data: %i - %s", resp.statuscode, resp.body));
                return null;
            } else {
                local data = _parseSunriseSunsetResponse(resp.body);
                return data;
            }
        } else {
            request.sendasync(function(resp) {
                if (resp.statuscode != 200) {
                    server.log(format("Error fetching sunrise/sunset data: %i - %s", resp.statuscode, resp.body));
                } else {
                    local data = _parseSunriseSunsetResponse(resp.body);
                    cb(data);
                }
            }.bindenv(this));
        }
    }

    function getConditions(cb = null) {
        local request = http.get(_buildUrl("conditions"), {});
        if (cb == null) {
            local resp = request.sendsync();
            if (resp.statuscode != 200) {
                server.log(format("Error fetching sunrise/sunset data: %i - %s", resp.statuscode, resp.body));
                return null;
            } else {
                local data = http.jsondecode(resp.body);
                return data;
            }
        } else {
            request.sendasync(function(resp) {
                if (resp.statuscode != 200) {
                    server.log(format("Error fetching sunrise/sunset data: %i - %s", resp.statuscode, resp.body));
                } else {
                    local data = http.jsondecode(resp.body)
                    cb(data);
                }
            }.bindenv(this));
        }
    }

    /***** Private Function - Do Not Call *****/
    function _buildUrl(method) {
        return format("%s/%s/%s/q/%s.json", _baseUrl, _apiKey, method, _encode(_location));
    }

    function _parseSunriseSunsetResponse(body) {
        try {
            local data = http.jsondecode(body);

            return {
                "sunrise" : data.sun_phase.sunrise,
                "sunset" : data.sun_phase.sunset,
                "now" : data.moon_phase.current_time
            };
        } catch (ex) {
            server.log(format("Error Parsing Response - %s", ex));
            return null;
        }
    }

    function _encode(str) {
        return http.urlencode({ s = str }).slice(2);
    }
}

// ============ START OF MAIN APPLICATION CODE =================

// Log the URLs we need
server.log("Open blind (CW): " + http.agenturl() + "?xmotorx=2");
server.log("Close blind (CCW): " + http.agenturl() + "?xmotorx=1");
server.log("OFF: " + http.agenturl() + "?xmotorx=0");
server.log("TRIM OPEN: " + http.agenturl() + "?trim=1");
server.log("TRIM CLOSED: " + http.agenturl() + "?trim=-1");

// Instantiate wunderground object for getting sunset time
wunderground <- Wunderground(WUNDERGROUND_KEY, "06511");



/**
 * Returns an ISO 8601 time string, since I don't trust the time coming from
 * the imp server.
 *
 * If 'hour' and 'minute' are passed in, the time string is generated with
 * today's date and those hours and mintues replaced. This is a hack to
 * accomodate generating a std. time string for the sunset timer, since the GCal
 * API already generates a nice time string for when the blinds should open.
 *
 */
function genTimeString(hour="", minute="") {
    local request = http.get("http://www.timeapi.org/est/now");
    local response = request.sendsync();
    return response.body
}

/**
 * Server callback for when an HTTP request comes in
 */
function requestHandler(request, response) {
  try {
    // check if the user sent led as a query parameter
    if ("xmotorx" in request.query) {


      if (request.query.xmotorx == "1" || request.query.xmotorx == "0"
      || request.query.xmotorx == "2" || request.query.xmotorx == "3" ||
      request.query.xmotorx == "4") {
        local motorState = request.query.xmotorx.tointeger();
        device.send("xmotorx", motorState);
      }
    }
    // Trims the blinds closed in case they didn't fully close on command
    else if ("trim" in request.query) {
        local trimDir = request.query.trim.tointeger();
        device.send("trim", trimDir);
    }
    // send a response back saying everything was OK.
    response.send(200, "OK");
  } catch (ex) {
    response.send(500, "Internal Server Error: " + ex);
  }
}

Next_Goal <- "!" // Next time at which the blinds should open

/**
 * The main loop for opening the blinds. Checks periodically if the current time
 * exceeds the time point at which the blinds should be raised. Also sets the
 * appropriate sunset time after a Calendar-triggered "open blinds" event.
 */ 
function checkWakeupTimeLoop() {
    // Oddly, the parameters that follow were chosen to have GCal return us the
    // ENDING time of the next wake up time. This is janky, and there's
    // definitely a way to sort it by start dates that I didn't see on first pass,
    // but since it works for now I'm leaving it just to move on...
    local timenow = genTimeString(); // The current date-time in ISO 8601 format
    local url_base = "https://www.googleapis.com";
    local uri_params = "/calendar/v3/calendars/"+CALENDAR_ID+"/events?singleEvents=true&orderBy=startTime&maxResults=1Y&timeMin=";
    local url = url_base+uri_params+timenow+"&key="+GOOGLE_KEY;
    local request = http.get(url); // Get the time of the next wake up event
    local response = request.sendsync();

    try {
        local data = http.jsondecode(response.body)
        local wake_up_time = data.items[0].start.dateTime
        server.log("WAKEUP TIME: "+wake_up_time)
        server.log("TIME NOW: "+timenow);

        // If there's been a change in the current target "open blinds"
        // time, and the current time is now past the old wake up time,
        // it's because we've just passed the "wake up time" and it's time to open
        // the blinds! This logic really needs cleanup so that it is driven not
        // by changes in the GCal wake up time, but instead in whether we have passed the latest
        // wakeup time setpoint, but it is built like this because of how I'm
        // checking the next wakeup time with GCal. To do this right, I would really
        // have to calibrate the agent server system time with the Internet's
        // consensus on the actual time (I found them to be wildly different in
        // the 'minutes' field), but as a proof of concept, I thought that
        // avoiding this calibration would save time.
        
        // A better approach would be to calculate the difference in seconds between the time
        // at which a new Calendar event is identified and the start time of that Calendar event,
        // then create a wakeup() trigger for that many seconds to trigger a blind-opening event.
        // This is already how the sunset blind-closer code works.
        if (wake_up_time != Next_Goal) {
            // Checks if GCal has found a new "next wake up time" event, AND
            // the old wake up time event is BEFORE the current time. 
            if (Next_Goal != "!" && date_cmp(timenow, Next_Goal) > 0) {
                device.send("xmotorx", 3); // Sends an "Open Blinds" command!
                
                // schedules the next blind-closing event
                wunderground.getSunriseSunset(function(data) {
                    server.log(format("Sunset at %s:%s", data.sunset.hour, data.sunset.minute));
                    
                    // Schedule when the blinds should automatically close
                    local seconds_till_sunset = get_seconds_til(timenow, data.sunset);
                    imp.wakeup(seconds_till_sunset, function() {
                        device.send("xmotorx", 4); // Sends a "Close Blinds" command!
                    });
                });
            }
            Next_Goal <- wake_up_time; // Update Next_Goal with latest time
        }
    }
    catch(error) {
        server.log("Error was "+error);
        
    }
    
    // The system has minute-resolution on wake up time.
    imp.wakeup(60,checkWakeupTimeLoop);
}

/**
 * Compares the two dates given as ISO 8601 strings. 
 * Returns -1 if dt1 < dt2, else 1.
 * 
 * TODO: Instead of +-1, make this function return the difference in seconds 
 * between the two dates,so that the scheduling of the blinds-closing based on 
 * sunset can take advantage of the date parsing done here.
 */ 
function date_cmp(dt1, dt2) {
    // Returns -1 if dt1 < dt2, else 1
    server.log("comparing dates!!!")
    local datetime1 = split(dt1,"-:T");
    local datetime2 = split(dt2,"-:T");
    local dt1_year = datetime1[0].tointeger();
    local dt2_year = datetime2[0].tointeger();
    local dt1_month = datetime1[1].tointeger();
    local dt2_month = datetime2[1].tointeger();
    local dt1_day = datetime1[2].tointeger();
    local dt2_day = datetime2[2].tointeger();
    local dt1_hour = datetime1[3].tointeger();
    local dt2_hour = datetime2[3].tointeger();
    local dt1_minute = datetime1[4].tointeger();
    local dt2_minute = datetime2[4].tointeger();
    
    if (dt1_year < dt2_year) {
        return -1;
    }
    else if (dt1_month < dt2_month) {
        return -1;
    }
    else if (dt1_day < dt2_day) {
        return -1;
    }
    else if (dt1_hour < dt2_hour) {
        return -1;
    }
    else if (dt1_minute < dt2_minute) {
        return -1;
    }

    return 1;

}

/**
 * Given the current time as an ISO 8601 string, and the HH:MM of the next sunset,
 * return the number of seconds until the next sunset.
 */
function get_seconds_til(timenow, sunset_data) {
    local datetime = split(dt2,"-:T");
    local hour_now = datetime[3].tointeger();
    local minute_now = datetime[4].tointeger();

    // Note that this hour calculation is safe because it is in 24-hour form.
    // 30 minutes are tacked on at the end of the calculation because it takes
    // about that long for it to get sufficiently dark to warrant closing the
    // blinds.
    local hour_diff = sunset_data.hour.tointeger() - hour_now;
    local mins_diff = abs(sunset_data.minute.tointeger() - minute_now);
    local seconds_diff = 60*60*hour_diff + 60*mins_diff + 60*30;

    return seconds_diff;
}
// register the HTTP handler
http.onrequest(requestHandler);

// Start the loop
checkWakeupTimeLoop();
