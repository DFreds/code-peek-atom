# Code Peek

This package allows you to quickly peek and edit functions contained in other
files instead of having to open the file separately. This was inspired by
[Brackets](http://brackets.io/)' quick edit feature and Maushundb's [Quick Editor](https://atom.io/packages/quick-editor) for CSS/LESS/SCSS.

![Code Peek Demo](https://github.com/DFreds/code-peek-atom/blob/master/code-peek.gif?raw=true)

# Supported Files
Currently, supported files include:
* JavaScript
* ES6
* TypeScript
* JSX
* PHP
* Java
* C#
* Python
* Coffee
* Ruby

## Adding A Language
If you'd like to add your own language, send me a regex string or make a pull request that adds one that will correctly find the first line of a function using a known name for that language in all cases. Currently, Code Peek supports languages that use curly brackets to indicate the start and end of a function as well as tab based languages such as Python.

Examples for a function called REPLACE:
* JS/ES6 - /function\s\+REPLACE\s\*\(|REPLACE\s\*(=|:)\s\*function\s\*\\(|REPLACE\s\*([=:])?\s\*\\(?\s\*\\(([\,\s\w]\*)?\\)?\s*=>/
* TS - /function\s\+REPLACE\s\*\(|REPLACE\s\*(=|:)\s\*function\s\*\\(/
* JSX - /function\s\+REPLACE\s\*\(|REPLACE\s\*(=|:)\s\*function\s\*\\(/
* PHP - /function\s\+REPLACE\s\*\\(/
* Java - /((public|private|protected|static|final|native|synchronized|abstract|transient)+\s)+[\$_\w\<\\>\\[\\]\,\s]*\s+REPLACE\\(/
* C# - /((public|private|protected|static|readonly|override|abstract|virtual|async)+\s)+[\$_\w\<\\>\\[\\]\,\s]\*\s+REPLACE\\(/
* Python - /def\s\+REPLACE\s\*\(/
* Coffee - /REPLACE\s\*(:|=)\s\*(\\([\,\s\w]\*\\))?\s\*(=>|->)/
* Ruby - /def\s\+(self\\.)?REPLACE/

# Installation
```
apm install code-peek
```
Or search for <code>code-peek</code> in the Atom settings view.

# Configuration

### Ask If Save On Modified
By default, clicking the "Close without saving" button after a file is modified using Code Peek will ask the user if they want to save their changes. This configuration option can be toggled off to stop the dialogue box from appearing.

### Code Peek Location
This setting dictates where the Code Peek panel should appear. By default, it will appear at the bottom of the screen. Additional options include top, left, right, header, footer, and modal.

### Max Height
By default, the maximum height of the Code Peek panel is 300px. This configuration option can be set to change the height, and supports a range from 200px to 800px. This only affects panels where the location is top, bottom, header, footer, or modal.

### Max Width
By default, the maximum width of the Code Peek panel is 500px. This configuration option can be set to change the width, and supports a range from 200px to 1000px. This only affects panels where the location is left or right.

# Key Bindings
The default <code>cmd-alt-e</code> or <code>ctrl-alt-e</code> will toggle code-peek while the cursor is over a function of a supported type.

This can be edited by defining key bindings as shown below.

```coffee
'.platform-darwin atom-text-editor':
  'cmd-alt-e': 'code-peek:peekFunction'
  'shift-escape': 'code-peek:toggleCodePeekOff'

'.platform-linux atom-text-editor, .platform-win32 atom-text-editor':
  'ctrl-alt-e': 'code-peek:peekFunction'
  'shift-escape': 'code-peek:toggleCodePeekOff'
```

### Full change log [here](./CHANGELOG.md).
