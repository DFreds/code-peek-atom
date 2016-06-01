{Range} = require 'atom'

module.exports =
class CodePeekUtil
  constructor: () ->

  @getFileType: (editor) ->
    splitTitle = editor.getLongTitle().split(".")
    return splitTitle[splitTitle.length - 1]

  @getWordContainingCursor: (editor) ->
    initial = editor.getCursorBufferPosition()

    editor.moveToBeginningOfWord()
    start = editor.getCursorBufferPosition()

    editor.moveToEndOfWord()
    end = editor.getCursorBufferPosition()

    editor.setCursorBufferPosition(initial)

    console.log "Start is #{start} and end is #{end}"
    console.log "Text editor content is #{editor.getText()}"

    return editor.getTextInBufferRange(new Range(start, end))

  @getEntireFunction: (editor, startingRow) ->
    line = editor.lineTextForBufferRow(startingRow)

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
      line = editor.lineTextForBufferRow(currRow)

      editor.setCursorBufferPosition([currRow, 0])
      editor.moveToEndOfLine()

      currCol = editor.getCursorBufferPosition().column
      passThroughs = passThroughs + 1

    return editor.getTextInBufferRange(new Range([startingRow, 0], [currRow, currCol]))
