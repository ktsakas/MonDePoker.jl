include("../poker_engine/PokerGame.jl")
include("../poker_engine/MonteCarlo.jl")
include("./agents/HonestPlayer.jl")
include("./agents/RandomPlayer.jl")
using .PokerGame, .RandomPlayer, .HonestPlayer

println(typeof(HonestPlayer.ask_bet), HonestPlayer.ask_bet isa Function)
play(UInt32(100), [
    RandomAgent,
    RandomAgent,
    RandomAgent,
    HonestAgent,
    HonestAgent,
    HonestAgent])
