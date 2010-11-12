require 'spec_helper'

describe OpenDsl do
  it "should define new classes on Object" do
    open_dsl do
      MyClass1 do
      end
    end

    Object.const_defined?("MyClass1").should be_true

  end

  it "should construct a new class if a constant by the same name doesn't already exist" do
    object = open_dsl do
      MyClass2 do
      end
    end

    object.class.name.should == "MyClass2"
  end

  it "should allow a collection to be the toplevel object" do
    things = open_dsl do
      things do
        thing_1 "weee"
      end
    end

    things.first.should == "weee"
  end

  it "should return an instance of an existing class if a it exists" do
    class ExistingClass1
      def hi_mom
      end
    end

    object = open_dsl do
      ExistingClass1 do
      end
    end

    object.class.name.should == "ExistingClass1"
    object.should respond_to(:hi_mom)
  end

  it "should assign attributes as open structs on the context object" do
    object = open_dsl do
      MyClass3 do
        style do
          link "333333"
        end
      end
    end

    object.style.should be_kind_of(OpenStruct)
    object.style.link.should == "333333"
  end

  it "should handle a mix of nested open structs and attribute assignments" do
    object = open_dsl do
      MyClass4 do
        style do
          link "333333"

          other_style do
            link "666666"
          end
        end
      end
    end

    object.style.should be_kind_of(OpenStruct)
    object.style.link.should == "333333"
    object.style.other_style.should be_kind_of(OpenStruct)
    object.style.other_style.link.should == "666666"
  end

  it "should assign a class instance to an attribute inferred from the class name" do
    class MyConfigClass1
    end

    object = open_dsl do
      MyClass5 do
        MyConfigClass1 do
          stuff do
            thing "omg"
          end
        end
      end
    end

    object.my_config_class1.should be_kind_of(MyConfigClass1)
    object.my_config_class1.stuff.thing.should == "omg"
  end

  it "should assign a class instance to an explicit attribute name" do
    class MyConfigClass2
    end

    object = open_dsl do
      MyClass6 do
        weird_name(MyConfigClass2) do
          stuff do
            thing "omg"
          end
        end
      end
    end

    object.weird_name.should be_kind_of(MyConfigClass2)
    object.weird_name.stuff.thing.should == "omg"
  end

  it "should assign an attribute on the toplevel object (not an OpenStruct)" do
    object = open_dsl do
      MyClass7 do
        name  "Weee"
      end
    end

    object.name.should == "Weee"
  end

  it "should treat plural attributes as collections" do
    object = open_dsl do
      MyClass15 do
        things do
          Thing do
            name "hi mom"
          end

          single_thing do
            name "boobies"
          end
        end
      end
    end

    object.things.find {|a| a.kind_of?(OpenStruct)}.name.should == "boobies"
    object.things.find {|a| a.class.name == 'Thing'}.name.should == "hi mom"
  end

  it "should work with the example from the README" do
    object = open_dsl do
      Finance do
        tax do
          rate "17.5%"
        end

        accounts do
          Account do
            name "earnings"
            withdrawal_limit 100_00
          end

          Account do
            name "deposits"
            withdrawal_limit 0
          end
        end
      end
    end

    object.tax.rate.should == "17.5%"
  end

  it "should raise an error if an existing class doesn't already have a setter defined" do
    class MyExistingClass
    end

    expect do
      open_dsl do
        MyExistingClass do
          something "foo"
        end
      end
    end.should raise_error("Expected MyExistingClass to have defined a setter method for 'something'")
  end

  it "should not pass true to the setter if no attribute value given" do
    class MyExistingClass1
      def something=(value)
      end
    end

    instance = MyExistingClass1.new
    MyExistingClass1.stub!(:new).and_return(instance)
    instance.should_receive(:something=).with(true)

    open_dsl do
      MyExistingClass1 do
        something
      end
    end
  end

  it "should work with multiple attribute values" do
    class MyExistingClass2
      def something=(first, second)
      end
    end

    instance = MyExistingClass2.new
    MyExistingClass2.stub!(:new).and_return(instance)
    instance.should_receive(:something=).with(:first, :second)

    open_dsl do
      MyExistingClass2 do
        something :first, :second
      end
    end
  end

  it "should assign an array of values if multiple attribute values are given" do
    things = open_dsl do
      things do
        thing :one, :two, :three
        thing :single
      end
    end

    things.first.should == [:one, :two, :three]
    things.last.should == :single
  end
end
