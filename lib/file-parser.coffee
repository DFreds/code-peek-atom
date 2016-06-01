{Range} = require 'atom'

module.exports =
class FileParser
  constructor: (@textEditor = null) ->

  setEditor: (textEditor) ->
    @textEditor = textEditor

  getFileType: ->
    return null if not @textEditor?

    splitTitle = @textEditor.getLongTitle().split(".")
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

  getEntireFunction: (startingRow) ->
    initial = @textEditor.getCursorBufferPosition()
    line = @textEditor.lineTextForBufferRow(startingRow)

    bracketArr = []
    passThroughs = 0

    currRow = startingRow
    currCol = 0
    while true
      if line.includes "{" and line.includes "}"
        # do nothing
      else if line.includes "{"
        bracketArr.push("")
      else if line.includes "}"
        bracketArr.pop()

      break if bracketArr.length is 0 and passThroughs isnt 0

      currRow = currRow + 1
      line = @textEditor.lineTextForBufferRow(currRow)

      @textEditor.setCursorBufferPosition([currRow, 0])
      @textEditor.moveToEndOfLine()

      currCol = @textEditor.getCursorBufferPosition().column
      passThroughs = passThroughs + 1

    @textEditor.setCursorBufferPosition(initial)
    return @textEditor.getTextInBufferRange(new Range([startingRow, 0], [currRow, currCol]))
