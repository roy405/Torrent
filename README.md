# Torrent:  A Real Time iOS Weather Application

Torrent, an iOS-based applica@on built using Apple's SwiDUI framework for Real-@me,
personalized and bespoke weather informa@on. With the integra@on of various buil@n iOS tools
and frameworks, sophis@cated external tools and an extremely reliable API, the applica@on is
equipped with the most robust, high performant and comprehensive func@onali@es to provide
users with a seamless experience for weather monitoring. It provides tailored weather updates
based on users’ bespoke needs, while also providing regular updates based on loca@on as
required and keep a feedback loop to also keep user inputs into considera@ons for future
improvements.

# Technologies Used:
- **SwiftUI:** Crafted using Apple’s most advanced UI Toolkit, the application leverages the power
and simplicity of SwiftUI and the Swift language to provide an efficient, seamless and truly
native experience for users.
- **CoreData:** The application uses CoreData as its in device data management along with
SQLite working under the hood of CoreData, also gets a comprehensive database
persistence solution.
- **MapKit:** Utilizes Apple's MapKit to provide a weather map that is dynamic and considers user
inputs.
- **Core Location:** Weather data without location is not bespoke and user focused. Hence, the
application leverages Apple’s CoreLocation to provide location specific weather information.
- **JSON Parsing:** Advanced JSON parsing concepts were utilized to transform, and process
required data from RAW data fetched from API (as required).
- **Networking:** Robust REST calls are made to WeatherAPI.com to fetch the most up-to date,
recent weather information for users.
- **User Defaults:** Utilized for simple, temporary short-term storage.
- **MVVM Design Pattern:** Model-View-ViewModel (MVVM) pattern was followed to ensure a
clean, maintainable, and scalable and contemporary applica@on architecture and codebase.

# Core Functionalities:

1. __Location-Based Weather:__
Various parts of the application uses real time location to fetch and display weather information.
When launching the application for the first time, the user is asked to provide permission to
access the location. Once the user provides location access, the application uses the location to
fetch weather updates periodically. If the user doesn’t provide the permissions, the application
further requests that the user turn on the loca@on services to take full advantage of the
application.

2. __Real-Time Weather Updates:__
As an intro, the App uses a tab view for navigation. On the main screen, which is the ‘Now’ tab
of the application, they can see the current weather which the application automatically fetches
every 3 hours based on the location of the user, keeping the weather update and the user
informed.

3. __City Selection:__
Users can select any city from a pre-defined list of 100 cities which are originally read from a
JSON file added with the original bundle of the application and then saved to CoreData before
retrieval to display in a list which can be accessed by tapping the ‘+’ button on the main screen.
Upon selecting a city, the app fetches weather data for the selected city is and displays it in a list
on the main screen ‘Now’. Users can add any many cities as they want based on their
requirement of keeping track of weathers in other cities in the list, hence no restrictions are set.
Only one instance of a city remains at a time while also allowing the user to delete weather info
for cities as they like.

4. __3-day Weather Forecast:__
On the Now “Page”, based on the user’s current location, weather forecasts are provided. They
are presented in small cards a right below the current weather and presents the min, max
temperatures, and condi@ons for the next 3 days (API restriction), hence allowing the weather
to prepare ahead for future weather conditions.

5. __Dynamic Weather Map:__
A unique feature that allows users to place a pointer on any city/town on the map. The map can
be accessed by tapping the map icon at the top of the ‘Now’ Screen. By le]ng the pointer rent.
on the name of any city, the weather for that city, place, town or any area if it’s a name, will be
fetched (given the API provides the information) and be displayed on a small cart just below the
pointer. The API requests are optimized to launch aDer a 3-second delay, giving users adequate
@me to pick a loca@on and conserving API call limits simultaneously.

6. __Daily Recommendations:__
Based on the live locations and user permission, the application provides daily weather
recommendations to users. This is presented in the ‘Recommendations’ tab. Once each day, the
application provides recommendations such as “wear sunscreen" on hot days or "carry an
umbrella" during rain. These are based on real-time weather data and change daily.

7. __Feedback System:__
The application allows users to provide feedback to create a feedback loop to consider user
recommendations as well in trying to improve. Users can navigate to the ‘Feedbacks’ tab and
tap the ‘+’ bu"on to record weather inconsistences which will be persisted by the app along
with the weather information that it fetches from the weather API and displays in the list that is
in the Feedback tab. Users can remove their feedback if required. These feedback are to be
used to refining weather informa@tin in the future for better, more precise info and experience.

# Error Handling Strategy
A two-pronged error-handling strategy is u@lized by Torrent to ensure that any poten@al errors
are handled and properly communicated to users for a comprehensive, error free experience.

1. __Location Services and Entrypoint (startup) level Error Handling:__
U@lising a `PassthroughSubject` from the Combine framework, the applica@on monitors
changes in loca@on services and based on permissions, reacts accordingly. Based on various
op@ons presented to the users for loca@on services, if the user grants permission, the app works
as usual, but if the user declines grant of loca@on services, the app displays a message regarding
the app’s requirement for loca@on services to func@on adequately allowing the user to use the
app to its full poten@al. In the case of parental restric@ons for loca@on services, the app also
displays a different message to the users le]ng the user know about the parental restric@on.

3. __Comprehensive App-Wide Error Handling (JSON, API calls, Data Manipula8on and
CoreData Interfacing):__
The app employs a custom `CoreDataError` enumera@on. This enum categorizes poten@al
errors, such as:
- Errors related to fetching or saving city data.
- Errors related to fetching, saving, or upda@ng current weather data.
- Errors related to feedback opera@ons.
- Errors related to recommenda@on
- Errors related to Weather informa@on
These errors originate from CoreData level func@ons and are propagated by the respec@ve
ViewModels, which processes these errors and forwards them to the views. Based on the issue
that occurred during these opera@ons, the end user is no@fied of any issues via alerts that is
thoroughly descrip@ve, ensuring transparency and fostering trust.

# ** How to Run:**
## **System Requirements**
- iOS version: Ensure the latest iOS version is present (17+)
- Device: Compatible with iPhone and iPad (iOS Specific devices)
- API Keys (WEATHERAPI from Rapid API) : Requires API Key plugged into the Source Code to work (FREE VERSION AVAILABLE)
## **Launching the App**
- After installation, find the Torrent icon on your home screen.
- Tap on the icon to launch the app.
## **Granting Loca8on Services**
- For accurate weather data, the app requires access to your location.
- Upon launching for the first time, a prompt will ask for permission to access your
location. Tap "Allow" to grant this permission.
- **Note:** You can always modify these permissions later in the iOS Settings under the [Your
Weather App Name] section. If you decide to deny location access, certain
functionalities of the application will not be as robust. This includes real-time weather and
recommendations. Manual weather access will be func@onal as always.
