namespace Test
{
    public class TestClass
    {

        public void Test()
        {
            // Do some stuff
            DoStuff(null);
        }

        public string DoStuff(string stuff) {

        }
    }
}


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
    Tester(null, null);
  }

  public override abstract virtual async string Tester(string test, string test2) {
    // something
  }
}
