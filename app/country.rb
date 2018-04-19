require_relative "../lib/paradox"
require_relative "./army"
require_relative "./economy"
require "active_support"

class Country
  attr_reader :tag, :node, :army, :economy
  def initialize(tag, node)
    @tag = tag
    @node = node
    @army = Army.new(node)
    @economy = Economy.new(node)
  end

  def subjects_tags
    take_property["subjects"]
  end

  def subjects
    human_subjects.select{ |tag, _| subjects_tags.include?(tag) }
  end

  def to_out
    { "tag" => @tag }
    .merge(@economy.print!).merge(@army.print!).merge({ "total_war_worth" => @node["total_war_worth"]})
  end

  def to_s
    "Country<#{@tag}>"
  end
  alias_method :to_s, :inspect
end

