TextEditorParser = require '../lib/text-editor-parser'
{Point, Range} = require 'atom'

describe "TextEditorParser", ->
  textEditor = null
  textEditorParser = null

  beforeEach ->
    waitsForPromise ->
      atom.workspace.open()
    runs ->
      textEditor = atom.workspace.getActiveTextEditor()
      textEditorParser = new TextEditorParser
      textEditorParser.setEditor textEditor

  setupTextEditor = (text, position) ->
    textEditor.setText(text)

    if position?
      textEditor.setCursorBufferPosition(position)

  it "should define the text editor and parser", ->
    expect(textEditor).toBeDefined()
    expect(textEditorParser).toBeDefined()

  describe "when getting the file type", ->
    fileType = null

    beforeEach ->
      spyOn(textEditor, 'getTitle').andReturn('javascripttest.js')
      fileType = textEditorParser.getFileType()

    it "gets the title", ->
      expect(textEditor.getTitle).toHaveBeenCalled()

    it "should return the file type", ->
      expect(fileType).toEqual('js')

  describe "when getting the grammar name", ->

    it "should return the grammar name from the text editor", ->
      spyOn(textEditor, 'getGrammar').andReturn({'name': 'Ruby'})
      expect(textEditorParser.getGrammarName()).toEqual('Ruby')
    it "should strip off semanticolor prefix if present", ->
      spyOn(textEditor, 'getGrammar').andReturn({'name': 'semanticolor - Ruby'})
      expect(textEditorParser.getGrammarName()).toEqual('Ruby')

  describe "when getting the word containing the cursor", ->
    word = null

    beforeEach ->
      text = """
        var testFunction = function () {
          test.testWord();
        };"
      """
      position = [1, 8]
      setupTextEditor(text, position)

      word = textEditorParser.getWordContainingCursor()

    it "should return testWord", ->
      expect(word).toEqual("testWord")

  describe "when getting the function info for a bracket function with an
    invalid starting row", ->
    functionInfo = null

    beforeEach ->
      functionInfo = textEditorParser.getFunctionInfoForBracket(-1)

    it "should return null", ->
      expect(functionInfo).toBeNull()

  describe "when getting the function info for a bracket function on one line",
    ->
    expectedText = null
    functionInfo = null

    beforeEach ->
      text = """
        var testFunction = function () { test.testWord(); };

        additionalStuff();
      """
      expectedText = """
        var testFunction = function () { test.testWord(); };
      """
      setupTextEditor(text)

      functionInfo = textEditorParser.getFunctionInfoForBracket(0)

    it "should return the function info", ->
      expect(functionInfo.text).toEqual(expectedText)
      expect(functionInfo.range).toEqual(new Range([0, 0], [0, 52]))

  describe "when getting the function info for a bracket function on multiple
    lines", ->
    expectedText = null
    functionInfo = null

    beforeEach ->
      text = """
        function testFunction()
        {
          test.testWord();
        }

        testOtherThing();
      """
      expectedText = """
        function testFunction()
        {
          test.testWord();
        }
      """
      setupTextEditor(text)

      functionInfo = textEditorParser.getFunctionInfoForBracket(0)

    it "should return the function info", ->
      expect(functionInfo.text).toEqual(expectedText)
      expect(functionInfo.range).toEqual(new Range([0, 0], [3, 1]))

  describe "when getting the function info for a tab function with an invalid
    starting row", ->
    functionInfo = null

    beforeEach ->
      functionInfo = textEditorParser.getFunctionInfoForTab(-1)

    it "should return null", ->
      expect(functionInfo).toBeNull()

  describe "when getting the function info for a tab function", ->
    expectedText = null
    functionInfo = null

    beforeEach ->
      text = """
        def testFunc():
          print "stuff"
          print "adding stuff"

        def additionalCrap():
          print "stuff"
      """

      expectedText = """
        def testFunc():
          print "stuff"
          print "adding stuff"

      """
      setupTextEditor(text)

      functionInfo = textEditorParser.getFunctionInfoForTab(0)

    it "should return the function info", ->
      expect(functionInfo.text).toEqual(expectedText)
      expect(functionInfo.range).toEqual(new Range([0, 0], [3, 0]))
