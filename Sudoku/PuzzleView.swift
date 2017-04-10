//
//  PuzzleView.swift
//  Sudoku
//
//  Created by Spencer Kitchen on 3/6/17.
//  Copyright © 2017 wsu.vancouver. All rights reserved.
//

/*   *
 *   *
 *   */

import UIKit

struct Colors {
    let navy = (r: 53.0 , g: 68.0, b: 91.0, a: 255.0)
    let blue  = (r: 58.0, g: 153.0, b: 217.0 ,a: 255.0)
    let aqua = (r: 41.0, g: 171.0, b: 163.0 ,a: 255.0)
    let cream = (r: 233.0, g: 225.0, b: 214.0, a: 255.0)
    let salmon = (r: 235.0, g: 114.0, b: 97.0, a: 255.0)
    
}

class PuzzleView: UIView {
    
    /*******************************************************
     * SELECT SQUARE WITH TAP GESTURES                     *
     *                                                     *
     * Sets up tap gesture reconizer and calls handleTap() *
     *  when tap is revieved.                              *
     * ~ From ChessFoo                                     *
     *******************************************************/
    
    var selected = (row : -1, col : -1)
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        NSLog("PuzzleView:init(frame)")
        addMyTapGestureRecognizer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NSLog("PuzzleView:init(decoder)")
        addMyTapGestureRecognizer()
    }
    
    func addMyTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PuzzleView.handleTap(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func awakeFromNib() {
        NSLog("awakeFromNib()")
    }
    
    func handleTap(_ sender : UIGestureRecognizer?) {
        NSLog("Tap!")
        
        let tapPoint = sender?.location(in: self)
        //NSLog("Tap: \(tapPoint)")
        
        let board = getSudokuBoard()
        let gridOrigin = board.size.width
        let delta = gridOrigin / 3
        let d = delta / 3
        let col = Int(((tapPoint?.x)! - board.origin.x)/d)
        let row = Int(((tapPoint?.y)! - board.origin.y)/d)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let puzzle = appDelegate.sudoku // fetch model data
        
        if 0 <= col && col < 9 && 0 <= row && row < 9 { //ifinsidepuzzlebounds
            if (!puzzle!.numberIsFixedAtRow(row: row, column: col)) { // and not a "fixed number"
                if (row != selected.row || col != selected.col) { // and not already selected
                    selected.row = row      // then select cell
                    selected.col = col
                    setNeedsDisplay()       // request redraw
                }
            }
        }
    }

    
    let margin : CGFloat = 10
    /***************************************
     * CREATE SUDOKU BOARD                 *
     *                                     *
     * Create sudoku square board          *
     ***************************************/
    func getSudokuBoard() -> CGRect {
        let size = min(self.bounds.width, self.bounds.height) - margin/2
        let center = CGPoint(x: self.bounds.width/2, y: self.bounds.height/2)
        let board = CGRect(x: center.x - size/2, y: center.y - size/2, width: size, height: size )
        return board
    }

    
    /******************
     * DRAW GAMEBOARD *
     ******************/
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        NSLog("drawRect")
        
        let c = Colors()
        let navy = getRGB(red: CGFloat(c.navy.r), green: CGFloat(c.navy.g), blue: CGFloat(c.navy.b), alpha: CGFloat(c.navy.a))
        let blue = getRGB(red: CGFloat(c.blue.r), green: CGFloat(c.blue.g), blue: CGFloat(c.blue.b), alpha: CGFloat(c.blue.a))
        //let aqua = getRGB(red: CGFloat(c.aqua.r), green: CGFloat(c.aqua.g), blue: CGFloat(c.aqua.b), alpha: CGFloat(c.aqua.a))
        let cream = getRGB(red: CGFloat(c.cream.r), green: CGFloat(c.cream.g), blue: CGFloat(c.cream.b), alpha: CGFloat(c.cream.a))
        let salmon = getRGB(red: CGFloat(c.salmon.r), green: CGFloat(c.salmon.g), blue: CGFloat(c.salmon.b), alpha: CGFloat(c.salmon.a))

        let board = getSudokuBoard()
        let gridSize = board.size.width
        let delta = gridSize / 3
        let d = delta / 3
        let s = d / 3
        let highlightSize = board.size.width / 9
        
        //highlight square ---------------------------------------------------------
        //  draw first so margins go overtop of highlight square
        if selected.row >= 0 && selected.col >= 0 {
            let x = board.origin.x + CGFloat(selected.col) * highlightSize
            let y = board.origin.y + CGFloat(selected.row) * highlightSize
    
            UIColor.init(red: cream.r, green: cream.g, blue: cream.b, alpha: cream.a).setFill()
            context!.fill(CGRect(x: x, y: y, width: d, height: d))
        }

        // Draw 3x3 board ----------------------------------------------------------
        context!.setLineWidth(4)
        //UIColor.black.setStroke()
        UIColor.init(red: navy.r, green: navy.g, blue: navy.b, alpha: navy.a).setStroke()
        context!.stroke(board)
        
        for r in 0 ..< 3 {
            for c in 0 ..< 3 {
                // Adds Border
                context!.stroke(CGRect(x: board.origin.x + CGFloat(c)*delta,
                    y: board.origin.y + CGFloat(r)*delta, width: delta, height: delta))
            }
        }
        
        // Draw 9 X 9 board --------------------------------------------------------
        for r in 0 ..< 9 {
            for c in 0 ..< 9 {
                context!.setLineWidth(1.0)
                // Adds Border
                context!.stroke(CGRect(x: board.origin.x + CGFloat(c)*d,
                    y: board.origin.y + CGFloat(r)*d, width: d, height: d))
            }
        }
        
        // Draw whats inside squares ------------------------------------------------
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let puzzle = appDelegate.sudoku

        
        let horizontalClass : NSInteger = self.traitCollection.horizontalSizeClass.rawValue
        let verticalClass : NSInteger = self.traitCollection.verticalSizeClass.rawValue
        
        //print("H: \(horizontalClass) V: \(verticalClass)")
        
        // Ipad vs Iphone
        let boldFont : UIFont
        let pencilFont : UIFont
        if horizontalClass == 2 && verticalClass == 2{
            boldFont = UIFont(name: "Helvetica-Bold", size: 60)!
            pencilFont = UIFont(name: "Helvetica", size: 20)!
        } else {
            boldFont = UIFont(name: "Helvetica-Bold", size: 30)!
            pencilFont = UIFont(name: "Helvetica", size: 10)!
        }
        
    
        let fixedAttributes = [NSFontAttributeName : boldFont,
                               NSForegroundColorAttributeName : UIColor.init(red: navy.r, green: navy.g, blue: navy.b, alpha: navy.a)] as [String : Any]
        let guessAttributes = [NSFontAttributeName : boldFont,
                               NSForegroundColorAttributeName : UIColor.init(red: blue.r, green: blue.g, blue: blue.b, alpha: blue.a)] as [String : Any]
        let conflictAttributes = [NSFontAttributeName : boldFont,
                                  NSForegroundColorAttributeName : UIColor.init(red: salmon.r, green: salmon.g, blue: salmon.b, alpha: salmon.a)] as [String : Any]
        let pencilAttributes = [NSFontAttributeName : pencilFont,NSForegroundColorAttributeName : UIColor.magenta] as [String : Any]
        
        for col in 0 ..< 9 {
            for row in 0 ..< 9 {
                let number = puzzle!.numberAtRow(row: row, column: col)
                let fixedNum = puzzle!.numberIsFixedAtRow(row: row, column: col)
                let text = "\(number)" as NSString
            
                // FIXED NUMBER  ---------------------------------------
                //  fixed numbers can be 1-9 and are set when game loads
                if fixedNum {
                    let textSize = text.size(attributes: fixedAttributes)
                    let x = board.origin.x + CGFloat(col)*d + 0.5*(d - textSize.width)
                    let y = board.origin.y + CGFloat(row)*d + 0.5*(d - textSize.height)
                    let textRect = CGRect(x: x, y: y, width: textSize.width, height: textSize.height)
                    text.draw(in: textRect, withAttributes: fixedAttributes)

                }
                
                // GUESS NUMBER  -----------------------------------------
                //  guess numbers are user filled in numbers, not fixed, skip if 0
                else if !fixedNum && number != 0 {
                    if puzzle!.isConflictingEntryAtRow(row: row, column: col) {
                        let textSize = text.size(attributes: conflictAttributes)
                        let x = board.origin.x + CGFloat(col)*d + 0.5*(d - textSize.width)
                        let y = board.origin.y + CGFloat(row)*d + 0.5*(d - textSize.height)
                        let textRect = CGRect(x: x, y: y, width: textSize.width, height: textSize.height)
                        text.draw(in: textRect, withAttributes: conflictAttributes)
                        
                    }else {
                        let textSize = text.size(attributes: guessAttributes)
                        let x = board.origin.x + CGFloat(col)*d + 0.5*(d - textSize.width)
                        let y = board.origin.y + CGFloat(row)*d + 0.5*(d - textSize.height)
                        let textRect = CGRect(x: x, y: y, width: textSize.width, height: textSize.height)
                        text.draw(in: textRect, withAttributes: guessAttributes)
                    }
                }
                
                // PENCIL NUMBER -------------------------------------
                //  pencil numbers are small numbers used to make educated guesses
                else {
                    let pencils = puzzle!.getPencilsAtRow(row: row, column: col)
                    var count = 0
                    for r in 0 ..< 3 {
                        for c in 0 ..< 3 {
                            if pencils[count] != 0 {
                                let pencilText = "\(count + 1)" as NSString
                                let textSize = text.size(attributes: pencilAttributes)
                                let x = board.origin.x + CGFloat(col)*d + CGFloat(c)*s + 0.5*(s - textSize.width)
                                let y = board.origin.y + CGFloat(row)*d + CGFloat(r)*s + 0.5*(s - textSize.height)
                                let textRect = CGRect(x: x, y: y, width: textSize.width, height: textSize.height)
                                pencilText.draw(in: textRect, withAttributes: pencilAttributes)
                            }
                            count += 1
                        }
                    }
                }
            }
        }
    }


        
    /****************************************************************
     * Add cornerRadius, borderWidth, and borderColor for UIViews   *
     * in Interface Builder. Can change from IB                     *
     *  SHOWS UP FOR PUZZLEVIEW AND BUTTON VIEW                     *
     ****************************************************************/
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    
    /******************
     * SET UP BUTTONS *
     ******************/
    let buttonTagsPortrait = [ // 2x6 button layout
        [1,2,3,4,5,11], // tags assigned in IB
        [6, 7, 8, 9, 10, 12]
    ]
    let buttonTagsPortraitTall = [ // 3x4 layout
        [1,2,3,11],
        [4,5,6,10],
        [7,8,9,12]
    ]
    let buttonTagsLandscape = [ // 6x2 layout
        [1,6],
        [2,7],
        [3,8],
        [4,9],
        [5,10],
        [11,12]
    ]
    let buttonTagsLandscapeTall = [ // 4x3 layout
        [1,2,3],
        [4,5,6],
        [7,8,9],
        [11,10,12]
    ]
    
    let aspectRatiosForLayouts : [Float] = [ 3.0, // 2 x 6
        4.0/3, //3x4
        1.0/3, //6x2
        3.0/4 // 4 x 3
    ]
    
    override func layoutSubviews() {
        super.layoutSubviews() // let Auto Layout finish
        
        let aspectRatio = Float(self.bounds.size.width / self.bounds.size.height)
        var closestLayout = 0
        var closestLayoutDiff = fabsf(aspectRatio - aspectRatiosForLayouts[0])
        for i in 1 ..< 4 {
            let diff = fabsf(aspectRatio - aspectRatiosForLayouts[i])
            if (diff < closestLayoutDiff) {
                closestLayout = i
                closestLayoutDiff = diff
            }
        }
        
        let buttonTagsFlavors = [
            buttonTagsPortrait, buttonTagsPortraitTall, buttonTagsLandscape, buttonTagsLandscapeTall
        ]
        let buttonTags = buttonTagsFlavors[closestLayout]
        
        func integersWithSum(sum : Int, count : Int) -> [Int] {
            var ints = [Int](repeating: sum / count, count: count)
            let r = sum % count
            for i in 0 ..< r {ints[i] += 1}
            return ints
        }
        
        let inset = 1
        let W = Int(self.bounds.width) - 2*inset, H = Int(self.bounds.height) - 2*inset
        let numColumns = buttonTags[0].count, numRows = buttonTags.count
        let widths  = integersWithSum(sum: W, count: numColumns)
        let heights = integersWithSum(sum: H, count: numRows)
        var y = CGFloat(inset)
        for r in 0 ..< numRows {
            let h = CGFloat(heights[r])
            var x = CGFloat(inset)
            for c in 0 ..< numColumns {
                let w = CGFloat(widths[c])
                let button = self.viewWithTag(buttonTags[r][c])
                button?.bounds = CGRect(x: 0, y: 0, width: w, height: h)
                button?.center = CGPoint(x: x + w/2, y: y + h/2)
                x += w
            }
            y += h
        }
        
    }

    
    /********************************************************************
     * GET RGB COLOR                                                    *
     *                                                                  *
     * returns (r)ed (g)reen (b)lue (a)lpha                             *
     * To set RGB colors you need to divide the known RGB value by 255  *
     *  EXAMPLE:                                                        *
     *    Pink: R: 255/255 = 1.0, G: 195/255 = .76, B: 225/255 = .88    *
     ********************************************************************/
    func getRGB(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> (r: CGFloat, g: CGFloat, b:CGFloat, a: CGFloat) {
        let r = red/255.0
        let g = green/255.0
        let b = blue/255.0
        let a = alpha/255.0
        return (r, g, b, a)
    }
}
