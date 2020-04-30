include("../src/PokerGame.jl")
using Test, .PokerGame

# total money equals six times the buy in
game_state = play(UInt32(1))
total_after_game = Int64(sum(p -> p.stack_size, game_state.players))
@test (1000 * 6) == total_after_game
