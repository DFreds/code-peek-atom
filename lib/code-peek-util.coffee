module.exports =
class CodePeekUtil
  constructor: () ->

  @getFileType: (editor) ->
    splitTitle = editor.getLongTitle().split(".")
    return splitTitle[splitTitle.length - 1]
