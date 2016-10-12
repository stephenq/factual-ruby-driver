class Factual
  module Query
    class Base
      include Enumerable

      def initialize(api, params)
        @api = api
        @params = params
      end

      attr_reader :action, :path, :params

      def each(&block)
        rows.each { |row| block.call(row) }
      end

      def last
        rows.last
      end

      def [](index)
        rows[index]
      end

      def data
        response["data"]
      end

      def rows
        data
      end

      def total_count
        if response.nil? || response["total_row_count"].nil? then
          resp = @api.get(self, :include_count => true, :limit => 1)
          resp["total_row_count"]
        else
          response["total_row_count"]
        end
      end

      def schema
        @schema ||= @api.schema(self)
      end

      # TODO move to Multiable module, and support multi writes
      def full_path
        @api.full_path(@action, @path, @params)
      end

      def populate(query_response)
        @response = query_response
      end

      def response
        @response ||= @api.get(self)
      end

      private

      def form_value(args)
        args = args.map { |arg| arg.is_a?(String) ? arg.strip : arg }
        args.length == 1 ? args.first : args.join(',')
      end

    end
  end
end
