# gps4camera

This little app is, at the heart, just a GPS track recorder.   While it's recording tracks, it has all the data necessary to show movement information.  So a bike computer-like screen was added (although it should work for cars and other vehicles).  In addition, there is a screen which shows the current date and time along with a QR code.  Both are updated once a second.  Use your camera to take a picture of the screen and this can be used to sync the phone time with the photos from the camera.  Note, this app does NOT sync the phone's time directly with the camera.  The idea is to take a photo with the QR code, parse the QR code and sync the QR code photo's time with the timestamp embedded in the QR code.  A secondary script will likely be created to automate this process.  

### App Features:
* Bike computer-like display, showing speed, heading, altitude, elapsed time, current time, etc
* QR code + date/time screen to be used to sync photos' timestamps to the date/time of the phone
* List and remove tracks
* Tap a track to view the track on a map
* Export and share a track to KML or GPX to any services available on the phone such as email, files, etc.
* Settings available to adjust units of measure

### Project Features:
* Dependency injection
* MVVM architecture
* ReactiveKit (Rx) Swift used between view models and controllers
* AppDelegate uses the service design pattern
* CoreData used to store tracks
* Network API uses Apple's NSURLSession


### Screen Shots

GPS View | QR Code | Map View
--- | --- | ---
<img src="https://raw.githubusercontent.com/rsbauer/gps4camera/master/images/gps.png" width="300"> | <img src="https://raw.githubusercontent.com/rsbauer/gps4camera/master/images/qr.png" width="300"> | <img src="https://raw.githubusercontent.com/rsbauer/gps4camera/master/images/map.png" width="300">

### Usage

#### qrfinder

The latest version can be found here: https://github.com/rsbauer/gps4camera/releases/ and look for the zip file with "qrfinder" in the name.  

You can put this in the same directory as the photos you wish to update.  Although it may be better to put it in /usr/local/bin so it'll be available from any directory.

qrfinder will need exiftool.  Exiftool can be found and installed from https://exiftool.org/

Once qrfinder and exiftool have been installed, you would run something like this:

`qrfinder [directory of the files you'd like to update] [image extension to search]`

or something like this:

`qrfinder /Users/rob/Pictures/today JPG`

(replace the directory and file extension with ones you use) 

Make sure you have either a gpx or kml file with the gps coordinates in the same directory.  Otherwise, the script will not make any changes.

## Development 

### Getting Started

You will need the source code from here and the latest Xcode installed.  

Although CocoaPods was used, the author added the Pods directory to the repository in case a pod is no longer avaialbe and to ease onboarding.  

If desired, pods can be installed: (this requiers CocoaPods to be installed)

  `pod install`

### Prerequisites

Before starting, you will need Cocoapods installed.  

1. Clone this repo

  `git clone [this repo url]`

2. Install pods

  `pod install`

5. Open the gps4camera.xcworkspace

  `open gps4camera.xcworkspace`

6. Build!

## Running the tests

From Xcode, select the Test Navigator and select all tests or individual tests.  
 
## Deployment

Deployments are ad hoc at this time.

### License

See LICENSE file located in this repository.

