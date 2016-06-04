module.exports =
class SupportedFiles
  @types =
    'js':
      regExpStr: 'function\\s*REPLACE\\s*\\(|
        var\\s*REPLACE\\s*=\\s*function\\s*\\('
    'java':
      regExpStr: '(private|public)\\s*\\w*\\s*REPLACE\\s*\\('

  @isSupported: (fileType) ->
    if @types[fileType]? then return true else return false

  @getFunctionRegExpForFileType: (fileType, functionName) ->
    if not @types[fileType] then throw new Error "File type #{fileType} is not \
      supported"

    regExpStr = @types[fileType].regExpStr
    return new RegExp(regExpStr.replace /REPLACE/g, functionName)
