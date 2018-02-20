module Github
  module Jobs
    class Client
      BASE_URL = "https://jobs.github.com/"
      PAGE_SIZE = 50

      def self.positions(opts = {})
        fetch_paginated_data("positions.json", opts).map{ |data| convert_to_job(data) }
      end

      private

      def self.fetch_data(path)
        HTTParty.get(BASE_URL + path)
      end

      def self.fetch_paginated_data(path, opts)
        Enumerator.new do |yielder|
          page = 0

          loop do
            default_opts = {page: page}
            query_opts = default_opts.merge(opts)
            query_params = query_opts.to_query

            results = fetch_data("#{path}?#{query_params}")

            if results.success?
              results.map { |item| yielder << item }
              if results.parsed_response.length == PAGE_SIZE
                # May still have additional items
                page += 1
              else
                # Last page was not full, no need to continue
                raise StopIteration
              end
            else
              raise StopIteration
            end
          end
        end.lazy
      end

      def self.convert_to_job(data)
        Job.new(data["id"], data["location"], data["description"])
      end
    end
  end
end
