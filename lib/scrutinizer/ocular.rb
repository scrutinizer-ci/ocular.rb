require "scrutinizer/ocular/version"

module Scrutinizer
  module Ocular
    extend self

    attr_accessor :enabled
    @enabled = false

    def watch!(profile = nil, &block)
      if self.should_run?
        setup!
        start! profile, &block
      end
    end

    def setup!
      require 'simplecov'
      require "scrutinizer/ocular/formatter"

      ::SimpleCov.formatter = create_formatter
    end

    def create_formatter
      if ENV['SCRUTINIZER_CC_FILE']
        return Scrutinizer::Ocular::LocalOutputFormatter
      end

      Scrutinizer::Ocular::UploadingFormatter
    end

    def start!(profile=nil, &block)
      ::SimpleCov.add_filter 'vendor'

      if profile
        ::SimpleCov.start(profile)
      elsif block
        ::SimpleCov.start(profile) { instance_eval(block) }
      else
        ::SimpleCov.start
      end
    end

    def should_run?
      ENV["CI"] || ENV["JENKINS_URL"] || ENV["SCRUTINIZER_COVERAGE"] || ENV['SCRUTINIZER_CC_FILE'] || @enabled
    end
  end
end
