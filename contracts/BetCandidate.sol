// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

struct Bet {
    uint ammount;
    uint candidate;
    uint timestamp;
    uint claimed;
}

struct Dispute {
    string candidate1;
    string candidate2;
    string image1;
    string image2;
    uint total1;
    uint total2;
    uint winner;
}

contract BetCandidate {

    Dispute public dispute;
    mapping(address => Bet) public allBets;

    address owner;
    uint fee = 1000; // 10% na precisão de 4 zeros
    uint public netPrize;

    constructor() {
        owner = msg.sender;
        dispute = Dispute({
            candidate1: "Donald Trump",
            candidate2: "Kamala Harris",
            image1: "https://www.google.com/imgres?q=trump&imgurl=https%3A%2F%2Fwww.cnnbrasil.com.br%2Fwp-content%2Fuploads%2Fsites%2F12%2FReuters_Direct_Media%2FBrazilOnlineReportWorldNews%2Ftagreuters.com2024binary_LYNXMPEK8O0JS-FILEDIMAGE.jpg%3Fw%3D420%26h%3D240%26crop%3D1%26quality%3D85&imgrefurl=https%3A%2F%2Fwww.cnnbrasil.com.br%2Finternacional%2Ftrump-fala-em-explodir-o-ira-em-caso-de-ameaca-a-candidato-presidencial%2F&docid=DM_0FkqxanrZEM&tbnid=0G1vpMJtmR_luM&vet=12ahUKEwj536K76e2IAxXwqJUCHWG1K9UQM3oECGUQAA..i&w=420&h=240&hcb=2&itg=1&ved=2ahUKEwj536K76e2IAxXwqJUCHWG1K9UQM3oECGUQAA",
            image2: "https://www.google.com/imgres?q=kamala&imgurl=https%3A%2F%2Ff.i.uol.com.br%2Ffotografia%2F2024%2F09%2F30%2F172772894266fb0d2e3cdd0_1727728942_3x2_md.jpg&imgrefurl=https%3A%2F%2Fwww1.folha.uol.com.br%2Fmundo%2F2024%2F09%2Fnew-york-times-declara-voto-em-kamala-harris-para-presidente-dos-eua.shtml&docid=Os87uqXsMjSXrM&tbnid=L2T14YV8B6xZVM&vet=12ahUKEwjjpJXK6e2IAxVPr5UCHfZdODEQM3oECBMQAA..i&w=768&h=512&hcb=2&itg=1&ved=2ahUKEwjjpJXK6e2IAxVPr5UCHfZdODEQM3oECBMQAA",
            total1: 0,
            total2: 0,
            winner: 0
        });
    }

    function bet(uint candidate) external payable  {
        require(candidate == 1 || candidate == 2, "Invalid candidate");
        require(msg.value > 0, "Invalid bet");
        require(dispute.winner == 0, "Dispute closed");

        Bet memory newBet;
        newBet.ammount = msg.value;
        newBet.candidate = candidate;
        newBet.timestamp = block.timestamp;

        allBets[msg.sender] = newBet;

        if(candidate == 1)
            dispute.total1 += msg.value;
        else 
            dispute.total2 += msg.value;

    }

    function finish(uint winner) external {
        require(msg.sender == owner, "Invalid account");
        require(winner == 1 || winner == 2, "Invalid candidate");
        require(dispute.winner == 0, "Dispute closed");
        
        dispute.winner = winner;

        uint grossPrize = dispute.total1 + dispute.total2;
        uint comission = (grossPrize * fee) / 1e4; // 1e4 = 1 * 10^4
        netPrize = grossPrize - comission;

        payable(owner).transfer(comission);
    }

    function claim() external {
        Bet memory userBet = allBets[msg.sender];
        require(dispute.winner > 0 && dispute.winner == userBet.candidate && userBet.claimed == 0, "Invalid claim");

        uint winnerAmount = dispute.winner == 1 ? dispute.total1 : dispute.total2;
        uint ratio = (userBet.ammount * 1e4) / winnerAmount;
        uint individualPrize = netPrize * ratio / 1e4;
        allBets[msg.sender].claimed = individualPrize;
        payable(msg.sender).transfer(individualPrize);
    }

}