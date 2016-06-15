{Range} = require 'atom'
FunctionInfo = require './function-info'

module.exports =
class TextEditorParser
  constructor: (@textEditor = null) ->

  setEditor: (textEditor) ->
    @textEditor = textEditor

  getFileType: ->
    return null if not @textEditor?

    splitTitle = @textEditor.getTitle().split(".")
    return splitTitle[splitTitle.length - 1]

  getWordContainingCursor: ->
    return null if not @textEditor?

    initial = @textEditor.getCursorBufferPosition()

    @textEditor.moveToBeginningOfWord()
    start = @textEditor.getCursorBufferPosition()

    @textEditor.moveToEndOfWord()
    end = @textEditor.getCursorBufferPosition()

    @textEditor.setCursorBufferPosition(initial)

    return @textEditor.getTextInBufferRange(new Range(start, end))

  getFunctionInfo: (startingRow, isTabBased) ->
    initial = @textEditor.getCursorBufferPosition()

    openBrackets = 0
    currRow = startingRow
    endOfLineColumn = 0

    while true
      # get line text at current row
      line = @textEditor.lineTextForBufferRow(currRow)

      # determine end of line column
      @textEditor.setCursorBufferPosition([currRow, 0])
      @textEditor.moveToEndOfLine()
      endOfLineColumn = @textEditor.getCursorBufferPosition().column

      if line.includes "{"
        openBrackets++

      if line.includes "}"
        openBrackets--
        break if openBrackets is 0

      currRow++

    @textEditor.setCursorBufferPosition(initial)

    functionRange = new Range([startingRow, 0], [currRow, endOfLineColumn])
    functionText = @textEditor.getTextInBufferRange(functionRange)
    return new FunctionInfo(functionText, functionRange)
    #return @textEditor.getTextInBufferRange(functionRange)
