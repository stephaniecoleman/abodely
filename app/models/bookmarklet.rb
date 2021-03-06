require 'nokogiri'
require 'open-uri'
require 'mechanize'

class Bookmarklet

	def initialize(url, user)
		@user = user
		@url = url
		@images = []
	end

	def run 
		@doc = Nokogiri::HTML(open(@url))
		scrape_images
		scrape_rent
		scrape_neighborhood
		scrape_contact
		create_apartment
		add_details
	end

	def scrape_images
		@doc.css('#thumbs a').each do |thumb|
    	@images << thumb['href']
		end
	end

	def scrape_rent
		@rent = @doc.at_css('.postingtitle').text.match(/\b\d+\b/)[0]
	end

	def scrape_neighborhood
		@neighborhood = @doc.at_css('.postingtitle').text.match(/\(.+/)[0].gsub(/\(|\)/, "")
	end

	def scrape_contact
		agent = Mechanize.new
		agent.get(@url)
		new_page = agent.page.link_with(:text => "show contact info")
		if new_page != nil
		  @number = new_page.click.body.match(/\d.?\d.?\d.?.?.?\d.?\d.?\d.?.?.?\d.?\d.?\d.?\d/)[0]
		else
		  @number = "See Craiglist page for contact info."
		end
	end

	def create_apartment
		hunt = @user.hunts.last
		@apartment = Apartment.new(:link => @url, :price => @rent, :street => @neighborhood, :contact => @number)
		@apartment.save
		hunt.apartments << @apartment
	end

	def add_details
		@images.each do |image_url|
			det = Detail.new(:remote_image_url => image_url, :apartment_id => @apartment.id)
			det.save
		end
	end

end



