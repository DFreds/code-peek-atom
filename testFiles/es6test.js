(function () {

  getTest (() => {
  });


  test2((test1, test2) => {

  });

  var test3 = () => {

  };
  var test4 = (test1, test2) => {

  };

  // not supported
  test5: () => console.log(this.i, this);

  test6: () => {
    console.log(this.a, typeof this.a, this);
    return this.a+10; // represents global object 'Window', therefore 'this.a' returns 'undefined'
  }

  getTest();
  test2(test, test2);
  test3();
  test4(test1, test2);
  test5();
  test6();
})();
