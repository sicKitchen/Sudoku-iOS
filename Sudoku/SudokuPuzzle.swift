//
//  SudokuPuzzle.swift
//  Sudoku
//
//  Created by Spencer Kitchen on 3/7/17.
//  Copyright © 2017 wsu.vancouver. All rights reserved.
//

import Foundation
import UIKit

//
// Holds all the relevent information related to square of game
//
struct Square {
    var number = 0              // holds number in square
    var fixed : Bool = false    // if square is fixed or not
    // Holds the pencil values, each slot represents 1-9 so index is off by 1
    // pencils = [1,1,1,1,1,1,1,1,1]
    //      +-+-+-+
    //      |1|2|3|
    //      +-+-+-+
    //      |4|5|6|
    //      +-+-+-+
    //      |7|8|9|
    //      +-+-+-+
    var pencils = [0,0,0,0,0,0,0,0,0]
}


class SudokuPuzzle {
    
    /***************************
     * Create the empty puzzle *
     ***************************/
    var CurrentState: [[Square]] = []
    
    init(){
        CurrentState = Array(repeating: Array(repeating: Square(), count: 9), count: 9)
        
    }
    
    
    /****************************************************************
     * SAVED STATE                                                  *
     *                                                              *
     * write to plist compatible array (used for data persistence). *
     ****************************************************************/
    func savedState() -> NSArray {
        
        let puzzleHolder = NSMutableArray(capacity: 81)
        
        for row in 0 ..< 9 {
            for col in 0 ..< 9 {
                let square = CurrentState[row][col]
                let squareDict = NSMutableDictionary()
                squareDict.setObject(square.number as Int, forKey: "number" as NSCopying)
                squareDict.setObject(square.fixed as Bool, forKey: "fixed" as NSCopying)
                squareDict.setObject(square.pencils as [Int], forKey: "pencils" as NSCopying)
                puzzleHolder.add(squareDict)
            }
        }
        return puzzleHolder
    }


    /*****************************************************************
     * SET STATE                                                     *
     *                                                               *
     * read from plist compatible array (used for data persistence). *
     *****************************************************************/
    func setState(puzzleArray: NSArray) {
        var i = 0
        for row in 0 ..< 9 {
            for col in 0 ..< 9 {
                let savedDict = puzzleArray[i] as! NSDictionary
                CurrentState[row][col].number = savedDict["number"] as! Int
                CurrentState[row][col].fixed = savedDict["fixed"] as! Bool
                CurrentState[row][col].pencils = savedDict["pencils"] as! [Int]
                i += 1
            }
        }
    }

    
    /*************************************************************
     * LOAD PUZZLE                                               *
     *                                                           *
     *Load new game encoded with given string (see Section 4.1). *
     *************************************************************/
    func loadPuzzle(puzzleString: String) {
        //NSLog(puzzleString)
        
        CurrentState = Array(repeating: Array(repeating: Square(), count : 9), count : 9)
        
        var i : Int = 0
        var num : Int
        
        for row in 0 ..< 9 {
            for col in 0 ..< 9  {
                let index = puzzleString.index(puzzleString.startIndex, offsetBy: i)
                let number = puzzleString[index]
                i += 1
                
                // If "." is read then set to 0, 0 are not 'fixed'
                if number == "." {
                    num = 0
                    setNumber(number: num, row: row, column: col, fixed: false)
                } else {
                    // Its a number, set 'fixed' number
                    num = Int(String(number))!
                    setNumber(number: num, row: row, column: col, fixed: true)
                }
                
            }
        }
    }
    
    
    /************************************************************************
     * NUMBER AT ROW                                                        *
     *                                                                      *
     * Fetch the number stored in the cell at the specified row and column; *
     * zero indicates an empty cell or the cell holds penciled in values.   *
     ************************************************************************/
    func numberAtRow(row: Int, column: Int) -> Int {
        return CurrentState[row][column].number
    }


