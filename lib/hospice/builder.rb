# encoding: utf-8

require 'erb'
require 'tempfile'
require 'zip/zip'
require 'zip/zipfilesystem'

module Hospice
  class Builder
    attr_reader :packages, :recipes, :cookbooks, :configuration, :configs

    def initialize(configuration)
      @configuration = configuration
      @packages = []
      @recipes = []
      @cookbooks = []
      @configs = []
      parse_configuration!
    end

    def zip
      tempfile  = Tempfile.new('hospice')
      path      = tempfile.path
      cookbooks = @cookbooks
      recipes   = @recipes
      configs = @configs

      Zip::ZipOutputStream.open(tempfile.path) do |z|
        %w(Vagrantfile Cheffile).each do |t|
          z.put_next_entry t
          z.print ERB.new((template t), nil, '-').result(binding)
        end
      end

      tempfile.close
      path
    end

    private

    def parse_configuration!
      Hospice::Package.all.each do |package|
        if @configuration.keys.include?(package.id)
          @packages << package
          parse_package!(package)
        end
      end
      @recipes = @recipes.flatten.compact.uniq
      @cookbooks = @cookbooks.flatten.compact.uniq
      @configs = @configs.flatten.compact.uniq
    end

    def parse_package!(package)
      @cookbooks << package.cookbooks
      @recipes << package.recipes
      @configs << package.config

      package.recursive_options.each do |option|
        if @configuration[package.id].include?(option.id)
          @cookbooks << option.cookbooks
          @recipes << option.recipes
          @configs << option.config
        end
      end
    end

    def template(name)
      File.read(File.dirname(__FILE__) + "/templates/#{name}.erb")
    end
  end
end