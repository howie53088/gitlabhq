module Gitlab
  module Prometheus
    module Queries
      class AdditionalMetricsEnvironmentQuery < BaseQuery
        include QueryAdditionalMetrics

        def query(environment_id)
          Environment.find_by(id: environment_id).try do |environment|
            query_metrics(common_query_context(environment))
          end
        end
      end
    end
  end
end
