require "rubygems"
require "fastercsv"
require "attlib"
require "uri"

# Helper method to check if URI is valid
def uri?(string)
    uri = URI.parse(string)
    %w( http https ).include?(uri.scheme)
rescue URI::BadURIError
    false
rescue URI::InvalidURIError
    false
end

# Following is the list of fields pulled from each line of data
fields = [
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
    "dvceScreenHeight"]

# Create a new output file
FasterCSV.open("output.csv", "w", { :col_sep => "\t" }) do |csv|

    # Open the raw tsv file, and process each line one at a time
    FasterCSV.foreach("events_pbz.txt", { :col_sep => "\t" }) do |row|
    	
        # Create a Hash of all the data points in the line by zipping with fields array
    	eventData = Hash[fields.zip(row)]

    	unless eventData["pageReferrer"].nil? 
    		puts("page_referrer = " + eventData["pageReferrer"])
    	end
    	
        # Second check to see if the marketing fields are set AND if page_referrer is a valid URL...

    	if (eventData["mktMedium"].nil? and 
            eventData["mktSource"].nil? and 
            eventData["mktTerm"].nil? and 
            eventData["mktContent"].nil? and
            eventData["mktCampaign"].nil? and
            uri?(eventData["pageReferrer"])
            ) then
    		
            referrer = Referrer.new(eventData["pageReferrer"])

    		if referrer.is_search_engine?
    			# set mkt_medium = "organic", mkt_source = searceventData engine name, mkt_term = searceventData engine terms
    			eventData['mktMedium'] = "organic"
    			eventData['mktSource'] = referrer.is_search_engine?
    			eventData['mktTerm'] = referrer.keywords

            elsif eventData["pageReferrer"].include? "psychicbazaar.com"
                # do not do anything - referrer is internal, so don't set any mkt values

    		else
    			# if not search engine, set `mktMedium` to `referrer` and `mktSource` to referrer domain
    			eventData['mktMedium'] = "referrer"
    			eventData['mktSource'] = URI(eventData['pageReferrer']).host
    			# set mkt_medium = "referrer", mkt_source = domain(pageReferrer)
    		end
    	end

    	puts "pageReferrer = " + (eventData["pageReferrer"]|| "") + " mktMedium = " + (eventData["mktMedium"]|| "") + 
          " mktSource" + (eventData["mktSource"]|| "")

        # Now write a new line of data to the output.csv file. 
        # Note - we use the original field array to maintain order of fields in output
        csv << fields.map { |f|  eventData[f]  } 

    end

end