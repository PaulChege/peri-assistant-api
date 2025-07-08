class InstitutionsController < ApplicationController
  def search
    query = params[:q]
    if query.blank?
      return json_response([])
    end

    results = GooglePlacesService.new.search(query)
    json_response(results)
  end
end 