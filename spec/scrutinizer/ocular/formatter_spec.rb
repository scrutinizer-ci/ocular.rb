
require 'spec_helper'
require 'simplecov'
require 'scrutinizer/ocular/formatter'

describe 'Scrutinizer::Ocular::Formatter' do
  def delete_coverage(coverage_file)
    File.delete(coverage_file) if File.exists? coverage_file
  end

  def fixture_path(relative_path)
    File.dirname(__FILE__) + '/fixtures/' + relative_path
  end

  let(:result) {
    SimpleCov::Result.new({
      fixture_path('foo.rb') => [nil, 2, 2, nil]
    })
  }

  let(:coverage_file) {
    '/tmp/local-formatter-cc.json'
  }

  before {
    delete_coverage(coverage_file)
  }

  after {
    delete_coverage(coverage_file)
  }

  describe "LocalOutputFormatter" do
    it "writes coverage to local file" do
      ENV['SCRUTINIZER_CC_FILE'] = coverage_file
      formatter = Scrutinizer::Ocular::LocalOutputFormatter.new
      formatter.format(result)

      output = File.open(coverage_file, 'r') do |file|
        file.read.to_s
      end

      output.should match(/^\[\{"name":"[^"]+\/foo\.rb","lines":\[null,2,2,null\]\}\]$/)
    end
  end

  describe "UploadingFormatter" do
    it "uploads code coverage" do
      ENV['SCRUTINIZER_REPOSITORY'] = 'foo/bar/baz'
      formatter = Scrutinizer::Ocular::UploadingFormatter.new
      output = Scrutinizer::Ocular::MemorizedOutput.new
      formatter.output = output
      formatter.format(result)

      output.output.should match(/Uploading code coverage/)
      output.output.should match(/Failed/)
      output.output.should match(/foo\/bar\/baz/)
    end
  end
end