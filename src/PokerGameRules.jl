module PokerGameRules
include("./PokerHand.jl")
using .PokerHand
using .PokerHand: values

export get_best_hand, is_hand_better, get_deck, Tie, deal!, suits
export high_card, pair, two_pair, three_of_a_kind, straight, flush, full_house, quads, straight_flush
export PokerHand

abstract type Tie end

struct HandCounts
    suit_counts::Dict{Char, Int64}
    value_counts::Dict{Char, Int64}
end

struct CardCount
    card::Card
    count::Int8
end

const OrderedCards = Array{CardCount, 1}
@enum PokerCombo high_card pair two_pair three_of_a_kind straight flush full_house quads straight_flush

struct BestHand
    combo::PokerCombo
    cards::OrderedCards
end

const Deck = Array{Card, 1}

suits = ['♠', '♣', '♥', '♦']

card = string(values[rand(1:12)], suits[rand(1:4)])

function get_deck()::Deck
    deck = []
    for rank in values
        card_suits = [Card(rank, suit) for suit in suits]
        append!(deck, card_suits)
    end
    return deck
end

function win_chance(starting_hand)

end

function get_winning_hand(hands, shared_cards)

end

function deal!(deck::Deck)::Card
    idx = rand(1:length(deck))
    card = deck[idx]
    deleteat!(deck, idx)
    return card
end

# check if handA is better than handB
function get_winning_hand(handA, handB, shared_cards)
    @assert length(handA) == 2
    @assert length(handB) == 2
    @assert length(shared_cards) == 5

    suit_counts = [suit => 0 for suit in suits]
    # max_matching_suits =
    # max_matching_values =
    # max_consecutive_values =
end

function get_ordered_counts(cards::CardTuples)::HandCounts
    suit_counts = Dict(suit => 0 for (value, suit) in cards)
    value_counts = Dict(value => 0 for (value, suit) in cards)
    for (value, suit) in cards
        suit_counts[suit] += 1
        value_counts[value] += 1
    end

    return HandCounts(suit_counts, value_counts)
end

# check if hand has a flush
function find_longest_suited(hand::OrderedCards)::Union{Nothing, OrderedCards}
    for suit in suits
        suit_match_idxs = findall(x::CardCount -> x.card.suit == suit, hand)

        if length(suit_match_idxs) >= 5
            flush_cards = [hand[idx] for idx in suit_match_idxs]
            return flush_cards
        end
    end

    return nothing
end

function find_flush(hand::OrderedCards)::Union{Nothing, OrderedCards}
    flush_cards = nothing
    for suit in suits
        suit_match_idxs = findall(x::CardCount -> x.card.suit == suit, hand)

        if length(suit_match_idxs) >= 5
            # println("hand: ", hand, " matches : ", suit_match_idxs)
            flush_cards = [CardCount(hand[idx].card, 1) for idx in suit_match_idxs]

            return sort(flush_cards, lt = (x, y) -> x.card.rank > y.card.rank)
        end
    end
end

# check if hand has a full house
function has_full_house(hand::OrderedCards)::Bool
    return (hand[1].count == 3) && (hand[4].count == 3 || hand[4].count == 2)
end

# check if hand has a straight
function find_straight(hand::OrderedCards)::Union{OrderedCards, Nothing}
    # reorder cards only by rank
    hand = sort(hand, lt = (x, y) -> x.card.rank > y.card.rank)

    straight_cards = []
    consecutives_count = 1
    straight_cards = nothing
    rank_idx = nothing
    prev_rank_idx = -1
    for card_count in hand
        rank_idx = get_value_idx(card_count.card.rank)
        if prev_rank_idx != -1 && (prev_rank_idx == rank_idx + 1)
            consecutives_count += 1
            push!(straight_cards, CardCount(card_count.card, 1))
        elseif prev_rank_idx == rank_idx
            # skip values that are the same
        else
            consecutives_count = 1
            straight_cards = [ CardCount(card_count.card, 1) ]
        end
        prev_rank_idx = rank_idx

        # if straight is found break out of loop
        if consecutives_count >= 5
            return straight_cards
        end
    end

    return nothing
end

# check if hand has a straight flush
function find_straight_flush(hand::OrderedCards)::Union{OrderedCards, Nothing}
    suited_cards = find_longest_suited(hand)
    if suited_cards != nothing
        return find_straight(suited_cards)
    end

    return nothing
end

get_value_idx(value) = findfirst(x -> x == value, values)

function sort_cards(hand::CardTuples)::CardTuples
    return sort(hand, lt = (x, y) -> x.rank > y.rank)
end

# used for finding three of a kind, two of a kind and high card
function get_ordered_card_counts(hand::CardTuples)::OrderedCards
    rank_counts = Dict(card.rank => 0 for card in hand)
    for card in hand
        rank_counts[card.rank] += 1
    end
    card_counts = map(c -> CardCount(c, rank_counts[c.rank]), hand)

    function isless(x::CardCount, y::CardCount)
        if x.count == y.count
            return x.card.rank > y.card.rank
        else
            return x.count > y.count
        end
    end
    ordered_card_counts = sort(card_counts, lt = isless)

    return ordered_card_counts
end

function get_best_hand(player_cards::CardTuples)::BestHand
    @assert length(player_cards) == 7

    ordered_cards = get_ordered_card_counts(player_cards)

    straight_flush_cards = find_straight_flush(ordered_cards)
    if straight_flush_cards != nothing return BestHand(straight_flush, ordered_cards) end

    if ordered_cards[1].count == 4 return BestHand(quads, ordered_cards) end

    if has_full_house(ordered_cards) return BestHand(full_house, ordered_cards) end

    flush_cards = find_flush(ordered_cards)
    if flush_cards != nothing
        return BestHand(flush, flush_cards)
    end

    straight_cards = find_straight(ordered_cards)
    if straight_cards != nothing return BestHand(straight, straight_cards) end

    if ordered_cards[1].count == 3 return BestHand(three_of_a_kind, ordered_cards) end

    if ordered_cards[1].count == 2 && ordered_cards[3].count == 2 return BestHand(two_pair, ordered_cards) end

    if ordered_cards[1].count == 2 return BestHand(pair, ordered_cards) end

    return BestHand(high_card, ordered_cards)
end

function compare_counts_and_ranks(pA_cards::OrderedCards, pB_cards::OrderedCards)
    idx = 1
    while idx <= 5
        if pA_cards[idx].count == pB_cards[idx].count
            if pA_cards[idx].card.rank == pB_cards[idx].card.rank
                # if set count and rank are equal compare next cards
                idx += pA_cards[idx].count
            else
                # set with highest rank wins
                return pA_cards[idx].card.rank > pB_cards[idx].card.rank
            end
        else
            # longest set wins
            return pA_cards[idx].count > pB_cards[idx].count
        end
    end

    return Tie
end

# compare 7 cards (hand + shared) between players
function is_hand_better(pA_cards::CardTuples, pB_cards::CardTuples)::Union{Bool, Type{Tie}}
    @assert length(pA_cards) == 7
    @assert length(pB_cards) == 7

    pA_best_hand = get_best_hand(pA_cards)
    pB_best_hand = get_best_hand(pB_cards)

    if pA_best_hand.combo == pB_best_hand.combo
        return compare_counts_and_ranks(pA_best_hand.cards, pB_best_hand.cards)
    else
        return pA_best_hand.combo > pB_best_hand.combo
    end
    throw("Error this should never be reached!")
end

function string_to_card_tuple(cards_str::String)
    cards_tuples = [(card[1], card[2]) for card in Base.split(cards_str, " ")]
    cards_tuples
end

end
