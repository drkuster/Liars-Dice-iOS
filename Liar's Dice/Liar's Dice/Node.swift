//
//  Node.swift
//  Liar's Dice
//
//  Created by Dylan Kuster on 7/24/20.
//  Copyright © 2020 Dylan Kuster. All rights reserved.
//

import Foundation

class Node
{
    var prev : Node?
    var next : Node?
    var value : Int = 0
    var availableDice = 5
    var dice = [1, 1, 1, 1, 1]
    var diceCount = [0, 0, 0, 0, 0, 0]
    
    init(value : Int, prev : Node?, next : Node?)
    {
        self.value = value
        self.prev = prev
        self.next = next
    }
    
    func startRound() -> [Int]
    {
        let randQ = Int.random(in: 1...6); let randN = Int.random(in: 1...6);
        gameMasterCallQuantity = randQ; gameMasterCallNum = randN;
        print("PLAYER \(value) CALLS: \(randQ) \(randN)'S!")
        return [randQ, randN]
    }
    
    func makeDecision(call : [Int]) -> [Int]
    {
        let n = Int.random(in: 1...100)
        if (n % 2 == 0) // Call BS
        {
            print("PLAYER \(value) CALLS BS")
            return [0]
        }
        else // Try to Raise Call
        {
            if (call[0] + 1 >= gameMasterTotalDice) // Call BS
            {
                print("PLAYER \(value) CALLS BS")
                return [0]
            }
            else // Raise Call
            {
                let q = gameMasterCallQuantity + 1; let randN = Int.random(in: 1...6);
                gameMasterCallQuantity = q; gameMasterCallNum = randN;
                print("PLAYER \(value) RAISES THE CALL TO: \(q) \(randN)'S")
                return [q, randN]
            }
        }
    }
    
    func shuffleDice()
    {
        var tempDice : [Int] = []
        var tempDiceCount = [0, 0, 0, 0, 0, 0]
        for _ in 0..<availableDice
        {
            let rand = Int.random(in: 1...6)
            tempDice.append(rand)
            tempDiceCount[rand - 1] += 1
        }
        dice = tempDice
        diceCount = tempDiceCount
    }
}
