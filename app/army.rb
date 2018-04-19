require_relative "../lib/paradox"
require "active_support"

class Army
  attr_reader :node
  def initialize(node)
    @node = node
  end

  def sub_unit
    @node["sub_unit"]
  end

  def land
    @node.find_all("army").map{|n| n.find_all("regiment")}.flatten(1).map{|r| {type: r["type"]}}
  end

  def navy
    @node.find_all("navy").map{|n| n.find_all("ship")}.flatten(1).map{|s| {type: s["type"]}}
  end

  def navy_by_type
    @node.find_all("navy").map{|n| n.find_all("ship")}.flatten(1).group_by{|s| s["type"]}.map{|t, s| {t => s.count}}
  end

  def unit_count(type)
    land.select{ |r| r[:type] == sub_unit[type]}.count
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

  def print!
    {
      "army" => land.count,
      "infantry" => infantry_count,
      "cavalry" => cavalry_count,
      "artillery" => artillery_count,
      "manpower" => @node['manpower'],
      "max_manpower" => @node['max_manpower'],
      "navy" => navy_by_type,
      "sailors" => @node['sailors'],
      "max_sailors" => @node['max_sailors'],
      "forts" => @node['forts']
    }
  end
end
