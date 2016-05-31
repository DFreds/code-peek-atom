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
    typeOfFile = CodePeekUtil.getFileType(textEditor)
    console.log "Type of file is #{typeOfFile}"

    if (typeOfFile isnt "js")
      atom.notifications.addWarning("Peek function only works for javascript files")
      return

    allPaths = atom.project.getPaths()
    console.log("All paths #{allPaths}")

    textEditor.selectWordsContainingCursors()
    selectedText = textEditor.getSelectedText()
    console.log "Selected text is #{selectedText}"

    regex = new RegExp("function\\s*#{selectedText}\\s*\\(|var\\s*#{selectedText}\\s*=\\s*function\\s*\\(")
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

      console.log(JSON.stringify(matchingFile, null, 2))
    )
