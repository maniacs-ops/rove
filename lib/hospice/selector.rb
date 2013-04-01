module Hospice
  class Selector
    attr_reader :name, :options

    def initialize(name, &block)
      @name    = name
      @options = []

      instance_eval &block
    end

    def option(name, &block)
      @options << Option.new(name, &block)
    end
  end
end