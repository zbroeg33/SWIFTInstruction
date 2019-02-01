import SpriteKit
import PlaygroundSupport
// Declare some global constants
class ExampleClass {
    
    var color: SKColor! //= SKColor.red
    var radius: CGFloat! //= 20 as CGFloat
    //let shape = SKShapeNode(circleOfRadius: radius)
    init(color: SKColor, radius: CGFloat) {
        self.color = color
        self.radius = radius
    }
}


let width = 400 as CGFloat
let height = 600 as CGFloat
let racketHeight = 150 as CGFloat
let ballRadius = 20 as CGFloat

// Three types of collision objects possible
enum CollisionTypes: UInt32 {
    case Ball = 1
    case Wall = 2
    case Racket = 4
}

// Racket direction
enum Direction: Int{
    case None = 0
    case Up = 1
    case Down = 2
}

// SpriteKit scene
class gameScene: SKScene, SKPhysicsContactDelegate {
    let racketSpeed = 500.0
    var direction = Direction.None
    var score = 0
    var gameRunning = false
    
    // Screen elements
    var racket: SKShapeNode?
    var ball: SKShapeNode?
    let scoreLabel = SKLabelNode()
    
    // Initialize objects during first start
    override func sceneDidLoad() {
        super.sceneDidLoad()
        var resr = SKShapeNode()
        scoreLabel.fontSize = 40
        scoreLabel.position = CGPoint(x: width/2, y: height - 100)
        self.addChild(scoreLabel)
        
        createWalls()
        createBall(position: CGPoint(x: width / 2, y: height / 2))
        createRacket()
        startNewGame()
        self.physicsWorld.contactDelegate = self
    }
    
    
    // Create the ball sprite
    func createBall(position: CGPoint) {
        let exampleInstance = ExampleClass(color: SKColor.red, radius: 20 as CGFloat)
        
        let physicsBody = SKPhysicsBody(circleOfRadius: exampleInstance.radius)
        ball = SKShapeNode(circleOfRadius: exampleInstance.radius)
        physicsBody.categoryBitMask = CollisionTypes.Ball.rawValue
        physicsBody.collisionBitMask = CollisionTypes.Wall.rawValue | CollisionTypes.Ball.rawValue | CollisionTypes.Racket.rawValue
        physicsBody.affectedByGravity = false
        physicsBody.restitution = 1
        physicsBody.linearDamping = 0
        physicsBody.velocity = CGVector(dx: -500, dy: 500)
        ball!.physicsBody = physicsBody
        ball!.position = position
        //ball!.fillColor = SKColor.white
        ball!.fillColor = exampleInstance.color
        //ball!.fillColor = exampleInstance.color
    }
    
