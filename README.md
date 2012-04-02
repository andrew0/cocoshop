__NOTE: Cocoshop is no longer being maintained, as it has been superseded by SceneDesigner ( https://github.com/andrew0/SceneDesigner ).__
-

Cocoshop - Open Source Visual Editor for Cocos2D
================================================

Cocoshop is a tiny, easy to use visual editor for Cocos2D-iPhone Engine, that
can be used for designing menus, game scenes and even levels.

```   
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

Philosophy
=====================
Cocoshop idea is to have minimum can't-live-without features, that will let developers easily create graphics part of cocos2d projects.  
If some feature of Cocos2D can be supported only by CSDReader - it shouldn't be included in Cocoshop.  
I.E. spriteSheets - a lot of work needed to add & debug CCSpriteBatchNode support to Cocoshop Editor.  
It's much easier just to load sprites with CSDReader using spriteBatchNode in your project.  
(Example: https://github.com/andrew0/cocoshop/blob/release-0.1/CSExamples/Classes/CSDTests.m#L211 )  

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
 *Note: Take a look at CSExample1.xcodeproj in this repo's root for more info about using CSDReader & CSDElement's*


Keyboard Shortcuts
=====================

File
--------------------
 * __CMD + N__ - New Project (Warning: no changes will be saved, save your work before creating new one)
 * __CMD + O__ - Open existing CSD project
 * __CMD + S__ - Save Project
 * __CMD + SHIFT + S__ - Save As

View
--------------------
 * __CMD + F__ - Toggle Fullscreen
 * __CMD + B__ - Toggle Workspace Borders
 * __CMD + 0__ - Reset Zoom (you can zoom with CMD + MouseScroll)
 
Windows
-------------------
All cocoshop windows can be used in both fullscreen & windowed mode.  
The only fullscreen issue is that if your project is bigger than your screen - you cannot scroll the node in fullscreen.  
But you always can scroll it in windowed mode. (Issue #30 )

 * __CMD + M__ - Main Editor Window
 * __CMD + I__ - Sprite Info
 * __CMD + L__ - Sprites List
 
Editing Sprites
-------------------
To use these combinations you need to select some sprite.

 * __Arrows__ - move sprite by one point in any direction.
 * __SHIFT + Arrows__ - move sprite faster.
 * __ALT + Arrows__ - move sprite's anchorPoint
 * __ALT + SHIFT + Arrows__ - move sprite's anchorPoint faster
 * __CTRL + Left/Right Arrows__ - rotate sprite left/right
 * __CTRL + SHIFT + Left/Right Arrows__ - rotate sprite faster.
 * __Backspace__ or __Delete__ - Remove Selected Sprite.
 * __CMD+C__ - Copy Selected Sprite
 * __CMD+V__ - Paste Sprite
 * __CMD+X__ - Cut Selected Sprite
 
Mouse
=====================
In cocoshop you can move and select sprites with mouse.  
Currently to rotate sprites with mouse you need to use sprite info window.

Trackpad Gestures
=====================
Cocoshop supports these trackpad gestures:  

 * Pinch - Scale Selected Sprite
 * Rotate - Rotate Selected Sprite
 
Repo Contents
=====================

 * cocoshop.xcodeproj - Cocoshop Project
 * CSExample1.xcodeproj - Cocos2d-iOS Cocoshop Examples
 * Files to inlcude to your Project
   1. CSDReader - CSD File Support.
   2. Cocos2DExtensions - Different Handy Classes, used in CSExamples. Makes your life easier.
 * libs - Cocos2d Engine 1.0.0-rc2 from Mac Template used in cocoshop.xcodeproj.
 * CSExamples/libs - Cocos2d Engine 1.0.0-rc2 from iOS Template used in CSExample1.xcodeproj

Contributing
=====================
Feel free to fork, modify & send pull requests as usual ;)  
There's always some issues to solve here: https://github.com/andrew0/cocoshop/issues  
You can also use them to see, what's on cocoshop's roadmap.  

 