module.exports =
class SupportedFiles
  @types =
    'JavaScript':
      regExp: ///
        # matches 'function REPLACE('
        function \s+ REPLACE \s* \(
          # or
          |
        # matches 'REPLACE = function (' or 'REPLACE: function ('
        REPLACE \s* (=|:) \s* function \s* \(
          # or
          |
        # matches es6 style functions
        REPLACE \s* ([=:])? \s* \(? \s* \( ([\,\s\w]*)? \)? \s* =>
          # or
          |
        # matches REPLACE(args) {}
        REPLACE\(? \s* \( ([\,\s\w]*)? \) \s* {
      ///
      isTabBased: false

    'TypeScript':
      regExp: ///
        # class
        class \s+ REPLACE(
          \s+ extends\s+ [_$a-zA-Z\xA0-\uFFFF][_$a-zA-Z0-9\xA0-\uFFFF]* |
        ) \s+ {
          # or
          |
        # matches 'function REPLACE('
        function \s+ REPLACE \s* \(
          # or
          |
        # matches 'REPLACE = function (' or 'REPLACE: function ('
        REPLACE \s* (=|:) \s* function \s* \(
          # or
          |
        # function:
        (private|protected|public)? (static)? \s+ REPLACE \s* \(
          # or
          |
        # interface
        interface \s+ REPLACE \s* {
      ///
      isTabBased: false

    'TypeScriptReact':
      regExp: ///
        # class
        class \s+ REPLACE(
          \s+ extends\s+ [_$a-zA-Z\xA0-\uFFFF][_$a-zA-Z0-9\xA0-\uFFFF]* |
        ) \s+ {
          # or
          |
        # matches 'function REPLACE('
        function \s+ REPLACE \s* \(
          # or
          |
        # matches 'REPLACE = function (' or 'REPLACE: function ('
        REPLACE \s* (=|:) \s* function \s* \(
          # or
          |
        # function:
        (private|protected|public)? (static)? \s+ REPLACE \s* \(
          # or
          |
        # interface
        interface \s+ REPLACE \s* {
      ///
      isTabBased: false

    'Go':
      regExp: ///
        # Matches func REPLACE( or func (t target) REPLACE(
        func\s+(|\(.*\)\s+)REPLACE\(
      ///
      isTabBased: true

    'JavaScript (JSX)':
      regExp: ///
        # matches 'function REPLACE('
        function \s+ REPLACE \s* \(
          # or
          |
        # matches 'REPLACE = function (' or 'REPLACE: function ('
        REPLACE \s* (=|:) \s* function \s* \(
          # or
          |
        # matches REPLACE(args) {}
        REPLACE\(? \s* \( ([\,\s\w]*)? \) \s* {
      ///
      isTabBased: false

    'PHP':
      regExp: ///
        # matches 'function REPLACE ('
        function \s+ REPLACE \s* \(
      ///
      isTabBased: false

    'CoffeeScript':
      regExp: ///
        # matches 'REPLACE: ' or 'REPLACE ='
        REPLACE \s* (:|=) \s*
        # optionally matches any arguments
        (
          \( [\, \s \w]* \)
        ) ?
        # matches '->' or '=>' to end the function
        \s* (=>|->)
      ///
      isTabBased: true

    'Python':
      regExp: ///
        # matches 'def REPLACE('
        def \s+ REPLACE \s* \(
      ///
      isTabBased: true

    'Ruby':
      regExp: ///
        # matches 'def'
        def \s+

        # optionally matches 'self.'
        (self\.)?

        # match REPLACE
        REPLACE
      ///
      isTabBased: true

    'Java':
      regExp: ///
        # match one or more of the following
        (
          # match one or more attributes
          (public|private|protected|static|final|
          native|synchronized|abstract|transient)+
          \s
        )+

        # match $ _ < > [ ] , whitespace or a word any number of times
        [\$_\w\<\>\[\]\,\s]*

        # any whitespace character one or more times
        \s+

        # match REPLACE
        REPLACE

        # match ( exactly
        \(
      ///
      isTabBased: false

    # 'c':
    #   regExp: ''
    #   isTabBased: false

    # 'cpp':
    #   regExp: ''
    #   isTabBased: false

    'C#':
      regExp: ///
        # match one or more of the following
        (
          # match one or more attributes
          (public|private|protected|static|readonly|
          override|abstract|virtual|async)+
          \s
        )+

        # match $ _ < > [ ] , whitespace or a word any number of times
        [\$_\w\<\>\[\]\,\s]*

        # any whitespace character one or more times
        \s+

        # match REPLACE
        REPLACE

        # match ( exactly
        \(
      ///
      isTabBased: false

    'R':
      regExp: ///
        REPLACE \s* <- \s* function \s* \(
          # or
          |
        REPLACE \s* = \s* function \s* \(
      ///
      isTabBased: false

  @isTabBased: (grammarName) ->
    if @types[grammarName]?
      return @types[grammarName].isTabBased
    else
      return false

  @getRegExpForGrammarName: (grammarName, functionName) ->
    if not @types[grammarName]?
      return

    # get the regular expression for the file type
    regExp = @types[grammarName].regExp

    # convert to string so we can replace
    regExpStr = regExp.toString()

    # escape the function name to avoid exceptions with special characters
    functionName = functionName.replace /[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g,
      "\\$&"

    # change all occurances of REPLACE placeholder to the actual function name
    regExpStr = regExpStr.replace /REPLACE/g, functionName

    # get rid of leading and ending slashes or else they will be escaped
    # when converting back to a regular expression
    regExpStr = regExpStr.replace /\//g, ""

    # convert back to regular expression
    return new RegExp(regExpStr)
