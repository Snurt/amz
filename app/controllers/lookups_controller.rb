class LookupsController < ApplicationController
  # GET /lookups
  # GET /lookups.xml
  def index
    require 'rexml/document' 
    require 'hmac-sha2'
    require 'open-uri'

    @SecretKey='l1OK46EWvCPid1jKYBzWR0aT1jz1U+luT5CG/VHm'
    @AWSAccessKeyId='AKIAIWVW3RXPPPYYY6DA'
    @ItemId="0679722769"
    @Operation="ItemSearch"
    @ResponseGroup="Large"
    @Keywords=if params[:keywords]==nil then "Camera" else params[:keywords] end
    @SearchIndex='Photo'
    if !(@Brand=params[:brand]) then @Brand=" " end
    @BrowseNode='330405011';   #Point & Shoot Digital Cameras
    @Service='AWSECommerceService'
    @Timestamp=CGI.escape(Time.new.strftime("%Y-%m-%dT%H:%M:%SPDT"))
    @Version='2009-01-06'

    @sstring=''
#    @sstring="GET\nwebservices.amazon.com\n/onca/xml\n"
    @sstring+='AWSAccessKeyId='+@AWSAccessKeyId
    @sstring+='&Brand='+@Brand
    @sstring+='&BrowseNode='+@BrowseNode
    @sstring+='&Keywords='+URI.escape(@Keywords)
    @sstring+='&Operation='+@Operation
    @sstring+='&ResponseGroup='+@ResponseGroup
    @sstring+='&SearchIndex='+@SearchIndex
    @sstring+='&Service='+@Service
    @sstring+='&Timestamp='+@Timestamp
    @sstring+='&Version='+@Version

    @aaaqs='http://webservices.amazon.com/onca/xml?'+@sstring   

    hmac = HMAC::SHA256.new(@SecretKey)
    hmac.update("GET\nwebservices.amazon.com\n/onca/xml\n"+@sstring)
    @aaaqs+='&Signature='+CGI::escape(Base64.encode64(hmac.digest).chomp)
## chomp is important! the base64 encoded version will have a newline at the end

    @doc= REXML::Document.new open(@aaaqs).read
    @ItemArray=Array.new

    @NumItems=@doc.elements["ItemSearchResponse/Items/TotalResults"].text
    @NumPages=@doc.elements["ItemSearchResponse/Items/TotalPages"].text

    @doc.elements.to_a("ItemSearchResponse/Items/Item/").each do |items|
      @ItemArray << [items.elements["*/Title"], items.elements["*/Manufacturer"], items.elements["*/LowestNewPrice/FormattedPrice"]]
   end
  end
end

