Cocoshop - Open Source Visual Editor for Cocos2D
================================================

```
    cocoshop
   
    Copyright (c) 2011 Andrew
    Copyright (c) 2011 Stepan Generalov
   
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
   
    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.
   
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
 
```

Features
=====================
In cocoshop you edit a node. Currently it supports background and sprites.  
You can change the size of the node, change it's background color & opacity.  
You can add sprites by drag&drop them to the main window, or by clicking 'Add Sprite' toolbar item.

Sprites have unique names, that you will use to distinguish individual sprites in your application code.
Sprites can be positioned/scaled/rotated with mouse, keyboard shortcuts, trackpad gestures and the Sprite Info Window.

How to use Cocoshop
=====================

 1. Prepare your sprites images. It's better to have csd and sprites in one folder.
 1. Launch cocoshop, set stage size, background color & opacity in Info Window.
 1. Drag&Drop your sprites to the Cocoshop's main window.
 1. After editing - save csd file and import folder with csd & sprites to your project.
 1. Import CSDReader.h, CSDReader.m, CSDElement.h, CSDElement.m to your project (located in 'CSDReader' folder)
 1. Load csd file & setup your node with CSDReader
 ```
	CSDReader *csd = [CSDReader readerWithFile:@"example1.csd"];
	CCNode *aNode = [csd newNode];
	[self addChild: aNode];
 ```
 1. Take a look at CSExample1.xcodeproj in this repo's root for more info about using CSDReader & CSDElement's


Keyboard Shortcuts
=====================

File
--------------------
 * CMD + N - New Project (Warning: no changes will be saved, save your work before creating new one)
 * CMD + O - Open existing CSD project
 * CMD + S - Save Project
 * CMD + SHIFT + S - Save As

View
--------------------
 * CMD + F - Toggle Fullscreen
 * CMD + B - Toggle Workspace Borders
 * CMD + 0 - Reset Zoom (you can zoom with CMD + MouseScroll)
 
Windows
-------------------
All cocoshop windows can be used in both fullscreen & windowed mode.
The only fullscreen issue is that if your project is bigger than your screen - you cannot scroll the node in fullscreen.
But you always can scroll it in windowed mode. (Issue #30 )

 * CMD + M - Main Editor Window
 * CMD + I - Sprite Info
 * CMD + L - Sprites List
 
Editing Sprites
-------------------




Philosophy
=====================