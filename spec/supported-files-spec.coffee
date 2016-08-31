SupportedFiles = require '../lib/supported-files'

describe "SupportedFiles", ->

  ###
    Test isSupported(fileType)
  ###
  describe "when checking if an invalid file type is supported", ->
    result = null

    beforeEach ->
      result = SupportedFiles.isSupported("randomtype")

    it "should return false", ->
      expect(result).toEqual(false)

  describe "when checking if an valid file type is supported", ->
    result = null

    beforeEach ->
      result = SupportedFiles.isSupported("js")

    it "should return true", ->
      expect(result).toEqual(true)

  ###
    Test isTabBased(fileType)
  ###
  describe "when checking if an invalid file type is tab based", ->
    result = null

    beforeEach ->
      result = SupportedFiles.isTabBased("invalid")

    it "should return false", ->
      expect(result).toEqual(false)

  describe "when checking if a non-tab based file type is tab based", ->
    result = null

    beforeEach ->
      result = SupportedFiles.isTabBased("java")

    it "should return false", ->
      expect(result).toEqual(false)

  describe "when checking if a tab based file type is tab based", ->
    result = null

    beforeEach ->
      result = SupportedFiles.isTabBased("py")

    it "should return true", ->
      expect(result).toEqual(true)

  ###
    Test getFunctionRegExpForFileType(fileType, functionName)
  ###
  describe "when getting the regular expression for an invalid file type", ->
    result = null

    it "should throw an error", ->
      expect(->
        SupportedFiles.getFunctionRegExpForFileType("invalid", "TEST")
      ).toThrow()

  describe "when getting the regular expression for a valid file type", ->
    result = null
    expectedResult = ///
      function \s+ TEST \s* \(
        |
      TEST \s* (=|:) \s* function \s* \(
        |
      TEST \s* ([=:])? \s* \(? \s* \( ([\,\s\w]*)? \)? \s* =>
    ///

    beforeEach ->
      result = SupportedFiles.getFunctionRegExpForFileType("js", "TEST")

    it "should return a regex with the new function name", ->
      expect(result).toEqual(expectedResult)
