<style>
div > img {
    height: 100%;
    position: absolute;
	color: white;
	background-color: black;
	border-radius: 5px;
	box-shadow: 0px 0px 4px rgba(0, 0, 0, 0.8);
	z-index: 10;
}

/* img {
	// filter: grayscale(100%);
} */

.stack_size {
	position: absolute;
	font-size: 14px;
	right: -50px;
	width: 80px;
	border-radius: 5px;
	text-align: right;
	bottom: 0px;
	background-color: #004D85;
	color: white;
	display: inline-block;
	padding: 2px 10px;
}

.cards img.first_card {
	position: absolute;
	top: 0px;
	right: -40%;
	height: 70%;
}
.cards img.second_card {
	position: absolute;
	top: 0px;
	right: -80%;
	height: 70%;
}
</style>

<div>
    <img src="https://api.adorable.io/avatars/300/some@adorable.io.png" alt="player avatar" />

    <div class="cards">
        <img src="./images/card_back.png" class="first_card" alt="player first card" />
        <img src="./images/card_back.png" class="second_card" alt="player second card" />
    </div>

    <div class="stack_size">980</div>
</div>