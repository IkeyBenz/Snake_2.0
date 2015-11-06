import Foundation

class MainScene: CCNode {
    
    enum Direction {
        case Right, Left, Straight
    }
    
    var pieceArray: [CCNode] = []
    var desiredRotation: Float = 3.14159
    var pieceRotation: Float = 130
    var snakeDirection: Direction = .Straight
    
    let screenWidth = CCDirector.sharedDirector().viewSize().width
    let screenHeight = CCDirector.sharedDirector().viewSize().height
    
    let fruitPiece = CCBReader.load("Piece")
    weak var background: CCNodeGradient!
    weak var screenFollowNode: CCNode!
    weak var gameoverLabel: CCLabelTTF!
    weak var ball: CCSprite!
    weak var base: CCSprite!
    weak var slider: CCSlider!
    
    func didLoadFromCCB() {
        loadInitialPiece()
        userInteractionEnabled = true
        fruitPiece.position = ccp(CGFloat(arc4random_uniform(UInt32(screenWidth))), CGFloat(arc4random_uniform(UInt32(screenHeight))))
        addChild(fruitPiece)
        slider.sliderValue = 0.5
        schedule("makeSnakeMove", interval: 0.07)

    }
    override func update(delta: CCTime) {
        snakeAteFruit()
        detectGameover()
        updateSnakeRotation()
        print(slider.sliderValue)

    }
    
    func loadInitialPiece() {
        let piece = CCBReader.load("Piece")
        piece.position = ccp(200, 200)
        addChild(piece)
        pieceArray.insert(piece, atIndex: 0)
    }
    func findNewPosition(currentPosition: CGPoint) -> CGPoint {
        var newPosition: CGPoint!
        let currentSnakeRotationInRadians = pieceArray[0].rotation / Float(180 / M_PI)
        
        let x = 10 * cos(currentSnakeRotationInRadians)
        let y = 10 * sin(currentSnakeRotationInRadians)
        
        newPosition = ccp(CGFloat(Float(currentPosition.x) - x), CGFloat(Float(currentPosition.y) + y))
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
    
    func detectGameover() {
        for piece in pieceArray {
            if piece != pieceArray[0] && piece != pieceArray[1] && piece != pieceArray[2] && piece != pieceArray[3] {
                if CGRectIntersectsRect(pieceArray[0].boundingBox(), piece.boundingBox()) {
                    unschedule("makeSnakeMove")
                    gameoverLabel.visible = true
                    let delay = CCActionDelay(duration: 1.5)
                    let restart = CCActionCallBlock(block: {CCDirector.sharedDirector().presentScene(CCBReader.loadAsScene("MainScene"))})
                    runAction(CCActionSequence(array: [delay, restart]))
                }
            }
            
        }
    }
    
    func updateSnakeRotation() {
        let addedRotationInDegrees = (slider.sliderValue * 40) - 20
        pieceRotation = pieceArray[0].rotation + addedRotationInDegrees
        desiredRotation = pieceRotation / Float(180 / M_PI)
        
    }

//    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
//        base.position = touch.locationInWorld()
//        ball.position = touch.locationInWorld()
//        base.visible = true
//        ball.visible = true
//    }
//    override func touchMoved(touch: CCTouch!, withEvent event: CCTouchEvent!) {
//        let location = touch.locationInNode(self)
//        let v = CGVector(dx: location.x - base.position.x, dy: location.y - base.position.y)
//        let angle = atan2(v.dy, v.dx)
//        let degrees = angle * CGFloat(180 / M_PI)
//        pieceRotation = -Float(degrees + 180)
//        desiredRotation = Float(angle + 3.14159)
//        
//        let length: CGFloat = base.boundingBox().height / 2
//        let xDist: CGFloat = sin(angle - 1.57079633) * length
//        let yDist: CGFloat = cos(angle - 1.57079633) * length
//        
//        if CGRectContainsPoint(base.boundingBox(), location) {
//            ball.position = location
//        } else {
//            ball.position = ccp(base.position.x - xDist, base.position.y + yDist)
//        }
//        
//    }
//    override func touchEnded(touch: CCTouch!, withEvent event: CCTouchEvent!) {
//        let move = CCActionMoveTo(duration: 0.2, position: base.position)
//        ball.runAction(move)
//        let delay = CCActionDelay(duration: 0.3)
//        let hideBall = CCActionCallBlock(block: {self.ball.visible = false})
//        let hideBase = CCActionCallBlock(block: {self.base.visible = false})
//        runAction(CCActionSequence(array: [delay, hideBall, hideBase]))
//    }
    
}
