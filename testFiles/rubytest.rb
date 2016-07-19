class Foo
  f = Foo.new

  def test
    puts 'this is a test'
  end

  f.test

  def with_params(param)
    puts "this has a #{param}"
  end

  f.with_params('parameter')

  def foo=(x)
    puts "OK: x=#{x}"
  end

  f.foo = 123

  def self.testingSelf
    puts "test"
  end
end

Foo.testingSelf
