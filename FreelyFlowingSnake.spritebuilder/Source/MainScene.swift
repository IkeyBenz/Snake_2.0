import Foundation

class MainScene: CCNode {
    var pieceArray: [CCNode] = []
    var desiredRotation: Float = 44
    
    func didLoadFromCCB() {
        loadInitialPiece()
        schedule("makeSnakeMove", interval: 2)
        print(pieceArray[0].position)
    }
    
    func loadInitialPiece() {
        let piece = CCBReader.load("Piece")
        piece.position = ccp(200, 200)
        addChild(piece)
        pieceArray.insert(piece, atIndex: 0)
    }
    func xComponent() -> Float {
        if desiredRotation < 180 {
            return Float(90)
        } else if desiredRotation == 180 {
            // Figure out what to do if desired Rotation is 180 or 0
        }
        return Float(270)
    }
    func positiveOrNegativeX(number: Float) -> Float {
        if desiredRotation > 0 && desiredRotation < 180 {
            return number
        } else {
            return -number
        }
    }
    func positiveOrNegativeY(number: Float) -> Float {
        if desiredRotation < 90 && desiredRotation > 0 || desiredRotation > 270 && desiredRotation < 360 {
            return -number
        } else {
            return number
        }
    }
    func findNewPosition(currentPosition: CGPoint, movementAngle: Float) -> CGPoint {
        var newPosition: CGPoint!
        let y = (15 * cos(movementAngle))
        let x = (15 * sin(movementAngle))
        
        newPosition = ccp(CGFloat(Float(currentPosition.x) + positiveOrNegativeX(x)), CGFloat(Float(currentPosition.y) + positiveOrNegativeY(y)))
        print(newPosition)
        return newPosition
    }
    func makeSnakeMove() {
        let lastPiece: CCNode = pieceArray[pieceArray.count - 1]
        let newPiece = CCBReader.load("Piece")
        let newPosition = findNewPosition(pieceArray[0].position, movementAngle: abs(xComponent() - desiredRotation))
        newPiece.position = newPosition
        newPiece.rotation = desiredRotation
        removeChild(lastPiece)
        pieceArray.removeAtIndex(pieceArray.indexOf(lastPiece)!)
        addChild(newPiece)
        pieceArray.insert(newPiece, atIndex: 0)
    }
}
