//
//  GameMaster.swift
//  Liar's Dice
//
//  Created by Dylan Kuster on 7/18/20.
//  Copyright © 2020 Dylan Kuster. All rights reserved.
//

import Foundation

public var gameMasterTotalDice = 0
public var gameMasterCallQuantity = 0
public var gameMasterCallNum = 0

protocol GameMasterProtocol
{
    func updateDiceVisuals(for dice : [Int])
}

class GameMaster
{
    
    var tableDiceCount = [0, 0, 0, 0, 0, 0]
    var roundNum = 1
    var availablePlayers = 4
    var playerList = PlayerList()
    var curPlayer : Node?
    var delegate : GameMasterProtocol?
    
    init()
    {
        playerList.setup()
        curPlayer = playerList.head
    }
    
    func updateRoundStarter()
    {
        curPlayer = curPlayer?.next
    }
    
    func evaluateCall(for player : Node) -> Bool
    {
        if ((tableDiceCount[gameMasterCallNum - 1] + player.prev!.diceCount[0]) < gameMasterCallQuantity)
        {
            print("\(tableDiceCount[gameMasterCallNum - 1] + player.prev!.diceCount[0]) < \(gameMasterCallQuantity)" )
            return true
        }
        else
        {
            print("\(tableDiceCount[gameMasterCallNum - 1] + player.prev!.diceCount[0]) >= \(gameMasterCallQuantity)" )
            return false
        }
    }
    
    func cycleList()
    {
        var temp = curPlayer
        for _ in 0..<availablePlayers
        {
            print("CUR: \(temp!.value)")
            temp = temp!.next
        }
    }
    
    func shufflePlayerDice()
    {
        var tempTotalDice = 0
        var temp = curPlayer
        var tempDiceCount = [0, 0, 0, 0, 0, 0]
        for _ in 0..<availablePlayers
        {
            temp!.shuffleDice()
            if (temp!.value == 1)
            {
                delegate?.updateDiceVisuals(for: temp!.dice)
            }
            print("PLAYER \(temp!.value) DICE: \(temp!.dice)")
            print("PLAYER \(temp!.value) DICE COUNT: \(temp!.diceCount)")
            print("----------------------------------------------------")
            tempDiceCount = zip(temp!.diceCount, tempDiceCount).map(+)
            tempTotalDice += temp!.availableDice
            temp = temp!.next
        }
        tableDiceCount = tempDiceCount
        gameMasterTotalDice = tempTotalDice
        print("TABLE DICE COUNT: \(tableDiceCount)")
        print("----------------------------------------------------")
    }
    
    func killPlayer(_ player : Int)
    {
        curPlayer = playerList.removeNode(player)
        self.availablePlayers -= 1
    }
}
