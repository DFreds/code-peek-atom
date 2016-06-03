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
