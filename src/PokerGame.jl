module PokerGame
include("./MonteCarlo.jl")
using .MonteCarlo, .PokerGameRules, .PokerHand

export play

struct Bet size::Int64 end

struct Fold end
struct Check end
struct Call
    ammount::UInt32
end
struct Raise
    ammount::UInt32
end
const BetOption = Union{Fold, Check, Call, Raise}

abstract type PokerStrategy end
struct RandomStrategy <: PokerStrategy end
struct HonestStrategy <: PokerStrategy end

mutable struct PokerPlayer
    stack_size::UInt32
    current_bet::UInt32
    cards::MonteCarlo.CardTuples
    has_folded::Bool
    strategy::PokerStrategy
end

struct GameRules
    small_blind::UInt32
    big_blind::UInt32
    buy_in::UInt32
    total_players::UInt8
end

mutable struct GameState
    rules::GameRules
    button_pos::UInt8
    players::Array{PokerPlayer}

    pot_size::UInt32
    bet_to_call::UInt32
    deck::MonteCarlo.Deck
    community_cards::CardTuples

    #street::Union{PreFlop, Flop, River, Turn}
    #state::Union{Deal, PlayerAction}
end

function ask_bet(strategy::RandomStrategy, player::PokerPlayer, bet_to_call::UInt32)::BetOption
    #println("random strategy")
    if rand(1:10) in 1:4
        return Fold()
    elseif rand(1:10) == 4
        return Raise(max(20, 2 * bet_to_call))
    else
        return bet_to_call == 0 ? Check() : Call(bet_to_call)
    end
end

function ask_bet(strategy::HonestStrategy, player::PokerPlayer, bet_to_call::UInt32)::BetOption
    win_chance = get_win_chance(player.cards)
    #println("honest ", win_chance.win_count, " / ", win_chance.total, " = ", win_chance.win_count / win_chance.total)
    return (win_chance.win_count / win_chance.total) > 0.15 ? Call(bet_to_call) : Fold()
end

function charge_blinds!(game::GameState)
    bet!(game, game.players[game.button_pos + 1], game.rules.small_blind)
    bet!(game, game.players[game.button_pos + 2], game.rules.big_blind)
    game.bet_to_call = game.rules.big_blind
end

function deal_to_players!(game::GameState)
    for (idx, player) in enumerate(game.players)
        @assert length(player.cards) == 0

        player.cards = [MonteCarlo.deal!(game.deck), MonteCarlo.deal!(game.deck)]
    end
end

function deal_community_cards!(game::GameState, count::UInt8)
    for i = 1:count push!(game.community_cards, MonteCarlo.deal!(game.deck)) end
end

function next_player_idx(idx, total_players)
    return 1 + (idx - 1) % total_players
end

function bet!(game::GameState, player::PokerPlayer, ammount::UInt32)
    player.stack_size -= ammount
    player.current_bet += ammount
    game.pot_size += ammount
end

function betting_round!(game::GameState)
    if game.pot_size == 0
        charge_blinds!(game)
        starting_pIdx = game.button_pos + 3
        # println("blinds at ", starting_pIdx)
        # println("blinds at ", game.players[2].current_bet)
        # println("blinds at ", game.players[3].current_bet)
    else
        starting_pIdx = game.button_pos + 1
        # println("next to blind at ", starting_pIdx)
    end

    active_players = count(p-> !p.has_folded, game.players)
    pIdx = starting_pIdx
    k = 0
    while pIdx ≠ nothing && active_players > 1
        player = game.players[pIdx]
        # skip players who folded
        if !player.has_folded
            # println("k ", k, " folded ", player.has_folded, " playing ", pIdx, " active ", active_players)

            # println("gg ", game.bet_to_call, " ≥ ", player.current_bet)
            @assert game.bet_to_call ≥ player.current_bet
            player_to_call = game.bet_to_call - player.current_bet
            bet = ask_bet(player.strategy, player, player_to_call)

            if bet isa Fold
                game.players[pIdx].has_folded = true
                active_players -= 1
            elseif bet isa Check
            elseif bet isa Call
                bet!(game, player, bet.ammount)
            elseif bet isa Raise
                # on raise start a new betting round and stop this betting round
                bet!(game, player, bet.ammount)
                game.bet_to_call = player.current_bet
                starting_pIdx = pIdx
            end
        end

        pIdx = next_player_idx(pIdx + 1, length(game.players))
        if pIdx == starting_pIdx pIdx = nothing end
    end
end

function award_winner!(game::GameState)
    winners = []
    for player in game.players[1:length(game.players)]
        if player.has_folded continue end

        if isempty(winners)
            winners = [ player ]
        else
            has_better_hand = is_hand_better([player.cards; game.community_cards], [winners[1].cards; game.community_cards])
            if has_better_hand isa Bool && has_better_hand
                winners = [ player ]
            elseif has_better_hand isa Tie
                push!(winners, player)
            end
        end
    end

    # FIX THIS
    for winner in winners
        winnings = game.pot_size ÷ length(winners)
        winner.stack_size += winnings
    end
    # println(game.community_cards, " ", winners)
end

function reset_game!(game::GameState)
    game.pot_size = 0
    game.bet_to_call = 0
    game.deck = MonteCarlo.get_deck()
    game.community_cards = []
    game.button_pos = 1

    for pIdx = 1:length(game.players)
        game.players[pIdx].current_bet = 0
        game.players[pIdx].cards = []
        game.players[pIdx].has_folded = false
    end
end

function play(total_rounds::UInt32, rules::GameRules = GameRules(UInt32(10), UInt32(20), UInt32(1000), UInt8(6)))::GameState
    players = [
        [PokerPlayer(rules.buy_in, 0, [], false, RandomStrategy()) for i=1:3];
        [PokerPlayer(rules.buy_in, 0, [], false, HonestStrategy()) for i=1:3]
    ]
    button_pos = 1
    # game = GameState(
    #     button_pos = UInt8(1),
    #     small_blind = small_blind,
    #     big_blind = big_blind,
    #     players = players,
    #     pot_size = UInt32(0),
    #     active_player_idx = UInt8(2),
    #     bet_to_call = UInt32(0),
    #     deck = get_deck(),
    #     community_cards = [])
    game = GameState(rules, UInt8(button_pos), players, UInt32(0), UInt32(0), MonteCarlo.get_deck(), [])

    for i = 1:total_rounds
        reset_game!(game)

        # Pre-flop
        # charge_blinds!(game)
        deal_to_players!(game)
        betting_round!(game)

        # Flop
        deal_community_cards!(game, UInt8(3))
        betting_round!(game)

        # River
        deal_community_cards!(game, UInt8(1))
        betting_round!(game)

        # Turn
        deal_community_cards!(game, UInt8(1))
        betting_round!(game)

        award_winner!(game)
        println("community cards ", game.community_cards)
        for (pIdx, p) in enumerate(game.players)
            # if p.has_folded continue end
            println(pIdx, ". ", typeof(p.strategy), " - ", (p.has_folded, p.cards), " ", p.stack_size)
        end
        println("=====================================================")

        total_after_game = Int64(sum(p -> p.stack_size, game.players))
        @assert (1000 * 6) == total_after_game
    end

    return game
end

# NOT WORKING YET
play(UInt32(100))

end
