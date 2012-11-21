require "rubygems"
require "fastercsv"
require "attlib"
require "uri"

header_arry = [
    "appId", 
    "platform",
    "dt",
    "tm",
    "eventName",
    "txnId",
    "vTracker",
    "vCollector",
    "vEtl",
    "userId",
    "userIpaddress",
    "visitId",
    "pageUrl",
    "pageTitle",
    "pageReferrer",
    "mktSource",
    "mktMedium",
    "mktTerm",
    "mktContent",
    "mktCampaign",
    "evCategory",
    "evAction",
    "evLabel",
    "evProperty",
    "evValue",
    "trOrderid",
    "trAffiliation",
    "trTotal",
    "trTax",
    "trShipping",
     "trCity",
    "trState",
    "trCountry",
    "tiOrderid",
    "tiSku",
    "tiName",
    "tiCategory",
    "tiPrice",
    "tiQuantity",
    "brName",
    "brFamily",
    "brVersion",
    "brType",
    "brRenderengine",
    "brLang",
    "brFeaturesPdf",
    "brFeaturesFlash",
    "brFeaturesJava",
    "brFeaturesDirector",
    "brFeaturesQuicktime",
    "brFeatursRealplayer",
    "brFeaturesWindowsmedia",
    "brFeaturesGears",
    "brFeaturesSilverlight",
    "brCookies",
    "osName",
    "osFamily",
    "osManufacturer",
    "dvceType",
    "dvceIsmobile",
    "dvceScreenwidth",
    "dvceScreenheight"]

FasterCSV.foreach("events_pbz.txt", { :col_sep => "\t" }) do |row|
	# First create a hash by zipping with header_arry
	h = Hash[header_arry.zip(row)]

	unless h["pageReferrer"].nil? 
		puts("page_referrer = " + h["pageReferrer"])
	end
	# Second check to see if `mkt_medium`, `mkt_source`, `mkt_campaign`, `mkt_term` or `mkt_content` are set, and if so, leave

	if ( h["mktMedium"].nil? and h["mktSource"].nil? and h["mktTerm"].nil? and h["mktContent"].nil? and h[mktCampaign].nil? and h["pageReferrer"].include?("psychicbazaar.com")) 
		referrer = Referrer.new(h["pageReferrer"])

		if referrer.is_search_engine?
			# set mkt_medium = "organic", mkt_source = search engine name, mkt_term = search engine terms
			h['mktMedium'] = "organic"
			h['mktSource'] = referrer.is_search_engine
			h['mktTerm'] = referrer.keywords

		else
			# if not search engine, set `mktMedium` to `referrer`
			h['mktMedium'] = "referrer"
			h['mktSource'] = URI(h['pageReferrer']).host
			# set mkt_medium = "referrer", mkt_source = domain(pageReferrer)
		end
	end

	puts "pageReferrer = " + h["pageReferrer"] + "mktMedium = " + h["mktMedium"] + "mktSource" + h["mktSource"]

end
