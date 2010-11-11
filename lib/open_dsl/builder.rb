module OpenDsl
  class Builder
    def self.build(file = nil, &blk)
      builder = new(file, &blk)
      builder.context.toplevel_object
    end

    def initialize(file = nil, &blk)
      if file
        build_from_file(file)
      elsif blk
        build_from_proc(blk)
      else
        raise "OpenDsl#new requires either a file to load or a block as an argument"
      end
    end

    def context
      @context
    end

    protected

    def build_from_file(file)
    end

    def build_from_proc(blk)
      instance_eval(&blk)
    end

    def method_missing(const_name, *args, &blk)
      @context = Context.new(const_name, &blk)
    end
  end
end
