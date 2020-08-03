//
//  PlayViewController.swift
//  Liar's Dice
//
//  Created by Dylan Kuster on 7/18/20.
//  Copyright © 2020 Dylan Kuster. All rights reserved.
//

import UIKit

class PlayViewController: UIViewController
{
    @IBOutlet weak var roundNum: UILabel!
    @IBOutlet weak var currentCallLabel: UILabel!
    @IBOutlet weak var bsButton: UIButton!
    @IBOutlet weak var raiseButton: UIButton!
    @IBOutlet weak var startRoundButton: UIButton!
    @IBOutlet weak var playerOneView: UIView!
    @IBOutlet weak var playerOneText: UILabel!
    @IBOutlet weak var playerOneDot: UIView!
    @IBOutlet weak var playerTwoView: UIView!
    @IBOutlet weak var playerTwoText: UILabel!
    @IBOutlet weak var playerTwoDot: UIView!
    @IBOutlet weak var playerThreeView: UIView!
    @IBOutlet weak var playerThreeText: UILabel!
    @IBOutlet weak var playerThreeDot: UIView!
    @IBOutlet weak var diceOne: UIImageView!
    @IBOutlet weak var diceTwo: UIImageView!
    @IBOutlet weak var diceThree: UIImageView!
    @IBOutlet weak var diceFour: UIImageView!
    @IBOutlet weak var diceFive: UIImageView!
    @IBOutlet weak var quantityDicePicker: UIPickerView!
    @IBOutlet weak var numDicePicker: UIPickerView!
    
	var p1StartingRound = false
    var quantitySelected = 1
    var numSelected = 1
	var diceImageViews : [UIImageView] = []
	let diceLiterals = [#imageLiteral(resourceName: "DiceOne"), #imageLiteral(resourceName: "DiceTwo"), #imageLiteral(resourceName: "DiceThree"), #imageLiteral(resourceName: "DiceFour"), #imageLiteral(resourceName: "DiceFive"), #imageLiteral(resourceName: "DiceSix")]
    var diceQuantity = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]
    let diceNums = [1, 2, 3, 4, 5, 6]
    let specialRed : UIColor = UIColor(red: 0.61, green: 0.11, blue: 0.12, alpha: 1.00)
	var end = false
	var userCalledBS = false
	var p1MakingDecision = false
    let gameMaster = GameMaster()
	var p1SetRound = DispatchGroup()
	var p1MakeDecision = DispatchGroup()
	var currentPlayer : Node?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
		diceImageViews = [diceOne, diceTwo, diceThree, diceFour, diceFive]
        quantityDicePicker.delegate = self
        quantityDicePicker.dataSource = self
        numDicePicker.delegate = self
        numDicePicker.dataSource = self
		gameMaster.delegate = self
		setupView()
		newRound()
    }
	
	func rollDie(for die : UIImageView)
	{
		DispatchQueue.main.async
		{
			var tempImages = self.diceLiterals
			tempImages.shuffle()
			die.animationDuration = 0.5
			die.animationImages = tempImages
			die.startAnimating()
			Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false)
			{ (timer) in
				die.stopAnimating()
			}
		}
	}
    
	func updateDiceVisuals(for dice: [Int])
	{
		for die in self.diceImageViews
		{
			self.rollDie(for : die)
		}
		DispatchQueue.main.sync
		{
			var i = 0
			for num in dice
			{
				self.diceImageViews[i].image = self.diceLiterals[num - 1]
				i += 1
			}
		}
	}
    
	func updateCallDisplay(completion: @escaping()->())
	{
		DispatchQueue.main.async
		{
			self.currentCallLabel.text = "P1 CALL: \(gameMasterCallQuantity) \(gameMasterCallNum)'s"
			self.quantityDicePicker.isHidden = true; self.numDicePicker.isHidden = true;
			self.quantityDicePicker.isUserInteractionEnabled = false; self.numDicePicker.isUserInteractionEnabled = false;
			self.startRoundButton.isHidden = true; self.startRoundButton.isEnabled = false;
			completion()
		}
	}
    
    func setupView()
    {
        playerOneView.layer.cornerRadius = playerOneView.frame.height / 2
        playerOneDot.layer.cornerRadius = playerOneDot.frame.height / 2
        playerTwoView.layer.cornerRadius = playerTwoView.frame.height / 2
        playerTwoDot.layer.cornerRadius = playerTwoDot.frame.height / 2
        playerThreeView.layer.cornerRadius = playerThreeView.frame.height / 2
        playerThreeDot.layer.cornerRadius = playerThreeDot.frame.height / 2
        bsButton.layer.cornerRadius = bsButton.frame.height / 5
        raiseButton.layer.cornerRadius = raiseButton.frame.height / 5
        startRoundButton.layer.cornerRadius = startRoundButton.frame.height / 5
        bsButton.isHidden = true; raiseButton.isHidden = true;
		bsButton.isEnabled = false; raiseButton.isEnabled = false; startRoundButton.isEnabled = false;
        playerOneView.layer.shadowColor = UIColor.black.cgColor
        playerOneView.layer.shadowOpacity = 0.75
        playerOneView.layer.shadowOffset = .zero
        playerOneView.layer.shadowRadius = 10
        playerOneDot.layer.shadowColor = UIColor.black.cgColor
        playerOneDot.layer.shadowOpacity = 0.5
        playerOneDot.layer.shadowOffset = .zero
        playerOneDot.layer.shadowRadius = 5
        
        playerTwoView.layer.shadowColor = UIColor.black.cgColor
        playerTwoView.layer.shadowOpacity = 0.75
        playerTwoView.layer.shadowOffset = .zero
        playerTwoView.layer.shadowRadius = 10
        playerTwoDot.layer.shadowColor = UIColor.black.cgColor
        playerTwoDot.layer.shadowOpacity = 0.5
        playerTwoDot.layer.shadowOffset = .zero
        playerTwoDot.layer.shadowRadius = 5
        
        playerThreeView.layer.shadowColor = UIColor.black.cgColor
        playerThreeView.layer.shadowOpacity = 0.75
        playerThreeView.layer.shadowOffset = .zero
        playerThreeView.layer.shadowRadius = 10
        playerThreeDot.layer.shadowColor = UIColor.black.cgColor
        playerThreeDot.layer.shadowOpacity = 0.5
        playerThreeDot.layer.shadowOffset = .zero
        playerThreeDot.layer.shadowRadius = 5
    }
}

