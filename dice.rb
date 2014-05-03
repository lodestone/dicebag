# This allows me to generate output as follows.
#
# For a DiceSet:
#
# <DiceSet:
#   @set: [d8=>7, d10=>5, d12=>2, d8=>8, d6=>1]>
#
# > ds=DiceSet.new [d^8, d^10, d^12, d^8]
# > ds.graph
#
# > # OR
# > Dice.roll what: d^6, how_many: 4, keep: 3
#
#
# 
# Running 100000 times, taking the top 3, the breakdown of results by value rolled are:
# …………………………………………………………………………………………………………………………………………………………………………………………………………………………………………………………………………
#     3   ( 0.00%)
#     4   ( 0.01%)
#     5   ( 0.03%)
#     6   ( 0.08%)
#     7   ( 0.21%) °
#     8   ( 0.33%) °
#     9   ( 0.69%) °°°
#    10   ( 1.02%) °°°°°
#    11   ( 1.61%) °°°°°°°°
#    12   ( 2.34%) °°°°°°°°°°°
#    13   ( 3.25%) °°°°°°°°°°°°°°°°
#    14   ( 4.25%) °°°°°°°°°°°°°°°°°°°°°
#    15   ( 5.42%) °°°°°°°°°°°°°°°°°°°°°°°°°°°
#    16   ( 6.29%) °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
#    17   ( 7.41%) °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
#    18   ( 8.13%) °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
#    19   ( 8.74%) °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
#    20   ( 8.91%) °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
#    21   ( 8.68%) °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
#    22   ( 8.06%) °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
#    23   ( 6.98%) °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
#    24   ( 5.78%) °°°°°°°°°°°°°°°°°°°°°°°°°°°°
#    25   ( 4.41%) °°°°°°°°°°°°°°°°°°°°°°
#    26   ( 3.18%) °°°°°°°°°°°°°°°
#    27   ( 2.14%) °°°°°°°°°°
#    28   ( 1.26%) °°°°°°
#    29   ( 0.56%) °°
#    30   ( 0.19%)
#
# Similar Anydice function here: http://anydice.com/program/25a0
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
    Die.new(max)
  end

  def d
    self.instance
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

  def initialize(sides, plus=0)
    @plus = plus
    @sides = sides
    roll
  end

  def +(x)
    @plus = x
    reroll
  end

  def inspect; "d#{@sides}=>#{value}"; end

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
