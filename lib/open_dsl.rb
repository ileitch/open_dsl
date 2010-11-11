$:.unshift(File.dirname(__FILE__))

require 'ostruct'

require 'open_dsl/string_helpers'
require 'open_dsl/builder'
require 'open_dsl/context'
require 'open_dsl/eval_stack'

module OpenDsl
  VERSION = '0.2'
end

def open_dsl(&blk)
  OpenDsl::Builder.build(&blk)
end
