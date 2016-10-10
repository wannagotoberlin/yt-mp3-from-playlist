require 'open-uri'
require 'json'

# The URL passed, no checks yet
puts "URL: #{ARGV[0]}"


# Get webpage to extract URL's of individual videos
page = open(ARGV[0]).read

puts "Downloaded the playlist page"

page = page.split('<table')[1]
page = page.split('table>')[0]

result = []
regex = /\?v=(.{11})/

puts "Extracting links"

page.scan(regex) do |match| 
	if not result.include? match 
		result << match 
	end
end

puts "Number of links extracted : #{result.size}"


# Iterate over each link and download the mp3 using existing tools online

result.each do |vid|
	vid = vid[0]

	dl_link = "http://www.youtubeinmp3.com/fetch/?video=youtube.com/watch?v=#{vid}#"
	data_link = "http://www.youtubeinmp3.com/fetch/?format=JSON&video=http://www.youtube.com/watch?v=#{vid}"


	# Get response on hitting the data_link 
	data = open(data_link).read

	info = {}
	song_title = ""


	# If correct info generated go ahead, if not go on the hard way
	begin
		
		info = JSON.parse(data)
		song_title = info['title']

	rescue Exception => e
		puts e
		puts "Error getting JSON info for #{vid}"

		# Generate a random title
		song_title = "song" + Random.rand(0..1000000).to_s


		# Get main web page and extract DL link
		mdp = open("http://www.youtubeinmp3.com/download/?video=https://www.youtube.com/watch?v=#{vid}").read
		mdl = mdp.split('id="download')[1].split('href')[1].split('"')[1]
		mdl = "http://www.youtubeinmp3.com" + mdl
		
		dl_link = mdl
	ensure
	end


	# Try downloading the current mp3
	begin
		`wget -O '#{song_title}' #{dl_link}`
	rescue Exception => e
		puts e
		puts "Failed to download #{vid}"
	end
end

