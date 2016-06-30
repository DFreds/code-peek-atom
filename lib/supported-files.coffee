module.exports =
class SupportedFiles
  @types =
    'js':
      regExp: ///
        # matches 'function REPLACE('
        function \s* REPLACE \s* \(

          # or
          |

        # matches 'REPLACE = function (' or 'REPLACE: function ('
        REPLACE \s* (=|:) \s* function \s* \(
      ///
      isTabBased: false

    'ts':
      regExp: ///
        # matches 'function REPLACE('
        function \s* REPLACE \s* \(

          # or
          |

        # matches 'REPLACE = function (' or 'REPLACE: function ('
        REPLACE \s* (=|:) \s* function \s* \(
      ///
      isTabBased: false

    'jsx':
      regExp: ///
        # matches 'function REPLACE('
        function \s* REPLACE \s* \(

          # or
          |

        # matches 'REPLACE = function (' or 'REPLACE: function ('
        REPLACE \s* (=|:) \s* function \s* \(
      ///
      isTabBased: false

    'php':
      regExp: ///
        # matches 'function REPLACE ('
        function \s* REPLACE \s* \(
      ///
      isTabBased: false

    'coffee':
      # TODO simplify
      regExp: ///
        (
          REPLACE \s* (:|=) \s* \( [\, \s \w]* \) \s* (=>|->)
        )
          |
        (
          REPLACE \s* (:|=) \s* (=>|->)
        )
      ///
      isTabBased: true

    'py':
      regExp: ///
        # matches 'def REPLACE('
        def \s* REPLACE \s* \(
      ///
      isTabBased: true

    'java':
      #regExp: '(public|private|protected)\\s*[\\w\\s\\S]*REPLACE\\s*\\('
      regExp: ///
        # matches public or private or protected)
        (public|private|protected) \s*
        # matches any type of return value or function property
        [\w\s\S]*
        # matches 'REPLACE ('
        REPLACE \s* \(
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
        # matches public or private or protected)
        (public|private|protected) \s*
        # matches any type of return value or function property
        [\w\s\S]*
        # matches 'REPLACE ('
        REPLACE \s* \(
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

    # change all occurances of REPLACE placeholder to the actual function name
    regExpStr = regExpStr.replace /REPLACE/g, functionName

    # get rid of leading and ending slashes or else they will be escaped
    # when converting back to a regular expression
    regExpStr = regExpStr.replace /\//g, ""

    # convert back to regular expression
    return new RegExp(regExpStr)
