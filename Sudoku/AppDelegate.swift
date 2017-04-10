//
//  AppDelegate.swift
//  Sudoku
//
//  Created by Spencer Kitchen on 3/6/17.
//  Copyright © 2017 wsu.vancouver. All rights reserved.
//

import UIKit

func sandboxArchivePath() -> String {
    let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as NSString
    return dir.appendingPathComponent("Sudoku.plist")
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var sudoku : SudokuPuzzle?

    // get puzzle names --------------------------------
    func getPuzzles(name: String) -> [String] {
        let path = Bundle.main.path(forResource: name, ofType: "plist")
        let array = NSArray(contentsOfFile: path!)
        return array as! [String]
    }

    
    // get simple puzzle -------------------------------
    lazy var simplePuzzles : [String] = {
        let selectedPuzzle = self.getPuzzles(name: "simple")
        return selectedPuzzle
    }()
    
    // get hard puzzle ----------------------------------
    lazy var hardPuzzles : [String] = {
        let selectedPuzzle = self.getPuzzles(name: "hard")
        return selectedPuzzle
    }()
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Data persistence - from LottoFu
        let archiveName = sandboxArchivePath()
        //print("archiveName: \(archiveName)")
        if FileManager.default.fileExists(atPath: archiveName) {    //saved data exists
            //print("data exists, loading from plist")
            if let dict = NSArray(contentsOfFile: archiveName){
                self.sudoku = SudokuPuzzle() //create board
                self.sudoku!.setState(puzzleArray: dict as NSArray)   //set to save state
            }
            
        } else {    //sandbox data is empty
            //print("no persistant data, creating new puzzle")
            self.sudoku = SudokuPuzzle() //create board
            let puzzleStr = self.randomPuzzle(puzzles: simplePuzzles)
            self.sudoku?.loadPuzzle(puzzleString: puzzleStr)
        }
        return true
    }
    
    // Select random puzzle -----------------------------------------
    private func randomPuzzle(puzzles : [String]) -> String {
        let rand = Int(arc4random_uniform(UInt32(puzzles.count)))
        return puzzles[rand]
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        //save puzzle state to sandbox
        let archiveName = sandboxArchivePath()
        //print("archiveName: \(archiveName)")
        let myDict = sudoku!.savedState()
        //print("SAVED DICT: ")
        //print (myDict)
        let error = myDict.write(toFile : archiveName, atomically: true)
        print("write: ", error)

    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

