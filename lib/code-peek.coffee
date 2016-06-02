CodePeekView = require './code-peek-view'
FileParser = require './file-parser'
{CompositeDisposable} = require 'atom'

module.exports = CodePeek =
  codePeekView: null
  panel: null
  subscriptions: null

  activate: ->
    @codePeekView = new CodePeekView()
    @panel = atom.workspace.addBottomPanel(item: @codePeekView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'code-peek:peekFunction': =>
      @peekFunction()

  deactivate: ->
    @panel.destroy()
    @subscriptions.dispose()
    @codePeekView.destroy()

  peekFunction: ->

    fileParser = new FileParser(atom.workspace.getActiveTextEditor())

    # TODO support more than just JS
    if (fileParser.getFileType() isnt "js")
      atom.notifications.addWarning("Peek function only works for javascript files")
      return

    functionName = fileParser.getWordContainingCursor()
    atom.notifications.addError("Unable to get word containing cursor") if not functionName?

    regex = new RegExp("function\\s*#{functionName}\\s*\\(|var\\s*#{functionName}\\s*=\\s*function\\s*\\(")
    atom.workspace.scan(regex, null, (matchingFile) ->

      matchingTextEditorPromise = atom.workspace.open(matchingFile.filePath, {
        initialLine: matchingFile.matches[0].range[0][0],
        activatePane: false,
        activateItem: false
      })

      Promise.all([matchingTextEditorPromise]).then (values) ->
        matchingTextEditor = values[0]
        fileParser.setEditor(matchingTextEditor)
        entireFunction = fileParser.getEntireFunction(matchingTextEditor.getCursorBufferPosition().row)
        console.log "Entire function is \n#{entireFunction}"
    )
