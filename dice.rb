require 'singleton'

module Kernel
  def d
    DiceBag.instance
  end
end

class DiceBag

  include Singleton

  def ^(max)
    @max = max
    Die.new(sides: max)
  end

  def roll(what: self, plus: 0, keep: nil, how_many: nil)
    puts "Rolling Away..."
    if what.is_a? Array
      keep = what.length if keep.nil?
      DiceSet.new set: what, top: keep, plus: plus
    elsif what.is_a? Die
      raise "Must include :how_many if you pass an individual Die" if how_many.nil?
      keep = how_many if keep.nil?
      DiceSet.new set: how_many.times.collect{ what.clone.reroll }, top: keep, plus: plus
    else
      raise what.class.inspect
    end
  end

end

class Die

  def initialize(sides: 6, plus: 0)
    @plus = plus
    @sides = sides
    roll
  end

  def +(x)
    @plus = x
    reroll
  end

  def inspect; "d#{@sides}#{"+#{@plus}" unless @plus.zero?}=>#{value}"; end

  def value; @value; end

  def roll; @value = rand(1..@sides)+@plus; self end

  def reroll; roll; end

  def to_s; value; end

  def to_i; value; end

end

class DiceSet

  attr_reader :how_many, :top_number_of_dice, :results
  attr_writer :how_many, :top_number_of_dice, :results

  def initialize(set: nil, plus: 0, top: 2)
    @set = set.is_a?(Die) ? [set] : set
    raise 'Dice passed to DiceSet must be instances of Die.' unless @set.any?{|s| s.is_a?(Die) }
    @plus = plus
    @how_many = 100_000
    @top_number_of_dice = top
    generate_results
  end

  def highest(top: @top_number_of_dice, re_roll: false)
    reroll if re_roll
    highest_results = @set.sort_by{|d| d.value }.reverse[0..top-1] 
    return highest_results.map(&:to_i).inject(0){|sum,i| sum += i } + @plus
  end

  def reroll
    @set.map(&:reroll)
    self
  end
  
  def roll; reroll; end

  def generate_results
    @results = Hash.new(0)
    @how_many.times { @results[highest(top: @top_number_of_dice, re_roll: true)] += 1  }
    self
  end

  def graph(r=@results)
    raise "There are no statistical results to graph. Run :generate_results" if r.empty?
    puts "Running #{@how_many} times, taking the top #{@top_number_of_dice}, the breakdown of results by value rolled are:"
    puts "…" * 100
    r.sort.each do |total, count| 
      percentage = (count.to_f/@how_many.to_f)
      printf "%3d ", total
      print '('
      printf "%5.2f", percentage * 100
      print "%) "
      dots = (percentage*500).to_i
      if dots > 100 
        print '°' * 80 
        print "*(#{dots})"
      else
        print '°' * (percentage*500).to_i
      end
      print "\n"
    end
    self
  end

  def results
    "results: #{(@results.sort_by {|k,v| k }).to_h.inspect}"
  end

  def inspect
    puts "<DiceSet:\n  @set: #{@set.inspect}>"
  end

  def self.inspect 
    puts "<DiceSet:\n  @set: #{@set.inspect}>"
  end

end


Dice = DiceBag.instance 
