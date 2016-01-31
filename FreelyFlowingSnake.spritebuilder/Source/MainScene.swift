import Foundation

class MainScene: CCNode, CCPhysicsCollisionDelegate {
    
    var pieceArray: [Piece] = []
    var piecesInMiniMap: [Piece] = []
    var desiredRotation: Float = 3.14159
    var pieceRotation: Float = 130
    var gameover = false
    
    let screenWidth = CCDirector.sharedDirector().viewSize().width
    let screenHeight = CCDirector.sharedDirector().viewSize().height
    let screenwidthPercent = CCDirector.sharedDirector().viewSize().width / 100
    let screenHeightPercent = CCDirector.sharedDirector().viewSize().height / 100
    
    let fruitPiece = CCBReader.load("Piece")
    let fruitPieceOnMiniMap = CCBReader.load("Piece") as! Piece
    weak var background: CCNodeGradient!
    weak var screenFollowNode: CCNode!
    weak var gameoverLabel: CCLabelTTF!
    weak var ball: CCSprite!
    weak var base: CCSprite!
    weak var slider: CCSlider!
    weak var scoreLabel: CCLabelTTF!
    weak var snakeLand: CCPhysicsNode!
    weak var barrier1: CCNodeColor!
    weak var barrier2: CCNodeColor!
    weak var door: CCNodeColor!
    weak var controls: CCNodeColor!
    weak var miniMap: CCNodeColor!
    
    var score = 0 {
        didSet {
            scoreLabel.string = "Score: \(score)"
            if score >= 5 {
                door.visible = false
            }
        }
    }
    
    func didLoadFromCCB() {
        snakeLand.collisionDelegate = self
        loadInitialPiece()
        userInteractionEnabled = true
        snakeLand.addChild(fruitPiece)
        miniMap.addChild(fruitPieceOnMiniMap)
        fruitPieceOnMiniMap.position = ccp(CGFloat(arc4random_uniform(UInt32(miniMap.contentSizeInPoints.width))), CGFloat(arc4random_uniform(UInt32(miniMap.contentSizeInPoints.height))))
        fruitPieceOnMiniMap.colorNode.color = CCColor(ccColor3b: ccColor3B(r: 255, g: 0, b: 0))
        fruitPiece.position = ccp(CGFloat(arc4random_uniform(UInt32(screenWidth))), CGFloat(arc4random_uniform(UInt32(screenWidth))))
        slider.sliderValue = 0.5
        schedule("makeSnakeMove", interval: 0.05)
        setupDoubleTap()
        sizeEverything()
    }
    
    override func update(delta: CCTime) {
        checkIfSnakeAteFruit()
        detectGameover()
        updateSnakeRotation()
    }
    
