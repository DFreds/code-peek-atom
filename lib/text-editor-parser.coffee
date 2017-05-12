{Range} = require 'atom'

module.exports =
class TextEditorParser
  constructor: (@textEditor) ->

  getFileType: ->
    return null if not @textEditor?

    splitTitle = @textEditor.getTitle().split(".")

    if splitTitle.length > 1
      return splitTitle[splitTitle.length - 1]
    else
      return null

  getGrammarName: ->
    return null if not @textEditor?
    return @textEditor.getGrammar().name.replace("semanticolor - ", "")

  getWordContainingCursor: ->
    initial = @textEditor.getCursorBufferPosition()

    @textEditor.moveToBeginningOfWord()
    start = @textEditor.getCursorBufferPosition()

    @textEditor.moveToEndOfWord()
    end = @textEditor.getCursorBufferPosition()

    @textEditor.setCursorBufferPosition(initial)

    return @textEditor.getTextInBufferRange(new Range(start, end))
