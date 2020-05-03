module MonteCarlo
using ..PokerGame, .PokerGameRules, .Cards
using .Cards: values
using .PokerGameRules: deleteat!
# using CSV, DataFrames, Tables

export get_win_chance
export PokerGameRules, PokerGame, Cards

players = 6

struct HandOutcome
    cardA::Rank
    cardB::Rank
    suited::Bool

    win_count::Int64
    tie_count::Int64
    total::Int64
end

function get_win_chance(cards::PokerGameRules.CardTuples, iters = 1000)::HandOutcome
    win_count = 0
    tie_count = 0
    for i in 1:iters
        #global win_count
        deck = get_deck()
        #println(deck)
        #println("ranks ", idx_from_rank_suit(cards[1].rank, cards[1].suit.i), " ", idx_from_rank_suit(cards[2].rank, cards[2].suit.i))
        deleteat!(deck, idx_from_rank_suit(cards[1].rank, cards[1].suit.i))
        #println(deck)
        idx_to_delete = idx_from_rank_suit(cards[2].rank, cards[2].suit.i)
        if idx_to_delete > length(deck) || deck[idx_to_delete] ≠ cards[2]
            idx_to_delete = findfirst(c -> c == cards[2], deck)
            #println("looking it up ", idx_to_delete)
        end
        deleteat!(deck, idx_to_delete)

        community_cards::CardTuples = [deal!(deck), deal!(deck), deal!(deck), deal!(deck), deal!(deck)]

        better_than_all = true
        for i in 1:(players-1)
            p2_hidden_cards::CardTuples = [deal!(deck), deal!(deck)]
            is_better = is_hand_better([cards; community_cards], [p2_hidden_cards; community_cards])

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

    return HandOutcome(
        cards[1].rank, cards[2].rank, cards[1].suit == cards[2].suit, # starting hand
        win_count,
        tie_count,
        iters)
end

#println(get_win_chance([Card(12, ♦), Card(14, ♠)], 1))

function main()
    filename = "C:/Users/ktsakas/Documents/MonDePoker.jl/src/starting_hands.csv"
    hand_win_ratios::Array{HandOutcome} = try
        df = CSV.read(filename)
        map(row -> HandOutcome(row.cardA, row.cardB, row.suited, row.win_count, row.tie_count, row.total), Tables.rows(df))
    catch
        fill(HandOutcome(2, 2, true, 0, 0, 0), 169)
    end

    pick_from = [Card(rankA, suit) for rankA = 2:14 for suit in [♦ ♥]]
    println(pick_from)
    row_idx = 1
    for cardA = 1:2:26 for cardB=(cardA+1):26
        # println(i, " ", j)
        p1_hidden_cards = [pick_from[cardA], pick_from[cardB]]
        #p1_hidden_cards = [A♦, A♥]

        hand_outcome = get_win_chance(p1_hidden_cards)

        prev_outcome = hand_win_ratios[row_idx]
        hand_win_ratios[row_idx] = HandOutcome(
            hand_outcome.cardA, hand_outcome.cardB, hand_outcome.suited, # starting hand
            prev_outcome.win_count + hand_outcome.win_count,
            prev_outcome.tie_count + hand_outcome.tie_count,
            prev_outcome.total + hand_outcome.total)

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

# main()

end
