CodePeekView = require './code-peek-view'
CodePeekUtil = require './code-peek-util'
{CompositeDisposable} = require 'atom'

module.exports = CodePeek =
  codePeekView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @codePeekView = new CodePeekView(state.codePeekViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @codePeekView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'code-peek:peekFunction': => @peekFunction()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @codePeekView.destroy()

  serialize: ->
    codePeekViewState: @codePeekView.serialize()

  peekFunction: ->
    console.log 'Peeking the function'

    textEditor = atom.workspace.getActiveTextEditor()

    if (CodePeekUtil.getFileType(textEditor) isnt "js")
      atom.notifications.addWarning("Peek function only works for javascript files")
      return

    functionName = CodePeekUtil.getWordContainingCursor(textEditor)

    regex = new RegExp("function\\s*#{functionName}\\s*\\(|var\\s*#{functionName}\\s*=\\s*function\\s*\\(")
    atom.workspace.scan(regex, null, (matchingFile) ->

      # {
      #   "filePath": "C:\\Users\\derek.fredrickson\\Documents\\GitHub\\code-peek-atom\\lib\\code-peek.coffee",
      #   "matches": [
      #     {
      #       "matchText": "peekFunction:",
      #       "lineText": "  peekFunction: ->",
      #       "lineTextOffset": 0,
      #       "range": [
      #         [
      #           27,
      #           2
      #         ],
      #         [
      #           27,
      #           15
      #         ]
      #       ]
      #     }
      #   ]
      # }

      matchingTextEditorPromise = atom.workspace.open(matchingFile.filePath, {
        initialLine: matchingFile.matches[0].range[0][0],
        activatePane: false,
        activateItem: false
      })

      Promise.all([matchingTextEditorPromise]).then (values) ->
        matchingTextEditor = values[0]
        entireFunction = CodePeekUtil.getEntireFunction(matchingTextEditor, matchingTextEditor.getCursorBufferPosition().row)
        console.log "Entire function is \n#{entireFunction}"
    )
