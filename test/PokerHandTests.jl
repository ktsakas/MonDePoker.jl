include("../src/PokerHand.jl")
using Test, .PokerHand

@test to_hand_tuples("2♠ 6♣ 6♦ A♥ 5♦ Q♦ 9♦") == [('2', '♠'), ('6', '♣'), ('6', '♦'), ('A', '♥'), ('5', '♦'), ('Q', '♦'), ('9', '♦')]