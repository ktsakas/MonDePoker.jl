module RandomPlayer
using ..PokerGame

export ask_bet

function ask_bet(player::PokerPlayer, bet_to_call::UInt32)::BetOption
    #println("random strategy")
    if rand(1:10) in 1:4
        return Fold()
    elseif rand(1:10) == 4
        return Raise(max(20, 2 * bet_to_call))
    else
        return bet_to_call == 0 ? Check() : Call(bet_to_call)
    end
end
end
