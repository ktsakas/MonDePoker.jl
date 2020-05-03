module HonestPlayer
using ..MonteCarlo,..PokerGame

export HonestAgent, ask_bet

function ask_bet(player::PokerPlayer, bet_to_call::UInt32)::BetOption
    win_chance = get_win_chance(player.cards)
    #println("honest ", win_chance.win_count, " / ", win_chance.total, " = ", win_chance.win_count / win_chance.total)
    return (win_chance.win_count / win_chance.total) > 0.15 ? Call(bet_to_call) : Fold()
end

const HonestAgent = PokerAgent(ask_bet)
end
