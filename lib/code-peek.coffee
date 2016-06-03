CodePeekView = require './code-peek-view'
FileParser = require './file-parser'
SupportedFiles = require './supported-files'
{CompositeDisposable} = require 'atom'

module.exports = CodePeek =
  codePeekView: null
  panel: null
  subscriptions: null

  activate: ->
    @codePeekView = new CodePeekView()
    @panel = atom.workspace.addBottomPanel(item: @codePeekView.getElement(),
      visible: false)

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

    fileParser = new FileParser(atom.workspace.getActiveTextEditor())
    fileType = fileParser.getFileType()

    # TODO support more than just JS
    if not SupportedFiles.isSupported(fileType)
      atom.notifications.addWarning("Peek function does not support \
        #{fileType} files")
      return

    functionName = fileParser.getWordContainingCursor()

    if not functionName?
      atom.notifications.addError("Unable to get word containing cursor")
      return

    regExp = SupportedFiles.getFunctionRegExpForFileType(fileType, functionName)
    atom.workspace.scan(regExp, null, (matchingFile) ->

      matchingTextEditorPromise = atom.workspace.open(matchingFile.filePath, {
        initialLine: matchingFile.matches[0].range[0][0],
        activatePane: false,
        activateItem: false
      })

      Promise.all([matchingTextEditorPromise]).then (values) ->
        matchingTextEditor = values[0]
        fileParser.setEditor(matchingTextEditor)
        entireFunction = fileParser.getEntireFunction(
          matchingTextEditor.getCursorBufferPosition().row)
        console.log "Entire function is \n#{entireFunction}"
    )
