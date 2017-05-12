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
    'TypeScript':
      regExp: ///
        # matches 'function REPLACE('
        function \s+ REPLACE \s* \(
          # or
          |
        # matches 'REPLACE = function (' or 'REPLACE: function ('
        REPLACE \s* (=|:) \s* function \s* \(
      ///

    'TypeScriptReact':
      regExp: ///
        # matches 'function REPLACE('
        function \s+ REPLACE \s* \(
          # or
          |
        # matches 'REPLACE = function (' or 'REPLACE: function ('
        REPLACE \s* (=|:) \s* function \s* \(
      ///

    'Go':
      regExp: ///
        # Matches func REPLACE( or func (t target) REPLACE(
        func\s+(|\(.*\)\s+)REPLACE\(
      ///

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

    'PHP':
      regExp: ///
        # matches 'function REPLACE ('
        function \s+ REPLACE \s* \(
      ///

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

    'Python':
      regExp: ///
        # matches 'def REPLACE('
        def \s+ REPLACE \s* \(
      ///

    'Ruby':
      regExp: ///
        # matches 'def'
        def \s+

        # optionally matches 'self.'
        (self\.)?

        # match REPLACE
        REPLACE
      ///

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
