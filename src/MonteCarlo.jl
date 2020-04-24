module MonteCarlo
include("./PokerGameRules.jl")
using .PokerGameRules, .PokerHand
using .PokerHand: values

total = 1000
players = 6

for i in 1:52
    for j in 1:51
        p1_hidden_cards = [Card(values[1 + (i ÷ 4)], '♦'), Card(values[1 + (j ÷ 4)], '♥')]

        win_count = 0
        for i in 1:total
            deck = get_deck()
            filter!(x -> x ∉ p1_hidden_cards, deck)

            community_cards::CardTuples = [deal!(deck), deal!(deck), deal!(deck), deal!(deck), deal!(deck)]

            better_than_all = true
            for i in 1:(players-1)
                p2_hidden_cards::CardTuples = [deal!(deck), deal!(deck)]
                is_better = is_hand_better([p1_hidden_cards; community_cards], [p2_hidden_cards; community_cards])

                if is_better == false
                    better_than_all = false
                    break
                elseif is_better == Tie
                    better_than_all = Tie
                end
            end

            if better_than_all == true
                win_count += 1
            elseif better_than_all == Tie
                win_count += 0.5
            end
        end


        println(p1_hidden_cards[1], p1_hidden_cards[2], " won: ", win_count, " times out of ", total, " or ", (win_count / total) * 100, "%")
    end
end

end
