## 1.4.18 - ES6 class shorthand method support
* Adds support for methodName() {} style es6 functions - Thanks jonyeezs!

## 1.4.17 - Semanticolor support
* Adds support for semanticolor grammars - Thanks glammers and marnen!

## 1.4.16 - Bug fixes
* Fixed issue where exception was thrown when grammar type of file was not set - Thanks crostine!
* Fixed issue where function would not be peeked if file did not have an extension but had a grammar type

## 1.4.15 - Find functions based on grammar type
* Code Peek now looks at the grammar type to determine how to find the function instead of the file type. For instance, if you were using the extension type .es6 before, Code Peek would complain that it doesn't support it. Now, it will see that the grammar is JavaScript and use that to match. Thanks tongjieme!

## 1.4.14 - Bug fix
* Fixed typo in save dialogue

## 1.4.13 - Add Go language support
* Support for Go functions - Thanks krohnjw!

## 1.4.12 - Configuration setting
* Added configuration to specify paths that code peek should ignore

## 1.4.11 - Bug fix
* Fixed issue where peeking a function name that contained regular expression characters was throwing an error

## 1.4.10 - Added ES6 function support
* Support for ES6 style functions

## 1.4.9 - Behavior changes and UI fix
* Code Peek closes when opening entire file when there is only one matching file - Thanks ProLoser
* Fixed styling on matching files list. Shouldn't take up as much room now. Thanks ProLoser

## 1.4.8 - Ruby regular expression fix
* Extend Ruby support to include class methods defined with self - Thanks michael-garland

## 1.4.7 - Ruby support
* Support for Ruby - Thanks goronfreeman

## 1.4.6 - Bug fix, new shortcut
* Fixed bug where the editor would scroll down on hitting the spacebar if the function was too long.
* Added shortcut to exit without saving (escape by default). It will be the same as the core:cancel shortcut.

## 1.4.5 - Java and C# regular expressions
* Fixed bug with the Java and C# regular expression. Should now find any and all Java and C# functions.

## 1.4.4 - Configuration settings
* Added configuration setting to specify maximum width of the panel. Ranges from 200px to 1000px, with 500px being the default. Only applies when location is left or right
* Fixed issue with C#/Java regex where it was finding usages of functions, not just the declarations

## 1.4.3 - Configuration settings
* Added configuration to specify location of code peek panel. Options include bottom (default), top, left, right, header, footer, and modal
* Added configuration setting to specify maximum height of the panel. Ranges from 200px to 800px, with 300px being the default. Only applies when location is top, bottom, header, footer, or modal.

## 1.4.2 - Python and CoffeeScript support
* Support for Python
* Support for CoffeeScript

## 1.4.1 - Minor bug fix
* Fixed issue where opening code peek on a function that had multiple matches before opening another code peek on a function that only had one match would reopen the previous code peek if the single file was clicked in the matching files list

## 1.4.0 - Matching files listing
* Added matching files list that allows quick switching between all files that have a match

## 1.3.0 - UI changes, configuration setting
* Added check icon to save and close file
* Added code icon to view entire file that contains function
* Added configuration for asking if sure when a file is modified and the code peek panel is closed without saving

## 1.2.0 -  UI changes, JSX support
* Support for JSX
* Fixed minor issue with TS regex
* Workaround for issue where Code Peek would fail if it found a match in a modified file. This was caused by an [Atom bug](https://github.com/atom/atom/issues/10900).
* Style changes
* User is now asked if they want to save changes to modified code peek function

## 1.1.1 - PHP support
* Support for PHP
* Simplified Java and C# regex expressions

## 1.1.0 - Close without saving button
* Added icon that closes code peek and discards changes to opened function
* Using shift+escape will save changes

## 1.0.1 - Better parsing for C#/Java
* Fixed C#/Java parser so that it will find protected functions
* Fixed C#/Java parser so it can find functions with typed returns

## 1.0.0 - First Release
* Support for JavaScript, TypeScript, Java, and C#
