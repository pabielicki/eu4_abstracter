require_relative "../lib/paradox"

class Country
  attr_reader :tag, :node
  def initialize(tag, node)
    @tag = tag
    @node = node
  end

  def primary_culture
    @primary_culture ||= @node["primary_culture"]
  end

  def accepted_cultures
    @accepted_cultures ||= @node.find_all("accepted_culture")
  end

  def government_rank
    @government_rank ||= @node["government_rank"]
  end

  def institutions
    @institutions ||= @node["institutions"]
  end

  def technology_group
    @technology_group ||= @node["technology_group"]
  end

  def num_of_cities
    @num_of_cities ||= @node["num_of_cities"].to_i
  end

  def idea_groups
    @active_idea_groups ||= @node["active_idea_groups"].enum_for(:each).to_a
  end

  def to_s
    "Country<#{@tag}>"
  end
  alias_method :to_s, :inspect
end

class Province
  attr_reader :id, :node
  def initialize(id, node)
    @id = id
    @node = node
  end

  def city?
    @node["is_city"]
  end

  def development
    (@node["base_tax"] || 0) +
    (@node["base_production"] || 0) +
    (@node["base_manpower"] || 0)
  end

  def owner
    @node["owner"]
  end

  def culture
    @node["culture"]
  end

  def local_autonomy
    @node["local_autonomy"] || 0
  end

  def min_autonomy
    @node["min_autonomy"] || 0
  end

  def effective_autonomy
    [local_autonomy, min_autonomy].max
  end

  def buildings
    (@node["buildings"] || {}).keys
  end

  def to_s
    "Province<#{@id}>"
  end
  alias_method :to_s, :inspect
end

class EU4Save
  attr_reader :path, :data
  def initialize(path)
    @path = path
    @data = ParadoxModFile.new(path: @path).parse!
  end

  def countries
    @countries ||= begin
      @data["countries"]
        .enum_for(:each)
        .map{|tag, node| [tag, Country.new(tag, node)] }
        .to_h
    end
  end

  def provinces
    @provinces ||= begin
      @data["provinces"]
        .enum_for(:each)
        .map{|id, node| [-id, Province.new(-id, node)] }
        .to_h
    end
  end

  def institutions
    @institutions ||= @data["institutions"] # => [1, 1, 0, 0, 0, 0, 0]
  end

  def institutions_penalties
    @institutions_penalties ||= @data["institutions_penalties"] # => [0.5, 0.07, 0.0, 0.0, 0.0, 0.0, 0.0]
  end

  def date
    @data["date"]
  end

  def player_tag
    @player_tag ||= @data["countries"].enum_for(:each).find{|k,v| v["human"]}.first
  end

  def humans
    @humans ||= @data["countries"].select{ |k,v| v.node["human"] }
  end

  def property_list
    ["capped_development" ,"realm_development", "treasury", "base_tax", "manpower", "max_manpower", "sailors", "max_sailors", "stability", "prestige", "forts", "num_of_controlled_cities", "num_of_allies", "average_effective_unrest", "average_autonomy", "average_home_autonomy", "total_war_worth", "technology"]
  end

  def take_property(humans, property)
    humans.map{ |k, v| {k => v.node[property]}}
  end


  def print_stats(humans)
    property_list.map do |property|
      {property => take_property(humans, property)}
    end
  end

  USELESS_DATA = ["mothballed_forts", "mil_spent_indexed", "dip_spend_indexed", "adm_spend_indexed", "losses", "assigned_estates", "ai"]

  def except(s, *keys)
    s.dup.except!(s, *keys)
  end

  def except!(s, *keys)
    keys.each { |key| s.delete(key) }
    s
  end

  def navy(humans)
    humans.map{ |k, v| {k => v.node["navy"].count} }
  end

  def aggressive_expansion
    @active_relations ||= begin
      map = {}
      @data["countries"].each do |tag, country|
        next unless country["active_relations"]
        country["active_relations"].each do |tag2, relations|
          relations.find_all("opinion").each do |opinion|
            next unless opinion["modifier"] == "aggressive_expansion"
            map[tag2] ||= {}
            map[tag2][tag] = -opinion["current_opinion"]
          end
        end
      end
      map
    end
  end

  def to_s
    "EU4Save<#{@path}>"
  end
  alias_method :to_s, :inspect
end
