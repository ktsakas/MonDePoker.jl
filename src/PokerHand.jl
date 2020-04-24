module PokerHand

export to_hand_tuples, Rank, Suit, Card, PokerHandStr, CardTuples, values

values = ['2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K', 'A']

const PokerHandStr = String
const Suit = Char
const Rank = Char
struct Card
    rank::Rank
    suit::Suit
end
const CardTuples = Array{Card, 1}

function to_hand_tuples(pokerHand::PokerHandStr)::CardTuples
    cards_tuples = [Card(card[1], card[2]) for card in Base.split(pokerHand, " ")]
    cards_tuples
end

function Base.:>(x::Rank, y::Rank)
    return findfirst(z -> z == x, values) > findfirst(z -> z == y, values)
end

end
