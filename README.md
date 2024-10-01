# AppKitFocusOverlay

A simple package for displaying the current focus (`nextKeyView`) target path for an AppKit window.

<p align="center">
    <img src="https://img.shields.io/github/v/tag/dagronf/AppKitFocusOverlay" />
    <img src="https://img.shields.io/badge/macOS-10.13+-purple" />
</p>

<p align="center">
   <a href="https://github.com/dagronf/dagronf.github.io/blob/master/art/projects/AppKitFocusOverlay/focus-before.png?raw=true">
	   <img src="https://github.com/dagronf/dagronf.github.io/blob/master/art/projects/AppKitFocusOverlay/focus-before.png?raw=true" width="400"/>
	</a>
   
   <a href="https://github.com/dagronf/dagronf.github.io/blob/master/art/projects/AppKitFocusOverlay/focus-after.png?raw=true">
	   <img src="https://github.com/dagronf/dagronf.github.io/blob/master/art/projects/AppKitFocusOverlay/focus-after.png?raw=true" width="400"/>
	</a>
</p>

* Press and hold `command-option-[` key to display the focus key path for the currently focussed window
* Press and hold `command-option-]` key to display the focus key path from the currently focussed UI element.

Supports both Swift and Objective-C projects.

## Why?

It's important for your app to be keyboard navigable and that the tab path makes sense to a user. There's been a bit of discussion of recent regarding keyboard navigation on iOS, [highlighting the `-UIFocusLoopDebuggerEnabled YES` launch argument option for iOS apps in Xcode.](https://twitter.com/stroughtonsmith/status/1473669534712274944?s=20). The question was posed as to whether this also worked for AppKit, and the short answer was no.

I built the prototype for this a few years back for use in my own apps. It's not as frictionless as adding a launch argument but it's straight forward enough to add. Given how useful it's been for me I thought I'd package it up cleanly and make it public.

## Demo

<a href="https://github.com/dagronf/dagronf.github.io/blob/master/art/projects/AppKitFocusOverlay/example.mp4?raw=true">Click here to see a demo video</a> of the focus overlay added to the wonderful '[ControlRoom](https://github.com/twostraws/ControlRoom)' application.

There are also very basic AppKit example applications (using both Swift and Objective-C) in the `Demo` subfolder you can play with.

## Simple setup

* Add the `https://github.com/dagronf/AppKitFocusOverlay` package to your application.

* Define a global instance of `AppKitFocusOverlay` in your app and access the instance within a method that gets called early in your app's lifecycle, such as `applicationDidFinishLaunching`.

```swift
import AppKitFocusOverlay
let _globalFocusOverlay = AppKitFocusOverlay()

func applicationDidFinishLaunching(_ aNotification: Notification) {
   // Force the focus overlay instance to init.
   _ = _globalFocusOverlay
   ...
}
```

## Features

### Custom hotkeys

You can define the hotkeys to use in the initializer of the instance. By default, these are `command-option-[` and `command-option-]`, but you can change them to `f13` and `f14` (for example) if you want.

Note that as of macOS 15.0 Sequoia [shortcuts _must_ include a modifier that isn't shift or option](https://developer.apple.com/forums//thread/763878?src=push&answerId=804374022#804374022) 

> This was an intentional change in macOS Sequoia to limit the ability of key-logging malware to observe keys in other applications. The issue of concern was that shift+option can be used to generate alternate characters in passwords, such as Ø (shift-option-O).
> 
> There is no workaround; macOS Sequoia now requires that a hotkey registration use at least one modifier that is not shift or option.

#### Example

```swift
import AppKitFocusOverlay
import HotKey               // Available due to AppKitFocusOverlay dependency 

let _globalFocusOverlay: AppKitFocusOverlay(
   windowHotKey: HotKey(key: .f13, modifiers: []),
   viewHotKey: HotKey(key: .f14, modifiers: [])
)

func applicationDidFinishLaunching(_ aNotification: Notification) {
   // Force the focus overlay instance to init.
   _ = _globalFocusOverlay
   ...
}
```

### Objective-C support

You can add `AppKitFocusOverlay` to your Objective-C project easily.

```objc
@import AppKitFocusOverlay;

@interface AppDelegate ()
/// Define an instance of the focus overlay
@property (nonatomic, strong) AppKitFocusOverlay* focusOverlay;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification*)aNotification {
   /// Create the overlay and attach
   AppKitFocusOverlay* focus = [[AppKitFocusOverlay alloc] init];
   [self setFocusOverlay: focus];
}

@end
```

#### Notes

* You may need to embed the swift libraries (Build settings) if your app doesn't already if you're planning to distribute an archive or release build to (eg.) your QA dept.
* If you need to customize the hotkeys for objective-c you'll need to fork this library and change the code in `AppKitFocusOverlay.swift`, as the HotKey library is not exposed through Objective-C and as such the hotkey-setting initializers are not exposed to objc.

# Screenshots

<img src="https://github.com/dagronf/dagronf.github.io/blob/master/art/projects/AppKitFocusOverlay/qr-example.jpg?raw=true" width="600"/>

<img src="https://github.com/dagronf/dagronf.github.io/blob/master/art/projects/AppKitFocusOverlay/custom-tabbing-order-objc.jpg?raw=true" width="380"/>


# Thanks!

Uses [HotKey](https://github.com/soffes/HotKey) to define and detect hot-key presses.

# License

## AppKitFocusOverlay

```
MIT License

Copyright (c) 2024 Darren Ford

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## HotKey

```
Copyright (c) 2017–2019 Sam Soffes, http://soff.es

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```
