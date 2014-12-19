# VLCX

VLCX is basically QuickTime Player, but with libvlc as a backend. The interface aims to be pretty much identical to QuickTime's, but there's still a lot to do to get there.

## Screenshots

### Playing a Video

![screenshot](https://raw.githubusercontent.com/insidegui/VLCX/master/releases/screenshots/screenshot.png)

### Playing a Song

![screenshot2](https://raw.githubusercontent.com/insidegui/VLCX/master/releases/screenshots/screenshot2.png)

### Color Adjustments Panel

![screenshot3](https://raw.githubusercontent.com/insidegui/VLCX/master/releases/screenshots/screenshot3.png)

## Using

If you just want to use VLCX, [download the latest release here](https://github.com/insidegui/VLCX/blob/master/releases/VLCX_latest.zip?raw=true).

## Building

To build VLCX from the source, get a copy of VLCKit.framework [here](https://wiki.videolan.org/VLCKit/).

The app also uses Sparkle for updating, you can learn more abour Sparkle [here](https://github.com/sparkle-project/Sparkle).
If you are going to release the app, you must change the SUFeedURL key in the Info.plist to point to your appcast, or just remove the auto-update feature entirely.

I'm also using Crashlytics to track usage/crashes, if you want to release the app and use Crashlytics, you must create a Config.h file and set your apikey like `#define CRASHLYTICS_API_KEY @"your-crashlytics-apikey-here"`.
If you're not using Crashlytics, comment out line `15` in `AppDelegate.m`.