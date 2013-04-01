module Hospice
  class Package < Option
    include Support::Storer

    def initialize(name, &block)
      super
      store
    end

    def category(name=nil)
      Hospice::Category.new(@category ||= name || 'Other')
      @category
    end
  end
end