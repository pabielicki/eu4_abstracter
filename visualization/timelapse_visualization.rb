#!/usr/bin/env ruby

require "RMagick"
require "pp"
require_relative "../lib/paradox"
require_relative "image_generation"
require_relative "game_map"
require_relative "world_history"

class TimelapseVisualization < ParadoxGame
  include ImageGeneration
  include GameMap

  def initialize(save_game, *roots)
    @world = WorldHistory.new(save_game)
    @date = Date.new(1462, 11, 23)
    super(*roots)
  end

  def dates_to_generate(frequency=1)
    (@world.start_date.year...@date.year).step(frequency).map{|year|
      if year == @world.start_date.year
        @world.start_date
      else
        Date.new(year, 1, 1, Date::JULIAN)
      end
    } + [@date]
  end

  def months_between(start_month, end_month)
    months = []
    ptr = start_month
    while ptr <= end_month do
      months << ptr
      ptr = ptr >> 1
    end
    months
  end

  def monthly
    months_between(@world.start_date, @date)
  end

  # Dynamic countries (colonial nations) have their color only in save file
  # regular countries have it only in game data
  def country_color_for(tag)
    @world.human_color(tag) || country_colors[tag]
  end

  def generate_maps_for_date!(date)
    # let's start with religions
    # province_map = Hash[
    #   land_province_ids.map{|id|
    #     religion = @world.province_state(id, date)["religion"]
    #     [id, religion_colors[religion]]
    #   }
    # ]
    # generate_map_image(build_color_map(province_map)).write("campaign/religion-#{date.year}-#{date.month}-#{date.day}.png")

    # and owner
    province_map = Hash[
      land_province_ids.map{|id|
        owner = @world.province_state(id, date)["owner"]
        fake_owner = @world.province_state(id, date)["fake_owner"]
        o = fake_owner ? fake_owner : owner
        [id, country_color_for(o)]
      }
    ]
    generate_map_image(build_color_map(province_map)).write("/home/paveu/Desktop/maps/countries-#{date.year}-#{date.month}-#{date.day}.png")
  end

  def generate_maps!
    dates_to_generate.each do |date|
      generate_maps_for_date!(date)
    end
  end

  def generate_map!
    generate_maps_for_date!(@date)
  end
end

vis = TimelapseVisualization.new(*ARGV)
vis.generate_maps!
