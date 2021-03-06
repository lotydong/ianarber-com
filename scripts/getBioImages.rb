# not able to use data in _data/contentful/spaces/_posts.yaml as they only
# contain post data and not asset data. So use Contentful Ruby plugin instead
require 'contentful'

# need to add these 2 values to environment
spaceId = ENV['CONTENTFUL_SPACE_ID']
accessToken = ENV['CONTENTFUL_ACCESS_TOKEN']

total_images = 6
image_urls = {}

# function definition ton convert a string value to a number
def convert_to_number(string)
    Integer(string || '')
rescue ArgumentError
    nil
end


##-----##-----## END VARIABLES AND FUNCTION DEFINITIONS ##-----##-----##


# This creates the Client for this Space/Access Token pair
client = Contentful::Client.new(
    space: spaceId,
    access_token: accessToken,
    dynamic_entries: :auto
)

# return only assets with 'aboutpage-bioimage' in its title
assets = client.assets('fields.title[match]' => 'aboutpage-bioimage')

# loop through returned image urls
counter = 0
while counter < total_images do
    # return only the index number in the filename e.g. aboutpage-bioimage-1.jpg => 1.jpg
    url = "#{assets.items[counter].fields[:file].url}"
    file = url.gsub(/.*-/, "")

    # remove extension and cast as Integer
    file = convert_to_number(file.gsub(/\.[A-Za-z]+/, ""))

    # add url to hash using index number as key
    image_urls[file] = url
    counter += 1
end

# output to file
File.open("_bioimages/bio-images.md", "w") do |f|
    f.puts "---"
    f.puts "images:"

    # loop through keys in hash to produce ordered output of urls based on index number in filename
    (1..6).each do |i|
        f.puts "    - link: #{image_urls[i]}"
        f.puts "      alt: Bio Gallery Image #{i}"
        f.puts "      id: img-slide-#{i}"
    end

    f.puts "---"
end
