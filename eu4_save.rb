require_relative "./lib/paradox"
require_relative "./app/country"
require "active_support"

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
    @humans ||= countries.select{ |k,v| v.node["was_player"] }
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
