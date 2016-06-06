CodePeekView = require './code-peek-view'
TextEditorParser = require './text-editor-parser'
SupportedFiles = require './supported-files'
{CompositeDisposable} = require 'atom'

# TODO should probably have tabs or some other mechanism to swich between files
# TODO allow saving or not saving, closing editor using escape or with X button
# TODO handle if code peek is already open and someone toggles it again
# TODO set gutter numbers of editor to match
module.exports = CodePeek =
  codePeekView: null
  panel: null
  subscriptions: null

  activate: ->
    @codePeekView = new CodePeekView()
    @panel = atom.workspace.addBottomPanel(item: @codePeekView)
    @panel.hide()

    # Events subscribed to in atom's system can be easily cleaned up with a
    # CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace',
      'code-peek:peekFunction': => @peekFunction()

  deactivate: ->
    @panel.destroy()
    @subscriptions.dispose()
    @codePeekView.destroy()

  peekFunction: ->

    if @panel.isVisible()
      @codePeekView.detachTextEditorView()
      @panel.hide()
      return

    textEditorParser = new TextEditorParser(
      atom.workspace.getActiveTextEditor())
    fileType = textEditorParser.getFileType()

    if not SupportedFiles.isSupported(fileType)
      atom.notifications.addWarning("Peek function does not support \
        #{fileType} files")
      return

    functionName = textEditorParser.getWordContainingCursor()

    if not functionName?
      atom.notifications.addError("Unable to get word containing cursor")
      return

    regExp = SupportedFiles.getFunctionRegExpForFileType(fileType, functionName)
    matchingFiles = 0
    atom.workspace.scan(regExp, {paths: ["*.#{fileType}"]}, (matchingFile) =>
      matchingFiles++

      if matchingFiles is 1
        atom.workspace.open(matchingFile.filePath, {
          initialLine: matchingFile.matches[0].range[0][0],
          activatePane: false,
          activateItem: false
        }).then (matchingTextEditor) =>
          textEditorParser.setEditor(matchingTextEditor)
          functionInfo = textEditorParser.getFunctionInfo(
            matchingTextEditor.getCursorBufferPosition().row)

          @startEditing(functionInfo, matchingTextEditor)
      else
        # TODO handle additional matches here
        console.log "found another match"
    ).then ->
      if matchingFiles is 0
        atom.notifications.addWarning("Could not find function in project")

  startEditing: (functionInfo, matchingTextEditor) ->
    @codePeekView.setupForEditing(functionInfo, matchingTextEditor)
    @panel.show()
    @codePeekView.attachTextEditorView()