    /***************************************************************************************
     * SET NUMBER                                                                          *
     *                                                                                     *
     * Set the number at the specified cell; assumes cell does not contain a fixed number, *
     ***************************************************************************************/
    func setNumber(number: Int, row: Int, column: Int, fixed: Bool) {
        CurrentState[row][column].number = number
        if fixed {
            CurrentState[row][column].fixed = fixed
        }
    }
    
    
    /****************************************************
     * NUMBER IS FIXED AT ROW                           *
     *                                                  *
     * Bool Determines if cell contains a fixed number. *
     ****************************************************/
    func numberIsFixedAtRow(row: Int, column: Int) -> Bool {
        return CurrentState[row][column].fixed
    }
    
    
    /****************************************************
     * IS CONFLICTING ENTRY AT ROW                      *
     *                                                  *
     * Does the number conflict with any other          *
     * number in the same row, column, or 3 × 3 square? *
     ****************************************************/
    func isConflictingEntryAtRow(row: Int, column: Int) -> Bool {
        let check = numberAtRow(row: row, column: column)
        var flag = false
        
        // Check row, row stays the same, column changes
        for i in 0 ..< 9 {
            let checkAgainst = numberAtRow(row: row, column: i)
            if check == checkAgainst && i != column {
                //print("row conflict")
                flag = true
            }
        }
        
        // Check column, column stays the same, row changes
        for i in 0 ..< 9 {
            let checkAgainst = numberAtRow(row: i, column: column)
            if check == checkAgainst && i != row {
                //print("column conflict")
                flag = true
            }
        }
        
        // Check 3x3 grid
        /*  row / 3 returns x.00, x.33, x.66. Floor of return will
         always be 0, 1, 2. Multiply by 3 and they turn into
         0, 3, 6 respectivly. Now its equal to start point
         of each small square.*/
        let r = Int(floor(Double(row) / 3.0) * 3)
        let c = Int(floor(Double(column) / 3.0) * 3)
       
        for i in r ..< r+3 {
            for j in c ..< c+3 {
                let checkAgainst = self.numberAtRow(row: i, column: j)
                if check == checkAgainst && i != row && j != column {
                    //print("3x3 conflict")
                    flag = true
                }
            }
        }
        return flag
    }
    
    
    /****************************************************
     * ANY PENCIL SET AT ROW                            *
     *                                                  *
     * Are there any penciled in values at the given    *
     * cell (assumes number = 0)?                       *
     ****************************************************/
    func anyPencilSetAtRow(row: Int, column: Int) -> Bool {
        var flag = false
        for slot in CurrentState[row][column].pencils {
            if slot != 0 {
                flag = true
            }
        }
        return flag
    }
    
    
    /****************************************************
     * NUMBER OF PENCILS SET AT ROW                     *
     *                                                  *
     * returns number of penciled in values at cell.    *
     ****************************************************/
    func numberOfPencilsSetAtRow(row: Int, column: Int) -> Int {
        let size = CurrentState[row][column].pencils.count
        return size
    }
    
    
    /****************************************************
     * GET PENCILS AT ROW                               *
     *                                                  *
     * returns the pencils filled in for square         *
     ****************************************************/
    func getPencilsAtRow(row: Int, column: Int) -> [Int] {
        return CurrentState[row][column].pencils
    }
    
    
    /********************************
     * IS SET PENCIL                *
     *                              *
     * Is the value n penciled in?  *
     ********************************/
    func isSetPencil(n: Int, row: Int, column: Int) -> Bool {
        if CurrentState[row][column].pencils[n-1] == 1 {
            return true
        }else {
            return false
        }
    }
    
    
    /****************************
     * SET PENCIL               *
     *                          *
     * Pencil the value n in.   *
     ****************************/
    func setPencil(n: Int, row: Int, column: Int) {
        // first check if the pencil number is already set
        if isSetPencil(n: n, row: row, column: column) {
            // delete current pencil number
            clearPencil(n: n, row: row, column: column)
        }else {
            // add current pencil number
            CurrentState[row][column].pencils[n-1] = 1
        }
    }
    
    
    /************************
     * CLEAR PENCIL         *
     *                      *
     * Clear pencil value n *
     ************************/
    func clearPencil(n: Int, row: Int, column: Int) {
        CurrentState[row][column].pencils[n-1] = 0
    }
    
    
    /********************************
     * CLEAR ALL PENCILS            *
     *                              *
     * Clear all penciled in values *
     ********************************/
    func clearAllPencils(row: Int, column: Int) {
        CurrentState[row][column].pencils = [0,0,0,0,0,0,0,0,0]
    }
    
    
    /****************************
     * GET FIRST EMPTY SQUARE   *
     ****************************/
    func getFirstEmptyCell() -> (row: Int, column: Int) {
        for r in 0 ..< 9 {
            for c in 0 ..< 9 {
                if numberAtRow(row: r, column: c) == 0 {
                    return (r, c)
                }
            }
        }
        return (-1, -1)
    }
    
    
    /****************************************
     * IS PUZZLE SOLVED                     *
     *                                      *
     * Check if the whole puzzle is solved  *
     ****************************************/
    func isPuzzleSolved() -> Bool {
        var flag = true
        
        for r in 0 ..< 9 {
            for c in 0 ..< 9 {
                // conflict means puzzle is not solved
                if isConflictingEntryAtRow(row: r, column: c) || numberAtRow(row: r, column: c) == 0 {
                    flag = false
                }
            }
        }
        // no colflicts, puzzle is solved
        return flag
    }
    
    
    /*************************************************************
     * CLEAR CONFLICTS                                           *
     *                                                           *
     * Clears all the numbers that are in conflict with solution *
     *************************************************************/
    func clearConflicts(){
        for row in 0 ..< 9 {
            for col in 0 ..< 9 {
                if !numberIsFixedAtRow(row: row, column: col) && isConflictingEntryAtRow(row: row, column: col) && numberAtRow(row: row, column: col) != 0  {
                    setNumber(number: 0, row: row, column: col, fixed: false)
                }
            }
        }
    }
    
    /*********************************************************************
     * CLEAR ALL                                                         *
     *                                                                   *
     * Clears all the non fixed cells, reguardless if conflicting or not *
     *********************************************************************/
    func clearAll(){
        for row in 0 ..< 9 {
            for col in 0 ..< 9 {
                if !numberIsFixedAtRow(row: row, column: col) {
                    setNumber(number: 0, row: row, column: col, fixed: false)
                }
            }
        }
    }
    
}
