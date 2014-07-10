class Factual
  module Write
    class Flag < Base
      PROBLEMS = [:closed, :duplicate, :nonexistent, :inaccurate, :inappropriate, :spam, :relocated, :other]
      VALID_KEYS = [:table, :factual_id, :problem, :user, :comment, :debug, :reference, :fields, :preferred]
      DEPRECATED_KEYS = [:data]

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
          raise "Deprecated flag option: #{key}" if DEPRECATED_KEYS.include?(key)
          raise "Invalid flag option: #{key}" unless VALID_KEYS.include?(key)
        end

        unless PROBLEMS.include?(params[:problem])
          raise "Flag problem should be one of the following: #{PROBLEMS.join(", ")}"
        end
      end
    end
  end
end
