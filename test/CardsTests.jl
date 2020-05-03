include("../poker_engine/Cards.jl")
using Test, .Cards

@testset "test card equality with shorthand notation" begin
    @test 2♠ == Card(2, ♠)
    @test 5♣ == Card(5, ♣)
    @test Q♦ == Card(12, ♦)
    @test A♥ == Card(14, ♥)
end
