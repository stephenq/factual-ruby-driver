class Factual
  module Write
    class Flag < Base
      VALID_KEYS = [:table, :factual_id, :data, :problem, :user, :comment, :debug, :reference, :fields, :preferred]

      def initialize(api, params)
        validate_params(params)
        super(api, params)
      end

      VALID_KEYS.each do |key|
        define_method(key) do |*args|
          Flag.new(@api, @params.merge(key => form_value(args)))
        end
      end

      def path
        "/t/#{@params[:table]}/#{@params[:factual_id]}/flag"
      end

      private

      def validate_params(params)
        params.keys.each do |key|
          raise "Invalid flag option: #{key}" unless VALID_KEYS.include?(key)
        end
      end
    end
  end
end
