module.exports =
class CodePeekUtil
  constructor: () ->

  @getFileType: (editor) ->
    splitTitle = editor.getLongTitle().split(".")
    return splitTitle[splitTitle.length - 1]

  @getFunctionName: (editor, pos) ->

  @findInProject: (functionName) ->
