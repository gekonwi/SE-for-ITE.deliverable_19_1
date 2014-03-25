require 'ebay_search'

class CheapestController < ApplicationController
	def search
	end

	def show
		@hash = EbaySearch.cheapest_item(params[:q])
	end
end
