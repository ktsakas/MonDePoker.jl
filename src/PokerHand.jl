module PokerHand

export to_hand_tuples, Rank, Suit, Card, PokerHandStr, CardTuples, values
export ♣, ♦, ♥, ♠, suits

const PokerHandStr = String
const Rank = UInt8
const rank_chars = ['X', '2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K', 'A']
struct Suit
    i::UInt8
end
const ♣ = Suit(1)
const ♦ = Suit(2)
const ♥ = Suit(3)
const ♠ = Suit(4)
const suits = [♣, ♦, ♥, ♠]
const suit_chars = ['♣', '♦', '♥', '♠']
function char(suit::Suit)
    return suit_chars[suit.i]
end
Base.string(s::Suit) = string(char(s))
Base.show(io::IO, s::Suit) = print(io, char(s))

struct Card
    rank::Rank
    suit::Suit
end
const CardTuples = Array{Card, 1}

function Card(rank_char::Char, suit_char::Char)
    rank::UInt8 = findfirst(x -> x == rank_char, rank_chars)
    suit_i = findfirst(y -> y == suit_char, suit_chars)

    Card(rank::Rank, Suit(suit_i))
end

function to_hand_tuples(pokerHand::PokerHandStr)::CardTuples
    cards_tuples = [Card(card[1]::Char, card[2]::Char) for card in Base.split(pokerHand, " ")]
    cards_tuples
end

*(r::Integer, s::Suit) = Card(r, s)

for s in "♣♦♥♠", (r,f) in zip(10:14, "TJQKA")
    ss, sc = Symbol(s), Symbol("$f$s")
    @eval (export $sc; const $sc = Card($r,$ss))
end

function Base.show(io::IO, card::Card)
    print(io, rank_chars[card.rank], card.suit)
end

end