// MARK: - GameMaster

extension PlayViewController : GameMasterProtocol
{
    func newRound()
    {
		gameMasterCallQuantity = 1; gameMasterCallNum = 1;
		if (self.gameMaster.availablePlayers < 2)
		{
			print("GAME OVER, PLAYER \(self.gameMaster.curPlayer!.value) WINS!")
			print("AVAILABLE PLAYERS: \(self.gameMaster.availablePlayers)")
		}
		else
		{
			DispatchQueue.global(qos: .background).async
			{
				DispatchQueue.main.sync
				{
					self.roundNum.text = "Round \(self.gameMaster.roundNum)"
				}
				var call : [Int]?
				print("ROUND: \(self.gameMaster.roundNum)")
				self.gameMaster.shufflePlayerDice()
				if (self.gameMaster.curPlayer!.value == 1)
				{
					print("PLAYER ONE STARTS ROUND")
					self.p1StartingRound = true
//					self.updateRaiseQuantityChoices(lowerBound : 1)
//					self.updateRaiseNumChoices(lowerBound: 1)
					DispatchQueue.main.sync
					{
						self.currentCallLabel.text = "P1 CALL: ?  ?'s"
					}
					self.enableUserSetRoundInput()
					self.p1SetRound.enter()
					self.p1SetRound.notify(queue: .main)
					{
						self.p1StartingRound = false
						call = [self.quantitySelected, self.numSelected]
						self.gameMaster.updateRoundStarter()
						self.updateCallDisplay
						{
							print("DONE!")
							self.playNewRound(with : self.gameMaster.curPlayer!, call: call!)
						}
					}
				}
				else
				{
					DispatchQueue.main.sync
					{
						self.currentCallLabel.text = "P\(self.gameMaster.curPlayer!.value) CALL: ?  ?'s"
						switch self.gameMaster.curPlayer?.value
						{
							case 2:
								self.playerOneView.backgroundColor = self.specialRed
								self.playerOneDot.backgroundColor = self.specialRed
								self.playerOneText.textColor = .white
							case 3:
								self.playerTwoView.backgroundColor = self.specialRed
								self.playerTwoDot.backgroundColor = self.specialRed
								self.playerTwoText.textColor = .white
							case 4:
								self.playerThreeView.backgroundColor = self.specialRed
								self.playerThreeDot.backgroundColor = self.specialRed
								self.playerThreeText.textColor = .white
							default:
								print("BIG PROBLEM!")
						}
					}
					usleep(useconds_t(Int.random(in: 1750000...2500000)))
					DispatchQueue.main.sync
					{
						switch self.gameMaster.curPlayer?.value
						{
							case 2:
								self.playerOneView.backgroundColor = .white
								self.playerOneDot.backgroundColor = .white
								self.playerOneText.textColor = .black
							case 3:
								self.playerTwoView.backgroundColor = .white
								self.playerTwoDot.backgroundColor = .white
								self.playerTwoText.textColor = .black
							case 4:
								self.playerThreeView.backgroundColor = .white
								self.playerThreeDot.backgroundColor = .white
								self.playerThreeText.textColor = .black
							default:
								print("BIG PROBLEM!")
						}
					}
					call = self.gameMaster.curPlayer?.startRound()
					self.gameMaster.updateRoundStarter()
					DispatchQueue.main.sync
					{
						self.currentCallLabel.text = "P\(self.gameMaster.curPlayer!.prev!.value) CALL: \(gameMasterCallQuantity) \(gameMasterCallNum)'s"
					}
					self.playNewRound(with : self.gameMaster.curPlayer!, call: call!)
				}
			}
		}
	}
	
