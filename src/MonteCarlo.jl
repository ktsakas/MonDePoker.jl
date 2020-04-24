module MonteCarlo
include("./PokerGameRules.jl")
using .PokerGameRules, .PokerHand
using .PokerHand: values

total = 10000
players = 6

hand_win_ratios = []
i, j = 0, 0
for rankA in 2:14 for rankB in 2:14 for suited in (!(rankA == rankB), false)
    # println(i, " ", j)
    p1_hidden_cards = [Card(rankA, ♦), Card(rankB, suited ? ♦ : ♥)]
    #p1_hidden_cards = [A♦, A♥]

    win_count = 0
    tie_count = 0
    for i in 1:total
        #global win_count
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
            tie_count += 1
        end
    end


    push!(hand_win_ratios, ((p1_hidden_cards[1], p1_hidden_cards[2]), win_count, total, tie_count))
end end end

sort!(hand_win_ratios, lt = (h1, h2) -> (h1[2] / h1[3]) > (h2[2] / h2[3]))
for h in hand_win_ratios
    win_count = h[2]
    total = h[3]
    tie_count = h[4]
    println(h[1], " won: ", win_count, " times out of ", total, " or ", (win_count / total) * 100, "% ties ", (tie_count / total) * 100, "%")
end

end
