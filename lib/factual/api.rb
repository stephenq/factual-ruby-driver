class Factual
  class API
    VERSION = "1.3.17"
    API_V3_HOST = "api.v3.factual.com"
    DRIVER_VERSION_TAG = "factual-ruby-driver-v" + VERSION
    PARAM_ALIASES = { :search => :q, :sort_asc => :sort }

    def initialize(access_token, debug_mode = false, host = nil, timeout = nil)
      @access_token = access_token
      @debug_mode = debug_mode
      @timeout = timeout
      @host = host || API_V3_HOST
      @headers = {}
    end

    def apply_header(key, value)
      @headers[key] = value if value
    end

    def get(query, other_params = {})
      merged_params = query.params.merge(other_params)
      handle_request(query.action || :read, query.path, merged_params)
    end

    def post(request)
      handle_request(nil, request.path, request.body, :post)
    end

    def schema(query)
      handle_request(:schema, query.path, query.params)["view"]
    end

    def raw_get(path, query)
      path = '/' + path unless path =~ /^\//
      url = "http://#{@host}#{path}"

      qs = query_string(query)
      url += "?#{qs}" unless qs.empty?

      resp = make_request(url)
      payload = JSON.parse(resp.body)
      handle_payload(payload)
    end

    def raw_post(path, body)
      path = '/' + path unless path =~ /^\//
      url = "http://#{@host}#{path}"
      resp = make_request(url, query_string(body), :post)
      payload = JSON.parse(resp.body)
      handle_payload(payload)
    end

    def diffs(view_id, params = {})
      start_date = (params[:start] || params["start"] || 0).to_i * 1000
      end_date = (params[:end] || params["end"] || Time.now).to_i * 1000

      path = "/t/#{view_id}/diffs?start=#{start_date}&end=#{end_date}"
      url = "http://#{@host}#{path}"
      resp = make_request(url)

      resp.body.split("\n").collect do |rowJson|
        row = JSON.parse(rowJson)
      end
    end

    def full_path(action, path, params)
      fp = "/#{path}"
      fp += "/#{action}" unless action == :read

      qs = query_string(params)
      fp += "?#{qs}" unless qs.empty?

      fp
    end

    private

    def handle_request(action, path, params, method=:get)
      if (method == :get)
        url = "http://#{@host}" + full_path(action, path, params)
        req = make_request(url)
      else
        url = "http://#{@host}#{path}"
        req = make_request(url, params, :post)
      end
      payload = JSON.parse(req.body)

      if (path == '/multi')
         payload.inject({}) do |res, item|
           name, p = item
           res[name] = handle_payload(p)
           res
         end
      else
        handle_payload(payload)
      end
    end

    def handle_payload(payload)
      raise StandardError.new(payload.to_json) unless payload["status"] == "ok"
      payload["response"] || payload["status"]
    end

    def make_request(url, body=nil, method=:get)
      start_time = Time.now

      headers = { "X-Factual-Lib" => DRIVER_VERSION_TAG }
      headers.merge!(@headers)

      res = if (method == :get)
              Timeout::timeout(@timeout){ @access_token.get(url, headers) }
            elsif (method == :post)
              Timeout::timeout(@timeout){ @access_token.post(url, body, headers) }
            else
              raise StandardError.new("Unknown http method")
            end

      elapsed_time = (Time.now - start_time) * 1000
      debug(url, method, headers, body, res, elapsed_time) if @debug_mode

      if res.code == '301' && res['location']
        res = make_request(res['location'])
      end

      res
    end

    def query_string(params)
      query_array = params.keys.inject([]) do |array, key|
        param_alias = PARAM_ALIASES[key.to_sym] || key.to_sym
        value = params[key].class == Hash ? params[key].to_json : params[key].to_s
        array << "#{param_alias}=#{CGI.escape(value)}"
      end

      query_array.join("&")
    end

    def debug(url, method, headers, body, res, elapsed_time)
      res_headers = res.to_hash.inject({}) do |h, kv|
        k, v = kv
        h[k] = v.join(',')
        h
      end

      puts "--- Driver version: #{DRIVER_VERSION_TAG}"
      puts "--- request debug ---"
      puts "req url: #{url}"
      puts "req method: #{method.to_s.upcase}"
      puts "req headers: #{JSON.pretty_generate(headers)}"
      puts "req body: #{body}" if body
      puts "---------------------"
      puts "--- response debug ---"
      puts "resp status code: #{res.code}"
      puts "resp status message: #{res.message}"
      puts "resp headers: #{JSON.pretty_generate(res_headers)}"
      puts "resp body: #{res.body}"
      puts "---------------------"
      puts "Elapsed time: #{elapsed_time} msecs"
      puts
    end
  end
end
