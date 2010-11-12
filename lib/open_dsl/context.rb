module OpenDsl
  class Context
    include StringHelpers
    attr_reader :toplevel_object

    def initialize(const_name, &blk)
      @stack = EvalStack.new(self)
      @toplevel_object = constant_or_constant_name?(const_name) ? new_instance(const_name) : mark_as_created_by_open_dsl(Array.new)
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
      struct = mark_as_created_by_open_dsl(OpenStruct.new)
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
        if !created_by_open_dsl?(@stack.bottom) && values.size == 0
          @stack.bottom.send("#{name}=", true)
        else
          @stack.bottom.send("#{name}=", *values)
        end
      end
    end

    def define_getter_and_setter_if_needed(name)
      return if @stack.bottom.respond_to?("#{name}=")
      raise "Expected #{@stack.bottom.class.name} to have defined a setter method for '#{name}'" unless created_by_open_dsl?(@stack.bottom)

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

    def created_by_open_dsl?(stack_object)
      stack_object.class.class_variables.include?("@@created_by_open_dsl")
    end

    def mark_as_created_by_open_dsl(object)
      object_class = object.class == Class ? object : object.class
      object_class.instance_eval { class_variable_set("@@created_by_open_dsl", true) }
      object
    end

    def get_or_define_const(name_or_const)
      return name_or_const if name_or_const.is_a?(Class)
      Object.const_defined?(name_or_const) ? Object.const_get(name_or_const) : mark_as_created_by_open_dsl(Object.const_set(name_or_const, Class.new))
    end
  end
end