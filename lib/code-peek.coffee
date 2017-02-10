CodePeekView = require './code-peek-view'
TextEditorParser = require './text-editor-parser'
SupportedFiles = require './supported-files'
FileInfo = require './data/file-info'
{CompositeDisposable} = require 'atom'

module.exports = CodePeek =
  codePeekView: null
  panel: null
  subscriptions: null

  activate: ->
    @codePeekView = new CodePeekView()

    @location = null
    @panel = @createPanel()

    @previousFunctionName = null

    @subscriptions = new CompositeDisposable

    @addAtomCommands()
    @handleClickEvents()

  deactivate: ->
    @panel.destroy()
    @subscriptions.dispose()
    @codePeekView.destroy()

  createPanel: ->
    if @panel? then @panel.destroy()

    @location = atom.config.get("code-peek.codePeekLocation")

    panel = null
    switch @location
      when "Bottom"
        panel = atom.workspace.addBottomPanel(item: @codePeekView)
      when "Top"
        panel = atom.workspace.addTopPanel(item: @codePeekView)
      when "Left"
        panel = atom.workspace.addLeftPanel(item: @codePeekView)
      when "Right"
        panel = atom.workspace.addRightPanel(item: @codePeekView)
      when "Header"
        panel = atom.workspace.addHeaderPanel(item: @codePeekView)
      when "Footer"
        panel = atom.workspace.addFooterPanel(item: @codePeekView)
      when "Modal"
        panel = atom.workspace.addModalPanel(item: @codePeekView)

    panel.hide()
    return panel

  addAtomCommands: ->
    @subscriptions.add atom.commands.add 'atom-text-editor',
      'code-peek:peekFunction': => @peekFunction()

    @subscriptions.add atom.commands.add 'atom-text-editor',
      'core:cancel': => @toggleCodePeekOff(false)
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
    if @location != atom.config.get("code-peek.codePeekLocation")
      # recreate the panel if the setting changed
      @panel = @createPanel()

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
    grammarName = textEditorParser.getGrammarName()

    if grammarName == "Null Grammar"
      atom.notifications.addError("Grammar type of file must be set to peek \
      function")
      return

    regExp = SupportedFiles.getRegExpForGrammarName(grammarName, functionName)

    if not regExp?
      atom.notifications.addWarning("Peek function does not currently support \
        #{grammarName} files")
      return

    @scanWorkspace(regExp, fileType, functionName)

  scanWorkspace: (regExp, fileType, functionName) ->

    pathsArray = @constructPathsArray(fileType)

    atom.workspace.scan(regExp, {paths: pathsArray}, (matchingFile) =>
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
          \"#{functionName}\" in project.")
        return

      # add files to list
      @codePeekView.addFiles(@matchingFiles)

      # open the first file in code peek
      @openFileForCodePeek(@matchingFiles[0])

  constructPathsArray: (fileType) ->
    pathsToInclude = []
    if fileType?
      pathsToInclude.push("*.#{fileType}")

    pathsToIgnore = atom.config.get("code-peek.ignoredPaths")
    if pathsToIgnore
      for path in pathsToIgnore
        # do the opposite of what is put in the ignored paths field
        # this is for user convenience in the settings menu
        pathsToInclude.push("!#{path}")

    return pathsToInclude

  openEntireFile: (fileInfo) ->
    atom.workspace.open(fileInfo.filePath, {
      initialLine: fileInfo.range.start.row
    })

    if @matchingFiles.length is 1
      # close the code peek panel and save changes
      console.log "only one matching file"
      @toggleCodePeekOff(true)

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
    if SupportedFiles.isTabBased(textEditorParser.getGrammarName())
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
    @codePeekView.attachTextEditorView(@location)
    @panel.show()

  toggleCodePeekOff: (shouldSave) ->
    # determine if we should ask them if they are sure they don't want to save
    if @codePeekView.isModified() and not
      shouldSave and
      atom.config.get("code-peek.askIfSaveOnModified")
        chosen = atom.confirm({
          message: 'This file has changes. Do you want to save them?'
          detailedMessage: "Your changes will be lost if you close this item \
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
