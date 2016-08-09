require 'spec_helper'
require 'yaml'

describe "Read APIs - Unicode Queries" do
  before(:all) do
    credentials = YAML.load(File.read(CREDENTIALS_FILE))
    key = credentials["key"]
    secret = credentials["secret"]
    @factual = Factual.new(key, secret)

    f = File.dirname(__FILE__) + '/unicode.yaml'
    @unicode_texts = YAML.load(File.read(f))
  end

  it "should be able to handle unicode" do
    @unicode_texts['cities'].each do |country, city|
      q = @factual.table("places-#{country}").filters('locality' => city)
      q.first['locality'].should == city
    end
  end
end
