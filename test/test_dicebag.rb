require 'minitest'
require "minitest/spec"
require 'dicebag'

puts "HERE"

class T < MiniTest::Test
  def test_this_thing
    assert false
  end
end
# class DiceTest < MiniTest::Test
#   test "this should work" do
#     puts "test"
#   end
#   # describe Dice do 

#   #   it "must be okay" do
#   #     puts "HERE"
#   #     @d = Dice.new
#   #     @d.must_not be nil
#   #   end

#   # end
# end
# describe "Marvel::Character" do

#   before do
#     VCR.use_cassette 'spidey' do
#       @spidey = Marvel::Character.find(SPIDER_MAN_ID)
#     end
#   end

#   it "should work ok" do
#     assert_equal "Spider-Man", @spidey.name
#     @spidey.name.must_equal "Spider-Man"
#   end

#   after do
#     VCR.eject_cassette 'spidey'
#   end
# end
# # class HolaTest < Test::Unit::TestCase
# #   def test_english_hello
# #     assert_equal "hello world",
# #       Hola.hi("english")
# #   end

# #   def test_any_hello
# #     assert_equal "hello world",
# #       Hola.hi("ruby")
# #   end

# #   def test_spanish_hello
# #     assert_equal "hola mundo",
# #       Hola.hi("spanish")
# #   end
# # end
