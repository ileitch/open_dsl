module OpenDsl
  class Context
    include StringHelpers
    attr_reader :toplevel_object

    def initialize(const_name, &blk)
      raise "Expected a constant name starting with an upper-case character, got '#{const_name}'" unless constant_or_constant_name?(const_name)
      @toplevel_object = new_instance(const_name)
      @stack = EvalStack.new(self)
      @stack.eval_and_keep(@toplevel_object, &blk)
    end

    protected

    def method_missing(name, *args, &blk)
      # TODO: detect an internal error?

      value = args.first
      if constant_or_constant_name?(name)
        assign_constant(name, &blk)
      elsif blk
        if constant_or_constant_name?(value)
          assign_constant_to_explicit_attribute(name, value, &blk)
        else
          if plural?(name)
            assign_collection(name, &blk)
          else
            assign_attribute_with_block(name, &blk)
          end
        end
      else
        assign_attribute(name, value)
      end
    end

    def assign_constant(name, &blk)
      instance = new_instance(name)
      assign_attribute(attribute_name(name), instance)
      @stack.eval(instance, &blk)
    end

    def assign_constant_to_explicit_attribute(name, const, &blk)
      instance = new_instance(const)
      assign_attribute(name, instance)
      @stack.eval(instance, &blk)
    end

    def assign_attribute_with_block(name, &blk)
      struct = OpenStruct.new
      assign_attribute(name, struct)
      @stack.eval(struct, &blk)
    end

    def assign_collection(name, &blk)
      array = Array.new
      assign_attribute(name, array)
      @stack.eval(array, &blk)
    end

    def assign_attribute(name, value)
      if @stack.bottom.kind_of?(Array)
        @stack.bottom << value
      else
        define_getter_and_setter_if_needed(name)
        @stack.bottom.send("#{name}=", value)
      end
    end

    def define_getter_and_setter_if_needed(name)
      return if name.respond_to?("#{name}=")

      @stack.bottom.class.instance_eval do
        define_method("#{name}=") do |value|
          instance_variable_set("@#{name}", value)
        end

        define_method(name) do
          instance_variable_get("@#{name}")
        end
      end
    end

    def new_instance(const_name)
      get_or_define_const(const_name).new
    end

    def get_or_define_const(name_or_const)
      return name_or_const if name_or_const.is_a?(Class)
      Object.const_defined?(name_or_const) ? Object.const_get(name_or_const) : Object.const_set(name_or_const, Class.new)
    end
  end
end