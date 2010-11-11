module OpenDsl
  class EvalStack
    def initialize(context_binding)
      @stack = []
      @context_binding = context_binding
    end

    def eval_and_keep(object, &blk)
      @stack.push(object)
      @context_binding.instance_eval(&blk)
    end

    def eval(object, &blk)
      eval_and_keep(object, &blk)
      @stack.pop
    end

    def bottom
      @stack.last
    end
  end
end