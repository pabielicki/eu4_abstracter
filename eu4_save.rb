require_relative "./lib/paradox"
require "active_support"

class Country
  attr_reader :tag, :node
  def initialize(tag, node)
    @tag = tag
    @node = node

  end
  def property_list
    ["capped_development" ,"realm_development", "treasury", "base_tax", "manpower", "max_manpower", "sailors", "max_sailors", "stability", "prestige", "forts", "num_of_cities", "num_of_allies", "average_effective_unrest", "average_autonomy", "average_home_autonomy", "total_war_worth", "powers", "inflation", "institutions"]
  end

  def sub_unit
    @node["sub_unit"]
  end

  def army
    @node.find_all("army").map{|n| n.find_all("regiment")}.flatten(1).map{|r| {type: r["type"]}}
  end

  def navy
    @node.find_all("navy").map{|n| n.find_all("ship")}.flatten(1).map{|s| {type: s["type"]}}
  end

  def navy_by_type
    @node.find_all("navy").map{|n| n.find_all("ship")}.flatten(1).group_by{|s| s["type"]}.map{|t, s| {t => s.count}}
  end

  def unit_count(type)
    army.select{ |r| r[:type] == sub_unit[type]}.count
  end

  def fleet_count(type)
    navy.select{ |r| r[:type] == sub_unit[type]}.count
  end

  def infantry_count
    unit_count("infantry")
  end

  def cavalry_count
    unit_count("cavalry")
  end

  def artillery_count
    unit_count("artillery")
  end

  def take_property(property)
    @node[property]
  end

  def income
    take_property("ledger")["lastmonthincome"]
  end

  def expense
    take_property("ledger")["lastmonthexpense"]
  end

  def balance
    income - expense
  end

  def subjects_tags
    take_property["subjects"]
  end

  def subjects
    human_subjects.select{ |tag, _| subjects_tags.include?(tag) }
  end

  def technology
    @node["technology"].to_h.map{ |k,v| {k => v} }
  end

  def pl
    property_list.map{ |p| {p => take_property(p) }}
  end

  def to_out
    { "tag" => @tag,
      "income" => income,
      "expense" => expense,
      "balance" => balance,
      "technology" => technology, 
      "army" => army.count,
      "infantry" => infantry_count,
      "cavalry" => cavalry_count,
      "artillery" => artillery_count,
      "navy" => navy_by_type}
    .merge(pl.reduce({}, :merge))
  end

  def to_s
    "Country<#{@tag}>"
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

  def humans
    @humans = countries.select{ |k,v| v.node["human"] || k == "BUR" }
  end

  def human_subjects_tags
    humans.map{ |tag, country| country.node["subjects"] }.flatten(1).compact
  end

  def human_subjects
   @human_subjects ||= countries.select{ |k, v| human_subjects_tags.include?(k) }
  end

  def subject_of_human(human_tag)
    human_subjects.select{ |k, v| v.node["overlord"] == human_tag }
  end

  def stats
    humans.flat_map do |tag, c|
      [c.to_out] + subject_of_human(tag).map{ |_, x| x.to_out }
    end
  end

  def to_s
    "EU4Save<#{@path}>"
  end
  alias_method :to_s, :inspect
end