	func loopThroughPlayers(with player : Node, call : [Int])
	{
		currentPlayer = player
		DispatchQueue.main.sync
		{
			switch player.value
			{
				case 2:
					self.playerOneView.backgroundColor = self.specialRed
					self.playerOneDot.backgroundColor = self.specialRed
					self.playerOneText.textColor = .white
				case 3:
					self.playerTwoView.backgroundColor = self.specialRed
					self.playerTwoDot.backgroundColor = self.specialRed
					self.playerTwoText.textColor = .white
				case 4:
					self.playerThreeView.backgroundColor = self.specialRed
					self.playerThreeDot.backgroundColor = self.specialRed
					self.playerThreeText.textColor = .white
				default:
					print("Player One..")
			}
		}
		if (player.value != 1)
		{
			usleep(useconds_t(Int.random(in: 1750000...2500000)))
		}
		DispatchQueue.main.sync
		{
			switch player.value
			{
				case 2:
					self.playerOneView.backgroundColor = .white
					self.playerOneDot.backgroundColor = .white
					self.playerOneText.textColor = .black
				case 3:
					self.playerTwoView.backgroundColor = .white
					self.playerTwoDot.backgroundColor = .white
					self.playerTwoText.textColor = .black
				case 4:
					self.playerThreeView.backgroundColor = .white
					self.playerThreeDot.backgroundColor = .white
					self.playerThreeText.textColor = .black
				default:
					print("Player One..")
			}
		}
		if (player.value == 1)
		{
			print("Waiting for player 1 to make decision..")
			p1MakingDecision = true
			return
		}
		else
		{
			if (player.makeDecision(call: call).count < 2)
			{
				DispatchQueue.main.sync
				{
                    self.currentCallLabel.text = "P\(player.value) CALL: BS!"
				}
			}
			else
			{
				DispatchQueue.main.sync
				{
					self.currentCallLabel.text = "P\(player.value) CALL: \(gameMasterCallQuantity) \(gameMasterCallNum)'s"
				}
				loopThroughPlayers(with: player.next!, call: call)
			}
		}
	}
	
	func updateRaiseNumChoices(lowerBound : Int)
	{
		if (lowerBound <= 6)
		{
			print("UPDATED RAISE NUM CHOICES")
			var temp : [Int] = []
			for i in lowerBound..<7
			{
				temp.append(i)
			}
//			diceNums = temp
			print(diceNums)
			DispatchQueue.main.async
			{
				self.numDicePicker.reloadComponent(0)
			}
		}
		else
		{
//			diceNums = []
			DispatchQueue.main.async
			{
				self.numDicePicker.reloadComponent(0)
				self.numDicePicker.selectRow(0, inComponent: 0, animated: false)
				self.numSelected = self.diceNums[0]
			}
		}
	}
	
