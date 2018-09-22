#!/usr/bin/env ruby
require_relative "eu4_save"

class Array
  def to_csv(csv_filename="hash.csv")
    require 'csv'
    CSV.open(csv_filename, "wb") do |csv|
      csv << first.keys # adds the attributes name on the first line
      self.each do |hash|
        csv << hash.values
      end
    end
  end
end

class Printer

  def print_all(gamestate, path)
    p "All"
    save = EU4Save.new(gamestate)
    save.stats.to_csv(path)
  end

  def raw(gamestate, path)
    save = EU4Save.new(gamestate)
    File.write(path, save)
  end

  def print_tag(gamestate, tag, path)
    p "Tag: #{tag.first}" 
    save = EU4Save.new(gamestate)
    tag = save.countries.select{ |t, _| t == tag}.first
    File.write(path, tag)
  end

  def tag_or_all(gamestate, path, *tag)
    tag.first ? print_tag(gamestate, tag.first, path) : print_all(gamestate, path)
  end

end

Printer.new.tag_or_all(*ARGV)
