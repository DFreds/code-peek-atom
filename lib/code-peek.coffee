CodePeekView = require './code-peek-view'
TextEditorParser = require './text-editor-parser'
SupportedFiles = require './supported-files'
FileInfo = require './file-info'
{CompositeDisposable} = require 'atom'

module.exports = CodePeek =
  codePeekView: null
  panel: null
  subscriptions: null

  activate: ->
    @codePeekView = new CodePeekView()
    @panel = atom.workspace.addBottomPanel(item: @codePeekView)
    @panel.hide()

    @previousFunctionName = null

    # Events subscribed to in atom's system can be easily cleaned up with a
    # CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace',
      'code-peek:peekFunction': => @peekFunction()

    @subscriptions.add atom.commands.add 'atom-workspace',
      'code-peek:toggleCodePeekOff': => @toggleCodePeekOff()

  deactivate: ->
    @panel.destroy()
    @subscriptions.dispose()
    @codePeekView.destroy()

  peekFunction: ->

    @matchingFiles = []

    textEditorParser = new TextEditorParser(
      atom.workspace.getActiveTextEditor())

    functionName = textEditorParser.getWordContainingCursor()
    if not functionName?
      atom.notifications.addError("Unable to get word containing cursor")
      return

    if @previousFunctionName is functionName
      # user selected the same function as last time, so just toggle off
      @toggleCodePeekOff()
      return

    @previousFunctionName = functionName
    fileType = textEditorParser.getFileType()

    if not SupportedFiles.isSupported(fileType)
      atom.notifications.addWarning("Peek function does not support \
        #{fileType} files")
      return

    regExp = SupportedFiles.getFunctionRegExpForFileType(fileType, functionName)

    atom.workspace.scan(regExp, {paths: ["*.#{fileType}"]}, (matchingFile) =>
      @matchingFiles.push(new FileInfo(matchingFile.filePath,
        matchingFile.matches[0].range[0][0]))
    ).then =>

      if @matchingFiles.length is 0
        atom.notifications.addWarning("Could not find function \
          #{functionName} in project")
        return

      @codePeekView.addFiles(@matchingFiles)

      atom.workspace.open(@matchingFiles[0].filePath, {
        initialLine: @matchingFiles[0].initialLine
        activatePane: false
        activateItem: false
      }).then (matchingTextEditor) =>
        @startEditing(matchingTextEditor)

  startEditing: (matchingTextEditor) ->
    if @panel.isVisible()
      @toggleCodePeekOff()

    textEditorParser = new TextEditorParser(matchingTextEditor)
    functionInfo = textEditorParser.getFunctionInfo(
      matchingTextEditor.getCursorBufferPosition().row,
      SupportedFiles.isTabBased(textEditorParser.getFileType()))

    @codePeekView.setupForEditing(functionInfo, matchingTextEditor)
    @toggleCodePeekOn()

  toggleCodePeekOn: ->
    @codePeekView.attachTextEditorView()
    @panel.show()

  toggleCodePeekOff: ->
    @codePeekView.detachTextEditorView()
    @panel.hide()
    @previousFunctionName = null
    @matchingFiles = []
