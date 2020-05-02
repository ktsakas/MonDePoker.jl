<style>
img {
    height: 100%;
}

div {
    position: relative;
    height: 100%;
}

div > img {
    position: absolute;
}

@keyframes slideInFromLeft {
  0% {
    left: 0%;
  }
}

.first_card {
    animation: 1s ease-out 0s 1 slideInFromLeft;
    left: 0%;
}
.second_card {
    animation: 1s ease-out 0s 1 slideInFromLeft;
    left: 20%;
}
.third_card {
    animation: 1s ease-out 0s 1 slideInFromLeft;
    left: 40%;
}
.forth_card {
    animation: 1s ease-out 0s 1 slideInFromLeft;
    left: 60%;
}
.card.fifth_card {
    animation: 1s ease-out 0s 1 slideInFromLeft;
    left: 80%;
}
</style>

<div>
    <img src="./images/card_back.png" class="card first_card" alt="community card" />
    <img src="./images/card_back.png" class="card second_card" alt="community card" />
    <img src="./images/card_back.png" class="card third_card" alt="community card" />
    <img src="./images/card_back.png" class="card forth_card" alt="community card" />
    <img src="./images/card_back.png" class="card fifth_card" alt="community card" />
</div>
