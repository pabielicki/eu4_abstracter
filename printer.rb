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
  def print(gamestate, path)
    save = EU4Save.new(gamestate)
    save.stats.to_csv(path)
  end
end

Printer.new.print(*ARGV)
