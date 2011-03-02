module Mogli
  class FqlMultiquery
    attr_reader :client, :queries, :raw_response
    
    # Takes Mogli::Client object
    def initialize(client)
      @client   = client
      @queries  = {}
    end
    
    # Adds single query to multiquery with class used to populate results
    def add_named_query_for_class(name, query, klass)
      @queries[name] = [query, klass]
    end
    
    # Fetch and parse results.
    # Returns hash with the query names as keys, class objects as values.
    # An empty or missing subquery value is returned as an empty array.
    def results
      parse_response @raw_response = @client.fql_multiquery(query_map)
    end
    
    protected
    
    def query_map
      @queries.each_key.inject({}) { |res,k| res[k] = @queries[k][0]; res }
    end
    
    def parse_response(response)
      # Fetch each subquery and map its results to the desired class,
      @queries.each_key.inject({}) do |res, name|
        # Default value is empty array
        res[name] = []
        # Find subquery by name in response
        vals = response.find{|r| r['name'] == name.to_s}
        if vals && vals.has_key?('fql_result_set')
          res[name] = @client.map_to_class(vals['fql_result_set'], @queries[name][1])
        end
        res
      end
    end
  end
end