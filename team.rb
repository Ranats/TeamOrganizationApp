require "rubygems"
require "sinatra"
require "sinatra/reloader"
require "erb"

#require "net/http"
#require "uri"
#require 'json'

require 'open-uri'
require 'nokogiri'

set :server, "webrick"

class UserInfo

  def initialize(isDebug)
    @users = []
    @icons = []
    page = get_page_info
    entry_users = page.search('//div[@class="group_inner event_p_area"]').search('//div[@class="thumb25_list"]')

    @num_of_users = entry_users.size

    entry_users.each do |node|
      @users.<< node.css('img').attribute('alt').value
      @icons << node.css('img').attribute('src').value
#      puts node.css('img').attribute('alt').value
#      puts node.css('img').attribute('src').value
    end

    if(isDebug)
      puts "number of users : #{@num_of_users}"
      puts "_____users_____",@users
      puts "_____icons_____",@icons
    end

  end

  attr_accessor :num_of_users,:users,:icons

  def get_page_info
    url = "http://connpass.com/event/17033"
    charset = nil
    html = open(url) do |f|
      charset = f.charset
      f.read
    end
    return Nokogiri::HTML.parse(html,nil,charset)
  end
end

user_info = UserInfo.new(false)

get '/' do
  @users = user_info.users
  @num_of_users = user_info.num_of_users
  @icons = user_info.icons
  @title = 'Team Organization'
  erb :team
end

post '/' do
  @checked = params[:checked].shuffle!
  @num = params[:min_member]
  @team = Array.new(@checked.size/@num.to_i){Array.new(@num.to_i)}
  @icons = {}

  user_info.users.each_with_index do |elem,i|
    @icons[elem] = user_info.icons[i]
  end

  i = 0
  (@checked.size / @num.to_i).times do |j|
    (@num.to_i).times do |k|
      @team[j][k] = @checked[i]
      i+=1
    end
  end

  while i<@checked.size do
    @team[rand((@checked.size/@num.to_i))] << @checked[i]
    i+=1
  end

  @title = 'Team Organization'

  erb :result
end