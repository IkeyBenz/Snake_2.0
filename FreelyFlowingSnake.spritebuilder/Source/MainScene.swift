import Foundation

class MainScene: CCNode {
    var pieceArray: [CCNode] = []
    var desiredRotation: Float = 44
    weak var ball: CCSprite!
    weak var base: CCSprite!
    
    func didLoadFromCCB() {
        loadInitialPiece()
        userInteractionEnabled = true
        schedule("makeSnakeMove", interval: 1)
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
        let y = 15 * cos(movementAngle)
        let x = 15 * sin(movementAngle)
        
        
        newPosition = ccp(CGFloat(Float(currentPosition.x) + positiveOrNegativeX(x)), CGFloat(Float(currentPosition.y) + positiveOrNegativeY(y)))
        print(newPosition)
        return newPosition
    }
    func makeSnakeMove() {
        let lastPiece: CCNode = pieceArray[pieceArray.count - 1]
        let newPiece = CCBReader.load("Piece")
        let newPosition = findNewPosition(pieceArray[0].position, movementAngle: abs(xComponent() - desiredRotation))
        newPiece.position = newPosition
        newPiece.rotation = desiredRotation - 90
        removeChild(lastPiece)
        pieceArray.removeAtIndex(pieceArray.indexOf(lastPiece)!)
        addChild(newPiece)
        pieceArray.insert(newPiece, atIndex: 0)
    }
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        ball.position = touch.locationInNode(self)
    }
    override func touchMoved(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        let location = touch.locationInNode(self)
        let v = CGVector(dx: location.x - base.position.x, dy: location.y - base.position.y)
        let angle = atan2(v.dy, v.dx)
        let degrees = angle * CGFloat(180 / M_PI)
        print(degrees + 180)
        desiredRotation = Float(degrees) + 180
        
        let length: CGFloat = base.boundingBox().height / 2
        let xDist: CGFloat = sin(angle - 1.57079633) * length
        let yDist: CGFloat = cos(angle - 1.57079633) * length
        
        if CGRectContainsPoint(base.boundingBox(), location) {
            ball.position = location
        } else {
            ball.position = ccp(base.position.x - xDist, base.position.y + yDist)
        }
        
    }
    override func touchEnded(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        let move = CCActionMoveTo(duration: 0.2, position: base.position)
        ball.runAction(move)
    }
    
}
