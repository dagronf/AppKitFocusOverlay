# AppKitFocusOverlay

A simple package for displaying the current focus target path for an AppKit window.

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

* Press and hold `option-[` key to display the focus key path for the currently focussed window
* Press and hold `option-]` key to display the focus key path from the currently focussed UI element.

## Demo

<a href="https://github.com/dagronf/dagronf.github.io/blob/master/art/projects/AppKitFocusOverlay/example.mp4?raw=true">Click here to see a demo video</a> of the focus overlay added to the wonderful '[ControlRoom](https://github.com/twostraws/ControlRoom)' application.

There is also a very basic AppKit example application in the `Demo` subfolder you can play with

## Simple setup

Define a global instance of `AppKitFocusOverlay` in your app and access the instance within a method that gets called early in your app's lifecycle, such as `applicationDidFinishLaunching`.

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

You can define the hotkeys to use in the initializer of the instance. By default, these are `option-[` and `option-]`, but you can change them to `f13` and `f14` (for example) if you want.

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

# Screenshots

<img src="https://github.com/dagronf/dagronf.github.io/blob/master/art/projects/AppKitFocusOverlay/qr-example.jpg?raw=true" width="600"/>

# Thanks!

Uses [HotKey](https://github.com/soffes/HotKey) to define and detect hot-key presses.

# License

MIT. Use it for anything you want, just attribute my work if you do. Let me know if you do use it somewhere, I'd love to hear about it!

```
MIT License

Copyright (c) 2021 Darren Ford

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
