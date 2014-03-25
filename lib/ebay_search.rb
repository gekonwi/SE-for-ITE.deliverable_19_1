require 'typhoeus'
require 'xmlsimple'

class EbaySearch
	MY_APP_ID = "GeorgKon-f675-471e-9e8a-9fdb2e584344"

	# Returns an Item object repreenting the currently offered
	# ebay item with the lowest item_prize+shipping_prize and
	# a title which matches the query.
	#
	# If there is no such item this returns nil.
	def self.cheapest_item(query)
		request = self.create_request(query)
		request.run
		# do some request checking
		xml = request.response.body

		hash = XmlSimple.xml_in(xml)

		return hash["searchResult"][0]["item"].size
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
				"paginationOutput.totalEntries" =>  1
				},
				headers: { Accept: " application/xmll" }
			)
	end
end