	func updateRaiseQuantityChoices(lowerBound : Int)
	{
		print("UPDATED RAISE QUANTITY CHOICES")
		var temp : [Int] = []
		for i in lowerBound...20
		{
			temp.append(i)
		}
		diceQuantity = temp
		print(diceQuantity)
		DispatchQueue.main.async
		{
			self.quantityDicePicker.reloadComponent(0)
			self.quantityDicePicker.selectRow(0, inComponent: 0, animated: false)
			self.numDicePicker.selectRow(0, inComponent: 0, animated: false)
			if (self.p1StartingRound)
			{
				print("P1 STARTING ROUND")
//				self.updateRaiseNumChoices(lowerBound: 1)
			}
			else
			{
//				self.updateRaiseNumChoices(lowerBound: gameMasterCallNum + 1)
			}
		}
	}
    
	func playNewRound(with player : Node, call : [Int])
    {
		DispatchQueue.global(qos: .background).async
		{
			if (!self.userCalledBS)
			{
				self.loopThroughPlayers(with: player, call: call)
			}
			if (self.p1MakingDecision)
			{
//				self.updateRaiseQuantityChoices(lowerBound: gameMasterCallQuantity)
				self.p1MakingDecision = false
				self.enableUserMakeDecisionInput()
				self.p1MakeDecision.enter()
				self.p1MakeDecision.notify(queue: .main)
				{
					self.disableUserMakeDecisionInput()
					if (self.userCalledBS)
					{
						print("USER CALLED BS!")
						self.currentCallLabel.text = "P1 CALL: BS"
						self.playNewRound(with: self.currentPlayer!, call: [0])
					}
					else
					{
						self.currentCallLabel.text = "P1 CALL: \(gameMasterCallQuantity) \(gameMasterCallNum)'s"
						self.playNewRound(with: self.currentPlayer!.next!, call: [gameMasterCallQuantity, gameMasterCallNum])
					}
				}
			}
			else
			{
				self.userCalledBS = false
				usleep(useconds_t(Int.random(in: 1750000...2500000)))
				if (self.gameMaster.evaluateCall(for: self.currentPlayer!))
				{
					DispatchQueue.main.sync
					{
						self.currentCallLabel.text = "SUCCESSFUL BS CALL!"
					}
					usleep(1500000)
					DispatchQueue.main.sync
					{
						self.currentCallLabel.text = "P\(self.currentPlayer!.prev!.value) LOSES A DIE.. 😖"
					}
					usleep(1500000)
					self.currentPlayer!.prev?.availableDice -= 1
					if (self.currentPlayer!.prev?.value == 1)
					{
						DispatchQueue.main.sync
						{
							self.diceImageViews.last?.isHidden = true
							self.diceImageViews.removeLast()
						}
					}
					print("PLAYER \(self.currentPlayer!.prev!.value) DICE: \(self.currentPlayer!.prev!.availableDice)")
					if (self.currentPlayer!.prev!.availableDice < 1)
					{
						DispatchQueue.main.sync
						{
							self.currentCallLabel.text = "P\(self.currentPlayer!.prev!.value) IS OUT!"
						}
						usleep(1500000)
						DispatchQueue.main.sync
						{
							switch self.currentPlayer!.prev!.value
							{
								case 2:
									self.playerOneView.isHidden = true
									self.playerOneDot.isHidden = true
									self.playerOneText.isHidden = true
								case 3:
									self.playerTwoView.isHidden = true
									self.playerTwoDot.isHidden = true
									self.playerTwoText.isHidden = true
								case 4:
									self.playerThreeView.isHidden = true
									self.playerThreeDot.isHidden = true
									self.playerThreeText.isHidden = true
								default:
									print("BIG PROBLEM!")
							}
						}
						if (self.currentPlayer!.prev!.value == 1)
						{
							print("PLAYER ONE ELIMINATED, GAME OVER")
							self.end = true
						}
						self.gameMaster.killPlayer(self.currentPlayer!.prev!.value)
					}
				}
				else
				{
					print("FAILED BS CALL!")
					DispatchQueue.main.sync
					{
						self.currentCallLabel.text = "FAILED BS CALL!"
					}
					usleep(1500000)
					DispatchQueue.main.sync
					{
						self.currentCallLabel.text = "P\(self.currentPlayer!.value) LOSES A DICE.. 😖"
					}
					usleep(1500000)
					self.currentPlayer!.availableDice -= 1
					if (self.currentPlayer!.value == 1)
					{
						DispatchQueue.main.sync
						{
							self.diceImageViews.last?.isHidden = true
							self.diceImageViews.removeLast()
						}
					}
					print("PLAYER \(self.currentPlayer!.value) DICE: \(self.currentPlayer!.availableDice)")
					if (self.currentPlayer!.availableDice < 1)
					{
						DispatchQueue.main.sync
						{
							self.currentCallLabel.text = "P\(self.currentPlayer!.value) IS OUT!"
						}
						usleep(useconds_t(Int.random(in: 1750000...2500000)))
						DispatchQueue.main.sync
						{
							switch self.currentPlayer!.value
							{
								case 2:
									self.playerOneView.isHidden = true
									self.playerOneDot.isHidden = true
									self.playerOneText.isHidden = true
								case 3:
									self.playerTwoView.isHidden = true
									self.playerTwoDot.isHidden = true
									self.playerTwoText.isHidden = true
								case 4:
									self.playerThreeView.isHidden = true
									self.playerThreeDot.isHidden = true
									self.playerThreeText.isHidden = true
								default:
									print("BIG PROBLEM!")
							}
						}
						print("PLAYER \(self.currentPlayer!.value) IS OUT")
						if (self.currentPlayer!.value == 1)
						{
							print("PLAYER ONE ELIMINATED, GAME OVER")
							self.end = true
						}
						self.gameMaster.killPlayer(self.currentPlayer!.value)
					}
				}
				if (!self.end)
				{
					self.gameMaster.roundNum += 1
					print("\n\n")
					self.newRound()
				}
			}
		}
    }
}

