//
//  ViewController.swift
//  Twittermenti
//
//  Created by Angela Yu on 17/07/2018.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import UIKit
import SwifteriOS
import CoreML
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    
    @IBOutlet weak var posLabel: UILabel!
    @IBOutlet weak var negLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    
    let tweetCount = 100
    
    let sentimentClassifier = TweetSentimentClassifier()
    
//    let swifter = Swifter(consumerKey: "_your_key_here", consumerSecret: "_your_secret_here_")
    
    let swifter = Swifter(consumerKey: "LTReJyreyyuz4SWjVABuA1WKI", consumerSecret: "ajf107xfd6869heCG8Ptn8iztfFHBWPIxLkFGvsmoEwI7MKZcz")

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func predictPressed(_ sender: Any) {
    
        fetchTweets()
        
    }
    
    func fetchTweets() {
        
        if let searchText = textField.text {
            
            swifter.searchTweet(using: searchText, lang: "en", count: tweetCount, tweetMode: .extended, success: { (results, metadata) in
                
                var tweets = [TweetSentimentClassifierInput]()
                
                for i in 0..<self.tweetCount {
                    if let tweet = results[i]["full_text"].string {
                        let tweetForClassification = TweetSentimentClassifierInput(text: tweet)
                        tweets.append(tweetForClassification)
                    }
                }
                
                self.makePrediction(with: tweets)
                
            }) { (error) in
                print("There was an error with the Twitter API Request, \(error)")
            }
        }
        
    }
    
    func makePrediction(with tweets: [TweetSentimentClassifierInput]) {
        
        do {
            
            let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
            
            var sentimentScore = 0
            var posCounter = 0
            var negCounter = 0
            
            for pred in predictions {
                let sentiment = pred.label
                
                if sentiment == "Pos" {
                    sentimentScore += 1
                    posCounter += 1
                } else if sentiment == "Neg" {
                    sentimentScore -= 1
                    negCounter -= 1
                }

            }
            
            updateUI(with: sentimentScore, posCounter, negCounter)
            
            
        } catch {
            print("There was an error with making a prediction, \(error)")
        }
        
    }
    
    func updateUI(with sentimentScore: Int, _ posCounter: Int, _ negCounter: Int) {
        print(sentimentScore, posCounter, negCounter)
        
        posLabel.text = String("Positive Thoughts: +\(posCounter)")
        negLabel.text = String("Negative Thoughts: \(negCounter)")
        resultLabel.text = String("Results:  \(sentimentScore)")
        
        switch sentimentScore {
        case 20... :
            self.sentimentLabel.text = "😍"
        case 11...20 :
            self.sentimentLabel.text = "😀"
        case 1...10 :
            self.sentimentLabel.text = "🙂"
        case 0 :
            self.sentimentLabel.text = "😐"
        case (-10)...(-1) :
            self.sentimentLabel.text = "😕"
        case (-20)...(-11) :
            self.sentimentLabel.text = "😡"
        default:
            self.sentimentLabel.text = "🤮"
        }
    }
}

