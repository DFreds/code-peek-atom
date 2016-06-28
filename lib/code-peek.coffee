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
    # TODO make location configurable? top, bottom, left, right,
    # header, footer, modal?
    @panel = atom.workspace.addBottomPanel(item: @codePeekView)
    @panel.hide()

    @previousFunctionName = null

    @subscriptions = new CompositeDisposable

    @addAtomCommands()
    @handleClickEvents()

  deactivate: ->
    @panel.destroy()
    @subscriptions.dispose()
    @codePeekView.destroy()

  addAtomCommands: ->
    @subscriptions.add atom.commands.add 'atom-text-editor',
      'code-peek:peekFunction': => @peekFunction()

    @subscriptions.add atom.commands.add 'atom-text-editor',
      'code-peek:toggleCodePeekOff': => @toggleCodePeekOff(true)

  handleClickEvents: ->
    @subscriptions.add @codePeekView.onCheckIconClicked(
      @toggleCodePeekOff.bind(@)
    )

    @subscriptions.add @codePeekView.onCodeIconClicked(
      @openEntireFile.bind(@)
    )

    @subscriptions.add @codePeekView.onCloseIconClicked(
      @toggleCodePeekOff.bind(@)
    )

    @subscriptions.add @codePeekView.onSelectFile(
      @openFileForCodePeek.bind(@)
    )

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
    @scanWorkspace(regExp, fileType)

  scanWorkspace: (regExp, fileType) ->
    # TODO make paths configurable?
    atom.workspace.scan(regExp, {paths: ["*.#{fileType}"]}, (matchingFile) =>
      initialLine = 0

      # HACK If the file has unsaved changes, we get a range object.
      # If it does not, we get an array for the range. Bug in Atom itself,
      # logged here: https://github.com/atom/atom/issues/10900
      if matchingFile.matches[0].range? and
        matchingFile.matches[0].range.start? and
        matchingFile.matches[0].range.start.row?
          initialLine = matchingFile.matches[0].range.start.row
      else
        initialLine = matchingFile.matches[0].range[0][0]

      @matchingFiles.push(new FileInfo(matchingFile.filePath,
        initialLine))
    ).then =>
      # finished scanning files
      if @matchingFiles.length is 0
        atom.notifications.addWarning("Could not find function \
          #{functionName} in project")
        return

      # add files to list
      @codePeekView.addFiles(@matchingFiles)

      # open the first file in code peek
      @openFileForCodePeek(@matchingFiles[0])

  openEntireFile: (fileInfo) ->
    atom.workspace.open(fileInfo.filePath, {
      initialLine: fileInfo.range.start.row
    })

  openFileForCodePeek: (file) ->
    if not file? or not file.filePath?
      return
    atom.workspace.open(file.filePath, {
      initialLine: file.initialLine
      activatePane: false
      activateItem: false
    }).then (matchingTextEditor) =>
      # finished opening file
      @startEditing(matchingTextEditor)

  startEditing: (matchingTextEditor) ->
    # hide the panel and save changes if it already visible
    if @panel.isVisible()
      @toggleCodePeekOff(true)

    textEditorParser = new TextEditorParser(matchingTextEditor)

    functionInfo = null
    if SupportedFiles.isTabBased(textEditorParser.getFileType())
      functionInfo = textEditorParser.getFunctionInfoForTab(
        matchingTextEditor.getCursorBufferPosition().row
      )
    else
      functionInfo = textEditorParser.getFunctionInfoForBracket(
        matchingTextEditor.getCursorBufferPosition().row
      )

    @codePeekView.setupForEditing(functionInfo, matchingTextEditor)
    @toggleCodePeekOn()

  toggleCodePeekOn: ->
    @codePeekView.attachTextEditorView()
    @panel.show()

  toggleCodePeekOff: (shouldSave) ->
    # determine if we should ask them if they are sure they don't want to save
    if @codePeekView.isModified() and not
      shouldSave and
      atom.config.get("code-peek.askIfSaveOnModified")
        chosen = atom.confirm({
          message: 'This file has changes. Do you want to save them?'
          detailedMessage: "Your changes will be lost if you close this item\
            without saving."
          buttons: ["Save", "Cancel", "Don't save"]
        })

        switch chosen
          when 0 then shouldSave = true
          when 1 then return
          when 2 then shouldSave = false

    @codePeekView.saveChanges() if shouldSave

    # toggle code peek off and reset variables
    @codePeekView.detachTextEditorView()
    @panel.hide()
    @previousFunctionName = null
    @matchingFiles = []
