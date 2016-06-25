require_relative './database'
require 'minitest/autorun'

class DatabaseTest < Minitest::Test
  class Foo
    def initialize(*args)
      i = 0
      args.each { |param| instance_variable_set("@var#{i+=1}", param) }
      @timestamp = Time.now
    end

    def ==(other)
      self.instance_variables.each do |variable_name|
        self.instance_variable_get(variable_name) == other.instance_variable_get(variable_name)
      end
    end
  end

  class Bar < Foo; end

  def setup
    File.open("./foo_test.sdb", "w") {}
    File.open("./bar_test.sdb", "w") {}

    @foodb = Database.new(:foo_test)
    @bardb = Database.new(:bar_test)

    @bar1 = Bar.new("name1")
    @bar2 = Bar.new("name2")
    @bar3 = Bar.new("name3")
    @bar4 = Bar.new("name4")

    @foo1 = Foo.new([@bar1, @bar2, @bar3], [@bar4], 10, 0)
    @foo2 = Foo.new([@bar2], [@bar3], 6, 10)
    @foo3 = Foo.new([@bar1, @bar2], [@bar3, @bar4], 10, 5)
    @foo4 = Foo.new([@bar1], [@bar3, @bar4], 10, 9)

    @bars = [@bar1, @bar2, @bar3, @bar4]
    @foos = [@foo1, @foo2, @foo3, @foo4]
  end

  def teardown
    File.open("foo_out.txt", "w") { |f| f.write(File.read("foo_test.sdb")) }
    File.delete("./foo_test.sdb", "./bar_test.sdb")
  end

  def test_create_new_database
    name = :test_database
    test_database = Database.new(name)

    assert_equal Database, test_database.class
  end

  def test_save_and_load_foos_on_database
    assert_equal "", File.read("./foo_test.sdb")
    assert_nil @foodb.load

    @foodb.save(@foos)

    refute_equal "", File.read("./foo_test.sdb")
    
    @foos.zip(@foodb.load).each do |exp_foo, act_foo|
      assert_true exp_foo == act_foo
    end
  end

  def test_save_and_load_bars_on_database
    assert_equal "", File.read("./bar_test.sdb")
    assert_nil @bardb.load

    @bardb.save(@bars)

    refute_equal "", File.read("./bar_test.sdb")
    
    assert @bars == @bardb.load
  end
end