{Range} = require 'atom'
FunctionInfo = require './data/function-info'

module.exports =
class TextEditorParser
  constructor: (@textEditor = null) ->

  setEditor: (textEditor) ->
    @textEditor = textEditor

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
    return null if not @textEditor?

    initial = @textEditor.getCursorBufferPosition()

    @textEditor.moveToBeginningOfWord()
    start = @textEditor.getCursorBufferPosition()

    @textEditor.moveToEndOfWord()
    end = @textEditor.getCursorBufferPosition()

    @textEditor.setCursorBufferPosition(initial)

    return @textEditor.getTextInBufferRange(new Range(start, end))

  getFunctionInfoForBracket: (startingRow) ->
    return null if startingRow < 0

    initial = @textEditor.getCursorBufferPosition()

    openBrackets = 0
    currRow = startingRow
    endOfLineColumn = 0

    # safety check in case it fails to break
    while currRow <= @textEditor.getLastBufferRow()
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

  getFunctionInfoForTab: (startingRow) ->
    return null if startingRow < 0

    tabText = @textEditor.getTabText()

    regExp = new RegExp("#{tabText}", "g")
    line = @textEditor.lineTextForBufferRow(startingRow)
    initialTabCount = (line.match(regExp) || []).length

    endOfLineColumn = 0
    currRow = startingRow + 1
    initial = @textEditor.getCursorBufferPosition()

    # safety check in case it fails to break
    while currRow <= @textEditor.getLastBufferRow()
      line = @textEditor.lineTextForBufferRow(currRow)

      lineTabCount = (line.match(regExp) || []).length

      if lineTabCount <= initialTabCount and line
        # go back a row unless its ruby... this keeps the 'end'
        currRow-- unless @getGrammarName() == 'Ruby'

        # determine end of line column
        @textEditor.setCursorBufferPosition([currRow, 0])
        @textEditor.moveToEndOfLine()
        endOfLineColumn = @textEditor.getCursorBufferPosition().column

        break

      currRow++

    @textEditor.setCursorBufferPosition(initial)

    functionRange = new Range([startingRow, 0], [currRow, endOfLineColumn])
    functionText = @textEditor.getTextInBufferRange(functionRange)
    return new FunctionInfo(functionText, functionRange)