    func setupDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: "pauseGame")
        doubleTap.numberOfTapsRequired = 2
        CCDirector.sharedDirector().view.addGestureRecognizer(doubleTap)
    }
    
    func pauseGame() {
        if paused {
            paused = false
        } else {
            paused = true
        }
    }
    
    func loadInitialPiece() {
        let piece = CCBReader.load("Piece") as! Piece
        piece.position = ccp(320, 280)
        snakeLand.addChild(piece)
        pieceArray.insert(piece, atIndex: 0)
    }
    
    func sizeEverything() {
        controls.contentSizeInPoints.width = CCDirector.sharedDirector().viewSize().width
        controls.contentSizeInPoints.height = CCDirector.sharedDirector().viewSize().width * CCDirector.sharedDirector().viewSize().width / CCDirector.sharedDirector().viewSize().height
        miniMap.contentSizeInPoints.height = 0.75 * controls.contentSizeInPoints.height
        miniMap.contentSizeInPoints.width = snakeLand.contentSizeInPoints.width * miniMap.contentSizeInPoints.height / snakeLand.contentSizeInPoints.height
    }
    
    func findNewPosition(currentPosition: CGPoint) -> CGPoint {
        var newPosition: CGPoint!
        let currentSnakeRotationInRadians = pieceArray[0].rotation / Float(180 / M_PI)
        
        let x = 10 * cos(currentSnakeRotationInRadians)
        let y = 10 * sin(currentSnakeRotationInRadians)
        
        newPosition = ccp(CGFloat(Float(currentPosition.x) - x), CGFloat(Float(currentPosition.y) + y))
        followSnake(ccp(CGFloat(x), CGFloat(y)), newPosition: newPosition)
        return newPosition
    }
    
    func makeSnakeMove() {
        let lastPiece: Piece = pieceArray[pieceArray.count - 1]
        let newPiece = CCBReader.load("Piece") as! Piece
        let newPosition = findNewPosition(pieceArray[0].position)
        
        newPiece.position = newPosition
        newPiece.rotation = pieceRotation
        newPiece.colorNode.color = CCColor(ccColor3b: ccColor3B(r: 255, g: 0, b: 0))
        
        snakeLand.removeChild(lastPiece)
        pieceArray.removeAtIndex(pieceArray.indexOf(lastPiece)!)
        
        snakeLand.addChild(newPiece)
        updateMiniMap(newPosition)
        pieceArray.insert(newPiece, atIndex: 0)
        if pieceArray.count > 1 {
            pieceArray[1].colorNode.color = CCColor(ccColor3b: ccColor3B(r: 0, g: 255, b: 0))
        }
    }
    
    func updateMiniMap(position: CGPoint) {
        let piece = CCBReader.load("Piece") as! Piece
        let x = miniMap.contentSizeInPoints.width * position.x / snakeLand.contentSizeInPoints.width
        let y = miniMap.contentSizeInPoints.height * position.y / snakeLand.contentSizeInPoints.height
        piece.position = ccp(x, y)
        piece.scale = Float(miniMap.contentSizeInPoints.width / snakeLand.contentSizeInPoints.width)
        miniMap.addChild(piece)
        
        if miniMap.children.count > score {
            miniMap.removeChild(miniMap.children[1] as! CCNode)
        }
        
    }
    
    func addSnakePiece() {
        score++
        let newPiece = CCBReader.load("Piece") as! Piece
        newPiece.position = findNewPosition(pieceArray[0].position)
        newPiece.rotation = pieceRotation
        newPiece.colorNode.color = CCColor(ccColor3b: ccColor3B(r: 0, g: 255, b: 0))
        pieceArray.insert(newPiece, atIndex: 0)
        snakeLand.addChild(newPiece)
        updateMiniMap(newPiece.position)
        pieceArray[1].colorNode.color = CCColor(ccColor3b: ccColor3B(r: 0, g: 255, b: 0))
    }
    
    func checkIfSnakeAteFruit() {
        if CGRectIntersectsRect(pieceArray[0].boundingBox(), fruitPiece.boundingBox()) {
            addSnakePiece()
            moveFruitPiece()
        }
    }
    
    func moveFruitPiece() {
        fruitPiece.position = ccp(CGFloat(arc4random_uniform(UInt32(screenWidth))), CGFloat(arc4random_uniform(UInt32(screenHeight))))
        fruitPieceOnMiniMap.position.x = miniMap.contentSizeInPoints.width * fruitPiece.position.x / snakeLand.contentSizeInPoints.width
        fruitPieceOnMiniMap.position.y = miniMap.contentSizeInPoints.height * fruitPiece.position.y / snakeLand.contentSizeInPoints.height
        fruitPieceOnMiniMap.scale = Float(miniMap.contentSizeInPoints.width / snakeLand.contentSizeInPoints.width)
    }
    
    func detectGameover() {
        for piece in pieceArray {
            if piece != pieceArray[0] && piece != pieceArray[1] && piece != pieceArray[2] && piece != pieceArray[3] {
                if CGRectIntersectsRect(pieceArray[0].boundingBox(), piece.boundingBox()) && !gameover {
                    unschedule("makeSnakeMove")
                    unschedule("addSnakePiece")
                    gameoverLabel.visible = true
                    let delay = CCActionDelay(duration: 1.5)
                    let restart = CCActionCallBlock(block: {CCDirector.sharedDirector().presentScene(CCBReader.loadAsScene("MainScene"))})
                    runAction(CCActionSequence(array: [delay, restart]))
                    gameover = true
                }
            }
        }
    }
    
    func sliderControl() {
        slider.sliderValue = 0.5
    }
    
    func updateSnakeRotation() {
        let addedRotationInDegrees = (slider.sliderValue * 30) - 15
        pieceRotation = pieceArray[0].rotation + addedRotationInDegrees
        desiredRotation = pieceRotation / Float(180 / M_PI)
        
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, snakePiece nodeA: CCNode!, barrier nodeB: CCNode!) -> Bool {
        print("Hit Barrier")
        return true
    }
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        
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
            ball.position = convertToNodeSpace(location)
            
            print(ball.position)
        } else {
            ball.position = ccp(base.position.x - xDist, base.position.y + yDist)
        }
        
    }
    
    override func touchEnded(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        let move = CCActionMoveTo(duration: 0.2, position: base.position)
        ball.runAction(move)
    }
    
    func followSnake(offSet: CGPoint, newPosition: CGPoint) {
        let XlessThan25: Bool = newPosition.x + snakeLand.position.x < CCDirector.sharedDirector().viewSize().width / 100 * 49
        let XgreaterThan75: Bool = newPosition.x + snakeLand.position.x > CCDirector.sharedDirector().viewSize().width / 100 * 51
        let YlessThan35: Bool = newPosition.y + snakeLand.position.y < CCDirector.sharedDirector().viewSize().height / 100 * 79
        let YgreaterThan65: Bool = newPosition.y + snakeLand.position.y > CCDirector.sharedDirector().viewSize().height / 100 * 81
        let movingRight: Bool = abs(pieceArray[0].rotation) > 90 && abs(pieceArray[0].rotation) < 270
        let movingLeft: Bool = abs(pieceArray[0].rotation) < 90 || abs(pieceArray[0].rotation) > 270
        let movingDown: Bool = abs(pieceArray[0].rotation) < 180
        let movingUp: Bool = abs(pieceArray[0].rotation) > 180
        let notTooFarRight: Bool = (snakeLand.position.x + offSet.x <= 0)
        let notTooFarLeft: Bool = (CCDirector.sharedDirector().viewSize().width - snakeLand.boundingBox().width < snakeLand.position.x + offSet.x)
        let notTooFarUp: Bool = (snakeLand.position.y - offSet.y <= controls.boundingBox().height)
        let notTooFarDown: Bool = (CCDirector.sharedDirector().viewSize().height - snakeLand.boundingBox().height < snakeLand.position.y - offSet.y)
        
        
        if XlessThan25 && movingLeft && notTooFarRight {
            snakeLand.position.x += CGFloat(offSet.x)
        }
        if XgreaterThan75 && movingRight && notTooFarLeft {
            snakeLand.position.x += CGFloat(offSet.x)
        }
        if YlessThan35 && movingDown && notTooFarUp {
            snakeLand.position.y -= CGFloat(offSet.y)
        }
        if YgreaterThan65 && movingUp && notTooFarDown {
            snakeLand.position.y -= CGFloat(offSet.y)
        }
    }
    
    func snakeLandToMMPosition(position: CGPoint) -> CGPoint {
        let x = miniMap.contentSizeInPoints.width * position.x / snakeLand.contentSizeInPoints.width
        let y = miniMap.contentSizeInPoints.height * position.y / snakeLand.contentSizeInPoints.height
        return ccp(x, y)
    }
    
}

class Piece: CCNode {
    weak var colorNode: CCNodeColor!
}