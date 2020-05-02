<script>
import PokerPlayer from "./PokerPlayer.svelte"
import CommunityCards from "./CommunityCards.svelte"
</script>

<style>
.poker_player {
	position: relative;
	width: 80px;
	height: 80px;
}

.first {
	position: absolute;
	right: 0px;
	top: 0px;
}

.second {
	position: absolute;
	right: 0px;
	bottom: 0px;
}

.third {
	position: absolute;
	right: 50%;
	bottom: 0px;
}

.fourth {
	position: absolute;
	left: 0px;
	bottom: 0px;
}

.fifth {
	position: absolute;
	left: 0px;
	top: 0px;
}

.sixth {
	position: absolute;
	left: 0px;
	top: 0px;
}

.community_cards {
	position: absolute;
	display: inline-block;
	height: 80px;
	width: 320px;
	left: calc(50% - 160px);
	top: calc(50% - 40px);
}

.poker_player {
	width: 80px;
	height: 80px;
}
</style>

<div id="game">
	<div class="community_cards">
		<CommunityCards />
	</div>

	<div class="poker_player first"><PokerPlayer /></div>
	<div class="poker_player second"><PokerPlayer /></div>
	<div class="poker_player third"><PokerPlayer /></div>
	<div class="poker_player fourth"><PokerPlayer /></div>
	<div class="poker_player fifth"><PokerPlayer /></div>
	<div class="poker_player sixth"><PokerPlayer /></div>

	<img src="./images/poker_table.svg" width="100%" alt="poker table" />
</div>