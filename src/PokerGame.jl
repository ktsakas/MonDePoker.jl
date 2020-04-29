module PokerGame
include("./PokerGameRules.jl")
using .PokerGameRules, .PokerHand

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

mutable struct PokerPlayer
    stack_size::UInt32
    current_bet::UInt32
    cards::PokerGameRules.CardTuples
    has_folded::Bool
end

mutable struct GameState
    button_pos::UInt8
    small_blind::UInt32
    big_blind::UInt32
    players::Array{PokerPlayer}

    pot_size::UInt32
    active_player_idx::UInt8
    last_raise_pIdx::UInt8
    bet_to_call::UInt32
    deck::PokerGameRules.Deck
    community_cards::CardTuples

    #street::Union{PreFlop, Flop, River, Turn}
    #state::Union{Deal, PlayerAction}
end

function ask_bet(player::PokerPlayer, bet_to_call::UInt32)::BetOption
    if rand(1:10) == 1
        return Fold()
    elseif rand(1:10) == 2
        return Raise(max(20, 2 * bet_to_call))
    else
        return bet_to_call == 0 ? Check() : Call(bet_to_call)
    end
end

function charge_blinds!(game::GameState)
    game.pot_size += game.small_blind + game.big_blind
    game.players[game.button_pos + 1].current_bet += game.small_blind
    game.active_player_idx += 1
    game.players[game.button_pos + 2].current_bet += game.big_blind
    game.active_player_idx += 1
    game.last_raise_pIdx = 1
    game.bet_to_call = game.big_blind
end

function deal_to_players!(game::GameState)
    for (idx, player) in enumerate(game.players)
        @assert length(player.cards) == 0

        player.cards = [deal!(game.deck), deal!(game.deck)]
    end
end

function deal_community_cards!(game::GameState, count::UInt8)
    for i = 1:count push!(game.community_cards, deal!(game.deck)) end
end

function next_player_idx(idx, total_players)
    return 1 + (idx - 1) % total_players
end

function betting_round!(game::GameState)
    for i = 0:length(game.players)-1
        pIdx = next_player_idx(game.active_player_idx + i, length(game.players))
        player = game.players[pIdx]
        if player.has_folded continue end

        @assert game.bet_to_call ≥ player.current_bet
        player_to_call = game.bet_to_call - player.current_bet
        bet = ask_bet(player, player_to_call)

        if bet isa Fold
            game.players[pIdx].has_folded = true
        elseif bet isa Check
        elseif bet isa Call
            player.stack_size -= bet.ammount
            player.current_bet += bet.ammount
            game.pot_size += bet.ammount
        elseif bet isa Raise
            # on raise start a new betting round and stop this betting round
            player.stack_size -= bet.ammount
            player.current_bet += bet.ammount
            game.bet_to_call = player.current_bet
            game.pot_size += bet.ammount
            game.last_raise_pIdx = pIdx
            betting_round!(game)
            break
        end
    end
end

function award_winner!(game::GameState)
    winners = []
    for player in game.players[2:length(game.players)]
        if player.has_folded continue end

        if isempty(winners)
            winners = [ player ]
        else
            has_better_hand::Bool = is_hand_better([player.cards; game.community_cards], [winners[1].cards; game.community_cards])
            if has_better_hand
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
    println(game.community_cards, " ", winners)
end

function reset_game!(game::GameState)
    game.pot_size = 0
    game.bet_to_call = 0
    game.deck = get_deck()
    game.community_cards = []
    game.active_player_idx = 2
    game.last_raise_pIdx::UInt8

    for pIdx = 1:length(game.players)
        game.players[pIdx].current_bet = 0
        game.players[pIdx].cards = []
    end
end

function play(total_rounds::UInt32, small_blind::UInt32 = UInt32(10), big_blind::UInt32 = UInt32(20), buy_in::UInt32 = UInt32(1000))
    players = [PokerPlayer(buy_in, 0, [], false) for i=1:6]
    button_pos = 1
    # game = GameState(
    #     button_pos = UInt8(1),
    #     small_blind = small_blind,
    #     big_blind = big_blind,
    #     players = players,
    #     pot_size = UInt32(0),
    #     active_player_idx = UInt8(2),
    #     last_raise_pIdx = UInt8(1),
    #     bet_to_call = UInt32(0),
    #     deck = get_deck(),
    #     community_cards = [])
    game = GameState(UInt8(button_pos), small_blind, big_blind, players, UInt32(0), UInt8(button_pos + 1), UInt8(1), UInt32(0), get_deck(), [])

    for i = 1:total_rounds
        reset_game!(game)

        # Pre-flop
        charge_blinds!(game)
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
        for p in game.players
            println(p.cards, ": ", p.has_folded, " - ", p.stack_size)
        end
    end
end

# NOT WORKING YET
play(UInt32(1000))

end
