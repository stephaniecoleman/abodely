class BookmarkletsController < ApplicationController
before_action :check_referer, only: [:index]
 	
  # GET /bookmarklets
  # GET /bookmarklets.json
  def index
    @url = params[:url]
    user = current_user
    @bookmarklet = Bookmarklet.new(@url, user)
    @bookmarklet.run
    redirect_to user.latest_hunt
  end

  private
  def check_referer
    url = request.referer
    if !url.match("craigslist.org")
      binding.pry
      redirect_to url
    else
      cl_indicators = ["all housing", "postingbody"]
      contents = open(url) {|f| f.read }
      if cl_indicators.any? { |indicator| !contents.include?(indicator) }
        redirect_to url
      end
    end
  end
end