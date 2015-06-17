module Cmr
  class CmrClient < BaseClient

    # Example for pulling collections from CMR. (Search Epic will use this)
    # To get list of collections:
    # client = Cmr::Client.client_for_environment('sit', Rails.configuration.services)
    # client.get_collections().body['feed']['entry']
    # TODO this is currently using the CMR Search API. We will switch to the CMR Ingest API when we get access.
    def get_collections(options={}, token=nil)
      format = options.delete(:format) || 'json'
      query = options_to_collection_query(options).merge(include_has_granules: true, include_granule_counts: true)
      get("/search/collections.#{format}", query, token_header(token))
    end
  end
end