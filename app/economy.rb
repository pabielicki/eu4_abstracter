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

  def income_table
    @node['ledger']['income']
  end
  def tax
    income_table ? income_table[0] : 0
  end

  def production
    income_table ? income_table[1] : 0
  end

  def trade
    income_table ? income_table[2] : 0
  end

  def gold
    income_table ? income_table[3] : 0
  end

  def stable_income
    (tax + production + trade + gold).round(3)
  end

  def expense
    @node['ledger']['lastmonthexpense']
  end

  def balance
    stable_income.to_f - expense.to_f
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

  def corruption
    @node['corruption']
  end

  def ideas
    @node['active_idea_groups'].to_h.map{ |k,v| {k => v} }
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
      'stable_income' => stable_income,
      'expense' => expense,
      'balance' => balance,
      'loans_count' => loans_count,
      'loans_amount' => loans_amount,
      'inflation' => inflation,
      'corruption' => corruption,
      'ideas' => ideas,
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
