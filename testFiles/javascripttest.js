var peekFunction = function () {
  console.log("hahads");
};

var testFunction = function () {
  test.anotherFunction();
  testFunction2();
};

var testFunction2 = function () {
  test.functionOnOneLine();
};

var testFunction3 = function () {
  test.functionBracketsOnOwnLine();
};

function functionOnOneLine() {  console.log('test'); }

function functionDoesNotExist() {
  test.nonExistent();
}

SomeClass.prototype.testClassFunc = function() {
  return null;
};

teststuff(arg1);
testClassFunc();

getTest();

return {
  getTest: function () {
      return 'test';
  }
};

teststuff(arg1) {

}

function peekFunction(testing) {
  console.log("I am doing something here");
}

var anotherFunction = function ()
{
  console.log("Test");
};

function functionOnOneLine() { return true; }

var functionBracketsOnOwnLine = function ()
{
  var test = true;
  if (test) {
    return true;
  }
  return false;
};
