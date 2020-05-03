include("../poker_engine/PokerGame.jl")
include("../poker_engine/MonteCarlo.jl")
include("./agents/HonestPlayer.jl")
include("./agents/RandomPlayer.jl")
using .PokerGame

println(typeof(HonestPlayer.ask_bet), HonestPlayer.ask_bet isa Function)
play(UInt32(100), [
    RandomPlayer.ask_bet,
    RandomPlayer.ask_bet,
    RandomPlayer.ask_bet,
    HonestPlayer.ask_bet,
    HonestPlayer.ask_bet,
    HonestPlayer.ask_bet])
