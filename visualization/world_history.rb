#!/usr/bin/env ruby

require_relative "../lib/paradox"

class ProvinceState
  attr_reader :state
  def initialize
    @state = {
      "cores" => [],
      "claims" => [],
      "discovered_by" => [],
    }
  end

  def command!(key, val)
    case key
    when "add_core"
      @state["cores"] |= [val]
    when "add_claim"
      @state["claims"] |= [val]
    when "remove_core"
      @state["cores"] -= [val]
    when "remove_claim"
      @state["claims"] -= [val]
    when "discovered_by"
      @state["discovered_by"] << val
    when "advisor"
      # We don't care
    when "controller"
      # This is weird
      @state[key] = val["controller"]
    when "revolt"
      # This is not persistent state change, just one off event
    else
      @state[key] = val
    end
  end

  def commands!(cmds)
    cmds.each do |key, val|
      command!(key, val)
    end
  end
end

class WorldHistory
  attr_reader :data, :provinces, :history
  def initialize(path)
    @path = path
    @data = ParadoxModFile.new(path: @path).parse!
    analyze!
  end

  def start_date
    @data["start_date"]
    # @start_date ||= Date.new(*@data["start_date"].split(".").map(&:to_i), Date::JULIAN)
  end

  def current_date
    # @data["date"]
    @current_date ||= Date.new(*@data["date"].split(".").map(&:to_i), Date::JULIAN)
  end

  def player
    @player ||= @data["player"]
  end

  def human?(tag)
    @data["countries"][tag]["was_player"] || tag == "MJZ"
  end

  def subject?(tag)
    !@data["countries"][tag]["overlord"].nil?
  end

  def overlord_is_human?(tag)
    overlord_tag = @data["countries"][tag]["overlord"]
    overlord_tag ? human?(overlord_tag) : false
  end

  def color(tag)
    defined = {
      "PER" => [54, 117, 136],
      "QNG" => [166,124,0],
      "PRU" => [95,111,124]
    }
    if defined[tag]
      defined[tag]
    else
      @data["countries"][tag]["colors"]["map_color"]
    end
  end

  def overlord_color(tag)
    overlord_tag = @data["countries"][tag]["overlord"]
    color(overlord_tag)
  end


  def country_color(tag)
    if @data["countries"][tag]
      color(tag)
    else
      [107, 66, 38]
    end
  end
  
  def human_color(tag)
    if @data["countries"][tag] && (human?(tag) || overlord_is_human?(tag))
      human?(tag) ? color(tag) : overlord_color(tag)
    else
      [107, 66, 38]
    end
  end
  # State at the end if date is nil
  def province_state(id, date=nil)
    state = ProvinceState.new
    provinces.fetch(id, {}).each do |key, val|
      if key.is_a?(Date)
        state.commands!(val) if date.nil? or key <= date
      else
        state.command!(key, val)
      end
    end
    state.state
  end

  private

  def analyze!
    @provinces = {}
    @data["provinces"].each do |id, data|
      # Sea provinces often don't have any history
      @provinces[-id] = data["history"] if data["history"]
    end

    @countries = {}
    @data["countries"].each do |id, data|
      @countries[id] = data["history"] if data["history"]
    end
  end
end

if __FILE__ == $0
  wh = WorldHistory.new(*ARGV)

  wh.provinces.keys.map{|id|
    puts "Province #{id}"
    [1400, 1450, 1500, 1550, 1600].each do |year|
      p({"year" => year}.merge(wh.province_state(id, Date.new(year, 1, 1, Date::JULIAN))))
    end
    puts ""
  }
end