    // Create the walls
    func createWalls() {
        createWall(rect: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: ballRadius, height: height)))
        createWall(rect: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: width, height: ballRadius)))
        createWall(rect: CGRect(origin: CGPoint(x: 0, y: height - ballRadius), size: CGSize(width: width, height: ballRadius)))
    }
    
    func createWall(rect: CGRect) {
        let node = SKShapeNode(rect: rect)
        node.fillColor = SKColor.white
        node.physicsBody = getWallPhysicsbody(rect: rect)
        self.addChild(node)
    }
    
    // Create the physics objetcs to handle wall collisions
    func getWallPhysicsbody(rect: CGRect) -> SKPhysicsBody {
        let physicsBody = SKPhysicsBody(rectangleOf: rect.size, center: CGPoint(x: rect.midX, y: rect.midY))
        physicsBody.affectedByGravity = false
        physicsBody.isDynamic = false
        physicsBody.collisionBitMask = CollisionTypes.Ball.rawValue
        physicsBody.categoryBitMask = CollisionTypes.Wall.rawValue
        return physicsBody
    }
    
    // Create the racket sprite
    func createRacket() {
        racket =  SKShapeNode(rect: CGRect(origin: CGPoint.zero, size: CGSize(width: ballRadius, height: racketHeight)))
        self.addChild(racket!)
        racket!.fillColor = SKColor.white
        let physicsBody = SKPhysicsBody(rectangleOf: racket!.frame.size, center: CGPoint(x: racket!.frame.midX, y: racket!.frame.midY))
        physicsBody.affectedByGravity = false
        physicsBody.isDynamic = false
        physicsBody.collisionBitMask = CollisionTypes.Ball.rawValue
        physicsBody.categoryBitMask = CollisionTypes.Racket.rawValue
        physicsBody.contactTestBitMask = CollisionTypes.Ball.rawValue
        racket!.physicsBody = physicsBody
    }
    
    // Start a new game
    func startNewGame() {
        score = 0
        scoreLabel.text = "0"
        racket!.position = CGPoint(x: width - ballRadius * 2, y: height / 2)
        
        var counter = 3
        let startLabel = SKLabelNode(text: "Game Over")
        startLabel.position = CGPoint(x: width / 2, y: height / 2)
        startLabel.fontSize = 160
        self.addChild(startLabel)
        
        // Animated countdown
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        startLabel.text = "3"
        startLabel.run(SKAction.sequence([fadeIn, fadeOut]), completion: {
            startLabel.text = "2"
            startLabel.run(SKAction.sequence([fadeIn, fadeOut]), completion: {
                startLabel.text = "1"
                startLabel.run(SKAction.sequence([fadeIn, fadeOut]), completion: {
                    startLabel.text = "0"
                    startLabel.run(SKAction.sequence([fadeIn, fadeOut]), completion: {
                        startLabel.removeFromParent()
                        self.gameRunning = true
                        self.ball!.position = CGPoint(x: 30, y: height / 2)
                        self.addChild(self.ball!)
                    })
                })
            })
        })
    }
    
    // Handle touch events to move the racket
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            var location = touch.location(in: self)
            if location.y > height / 2 {
                direction = Direction.Up
            } else if location.y < height / 2{
                direction = Direction.Down
            }
        }
    }
    
    // Stop racket movement
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        direction = Direction.None
    }
    
    // Game loop:
    // - Game over check: Ball still on screen
    // - Trigger racket movement
    var dt = TimeInterval(0)
    override func update(_ currentTime: TimeInterval) {
        if gameRunning {
            super.update(currentTime)
            checkGameOver()
            if dt > 0 {
                moveRacket(dt: currentTime - dt)
            }
            dt = currentTime
        }
    }
    
    // Move the racket up or down
    func moveRacket(dt: TimeInterval) {
        if direction == Direction.Up && racket!.position.y < height - racketHeight {
            racket!.position.y = racket!.position.y + CGFloat(racketSpeed * dt)
        } else if direction == Direction.Down && racket!.position.y > 0 {
            racket!.position.y = racket!.position.y - CGFloat(racketSpeed * dt)
        }
    }
    
    // Check if the ball is still on screen
    // Game Over animation
    func checkGameOver() {
        if ball!.position.x > CGFloat(width) {
            gameRunning = false
            ball!.removeFromParent()
            let gameOverLabel = SKLabelNode(text: "Game Over")
            gameOverLabel.position = CGPoint(x: width / 2, y: height / 2)
            gameOverLabel.fontSize = 60
            self.addChild(gameOverLabel)
            
            // Game Over animation
            /*let rotateAction = SKAction.rotate(byAngle: CGFloat(M_PI), duration: 1)
            let fadeInAction = SKAction.fadeIn(withDuration: 2)
            gameOverLabel.run(SKAction.repeat(rotateAction, count: 2))*/
            gameOverLabel.run(SKAction.fadeOut(withDuration: 2.5), completion: {
                gameOverLabel.removeFromParent()
                self.startNewGame()
            })
            //self.startNewGame()
        }
    }
    
    // Detect collisions between ball and racket to increase the score
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == CollisionTypes.Racket.rawValue || contact.bodyB.categoryBitMask == CollisionTypes.Racket.rawValue {
            score += 1
            scoreLabel.text = String(score)
        }
    }
}

//Initialize the playground and start the scene:
let skView = SKView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: height)))
let scene = gameScene(size: skView.frame.size)
skView.presentScene(scene)

PlaygroundPage.current.liveView =  skView
