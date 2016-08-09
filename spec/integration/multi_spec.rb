require 'spec_helper'
require 'yaml'

describe "Multi API" do
  before(:all) do
    credentials = YAML.load(File.read(CREDENTIALS_FILE))
    key = credentials["key"]
    secret = credentials["secret"]
    @factual = Factual.new(key, secret)
  end

  it "should be able to do multi queries" do
    places_query = @factual.table("places").search('food').filters(:postcode => 90067)
    facets_query = @factual.facets("places-us").select("locality")

    responses = @factual.multi(
      :nearby_food => places_query,
      :locality_facets => facets_query)

    responses[:nearby_food].rows.length.should == 20
    responses[:nearby_food].rows.each do |row|
      row.class.should == Hash
      row.keys.should_not be_empty
    end

    puts responses[:locality_facets].first.inspect
    responses[:locality_facets].first[1]["los angeles"].to_s.should_not be_empty
  end
end
