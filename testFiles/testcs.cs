public class TestCs {
  public void test() {
    // blah
  }

  string test2 ()
  {
    Testing.CallingTest2();
  }
}

public class Testing {
  public void CallingTest() {
    TestCs.test();
    CallingTest2();
  }

  public string CallingTest2()
  {
    test2();
  }
}
