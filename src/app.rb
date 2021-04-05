require "csv"
require "tty-prompt"
require "tty-table"
require "colorize"
# prompt = TTY::Prompt.new

def append_to_user_csv(username, password, head=nil, body=nil, arm=nil, leg=nil, back=nil, weapon_melee=nil, weapon_ranged=nil, shield=nil, pilot=nil)
    CSV.open("user.csv", "a") do |row|
        row << [username, password, head, body, arm, leg, back, weapon_melee, weapon_ranged, shield, pilot]
    end
end

def write_to_csv(users)
    headers = users.first.headers || ["username", "password", "build"]
    CSV.open("user.csv", "w") do |csv|
        csv << headers
        users.each do |user|
            csv << user
        end
    end
end

def load_user_details(all_users, username)
    all_users.each do |user|
        if user[:username] == username
            return user
        end
    end
end

def username_registered?(username)
    CSV.foreach("user.csv", "a+", headers: true, header_converters: :symbol) do |row|
        if row[:username] == username
            # puts row[0]
            return true
        end
    end
    return false
end

def request_part_name(message)
    print message
    return gets.chomp.downcase.split(/\s+/).each{ |word| word.capitalize! }.join(' ')
end

def request_username(message)
    print message
    return gets.chomp.downcase
end

def request_password(message)
    print message
    return gets.chomp.downcase
end

def category_menu
    prompt = TTY::Prompt.new
    prompt.select("Please select a category") do |menu|
        menu.choice "Head"
        menu.choice "Body"
        menu.choice "Arm"
        menu.choice "Leg"
        menu.choice "Back"
        menu.choice "Weapon_Melee"
        menu.choice "Weapon_Ranged"
        menu.choice "Shield"
        menu.choice "Pilot"
    end
end

def feature_menu
    prompt = TTY::Prompt.new
    prompt.select("What would you like to do?") do |menu|
        menu.choice "Review my current build"
        menu.choice "Start a new build"
        menu.choice "Search for parts by name"
        menu.choice "Filter and sort parts"
        menu.choice "Get a build recommendation"
        menu.choice "Log out"
    end
end

def title_menu
    prompt = TTY::Prompt.new
    prompt.select("What would you like to do?") do |menu|
        menu.choice "Sign up"
        menu.choice "Log in"
    end
end

def create_user_data_table(this_user)
    TTY::Table.new(
        [   "Part",             "Name",                         "  ",   "Type",       "S"],
        [
            ["Head",            this_user[:head],            "  ",   "Armor",      this_user[:head]], 
            ["Body",            this_user[:body],            "  ",   "Melee ATK",  this_user[:body]], 
            ["Arm",             this_user[:arm],             "  ",   "Shot ATK",   this_user[:arm]], 
            ["Leg",             this_user[:leg],             "  ",   "Melee DEF",  this_user[:leg]], 
            ["Back",            this_user[:back],            "  ",   "Shot DEF",   this_user[:back]], 
            ["Melee Weapon",    this_user[:weapon_melee],    "  ",   "Beam RES",   this_user[:weapon_melee]], 
            ["Ranged Weapon",   this_user[:weapon_ranged],   "  ",   "Phys RES",   this_user[:weapon_ranged]], 
            ["Shield",          this_user[:shield],          "  ",   nil,          nil], 
            ["Pilot",           this_user[:pilot],           "  ",   nil,          nil]
        ]
    )  
end

