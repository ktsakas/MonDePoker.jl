module MonteCarlo
include("./PokerGameRules.jl")
using .PokerGameRules, .PokerHand
using .PokerHand: values
using .PokerGameRules: deleteat!
using CSV, DataFrames, Tables

total = 10000
players = 6

struct HandOutcome
    cardA::Rank
    cardB::Rank
    suited::Bool

    win_count::Int64
    tie_count::Int64
    total::Int64
end

filename = "C:/Users/ktsakas/Documents/MonDePoker.jl/src/starting_hands.csv"
hand_win_ratios = try
    df = CSV.read(filename)
    hand_win_ratios::Array{HandOutcome} = map(row -> HandOutcome(row.cardA, row.cardB, row.suited, row.win_count, row.tie_count, row.total), Tables.rows(df))
catch
    hand_win_ratios::Array{HandOutcome} = fill(HandOutcome(2, 2, true, 0, 0, 0), 169)
end

pick_from = [Card(rankA, suit) for rankA = 2:14 for suit in [♦ ♥]]
println(pick_from)
row_idx = 1
for cardA = 1:2:26 for cardB=(cardA+1):26
    global row_idx
    # println(i, " ", j)
    p1_hidden_cards = [pick_from[cardA], pick_from[cardB]]
    #p1_hidden_cards = [A♦, A♥]

    win_count = 0
    tie_count = 0
    for i in 1:total
        #global win_count
        deck = get_deck()
        deleteat!(deck, idx_from_rank_suit(p1_hidden_cards[1].rank, p1_hidden_cards[1].suit.i))
        deleteat!(deck, idx_from_rank_suit(p1_hidden_cards[2].rank, p1_hidden_cards[2].suit.i))

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

    rankA = p1_hidden_cards[1].rank
    rankB = p1_hidden_cards[2].rank
    suited = p1_hidden_cards[1].suit == p1_hidden_cards[2].suit
    prev_outcome = hand_win_ratios[row_idx]
    hand_win_ratios[row_idx] = HandOutcome(
        rankA, rankB, suited, # starting hand
        prev_outcome.win_count + win_count,
        prev_outcome.tie_count + tie_count,
        prev_outcome.total + total)
    row_idx += 1
    # push!(hand_win_ratios, hand_outcome)
end end

println("row idx: ", row_idx)

CSV.write(filename, hand_win_ratios)

# sort!(hand_win_ratios, lt = (h1, h2) -> (h1.win_count / h1.total) > (h2.win_count / h2.total))
# for h in hand_win_ratios
#     println(h.cardA, " ", h.cardB, " won: ", h.win_count, " times out of ", h.total, " or ", (h.win_count / h.total) * 100, "% ties ", (h.tie_count / h.total) * 100, "%")
# end

end
