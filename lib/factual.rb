require 'rubygems'
gem 'oauth'

require 'json'
require 'cgi'
require 'timeout'

require 'oauth'

require File.expand_path('../factual/api', __FILE__)
require File.expand_path('../factual/query/base', __FILE__)
require File.expand_path('../factual/query/table', __FILE__)
require File.expand_path('../factual/query/facets', __FILE__)
require File.expand_path('../factual/query/match', __FILE__)
require File.expand_path('../factual/query/resolve', __FILE__)
require File.expand_path('../factual/query/geocode', __FILE__)
require File.expand_path('../factual/query/geopulse', __FILE__)
require File.expand_path('../factual/write/base', __FILE__)
require File.expand_path('../factual/write/flag', __FILE__)
require File.expand_path('../factual/write/boost', __FILE__)
require File.expand_path('../factual/write/submit', __FILE__)
require File.expand_path('../factual/write/clear', __FILE__)
require File.expand_path('../factual/write/insert', __FILE__)
require File.expand_path('../factual/multi', __FILE__)

class Factual
  def initialize(key, secret, options = {})
    debug_mode = options[:debug].nil? ? false : options[:debug]
    host = options[:host]
    timeout = options[:timeout]
    @api = API.new(generate_token(key, secret), debug_mode, host, timeout)
  end

  def apply_header(key, value)
    @api.apply_header(key, value)
  end

  def table(table_id_or_alias)
    Query::Table.new(@api, "t/#{table_id_or_alias}")
  end

  def facets(table_id_or_alias)
    Query::Facets.new(@api, "t/#{table_id_or_alias}")
  end

  def match(*args)
    table = 'places'
    values = args[-1]
    if args.first.is_a?(String)
      table = args[0]
    end
    Query::Match.new(@api, table, :values => values)
  end

  def resolve(*args)
    table = 'places'
    values = args[-1]
    if args.first.is_a?(String)
      table = args[0]
    end
    Query::Resolve.new(@api, table, :values => values)
  end

  def geocode(lat, lng)
    Query::Geocode.new(@api, lat, lng)
  end

  def geopulse(lat, lng)
    Query::Geopulse.new(@api, lat, lng)
  end

  def get(path, query={})
    @api.raw_get(path, query)
  end

  def post(path, body={})
    @api.raw_post(path, body)
  end

  def diffs(view, params = {})
    @api.diffs(view, params)
  end

  def multi(queries)
    multi = Multi.new(@api, queries)
    multi.send
  end

  def clear(*params)
    fields = []
    fields = params.pop if params.last.is_a? Array

    table, user, factual_id = params
    clear_params = {
      :table => table,
      :factual_id => factual_id,
      :fields => fields.join(","),
      :user => user }

    Write::Clear.new(@api, clear_params)
  end

  def boost(table, user, factual_id, q)
    boost_params = {
      :table => table,
      :factual_id => factual_id,
      :q => q,
      :user => user }

    Write::Boost.new(@api, boost_params)
  end

  def flag(table, user, factual_id, problem, opts={})
    flag_params = {
      :table => table,
      :factual_id => factual_id,
      :problem => problem,
      :user => user }

    data = opts[:data] || opts["data"]
    flag_params[:data] = data if data

    fields = opts[:fields] || opts["fields"]
    flag_params[:fields] = fields if fields

    Write::Flag.new(@api, flag_params)
  end

  def submit(*params)
    values = {}
    values = params.pop if params.last.is_a? Hash

    table, user, factual_id = params
    submit_params = {
      :table => table,
      :user => user,
      :factual_id => factual_id,
      :values => values }
    Write::Submit.new(@api, submit_params)
  end

  def insert(*params)
    values = {}
    values = params.pop if params.last.is_a? Hash

    table, user = params
    insert_params = {
      :table => table,
      :user => user,
      :values => values }
    Write::Insert.new(@api, insert_params)
  end

  private

  def generate_token(key, secret)
    OAuth::AccessToken.new(OAuth::Consumer.new(key, secret))
  end
end
