include("../src/PokerGameRules.jl")
using Test, .PokerHand, .PokerGameRules

# validate straight flush
@test get_best_hand(to_hand_tuples("4♥ 8♥ Q♣ 6♥ 5♥ T♠ 7♥")).combo == straight_flush
@test get_best_hand(to_hand_tuples("4♥ 8♥ 5♣ 6♥ 5♥ T♠ 7♥")).combo == straight_flush

# validate four of a kind in hand
@test get_best_hand(to_hand_tuples("6♠ 6♣ Q♦ 6♥ 5♦ 6♣ 9♦")).combo == quads

# validate full house
@test get_best_hand(to_hand_tuples("T♠ T♣ 5♣ 6♥ 5♦ T♠ 9♠")).combo == full_house

# validate flush
@test get_best_hand(to_hand_tuples("6♦ T♣ Q♦ 6♥ 5♦ 3♦ 9♦")).combo == PokerGameRules.flush

# validate straight
@test get_best_hand(to_hand_tuples("4♠ 8♣ 5♣ 6♥ 5♦ T♠ 7♠")).combo == straight

# validate three of a kind
@test get_best_hand(to_hand_tuples("A♦ A♣ A♠ K♥ 3♠ 6♦ 9♦")).combo == three_of_a_kind

# HAND RANKING TESTS

@testset "compare straight flush" begin
    straight_flush_hand = to_hand_tuples("2♦ A♣ 5♦ K♥ 3♦ 6♦ 4♦")

    ### better than four of a kind
    @test is_hand_better(straight_flush_hand, "4♦ 4♣ 4♠ K♥ 4♠ 6♦ K♦" |> to_hand_tuples) == true
    ### better than full house
    @test is_hand_better(straight_flush_hand, "A♦ A♣ A♠ K♥ 3♠ 6♦ K♦" |> to_hand_tuples) == true
end

@testset "compare four of a kind" begin
    quads_hand = to_hand_tuples("7♦ 7♣ 5♦ 7♥ 3♦ 6♦ 7♠")

    ### better than full house
    @test is_hand_better(quads_hand, "A♦ A♣ A♠ K♥ 3♠ 6♦ K♦" |> to_hand_tuples) == true
    ### worse than full straight
    @test is_hand_better(quads_hand, "8♣ 9♣ A♠ J♣ T♣ 6♦ 7♣" |> to_hand_tuples) == false
    ### worse than better quads
    @test is_hand_better(quads_hand, "T♦ K♣ K♠ K♥ 3♠ 6♦ K♦" |> to_hand_tuples) == false
end

@testset "compare full house" begin
    full_house_hand = to_hand_tuples("3♦ Q♦ 5♦ 5♣ T♦ 5♥ T♠")

    ### better than flush
    @test is_hand_better(full_house_hand, "4♣ 9♣ A♠ K♣ 3♣ 6♣ K♦" |> to_hand_tuples) == true
    ### tied full house
    @test is_hand_better(full_house_hand, "K♣ J♣ 5♦ 5♣ T♦ 5♥ T♠" |> to_hand_tuples) == Tie
    ### worse than full house with better triplet
    @test is_hand_better(full_house_hand, "7♦ T♣ 5♦ 5♣ T♦ 5♥ T♠" |> to_hand_tuples) == false
    ### worse than full house with better pair
    @test is_hand_better(full_house_hand, "A♦ A♣ 5♦ 5♣ T♦ 5♥ T♠" |> to_hand_tuples) == false
end

@testset "compare flush" begin
    flush_hand = to_hand_tuples("4♥ T♥ 5♦ 5♥ T♠ 9♥ K♥")

    ### better than straight
    @test is_hand_better(flush_hand, "8♦ A♣ 6♦ 5♣ Q♦ 7♥ 9♠" |> to_hand_tuples) == true
    ### tied flush
    @test is_hand_better(flush_hand, "4♥ T♥ A♦ 5♥ A♠ 9♥ K♥" |> to_hand_tuples) == Tie
    ### worse than better flush
    @test is_hand_better(flush_hand, "4♥ T♥ 5♦ 5♥ T♠ 9♥ A♥" |> to_hand_tuples) == false
end

## triplet
    ### better triplet
    @test is_hand_better("7♦ Q♣ Q♦ Q♥ 3♦ 6♦ J♠"  |> to_hand_tuples, "7♦ T♣ 5♦ K♥ 3♦ T♦ T♠" |> to_hand_tuples) == true

## pair
    ### better pair
    @test is_hand_better("7♦ Q♣ 5♦ 6♥ 3♦ 6♦ J♠"  |> to_hand_tuples, "7♦ Q♣ 5♦ 5♥ 3♦ 6♦ J♠" |> to_hand_tuples) == true

@testset "compare high cards" begin
    ### better high card
    @test is_hand_better("7♦ Q♣ 5♦ A♥ 3♦ 6♦ J♠"  |> to_hand_tuples, "7♦ Q♣ 5♦ K♥ 3♦ 6♦ J♠" |> to_hand_tuples) == true

    ### tie high card
    @test is_hand_better("T♦ Q♣ A♦ 7♥ 3♦ 6♦ 2♠"  |> to_hand_tuples, "T♣ Q♥ A♦ 7♥ 3♦ 6♦ 2♠" |> to_hand_tuples) == Tie
end