def search_parts(category)
    user_input = request_part_name("Please enter a Gundam name: ")
    CSV.foreach("#{category}.csv", :quote_char => "|", headers: true, header_converters: :symbol) do |row|
        if row[:name] == user_input
            part_details = TTY::Table.new(
                [
                    ["Name",       row[:name]],
                    ["", ""],
                    ["Type",       row[:type]],
                    ["Armor",      row[:armor]], 
                    ["Melee ATK",  row[:melee_atk]], 
                    ["Shot ATK",   row[:shot_atk]], 
                    ["Melee DEF",  row[:melee_def]], 
                    ["Shot DEF",   row[:shot_def]], 
                    ["Beam RES",   row[:beam_res]], 
                    ["Phys RES",   row[:phys_res]],
                    ["", ""],
                    ["EX Skill",        row[:ex_skill_name]],
                    ["Skill Type",      row[:ex_skill_type]],
                    ["Pierce",          row[:ex_skill_pierce]],
                    ["Power",           row[:ex_skill_power]],
                    ["Initial Charge",  row[:ex_skill_initial_cooldown]],
                    ["Cooldown",        row[:ex_skill_cooldown]],
                    ["", ""],
                    ["Trait 1",    row[:trait_1_description]],
                    ["Trait 2",    row[:trait_2_description]],
                    ["", ""],      
                    ["Word Tag 1", row[:word_tag_1]],
                    ["Word Tag 2", row[:word_tag_2]]
                ]
            )
            puts part_details.render(:unicode, alignments: [:left, :center])
            return row
        end
    end
    puts "Invalid name".colorize(:red)
end

def load_all_users
    all_users = []
    CSV.foreach("user.csv", headers: true, header_converters: :symbol) do |row|
        headers ||= row.headers
        all_users << row
    end
    return all_users
end

users = load_all_users
is_signed_in = false
# p all_users

puts "Welcome to GBM Helper"

user_choice = title_menu

case user_choice
when "Sign up"
    username = request_username("Please enter a username: ")
    is_username_found = username_registered?(username)
    while is_username_found
        username = request_username("Username is already taken\nPlease enter a different username: ")
        is_username_found = username_registered?(username)
    end
    password = request_password("Please enter a password: ")
    puts "Successful sign-up"
    append_to_user_csv(username, password)
    users = load_all_users
    this_user = load_user_details(users, username)
    # p this_user
    is_signed_in = true
    while is_signed_in
        user_choice = feature_menu
        case user_choice
        when "Review my current build"
            current_build = create_user_data_table(this_user)
            puts current_build.render(:unicode, alignments: [:left, :center])
        when "Start a new build"
            puts "a"
        when "Search for parts by name"
            puts "b"
        when "Filter and sort parts"
            puts "c"
        when "Get a build recommendation"
            puts "d"
        when "Log out"
            is_signed_in = false
            puts "Thank you for using GBM Helper"
        end
    end
when "Log in"
    username = request_username("Please enter your username: ")
    is_username_found = username_registered?(username)
    if is_username_found == true
        users = load_all_users
        this_user = load_user_details(users, username)
        password = request_password("Please enter your password: ")
        if password == this_user[:password]
            puts "Successful login"
            is_signed_in = true
            while is_signed_in
                user_choice = feature_menu
                case user_choice
                when "Review my current build"
                    current_build = create_user_data_table(this_user)
                    puts current_build.render(:unicode, alignments: [:left, :center])
                when "Start a new build"
                    users.each do |user|
                        if user[:username] == this_user[:username]
                            user[:head] = nil
                            user[:body] = nil
                            user[:arm] = nil
                            user[:leg] = nil
                            user[:back] = nil
                            user[:weapon_melee] = nil
                            user[:weapon_ranged] = nil
                            user[:shield] = nil
                            user[:pilot] = nil
                        end
                    end
                    write_to_csv(users)
                when "Search for parts by name"
                    user_choice = category_menu.downcase
                    search_parts(user_choice)
                when "Filter and sort parts"
                    puts "c"
                when "Get a build recommendation"
                    puts "d"
                when "Log out"
                    is_signed_in = false
                    puts "Thank you for using GBM Helper"
                end
            end
        else
            puts "Invalid password".colorize(:red)
        end
    else 
        puts "Username not found".colorize(:red) 
        puts "Please sign up for a new account"
    end
end
