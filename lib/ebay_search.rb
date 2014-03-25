require 'typhoeus'
require 'xmlsimple'

class EbaySearch
	MY_APP_ID = "GeorgKon-f675-471e-9e8a-9fdb2e584344"

	# Returns an Item object repreenting the currently offered
	# ebay item with the lowest item_price+shipping_price and
	# a title which matches the query.
	#
	# If there is no such item this returns nil.
	def self.cheapest_item(query)
		request = self.create_request(query)
		request.run
		# do some request checking
		xml = request.response.body
		hash = XmlSimple.xml_in(xml)
		item_hash = hash["searchResult"][0]["item"][0]

		pp item_hash
		return create_item(item_hash)
	end

	private

	def self.create_request(query)
		return Typhoeus::Request.new(
			"http://svcs.ebay.com/services/search/FindingService/v1",
			method: :get,
			params: {
				"OPERATION-NAME" => "findItemsByKeywords",
				"SERVICE-VERSION" => "1.0.0",
				"SECURITY-APPNAME" => MY_APP_ID,
				"RESPONSE-DATA-FORMAT" => "XML",
				#{}"REST-PAYLOAD" => nil, # no value required
				"keywords" => query,
				"itemFilter(0).name" => "AvailableTo",
				"itemFilter(0).value" => "US",
				"itemFilter(1).name" => "Condition",
				"itemFilter(1).value" => "New",
				"itemFilter(2).name" => "ListingType",
				"itemFilter(2).value" => "FixedPrice",
				"sortOrder" => "PricePlusShippingLowest",
				"paginationInput.entriesPerPage" =>  1 # request only the first item
				},
				headers: { Accept: " application/xmll" }
			)
	end

	def self.create_item(hash)
		item = Item.new
		item.title = hash["title"][0]

		current_price = hash["sellingStatus"][0]["currentPrice"][0]
		if current_price["currencyId"] != "USD"
			current_price = hash["sellingStatus"][0]["convertedCurrentPrice"][0]
		end
		item.item_price = "USD #{current_price["content"]}"

		shipping_cost_info = hash["shippingInfo"][0]["shippingServiceCost"][0]
		item.shipping_price = "#{shipping_cost_info["currencyId"]} #{shipping_cost_info["content"]}"

		item.view_url = hash["viewItemURL"][0]
		item.pic_url = hash["galleryURL"][0]

		return item
	end
end