// MARK: - User Controls

extension PlayViewController
{
    @IBAction func raiseButtonPressed(_ sender: UIButton)
    {
		gameMasterCallQuantity = quantitySelected; gameMasterCallNum = numSelected;
        p1MakeDecision.leave()
    }
	
    @IBAction func bsButtonPressed(_ sender: UIButton)
	{
		userCalledBS = true; p1MakeDecision.leave()
    }
    
    @IBAction func startRoundPressed(_ sender: UIButton)
    {
		gameMasterCallQuantity = self.quantitySelected; gameMasterCallNum = self.numSelected;
		self.currentCallLabel.text = "\(gameMasterCallQuantity) \(gameMasterCallNum)'s"
		p1SetRound.leave()
    }
    
    func enableUserMakeDecisionInput()
    {
        DispatchQueue.main.sync
        {
            self.bsButton.isHidden = false; self.raiseButton.isHidden = false; self.quantityDicePicker.isHidden = false; self.numDicePicker.isHidden = false;
			self.bsButton.isEnabled = true; self.raiseButton.isEnabled = true;
            self.quantityDicePicker.isUserInteractionEnabled = true;
            self.numDicePicker.isUserInteractionEnabled = true;
        }
    }
    
    func disableUserMakeDecisionInput()
    {
		self.bsButton.isHidden = true; self.raiseButton.isHidden = true; self.quantityDicePicker.isHidden = true; self.numDicePicker.isHidden = true;
		self.bsButton.isEnabled = false; self.raiseButton.isEnabled = false;
		self.quantityDicePicker.isUserInteractionEnabled = false;
		self.numDicePicker.isUserInteractionEnabled = false;
    }
    
	func enableUserSetRoundInput()
	{
		DispatchQueue.main.sync
		{
			print("SET ROUND INTERACTION ENABLED")
			self.quantityDicePicker.isHidden = false; self.numDicePicker.isHidden = false;
			self.quantityDicePicker.isUserInteractionEnabled = true; self.numDicePicker.isUserInteractionEnabled = true;
			self.startRoundButton.isHidden = false; self.startRoundButton.isEnabled = true;
		}
	}
}

// MARK: - Picker Delegate Methods

extension PlayViewController : UIPickerViewDelegate, UIPickerViewDataSource
{
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        if (pickerView.tag == 100)
        {
			return diceQuantity.count
        }
        else
        {
			return diceNums.count
        }
    }
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        if (pickerView.tag == 100)
        {
            return String(diceQuantity[row])
        }
        else
        {
            return String(diceNums[row])
        }
    }
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if (pickerView.tag == 100)
        {
			quantitySelected = diceQuantity[row]
        }
        else
        {
			numSelected = diceNums[row]
        }
    }
}
