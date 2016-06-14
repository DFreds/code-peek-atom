{$, View} = require 'atom-space-pen-views'

module.exports =
class FileListView extends View
  @content: ->
    @div =>
      @ol class: 'list-group', outlet: 'list'

  initialize: ->
    @items = []

  destroy: ->

  addFile: (filePath, initialLine) =>
    #TODO add click handler to change to new text editor... not sure how
    #TODO add styling
    fileName = filePath.replace(/^.*[\\\/]/, '')

    listElement = document.createElement('li')
    listElement.textContent = fileName
    #listElement.classList.add("testClass")

    @list.append(listElement)

  removeAllFiles: =>
    $(@list).empty()
