//
//  ViewController.swift
//  NumberTracker
//
//  Created by Sushant Tiwari on 23/05/17.
//  Copyright © 2017 Sushant Tiwari. All rights reserved.
//

import UIKit
import SocketIO
import UserNotifications
import AudioToolbox

let serverName = URL(string: "http://ios-test.us-east-1.elasticbeanstalk.com/")
let nameSpace = "/random"
let socketEvent = "capture"

let kSavedRandomKey = "randomNumberDBKey"

class ViewController: UIViewController {
    
    var socket: SocketHandler? = nil
    var numberArray = [Int]()
    var totalRandCount: Int = 0
    @IBOutlet weak var lineChart: LineChart!
    @IBOutlet weak var totalRandCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        socket?.getInt(forEvent: socketEvent) {[weak self] randNum in
            guard let randomNumber = randNum else {
                return
            }
            self?.add(randomNumber: randomNumber)
        }
        lineChart.isUserInteractionEnabled = false
        lineChart.setup()
        totalRandCount = getCountFromDataBase()
        totalRandCountLabel.text = "\(totalRandCount)"
        if totalRandCount > 0 {
            numberArray = getValuesFromDataBase()
            lineChart.updateChart(withData: numberArray)
        }
    }
    
    func add(randomNumber: Int) {
        if(randomNumber > 9 || randomNumber < 1) {
            return
        }
        if let first = numberArray.first {
            if(first == randomNumber) {
                triggerLocalNotif()
            }
        }
        numberArray.insert(randomNumber, at: 0)
        if(numberArray.count > 10) {
            numberArray.removeLast()
        }
        lineChart.updateChart(withData: numberArray)
        addToDatabase(randomNumber: randomNumber)
        totalRandCount += 1
        totalRandCountLabel.text = "\(totalRandCount)"
    }
    
    func addToDatabase(randomNumber num: Int) {
        if var numberArray = UserDefaults.standard.object(forKey: kSavedRandomKey) as? [Int] {
            numberArray.append(num)
            UserDefaults.standard.set(numberArray, forKey: kSavedRandomKey)
        } else {
            UserDefaults.standard.set([num], forKey: kSavedRandomKey)
        }
    }
    
    func getCountFromDataBase() -> Int {
        if let numberArray = UserDefaults.standard.object(forKey: kSavedRandomKey) as? [Int] {
            return numberArray.count
        } else {
            return 0
        }
    }
    
    func getValuesFromDataBase() -> [Int] {
        if var numberArray = UserDefaults.standard.object(forKey: kSavedRandomKey) as? [Int] {
            if(numberArray.count < 10) {
                return numberArray
            } else {
                var arr = [Int]()
                for i in numberArray.count - 10 ..< numberArray.count {
                    arr.append(numberArray[i])
                }
                return arr
            }
        } else {
            return [Int]()
        }
    }
    
    func triggerLocalNotif() {
        let content = UNMutableNotificationContent()
        content.title = "Random Number Tracker"
        content.body = "Two same random numbers received consecutively."
        content.categoryIdentifier = "category"
        content.sound = UNNotificationSound(named: "customNotifSound.caf")
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 0.01,
            repeats: false)
        let request = UNNotificationRequest(
            identifier: "identifier",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request) { [weak self] (error) in
            self?.playSound()
        }
    }
    
    func playSound() {
        let url = NSURL(fileURLWithPath: Bundle.main.path(forResource: "customNotifSound", ofType: ".caf")!)
        var soundId = SystemSoundID()
        AudioServicesCreateSystemSoundID(url, &soundId)
        AudioServicesPlaySystemSound(soundId)
    }
    
}

