# Code Peek

This package allows you to quickly peek and edit functions contained in other
files instead of having to open the file separately. This was inspired by
[Brackets](http://brackets.io/)' quick edit feature and Maushundb's [Quick Editor](https://atom.io/packages/quick-editor) for CSS/LESS/SCSS.

![Code Peek Demo](https://github.com/DFreds/code-peek-atom/blob/master/code-peek.gif?raw=true)

# Supported Files
Currently, supported files include:
* JavaScript
* TypeScript
* JSX
* PHP
* Java
* C#
* Python
* Coffee

More will be coming soon.

## Adding A Language
If you'd like to add your own language, send me a regex string or make a pull request that adds one that will correctly find the first line of a function using a known name for that language in all cases. Currently, Code Peek supports languages that use curly brackets to indicate the start and end of a function as well as tab based languages such as Python.

Examples for a function called REPLACE:
* JS - /function\s\*REPLACE\s\*\(|REPLACE\s\*(=|:)\s\*function\s\*\\(/
* TS - /function\s\*REPLACE\s\*\(|REPLACE\s\*(=|:)\s\*function\s\*\\(/
* JSX - /function\s\*REPLACE\s\*\(|REPLACE\s\*(=|:)\s\*function\s\*\\(/
* PHP - /function\s\*REPLACE\s\*\\(/
* Java - /(public|private|protected)\s\*[\w\s\S]\*REPLACE\s\*\\(/
* C# - /(public|private|protected)\s\*[\w\s\S]\*REPLACE\s\*\\(/
* Python - /def\s\*REPLACE\s\*\(/
* Coffee - (REPLACE\s\*(:|=)\s\*\\([\\,\s\w]\*\\)\s\*(=>|->))|(REPLACE\s\*(:|=)\s\*(=>|->))

# Installation
```
apm install code-peek
```
Or search for <code>code-peek</code> in the Atom settings view.

# Key Bindings
The default <code>cmd-alt-e</code> or <code>ctrl-alt-e</code>will toggle code-peek while the cursor is over a function of a supported type.

This can be edited by defining key bindings as shown below.

```coffee
'.platform-darwin atom-text-editor':
  'cmd-alt-e': 'code-peek:peekFunction'
  'shift-escape': 'code-peek:toggleCodePeekOff'

'.platform-linux atom-text-editor, .platform-win32 atom-text-editor':
  'ctrl-alt-e': 'code-peek:peekFunction'
  'shift-escape': 'code-peek:toggleCodePeekOff'

```

# Coming Soon
* Additional language support
  * HTML/CSS
  * C++ (standard style function definitions)
  * C

### Full change log [here](./CHANGELOG.md).
