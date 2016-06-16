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
    @subscriptions.add atom.commands.add 'atom-text-editor',
      'code-peek:peekFunction': => @peekFunction()

    @subscriptions.add atom.commands.add 'atom-text-editor',
      'code-peek:toggleCodePeekOff': => @toggleCodePeekOff(true)

    @subscriptions.add @codePeekView.onCloseIconClicked(
      @toggleCodePeekOff.bind(@)
    )
    # @subscriptions.add @codePeekView.onSelectFile(@openFile)

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
      @toggleCodePeekOff(true)
      return

    @previousFunctionName = functionName
    fileType = textEditorParser.getFileType()

    if not SupportedFiles.isSupported(fileType)
      atom.notifications.addWarning("Peek function does not support \
        #{fileType} files")
      return

    regExp = SupportedFiles.getFunctionRegExpForFileType(fileType, functionName)

    atom.workspace.scan(regExp, {paths: ["*.#{fileType}"]}, (matchingFile) =>
      initialLine = 0

      # HACK I literally have no idea why this is happening. If the file has
      # unsaved changes, we get a range object. If it does not, we get an array
      # for the range.
      if matchingFile.matches[0].range? and
        matchingFile.matches[0].range.start? and
        matchingFile.matches[0].range.start.row?
          initialLine = matchingFile.matches[0].range.start.row
      else
        initialLine = matchingFile.matches[0].range[0][0]

      console.log "initial line is #{initialLine}"
      @matchingFiles.push(new FileInfo(matchingFile.filePath,
        initialLine))
    ).then =>
      if @matchingFiles.length is 0
        atom.notifications.addWarning("Could not find function \
          #{functionName} in project")
        return

      # @codePeekView.addFiles(@matchingFiles)
      @openFile(@matchingFiles[0])

  openFile: (file) ->
    atom.workspace.open(file.filePath, {
      initialLine: file.initialLine
      activatePane: false
      activateItem: false
    }).then (matchingTextEditor) =>
      @startEditing(matchingTextEditor)

  startEditing: (matchingTextEditor) ->
    if @panel.isVisible()
      @toggleCodePeekOff(true)

    textEditorParser = new TextEditorParser(matchingTextEditor)
    functionInfo = textEditorParser.getFunctionInfo(
      matchingTextEditor.getCursorBufferPosition().row,
      SupportedFiles.isTabBased(textEditorParser.getFileType()))

    @codePeekView.setupForEditing(functionInfo, matchingTextEditor)
    @toggleCodePeekOn()

  toggleCodePeekOn: ->
    @codePeekView.attachTextEditorView()
    @panel.show()

  toggleCodePeekOff: (shouldSave) ->
    @codePeekView.detachTextEditorView()
    @codePeekView.saveChanges() if shouldSave
    @panel.hide()
    @previousFunctionName = null
    @matchingFiles = []
