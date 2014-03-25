require 'ebay_search'

class CheapestController < ApplicationController
	def search
	end

	def show
		@query = params[:q]
		@item = EbaySearch.cheapest_item(@query)
	end
end
