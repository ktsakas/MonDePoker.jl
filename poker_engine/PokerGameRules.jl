include("./Cards.jl")

module PokerGameRules
using ..Cards
using ..Cards: values

export get_best_hand, is_hand_better, get_deck, Tie, deal!, deleteat!, idx_from_rank_suit, Deck
export high_card, pair, two_pair, three_of_a_kind, straight, flush, full_house, quads, straight_flush

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

@inline function idx_from_rank_suit(rank, suit)
    return (rank - 2) * 4 + suit
end

function get_deck()::Deck
    deck = Array{Card}(undef, 52)
    for rank in 2:14 for suit in 1:4
        #println((rank - 2) * 4 + suit)
        deck[idx_from_rank_suit(rank, suit)] = Card(rank, Suit(suit))
    end end
    return deck
end

function deleteat!(deck::Deck, index::Integer)
    # remove random card from deck
    deck[index] = deck[length(deck)]
    resize!(deck, length(deck)-1)
end

function deal!(deck::Deck)::Card
    idx = rand(1:length(deck))
    # random card to be dealt
    card = deck[idx]
    deleteat!(deck, idx)
    return card
end

deck = get_deck()
for i in 1:52
    # println(deal!(deck))
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
            longest_suited = [CardCount(hand[idx].card, 1) for idx in suit_match_idxs]
            return sort(longest_suited, lt = (x, y) -> x.card.rank > y.card.rank)
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
    # add ace as lowest card too
    if hand[1].card.rank == 14
        push!(hand, CardCount(Card(1, hand[1].card.suit), 1))
    end

    straight_cards = []
    consecutives_count = 1
    straight_cards = nothing
    rank = nothing
    prev_rank = -1
    for idx = 1:length(hand)
        card_count = hand[idx]
        rank = card_count.card.rank
        if prev_rank != -1 && (prev_rank == rank + 1)
            consecutives_count += 1
            push!(straight_cards, CardCount(card_count.card, 1))
        # ace low card
        # elseif prev_rank == 2 && hand[1].rank == 14
        #     consecutives_count += 2
        #     push!(straight_cards, CardCount(card_count.card, 1))
        #     push!(straight_cards, CardCount(hand[1].card, 1))
        elseif prev_rank == rank
            # skip values that are the same
        elseif length(hand)-idx+consecutives_count < 5
            return nothing
        else
            consecutives_count = 1
            straight_cards = [ CardCount(card_count.card, 1) ]
        end
        prev_rank = rank

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
    longest_suited = find_longest_suited(ordered_cards)

    if longest_suited != nothing && length(longest_suited) >= 5
        straight_flush_cards = find_straight(longest_suited)
        if straight_flush_cards != nothing return BestHand(straight_flush, ordered_cards) end
    end

    if ordered_cards[1].count == 4 return BestHand(quads, ordered_cards) end

    if has_full_house(ordered_cards) return BestHand(full_house, ordered_cards) end

    if longest_suited != nothing && length(longest_suited) >= 5
        return BestHand(flush, longest_suited[1:5])
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
