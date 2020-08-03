//
//  PlayerList.swift
//  Liar's Dice
//
//  Created by Dylan Kuster on 7/24/20.
//  Copyright © 2020 Dylan Kuster. All rights reserved.
//

import Foundation

class PlayerList
{
    var p1 = Node(value: 1, prev: nil, next: nil)
    var p2 = Node(value: 2, prev: nil, next: nil)
    var p3 = Node(value: 3, prev: nil, next: nil)
    var p4 = Node(value: 4, prev: nil, next: nil)
    var head : Node?
    
    func setup()
    {
        p1.next = p2; p2.next = p3; p3.next = p4; p4.next = p1;
        p1.prev = p4; p2.prev = p1; p3.prev = p2; p4.prev = p3;
        head = p1
    }
    
    func removeNode(_ player : Int) -> Node
    {
        var temp = head
        while (temp?.value != player)
        {
            temp = temp?.next
        }
        if (head === temp)
        {
            head = temp?.next
        }
        temp?.prev?.next = temp?.next
        temp?.next?.prev = temp?.prev
        return temp!.next!
    }
}
