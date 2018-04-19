require_relative "../lib/paradox"
require "active_support"

class Economy
  attr_reader :node

  def initialize(node)
    @node = node
  end

  def income
    @node['ledger']['lastmonthincome']
  end

  def expense
    @node['ledger']['lastmonthexpense']
  end

  def balance
    income - expense
  end

  def technology
    @node["technology"].to_h.map{ |k,v| {k => v} }
  end

  def capped_development
    @node['capped_development']
  end

  def realm_development
    @node['realm_development']
  end

  def treasury
    @node['treasury']
  end

  def stability
    @node['stability']
  end

  def num_of_cities
    @node['num_of_cities']
  end

  def autonomy
    @node['average_home_autonomy']
  end

  def inflation
    @node['inflation']
  end

  def institutions
    @node['institutions']
  end

  def powers
    @node['powers']
  end

  def unrest
    @node['average_effective_unrest']
  end

  def loans
    @node.to_h.select{ |k,v| k=="loan" }
  end

  def loans_count
    c = loans.flat_map do |_, l|
      if l.class.to_s == "Array"
        l.count
      elsif l.class.to_s == "PropertyList"
        1
      end
    end
    c.first
  end

  def loans_amount
    a = loans.flat_map do |_, ls|
      if ls.class.to_s == "Array"
        ls.sum{ |x| x["amount"] }
      else
        ls["amount"]
      end
    end
    a.first
  end

  def print!
    {
      'capped_development' => capped_development,
      'realm_development' => realm_development,
      'treasury' => treasury,
      'income' => income,
      'expense' => expense,
      'balance' => balance,
      'loans_count' => loans_count,
      'loans_amount' => loans_amount,
      'inflation' => inflation,
      'stability' => stability,
      'unrest' => unrest,
      'num_of_cities' => num_of_cities,
      'autonomy' => autonomy,
      'powers' => powers,
      'technology' => technology,
      'institutions' => institutions
    }
  end

end
