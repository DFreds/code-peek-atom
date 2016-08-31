module.exports =
class SupportedFiles
  @types =
    'js':
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
      ///
      isTabBased: false

    'ts':
      regExp: ///
        # matches 'function REPLACE('
        function \s+ REPLACE \s* \(
          # or
          |
        # matches 'REPLACE = function (' or 'REPLACE: function ('
        REPLACE \s* (=|:) \s* function \s* \(
      ///
      isTabBased: false

    'jsx':
      regExp: ///
        # matches 'function REPLACE('
        function \s+ REPLACE \s* \(
          # or
          |
        # matches 'REPLACE = function (' or 'REPLACE: function ('
        REPLACE \s* (=|:) \s* function \s* \(
      ///
      isTabBased: false

    'php':
      regExp: ///
        # matches 'function REPLACE ('
        function \s+ REPLACE \s* \(
      ///
      isTabBased: false

    'coffee':
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

    'py':
      regExp: ///
        # matches 'def REPLACE('
        def \s+ REPLACE \s* \(
      ///
      isTabBased: true

    'rb':
      regExp: ///
        # matches 'def'
        def \s+

        # optionally matches 'self.'
        (self\.)?

        # match REPLACE
        REPLACE
      ///
      isTabBased: true

    'java':
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

    'cs':
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

  @isSupported: (fileType) ->
    if @types[fileType]? then return true else return false

  @isTabBased: (fileType) ->
    if @types[fileType]?
      return @types[fileType].isTabBased
    else
      return false

  @getFunctionRegExpForFileType: (fileType, functionName) ->
    if not @types[fileType] then throw new Error "File type #{fileType} is not \
      supported"

    # get the regular expression for the file type
    regExp = @types[fileType].regExp

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
