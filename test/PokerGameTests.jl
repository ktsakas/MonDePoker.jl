include("../poker_engine/PokerGame.jl")
using Test, .PokerGame

@testset "total money doesn't change" begin
    game_state = play(UInt32(1), GameRules(UInt32(10), UInt32(20), UInt32(1000), UInt8(6)))
    total_after_game = Int64(sum(p -> p.stack_size, game_state.players))
    @test (1000 * 6) == total_after_game
end
