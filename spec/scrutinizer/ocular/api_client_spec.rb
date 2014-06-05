
require 'spec_helper'
require 'scrutinizer/ocular/api_client'

describe Scrutinizer::Ocular::ApiClient do

  client = Scrutinizer::Ocular::ApiClient.new(
    "https://scrutinizer-ci.com/api",
    "g/scrutinizer-ci/scrutinizer",
    "abcdef",
    ["abc123", "def456"],
    nil
  )

  it "uploads coverage data" do
    client.upload("rb-cc", "abcdef")
  end

end