require 'singleton'

module Kernel
  def d
    DiceBag.instance
  end
end

class DiceDSL

  class << self

    def parse(dices)
      %r{^(?<top_or_bottom>t|b)?(?<tb_number>\d)?\[(?<dice>.*)\](?<explode>\*)?(?<plus>\+\d+)?\=?(?<target>.*)?$} =~ dices
      die_set = eval "[" + string_to_dice_array(dice) + "]"
      dice_pool({set: die_set, top: tb_number.to_i, plus: plus.to_i})
    end

    def dice_pool(*args)
      DicePool.new(*args)
    end

    def string_to_dice_array(dice)
      dice.gsub(/\s+/, '').
        split("+").
        map{|ds| ds.split('d') }.
        collect {|how_many, dice_face| (["d^#{dice_face}"]*how_many.to_i ).join(",") }.
        join(",")
    end

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
      DicePool.new set: how_many.times.collect{ what.clone.reroll }, top: keep, plus: plus
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

class DicePool

  attr_reader :how_many, :top_number_of_dice, :results, :set
  attr_writer :how_many, :top_number_of_dice, :results

  def initialize(set: nil, plus: 0, top: 2)
    @set = set.is_a?(Die) ? [set] : set
    raise 'Dice passed to DicePool must be instances of Die.' unless @set.any?{|s| s.is_a?(Die) }
    @plus = plus
    @how_many = 100_000
    @top_number_of_dice = top
    # generate_results
  end

  def highest(top: @top_number_of_dice, re_roll: false)
    reroll if re_roll
    highest_results = @set.sort_by{|d| d.value }.reverse[0..top-1] 
    return highest_results.map(&:to_i).inject(0){|sum,i| sum += i } + @plus
  end
  alias :result :highest

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
    data = ""
    data << "Running #{@how_many} times, taking the top #{@top_number_of_dice}, the breakdown of results by value rolled are:"
    data << "\n" + ("…" * 100) + "\n"
    r.sort.each do |total, count| 
      percentage = (count.to_f/@how_many.to_f)
      data << sprintf("%3d ", total)
      data << '('
      data << sprintf("%5.2f", percentage * 100)
      data << "%) "
      dots = (percentage*500).to_i
      if dots > 100 
        data << '°' * 80
        data << "*(#{dots})"
      else
        data << '°' * (percentage*500).to_i
      end
      data << "\n"
    end
    data
  end

  def roll_results
    @set.inspect
  end

  def results
    "results: #{(@results.sort_by {|k,v| k }).to_h.inspect}"
  end

  def total
    # @set.map(&:value).inject(0){|sum, i| sum += i} + @plus
    highest(top: @top_number_of_dice)
  end

  def inspect
    puts "<DicePool:\n  @set: #{@set.inspect}, @plus: #{@plus}, @total: #{total}, @top: #{@top_number_of_dice}>"
  end

  def self.inspect 
    puts "<DicePool:\n  @set: #{@set.inspect}, @plus: #{@plus}, @total: #{total}, @top: #{@top_number_of_dice}>"
  end

end


Dice = DiceBag.instance 


# ds=DiceDSL.parse("3[4d6]"); [ds.reroll.total, ds.reroll.total, ds.reroll.total, ds.reroll.total, ds.reroll.total, ds.reroll.total]
