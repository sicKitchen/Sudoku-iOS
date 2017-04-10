//
//  ViewController.swift
//  Sudoku
//
//  Created by Spencer Kitchen on 3/6/17.
//  Copyright © 2017 wsu.vancouver. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var puzzleView: PuzzleView!
    
    
    lazy var sudoku : SudokuPuzzle! = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.sudoku
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    /********************
     * PENCIL BUTTON    *
     ********************/
    var pencilEnabled : Bool = false  // controller property
    @IBAction func pencilPressed(_ sender: UIButton) {
        print("Pencil Toggle")
        pencilEnabled = !pencilEnabled   // toggle
        sender.isSelected = pencilEnabled
    }
    
    
    /********************
     * NUMBER BUTTONS   *
     ********************/
    @IBAction func number(_ sender: UIButton) {
        print("numberTag: \(sender.tag)")
        let number = sender.tag
        let row = puzzleView.selected.row
        let col = puzzleView.selected.col
        
        // When pencil mode is selected
        if pencilEnabled {
            //print("abount to enter setPencil")
            sudoku.setPencil(n: number, row: row, column: col)
        }
        // When pencil mode isnt selected
        else {
            sudoku.setNumber(number: number, row: row, column: col, fixed: false)
            // Check if puzzle is solved
            if sudoku.isPuzzleSolved() {
                //print("you solved the puzzle")
                solvedAlert()
            }
        }
        
        self.puzzleView.setNeedsDisplay()
    }
    
    // Puzzle solved alert --------------------------------------------------------------
    private func solvedAlert(){
        let alertController = UIAlertController (
            title : "You won the game!", message : "Would You Like To Play Another Game?",
            preferredStyle : .alert)
        
        alertController.addAction(UIAlertAction (
            title: "Cancel", style: .default))
        
        alertController.addAction(UIAlertAction (
            title: "Continue", style: UIAlertActionStyle.default, handler: mainMenu(_:)))
        
        self.present(alertController, animated: true)
    }

    
    /****************
     * CLEAR BUTTON *
     ****************/
    @IBAction func clear(_ sender: UIButton) {
        print("Clear")
        let row = puzzleView.selected.row
        let col = puzzleView.selected.col

        // Clear for pencil toggle enabled
        if pencilEnabled {
            if sudoku.anyPencilSetAtRow(row: row, column: col){
                clearAlert(row: row, column: col)
            }
        } else {
            // clear for non fixed number
            sudoku.setNumber(number: 0, row: row, column: col, fixed: false)
        }
        self.puzzleView.setNeedsDisplay()
    }
    
    // Clear pencil alert ---------------------------------------------------------------
    private func clearAlert(row: Int, column: Int){
        let alert = UIAlertController (title : "Delete all penciled numbers in square?",
            message : "You can't UNDO this!", preferredStyle : .alert)
        
        alert.addAction(UIAlertAction (title: "Cancel", style: .default))
        alert.addAction(UIAlertAction (title: "Yes", style: .default, handler:
            {(UIAlertAction) in
                //print("in clear pencil handle")
                self.sudoku.clearAllPencils(row: row, column: column)
                self.puzzleView.setNeedsDisplay()
            }))
        self.present(alert, animated: true)
    }
    
    
    /****************
     * MENU BUTTON  *
     ****************/
    @IBAction func mainMenu(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let puzzle = appDelegate.sudoku
        
        let alertController = UIAlertController(
            title: "Main Menu",
            message: nil,
            preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil))
        
        alertController.addAction(UIAlertAction(
            title: "New Easy Game",
            style: .default,
            handler: { (UIAlertAction) -> Void in
                let puzzleStr = self.randomPuzzle(puzzles: appDelegate.simplePuzzles)
                puzzle?.loadPuzzle(puzzleString: puzzleStr)
                self.selectFirstAvailableCell()
                self.puzzleView.setNeedsDisplay()}))
        
        alertController.addAction(UIAlertAction(
            title: "New Hard Game",
            style: .default,
            handler: { (UIAlertAction) -> Void in
                let puzzleStr = self.randomPuzzle(puzzles: appDelegate.hardPuzzles)
                puzzle?.loadPuzzle(puzzleString: puzzleStr)
                self.selectFirstAvailableCell()
                self.puzzleView.setNeedsDisplay()}))
        
        alertController.addAction(UIAlertAction(
            title: "Clear Conflicting Cells",
            style: .default,
            handler: { (UIAlertAction) -> Void in
                puzzle?.clearConflicts()
                self.selectFirstAvailableCell()
                self.puzzleView.setNeedsDisplay()}))
        
        alertController.addAction(UIAlertAction(
            title: "Clear All Cells",
            style: .default,
            handler: { (UIAlertAction) -> Void in
                puzzle?.clearAll()
                self.selectFirstAvailableCell()
                self.puzzleView.setNeedsDisplay()}))
            
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            let popoverPresenter = alertController.popoverPresentationController
            let menuButtonTag = 12
            let menuButton = puzzleView.viewWithTag(menuButtonTag)
            popoverPresenter?.sourceView = menuButton
            popoverPresenter?.sourceRect = (menuButton?.bounds)!
        }
        self.present(alertController, animated: true, completion: nil)
        
    }
        

    // select the first open square -------------------------------
    private func selectFirstAvailableCell(){
        let pos = sudoku.getFirstEmptyCell()
        puzzleView.selected.row = pos.row
        puzzleView.selected.col = pos.column
    }
    
    // Select random puzzle -----------------------------------------
    private func randomPuzzle(puzzles : [String]) -> String {
        let rand = Int(arc4random_uniform(UInt32(puzzles.count)))
        return puzzles[rand]
    }
    
}

