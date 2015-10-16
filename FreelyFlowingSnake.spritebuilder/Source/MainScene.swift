import Foundation

class MainScene: CCNode {
    var pieceArray: [CCNode] = []
    var desiredRotation: Float = 3.14159
    var pieceRotation: Float = 130
    
    let screenWidth = CCDirector.sharedDirector().viewSize().width
    let screenHeight = CCDirector.sharedDirector().viewSize().height
    
    let fruitPiece = CCBReader.load("Piece")
    weak var ball: CCSprite!
    weak var base: CCSprite!
    
    func didLoadFromCCB() {
        loadInitialPiece()
        userInteractionEnabled = true
        fruitPiece.position = ccp(CGFloat(arc4random_uniform(UInt32(screenWidth))), CGFloat(arc4random_uniform(UInt32(screenHeight))))
        addChild(fruitPiece)
        schedule("makeSnakeMove", interval: 0.1)
        
    }
    override func update(delta: CCTime) {
        snakeAteFruit()
    }
    
    func loadInitialPiece() {
        let piece = CCBReader.load("Piece")
        piece.position = ccp(200, 200)
        addChild(piece)
        pieceArray.insert(piece, atIndex: 0)
    }
    func findNewPosition(currentPosition: CGPoint) -> CGPoint {
        var newPosition: CGPoint!
        let y = 15 * sin(desiredRotation)
        let x = 15 * cos(desiredRotation)
        
        newPosition = ccp(CGFloat(Float(currentPosition.x) - x), CGFloat(Float(currentPosition.y) - y))
        return newPosition
    }
    func makeSnakeMove() {
        let lastPiece: CCNode = pieceArray[pieceArray.count - 1]
        let newPiece = CCBReader.load("Piece")
        let newPosition = findNewPosition(pieceArray[0].position)
        newPiece.position = newPosition
        newPiece.rotation = pieceRotation
        removeChild(lastPiece)
        pieceArray.removeAtIndex(pieceArray.indexOf(lastPiece)!)
        addChild(newPiece)
        pieceArray.insert(newPiece, atIndex: 0)
    }
    func addSnakePiece() {
        let newPiece = CCBReader.load("Piece")
        newPiece.position = findNewPosition(pieceArray[0].position)
        newPiece.rotation = pieceRotation
        pieceArray.insert(newPiece, atIndex: 0)
        addChild(newPiece)
    }
    func snakeAteFruit() {
        if CGRectIntersectsRect(pieceArray[0].boundingBox(), fruitPiece.boundingBox()) {
            addSnakePiece()
            fruitPiece.position = ccp(CGFloat(arc4random_uniform(UInt32(screenWidth))), CGFloat(arc4random_uniform(UInt32(screenHeight))))
        }
    }
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        base.position = touch.locationInWorld()
        ball.position = touch.locationInWorld()
        base.visible = true
        ball.visible = true
    }
    override func touchMoved(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        let location = touch.locationInNode(self)
        let v = CGVector(dx: location.x - base.position.x, dy: location.y - base.position.y)
        let angle = atan2(v.dy, v.dx)
        let degrees = angle * CGFloat(180 / M_PI)
        pieceRotation = -Float(degrees + 180)
        desiredRotation = Float(angle + 3.14159)
        
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
        let delay = CCActionDelay(duration: 0.3)
        let hideBall = CCActionCallBlock(block: {self.ball.visible = false})
        let hideBase = CCActionCallBlock(block: {self.base.visible = false})
        runAction(CCActionSequence(array: [delay, hideBall, hideBase]))
    }
    
}
