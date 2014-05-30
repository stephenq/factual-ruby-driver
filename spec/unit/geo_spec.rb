require 'spec_helper'

describe Factual::Query::Geocode do
  include TestHelpers

  before(:each) do
    @token = get_token
    @api = get_api(@token)
    @base = "http://api.v3.factual.com/"

    @geocode = Factual::Query::Geocode.new(@api, LAT, LNG)
  end

  it "should be able to set the geocode url" do
    @geocode.first
    expected_url = @base + %{places/geocode?geo={"$point":[#{LAT},#{LNG}]}}
    CGI::unescape(@token.last_url).should == expected_url
  end
end
