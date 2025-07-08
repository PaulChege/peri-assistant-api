require 'httparty'

class GooglePlacesService
  def initialize(api_key = ENV['GOOGLE_PLACES_API_KEY'])
    @api_key = api_key
  end

  # Optionally accept location_bias and max_result_count for more advanced queries
  def search(query, location_bias: nil, page_size: 5)
    body = {
      textQuery: query,
      pageSize: page_size,
      includedType: 'school',
    }
    body[:locationBias] = location_bias if location_bias

    headers = {
      'Content-Type' => 'application/json',
      'X-Goog-Api-Key' => @api_key,
      'X-Goog-FieldMask' => 'places.id,places.displayName,places.formattedAddress,places.primaryType,places.primaryTypeDisplayName'
    }

    response = HTTParty.post(ENV['GOOGLE_PLACES_API_BASE_URL'], headers: headers, body: body.to_json)
    if response.success? && response.parsed_response['places'].present?
      { 'results' => response.parsed_response['places'].map { |result| result.dig('displayName', 'text') } }
    else
      { 'results' => [] } # TODO: Monitor error
    end
  end
end 