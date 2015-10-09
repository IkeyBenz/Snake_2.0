import Foundation

class MainScene: CCNode {
    var pieceArray: [CCNode] = []
    var desiredRotation: Float!
    
    func didLoadFromCCB() {
        loadInitialPiece()
    }
    func loadInitialPiece() {
        let piece = CCBReader.load("Piece")
        piece.position = ccp(100, 100)
        addChild(piece)
        pieceArray.append(piece)
    }
    func findNewPosition(currentPosition: CGPoint, angle: Float) -> CGPoint {
        var newPosition: CGPoint!
        if pieceArray[0].rotation == desiredRotation {
            let x = 15 * sin(desiredRotation)
            let y = 15 * cos(desiredRotation)
            newPosition.x = currentPosition.x + CGFloat(x)
            newPosition.y = currentPosition.y + CGFloat(y)
        } else {
            
        }
        return newPosition
    }
}
