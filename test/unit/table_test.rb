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

  test "adding a player to a table should have the player sitting down" do
    player = Player.new("John")
    player.sit_down @table
    assert player.sitting_down?
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
  test "dealing the players should leave a dealt table" do
    john = Player.new("John")
    paul = Player.new("Paul")
    john.sit_down @table
    paul.sit_down @table
    @table.deal
    assert @table.dealt?
  end

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
  
  # state tests
  test "a fresh table should be in start state" do
    assert_equal :start, @table.state
  end

  test "a dealt table should be in dealt state" do
    john = Player.new("John")
    paul = Player.new("Paul")
    john.sit_down @table
    paul.sit_down @table
    @table.deal
    assert_equal :dealt, @table.state
  end

  test "a flopped table should be in flopp state" do
    @table.flop
    assert_equal :flop, @table.state
  end

  test "a flopped and turned table should be in turn state" do
    @table.flop
    @table.turn
    assert_equal :turn, @table.state
  end

  test "a flopped, turned and rivered table should be in river state" do
    @table.flop
    @table.turn
    @table.river
    assert_equal :river, @table.state
  end
  
  # position tests
  test "first player should go on first position" do
    john = Player.new("John")
    john.sit_down @table
    assert_equal john, @table[0]
  end

  test "second player should go on second position" do
    john = Player.new("John")
    paul = Player.new("Paul")
    john.sit_down @table
    paul.sit_down @table
    assert_equal paul, @table[1]
  end

  test "first player standing up should leave second player on second position" do
    john = Player.new("John")
    paul = Player.new("Paul")
    john.sit_down @table
    paul.sit_down @table
    john.stand_up
    assert_equal paul, @table[1]
  end

  test "sitting down after standing up should leave new player on first position" do
    john = Player.new("John")
    paul = Player.new("Paul")
    john.sit_down @table
    paul.sit_down @table
    john.stand_up
    john.sit_down @table
    assert_equal john, @table[0]
  end
  
  test "position should be known by player" do
    john = Player.new("John")
    john.sit_down @table
    assert_equal 0, @table.position(john)
  end
  
  # dealer and blinds tests
  test "there shouldn't be a dealer on a table with one player" do
    john = Player.new("John")
    john.sit_down @table
    assert_nil @table.dealer
  end

  test "adding players should not result in a dealer" do
    john = Player.new("John")
    paul = Player.new("Paul")
    john.sit_down @table
    paul.sit_down @table
    assert_nil @table.dealer
  end
  
  test "dealing the flop should result in a dealer" do
    john = Player.new("John")
    paul = Player.new("Paul")
    john.sit_down @table
    paul.sit_down @table
    @table.flop
    assert_not_nil @table.dealer
  end

  # head-to-head, first flop dealer/blinds tests:
  test "dealing the flop head-to-head should result in the expected dealer" do
    john = Player.new("John")
    paul = Player.new("Paul")
    john.sit_down @table
    paul.sit_down @table
    @table.flop
    assert_equal john, @table.dealer
  end

  test "dealing the flop head-to-head should result in the expected small blind" do
    john = Player.new("John")
    paul = Player.new("Paul")
    john.sit_down @table
    paul.sit_down @table
    @table.flop
    assert_equal john, @table.small_blind
  end

  test "dealing the flop head-to-head should result in the expected big blind" do
    john = Player.new("John")
    paul = Player.new("Paul")
    john.sit_down @table
    paul.sit_down @table
    @table.flop
    assert_equal paul, @table.big_blind
  end

  # head-to-head, second flop dealer/blinds tests:
  test "dealing the second flop head-to-head should result in the expected dealer" do
    john = Player.new("John")
    paul = Player.new("Paul")
    john.sit_down @table
    paul.sit_down @table
    @table.flop
    @table.reset # correct?
    @table.flop
    assert_equal paul, @table.dealer
  end

  test "dealing the second flop head-to-head should result in the expected small blind" do
    john = Player.new("John")
    paul = Player.new("Paul")
    john.sit_down @table
    paul.sit_down @table
    @table.flop
    @table.reset # correct?
    @table.flop
    assert_equal paul, @table.small_blind
  end

  test "dealing the second flop head-to-head should result in the expected big blind" do
    john = Player.new("John")
    paul = Player.new("Paul")
    john.sit_down @table
    paul.sit_down @table
    @table.flop
    @table.reset # correct?
    @table.flop
    assert_equal john, @table.big_blind
  end
  
  # 2-plus, first flop dealer/blinds tests:
  test "dealing the flop should result in the expected dealer" do
    john = Player.new("John")
    paul = Player.new("Paul")
    george = Player.new("George")
    john.sit_down @table
    paul.sit_down @table
    george.sit_down @table
    @table.flop
    assert_equal john, @table.dealer
  end

  test "dealing the flop should result in the expected small blind" do
    john = Player.new("John")
    paul = Player.new("Paul")
    george = Player.new("George")
    john.sit_down @table
    paul.sit_down @table
    george.sit_down @table
    @table.flop
    assert_equal paul, @table.small_blind
  end

  test "dealing the flop should result in the expected big blind" do
    john = Player.new("John")
    paul = Player.new("Paul")
    george = Player.new("George")
    john.sit_down @table
    paul.sit_down @table
    george.sit_down @table
    @table.flop
    assert_equal george, @table.big_blind
  end

  # 2-plus, second flop dealer/blinds tests:
  test "dealing the second flop should result in the expected dealer" do
    john = Player.new("John")
    paul = Player.new("Paul")
    george = Player.new("George")
    john.sit_down @table
    paul.sit_down @table
    george.sit_down @table
    @table.flop
    @table.reset # correct?
    @table.flop
    assert_equal paul, @table.dealer
  end

  test "dealing the second flop should result in the expected small blind" do
    john = Player.new("John")
    paul = Player.new("Paul")
    george = Player.new("George")
    john.sit_down @table
    paul.sit_down @table
    george.sit_down @table
    @table.flop
    @table.reset # correct?
    @table.flop
    assert_equal george, @table.small_blind
  end

  test "dealing the second flop should result in the expected big blind" do
    john = Player.new("John")
    paul = Player.new("Paul")
    george = Player.new("George")
    john.sit_down @table
    paul.sit_down @table
    george.sit_down @table
    @table.flop
    @table.reset # correct?
    @table.flop
    assert_equal john, @table.big_blind
  end
  
end