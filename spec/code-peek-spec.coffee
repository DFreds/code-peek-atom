CodePeek = require '../lib/code-peek'

# TODO this needs way more work to show actual coverage
describe "CodePeek", ->
  [activationPromise, editor, editorView, workspaceView] = []

  beforeEach ->
    waitsForPromise ->
      atom.workspace.open()

    runs ->
      workspaceView = atom.views.getView atom.workspace
      editor = atom.workspace.getActiveTextEditor()
      editorView = atom.views.getView editor
      editor.setText """
        getTest();

        var getTest = function () {
          return true;
        };
      """
      editor.setCursorScreenPosition [0, 4]

      activationPromise = atom.packages.activatePackage 'code-peek'

  activateAndThen = (command, callback) ->
    atom.commands.dispatch(editorView, command)
    waitsForPromise -> activationPromise
    runs(callback)

  describe "when a code-peek:peekFunction event is triggered", ->
    it "activates", ->
      activateAndThen 'code-peek:peekFunction', ->
        expect(workspaceView.querySelector(".code-peek")).toExist()

    it "shows a panel", ->
      activateAndThen 'code-peek:peekFunction', ->
        waitsFor -> workspaceView.querySelector ".code-peek"


# CodePeek = require '../lib/code-peek'
#
# # Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
# #
# # To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# # or `fdescribe`). Remove the `f` to unfocus the block.
#
# describe "CodePeek", ->
#   [workspaceElement, activationPromise] = []
#
#   beforeEach ->
#     workspaceElement = atom.views.getView(atom.workspace)
#     activationPromise = atom.packages.activatePackage('code-peek')
#
#   describe "when the code-peek:toggle event is triggered", ->
#     it "hides and shows the modal panel", ->
#       # Before the activation event the view is not on the DOM, and no panel
#       # has been created
#       expect(workspaceElement.querySelector('.code-peek')).not.toExist()
#
#       # This is an activation event, triggering it will cause the package to be
#       # activated.
#       atom.commands.dispatch workspaceElement, 'code-peek:toggle'
#
#       waitsForPromise ->
#         activationPromise
#
#       runs ->
#         expect(workspaceElement.querySelector('.code-peek')).toExist()
#
#         codePeekElement = workspaceElement.querySelector('.code-peek')
#         expect(codePeekElement).toExist()
#
#         codePeekPanel = atom.workspace.panelForItem(codePeekElement)
#         expect(codePeekPanel.isVisible()).toBe true
#         atom.commands.dispatch workspaceElement, 'code-peek:toggle'
#         expect(codePeekPanel.isVisible()).toBe false
#
#     it "hides and shows the view", ->
#       # This test shows you an integration test testing at the view level.
#
#       # Attaching the workspaceElement to the DOM is required to allow the
#       # `toBeVisible()` matchers to work. Anything testing visibility or focus
#       # requires that the workspaceElement is on the DOM. Tests that attach the
#       # workspaceElement to the DOM are generally slower than those off DOM.
#       jasmine.attachToDOM(workspaceElement)
#
#       expect(workspaceElement.querySelector('.code-peek')).not.toExist()
#
#       # This is an activation event, triggering it causes the package to be
#       # activated.
#       atom.commands.dispatch workspaceElement, 'code-peek:toggle'
#
#       waitsForPromise ->
#         activationPromise
#
#       runs ->
#         # Now we can test for view visibility
#         codePeekElement = workspaceElement.querySelector('.code-peek')
#         expect(codePeekElement).toBeVisible()
#         atom.commands.dispatch workspaceElement, 'code-peek:toggle'
#         expect(codePeekElement).not.toBeVisible()
