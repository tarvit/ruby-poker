require File.expand_path("../test_helper", File.dirname(__FILE__))

class TableTest < ActiveSupport::TestCase
  def setup
    @table = Table.new
  end

  # table setup
  test "a new table should not have any players" do
    assert @table.empty?
  end
  
  test "adding a player to a table should add the player" do
    player = Player.new("John")
    player.sit_down @table
    assert @table.has_player? player
  end

  test "adding a player to a table should have the player at table" do
    player = Player.new("John")
    player.sit_down @table
    assert player.at_table? @table
  end

  test "adding a player twice to a table should not add the player twice" do
    player = Player.new("John")
    player.sit_down @table
    player.sit_down @table
    assert_equal 1, @table.players.size
  end
  
  test "removing a player from a table should remove the player" do
    player = Player.new("John")
    player.sit_down @table
    player.stand_up
    assert !(@table.has_player? player)
  end
  
  test "adding an 11th player to the table should fail" do
    assert_raise RuntimeError do
      11.times { Player.new("John").sit_down @table }
    end
  end
  
  # dealing tests
  test "dealing the players should give a hole to all players" do
    john = Player.new("John")
    paul = Player.new("Paul")
    john.sit_down @table
    paul.sit_down @table
    @table.deal
    assert john.dealt?
    assert paul.dealt?
  end
  
  test "dealing the flop should have 3 cards on the table" do
    @table.flop
    assert_equal 3, @table.cards.size
  end

  test "dealing the flop should take a burn card and 3 cards off the deck" do
    @table.flop
    assert_equal 48, @table.deck.size
  end

  test "dealing the turn should have 4 cards on the table" do
    @table.flop
    @table.turn
    assert_equal 4, @table.cards.size
  end

  test "dealing the turn should take two burn cards and 4 cards off the deck" do
    @table.flop
    @table.turn
    assert_equal 46, @table.deck.size
  end

  test "dealing the river should have 5 cards on the table" do
    @table.flop
    @table.turn
    @table.river
    assert_equal 5, @table.cards.size
  end

  test "dealing the river should take 3 burn cards and 5 cards off the deck" do
    @table.flop
    @table.turn
    @table.river
    assert_equal 44, @table.deck.size
  end
  
end