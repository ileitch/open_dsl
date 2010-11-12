module OpenDsl
  class Context
    include StringHelpers
    attr_reader :toplevel_object

    def initialize(const_name, &blk)
      @stack = EvalStack.new(self)
      if constant_or_constant_name?(const_name)
        @toplevel_object_already_exists = existing_class?(const_name)
        @toplevel_object = new_instance(const_name)
      else
        @toplevel_object = Array.new
      end
      @stack.eval_and_keep(@toplevel_object, &blk)
    end

    protected

    def method_missing(name, *args, &blk)
      # TODO: detect an internal error?

      if constant_or_constant_name?(name)
        assign_constant(name, &blk)
      elsif blk
        if constant_or_constant_name?(args.first)
          assign_constant_to_explicit_attribute(name, args.first, &blk)
        else
          if plural?(name)
            assign_collection(name, &blk)
          else
            assign_attribute_with_block(name, &blk)
          end
        end
      else
        assign_attribute(name, *args)
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

    def assign_attribute(name, *values)
      if @stack.bottom.kind_of?(Array)
        @stack.bottom << (values.size == 1 ? values.first : values)
      else
        define_getter_and_setter_if_needed(name)
        if @toplevel_object_already_exists && values.size == 0
          @stack.bottom.send("#{name}=", true)
        else
          @stack.bottom.send("#{name}=", *values)
        end
      end
    end

    def define_getter_and_setter_if_needed(name)
      return if @stack.bottom.respond_to?("#{name}=")
      raise "Expected #{@toplevel_object.class.name} to have defined a setter method for '#{name}'" if @toplevel_object_already_exists

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

    def existing_class?(name_or_const)
      return true if name_or_const.is_a?(Class)
      Object.const_defined?(name_or_const)
    end

    def get_or_define_const(name_or_const)
      return name_or_const if name_or_const.is_a?(Class)
      Object.const_defined?(name_or_const) ? Object.const_get(name_or_const) : Object.const_set(name_or_const, Class.new)
    end
  end
end