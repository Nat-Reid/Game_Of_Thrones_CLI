def access_regions
  response = RestClient.get("https://api.got.show/api/regions/")
  JSON.parse(response.body)
  # binding.pry
  # jj["data"]["children"].each_with_index do |post, index|
  # puts "#{index}. " + post["data"]["title"]
end

def seed_regions
  puts "- Seeding Region Data"
  Region.destroy_all
  access_regions.each do |region_hash|
    Region.create(name: region_hash["name"])
  end
end

seed_regions

def access_houses
  response = RestClient.get("https://api.got.show/api/houses/")
  JSON.parse(response.body)
end

def seed_houses
  puts "- Seeding House Data"
  House.destroy_all
  access_houses.each do |house_hash|
    region_id = Region.find_by(name: house_hash["region"])&.id #in case region doesn't exist
    if region_id && house_hash["coatOfArms"]
      House.create(region_id: region_id,
                  name: house_hash["name"],
                  coat_of_arms: house_hash["coatOfArms"],
                  ancestral_weapon: house_hash["ancestralWeapon"].first)
    end
  end
end

seed_houses

def access_characters
  response = RestClient.get("https://api.got.show/api/characters/")
  JSON.parse(response.body)
end

def seed_characters
  puts "- Seeding Character Data"
  Character.destroy_all
  access_characters.each do |character_hash|
    house_id = House.find_by(name: character_hash["house"])&.id
    if house_id
      Character.create(house_id: house_id,
                        name: character_hash["name"],
                        title: character_hash["titles"].first,
                        culture: character_hash["culture"])
    end
  end
end

seed_characters

def access_events
  JSON.parse(File.read("./json_seed_info/character_events.json"))
end

def seed_events
  puts "- Seeding Event Data"
  Event.destroy_all
  CharacterEvent.destroy_all
  access_events.each do |event_hash|
    region_id = Region.find_by(name: event_hash["region"])&.id
    new_event = Event.create(region_id: region_id,
                name: event_hash["name"])
    seed_character_event(event_hash["characters"], new_event.id)
    #for each character in the array find character_id, create characterEvents
  end
end

def seed_character_event(character_names, event_id)
  character_names.each do |char_name|
    char_id = Character.find_by(name: char_name)&.id
    CharacterEvent.create(character_id: char_id, event_id: event_id)
  end
end

seed_events


#takes super long but only way to get more than 10 char
# 6:28 vs 2:10
# def access_books
#   i = 1
#   while i < 1400
#     response = RestClient.get("https://www.anapioficeandfire.com/api/characters/#{i}")
#     jsonFile = JSON.parse(response.body)
#     #puts jsonFile["name"]
#     i += 1
#   end
# end
#
#
# access_books





#############################
