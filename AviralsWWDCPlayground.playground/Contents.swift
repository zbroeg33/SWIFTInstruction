import SpriteKit
import PlaygroundSupport
import GameKit
struct EmojiModel
{
    var emoji : String
    var emojiValue  : Int
    var emojiTime : CGFloat
    var emojiName : String
    
    init(emoji : String,emojiValue : Int,emojiTime : CGFloat)
    {
        self.emoji = emoji
        self.emojiValue = emojiValue
        self.emojiTime = emojiTime
        emojiName = "\(emojiValue)"
        
    }
    
    func getEmoji() -> String
    {
        return self.emoji
    }
    
    func getEmojiTime() -> CGFloat{
        return self.emojiTime
    }
    
    func getEmojiValue() -> Int
    {
        return self.emojiValue
    }
    
}
//Extending the Class SKSpriteNode to set the touchAblePoroperty of Button and other Elements.
class TouchableSrpiteNode : SKSpriteNode
{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.25)
        fadeOutAction.timingMode = .easeInEaseOut
        
        self.run(fadeOutAction, completion: {
            
            self.removeFromParent()
        })
        
    }
}

//Extending the Class SKLabelNode to set the touchAbleProperty of the Emoji
protocol TouchableSpriteTextNodeDelegate: class {
    func didTap(sender: TouchableSpriteTextNode)
}

class TouchableSpriteTextNode : SKLabelNode
{
    var delegate : TouchableSpriteTextNodeDelegate!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let action = SKAction.playSoundFileNamed("popSound.mp3", waitForCompletion: false)
        self.run(action)
        
        if let delegate = delegate
        {
            delegate.didTap(sender: self)
            return
        }
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.05)
        fadeOutAction.timingMode = .easeInEaseOut
        self.run(fadeOutAction, completion: {
            self.removeFromParent()
        })
        
    }
}

public class MainScene: SKScene {
    
    //Properties
    var flowerTextures = [SKTexture]()
    let buttonNodeName = "button"
    
    // StringsForLocalization
    var isInitialScene = true
    let wwdcIconName = "wwdcIcon"
    let initialTextNodes = "welcome"
    let helloString = "Hello"
    let namasteString = "Namaste"
    let emojiHandString = "🙏"
    let welcomeString = "Welcome to"
    let gameName = "Happoji"
    
    // Game Timer and Score Label
    let roundIdentifier = "roundLabel"
    let timerIndentifier = "timerLabel"
    let scoreIdentifier = "scoreLabel"
    
    var timer : SKLabelNode = SKLabelNode()
    var score : SKLabelNode = SKLabelNode()
    
    //Variables for Initial Emoji Animation
    var lineWiseX : CGFloat = 0
    var lineWiseY : CGFloat = 0
    var jumpedAhead = false
    
    //Emojis for Initial View
    let emojis = ["😀","😃","😄"]
    
    // Game Rules
    let noOfRounds = 1
    var currentRound = 1
    let totalTime = [60,50,40]
    let totalScore = [10,15,20]
    let totalEmojis = [60,50,40]
    var scoreValue = 0
    var isTimeOver = false
    //EmojiSetForRound
    var emojisRound : [EmojiModel] = [EmojiModel]()
    
    
    //Lifecycle
    override public func didMove(to view: SKView) {
        super.didMove(to: view)
        
        let background = SKSpriteNode(imageNamed: "halftone")
        background.name = "background"
        background.setScale(1.5)
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(background)
        
        setUpIntialScene()
        
        // setting Flower Textures
        for i in 1...8 {
            flowerTextures.append(SKTexture(imageNamed: "flower\(i).png"))
        }
        
    }
    
    //Initial Welcome Scene
    func setUpIntialScene()
    {
        scaleMode = .resizeFill
        physicsWorld.gravity = CGVector.zero
        view?.isMultipleTouchEnabled = true
        
        
        let namaste = SKLabelNode(fontNamed: "Helvetica Neue")
        namaste.text = namasteString
        namaste.name = initialTextNodes
        namaste.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: namaste.frame.width * 1.25 , height: namaste.frame.height * 2.5))
        namaste.physicsBody?.isDynamic = false
        namaste.fontSize = 30
        namaste.fontColor = SKColor.black
        namaste.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(namaste)
        
        let hello = SKLabelNode(fontNamed: "Helvetica Neue")
        hello.text = helloString
        hello.name = initialTextNodes
        hello.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: hello.frame.width * 1.25 , height: hello.frame.height * 2.5))
        hello.physicsBody?.isDynamic = false
        hello.fontSize = 30
        hello.fontColor = SKColor.black
        hello.position = CGPoint(x: frame.midX , y: frame.midY + namaste.frame.height + 10)
        addChild(hello)
        
        let emoji = SKLabelNode(fontNamed: "Helvetica Neue")
        emoji.text = emojiHandString
        emoji.name = initialTextNodes
        emoji.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: emoji.frame.width * 1.25 , height: emoji.frame.height * 2.5))
        emoji.physicsBody?.isDynamic = false
        emoji.fontSize = 45
        emoji.fontColor = SKColor.black
        emoji.position = CGPoint(x: frame.midX , y: frame.midY - (namaste.frame.height + 10) - 10)
        addChild(emoji)
        
        let welcomeTo = SKLabelNode(fontNamed: "Helvetica Neue")
        welcomeTo.text = welcomeString
        welcomeTo.name = initialTextNodes
        welcomeTo.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: welcomeTo.frame.width * 1.25 , height: welcomeTo.frame.height * 2.5))
        welcomeTo.physicsBody?.isDynamic = false
        welcomeTo.fontSize = 20
        welcomeTo.fontColor = SKColor.black
        welcomeTo.position = CGPoint(x: frame.midX , y: frame.midY - (namaste.frame.height + 10) - (emoji.frame.height + 10))
        addChild(welcomeTo)
        
        let game = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        game.text = gameName
        game.name = initialTextNodes
        game.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: game.frame.width * 1.25 , height: game.frame.height * 2.5))
        game.physicsBody?.isDynamic = false
        game.fontSize = 30
        game.fontColor = SKColor.black
        game.position = CGPoint(x: frame.midX , y: frame.midY - (namaste.frame.height + 10) - (emoji.frame.height + 10) - (welcomeTo.frame.height + 10) - 5)
        addChild(game)
        
        let button = PlayButton()
        button.name = buttonNodeName
        button.position = CGPoint(x: frame.midX , y: frame.midY - (namaste.frame.height + 10) - (emoji.frame.height + 10) - (welcomeTo.frame.height + 10) - (game.frame.height + 10) - 5)
        button.delegate = self
        button.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: button.frame.width * 1.25 , height: button.frame.height * 2.5))
        button.physicsBody?.isDynamic = false
        button.alpha = 0
        addChild(button)
        
        
        //addLinewiseEmojiElements()
        
    }
    
    //Function to add Emojis in the Initial Scene
    /*func addLinewiseEmojiElements()
    {
        let wait = SKAction.wait(forDuration:0.02)
        let action = SKAction.run {
            let point = CGPoint(x: self.lineWiseX, y: self.lineWiseY)
            self.createRandomEmoji(at: point)
            self.lineWiseX = self.lineWiseX + 30
            
            if (!self.jumpedAhead && self.lineWiseX > 150 && self.lineWiseY < (self.frame.midY + 100)){
                self.lineWiseX = self.lineWiseX + 160
                self.jumpedAhead = true
            }
            
            if(self.lineWiseX >= self.frame.width + 50)
            {
                self.lineWiseX = 0
                self.jumpedAhead = false
                self.lineWiseY = self.lineWiseY + 30
            }
            if (self.lineWiseY >= self.frame.height)
            {
                self.removeAllActions()
                self.enumerateChildNodes(withName: self.buttonNodeName) { (node, stop) in
                    let fadeInAction = SKAction.fadeIn(withDuration: 0.1)
                    fadeInAction.timingMode = .easeInEaseOut
                    node.run(fadeInAction, completion: {
                        node.alpha = 1
                    })
                }
            }
        }
        
        run(SKAction.repeatForever(SKAction.sequence([wait, action])))
        
    }*/
    
    //function to Create Random Emoji given a point
    func createRandomEmoji(at point: CGPoint) {
        let randomEmojiIndex = GKRandomSource.sharedRandom().nextInt(upperBound: emojis.count)
        
        let person = TouchableSpriteTextNode(fontNamed: "Helvetica Neue")
        person.text = emojis[randomEmojiIndex]
        person.isUserInteractionEnabled = true
        person.name = wwdcIconName
        person.fontSize = 25
        person.position = CGPoint(x: point.x, y: point.y)
        
        let maxRadius = max(person.frame.size.width/2, person.frame.size.height/2)
        let interPersonSeparationConstant: CGFloat = 1.25
        person.physicsBody = SKPhysicsBody(circleOfRadius: maxRadius*interPersonSeparationConstant)
        
        addChild(person)
    }
    
    //Function that starts the game
    func gameStart()
    {
        self.setUpGameScene()
    }
    
    //Function to Initiate the CountDown
    func setUpScene() {
        scaleMode = .resizeFill
        physicsWorld.gravity = CGVector.zero
        view?.isMultipleTouchEnabled = true
        
        self.removeAllActions()
        self.removeAllChildren()
        let background = SKSpriteNode(imageNamed: "halftone")
        background.name = "background"
        background.setScale(1.5)
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(background)
        
        //Call the function to start the game
        gameStart()
    }
    
    //Function to set the Emoji Array
    func setEmojiArray()
    {
        //Setting Emoji Array with scoreValue and Time the Emoji will stay
        var emoji = EmojiModel(emoji: "🙂", emojiValue: 0, emojiTime: 1)
        emojisRound.append(emoji)
        
        emoji = EmojiModel(emoji: "🙃", emojiValue: 1, emojiTime: 1)
        emojisRound.append(emoji)
        
        emoji = EmojiModel(emoji: "😀", emojiValue: 0, emojiTime: 1)
        emojisRound.append(emoji)
        
        emoji = EmojiModel(emoji: "😃", emojiValue: 0, emojiTime: 1)
        emojisRound.append(emoji)
    }
    
    //Function to set Random Emoji in the game scene. Choose a Position Randomly.
    func addEmojiOnRandomPlaces()
    {
        if isTimeOver == true{
            return
        }
        let randomEmojiIndex = GKRandomSource.sharedRandom().nextInt(upperBound: emojisRound.count)
        
        let randomEmojiPositionX = 10 +  GKRandomSource.sharedRandom().nextInt(upperBound: Int(self.frame.width - 20))
        let randomEmojiPositionY = 50 + GKRandomSource.sharedRandom().nextInt(upperBound: Int(self.frame.height - 40))
        
        let emoji = TouchableSpriteTextNode(fontNamed: "Helvetica Neue")
        emoji.delegate = self
        emoji.text = emojisRound[randomEmojiIndex].emoji
        emoji.isUserInteractionEnabled = true
        emoji.name = emojisRound[randomEmojiIndex].emojiName
        emoji.fontSize = 30
        emoji.position = CGPoint(x: CGFloat(randomEmojiPositionX), y: CGFloat(randomEmojiPositionY))
        
        let maxRadius = max(emoji.frame.size.width/2, emoji.frame.size.height/2)
        let interPersonSeparationConstant: CGFloat = 1.25
        emoji.physicsBody = SKPhysicsBody(circleOfRadius: maxRadius*interPersonSeparationConstant)
        
        let randomTime = GKRandomSource.sharedRandom().nextInt(upperBound: 4)
        let time = emojisRound[randomEmojiIndex].emojiTime + CGFloat(randomTime)
        let fadeOutAction = SKAction.fadeOut(withDuration: TimeInterval(time))
        fadeOutAction.timingMode = .easeInEaseOut
        emoji.run(fadeOutAction, completion: {
            emoji.removeFromParent()
            self.addEmojiOnRandomPlaces()
        })
        
        addChild(emoji)
    }
    
    //Function to set the Game UI Elements and Initiate the Game
    func setUpGameScene()
    {
        let round = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        round.text = "Round \(currentRound)"
        round.name = roundIdentifier
        round.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: round.frame.width * 1.25 , height: round.frame.height * 2.5))
        round.physicsBody?.isDynamic = false
        round.fontSize = 20
        round.fontColor = SKColor.black
        round.position = CGPoint(x: 50 , y: self.frame.height - 25)
        addChild(round)
        round.alpha = 0
        var fadeOutAction = SKAction.fadeIn(withDuration: 1)
        fadeOutAction.timingMode = .easeInEaseOut
        round.run(fadeOutAction, completion: {
            round.alpha = 1
        })
        
        timer = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        timer.text = "Timer : \(self.totalTime[currentRound - 1])"
        timer.name = timerIndentifier
        timer.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: timer.frame.width * 1.25 , height: timer.frame.height * 2.5))
        timer.physicsBody?.isDynamic = false
        timer.fontSize = 20
        timer.fontColor = SKColor.black
        timer.position = CGPoint(x: self.frame.width - 70 , y: self.frame.height - 25)
        addChild(timer)
        timer.alpha = 0
        fadeOutAction = SKAction.fadeIn(withDuration: 1)
        fadeOutAction.timingMode = .easeInEaseOut
        timer.run(fadeOutAction, completion: {
            self.timer.alpha = 1
        })
        
        score = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        score.text = "Score : 0"
        score.name = scoreIdentifier
        score.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: timer.frame.width * 1.25 , height: timer.frame.height * 2.5))
        score.physicsBody?.isDynamic = false
        score.fontSize = 20
        score.fontColor = SKColor.black
        score.position = CGPoint(x: 60 , y: 15)
        addChild(score)
        score.alpha = 0
        fadeOutAction = SKAction.fadeIn(withDuration: 1)
        fadeOutAction.timingMode = .easeInEaseOut
        score.run(fadeOutAction, completion: {
            self.score.alpha = 1
        })
        
        let button = ResetButton()
        button.name = buttonNodeName
        button.position = CGPoint(x: frame.width - 70, y: 25)
        button.delegate = self
        addChild(button)
        
        
        let wait = SKAction.wait(forDuration:0.02)
        let action = SKAction.run {
            self.addEmojiOnRandomPlaces()
        }
        
        run(SKAction.repeat(SKAction.sequence([wait, action]) , count: totalEmojis[currentRound-1] ))
        
        var timeCount = totalTime[self.currentRound - 1] - 1
        let waitTimer = SKAction.wait(forDuration: 1)
        let actionTimer = SKAction.run {
            self.timer.text = "Timer : \(timeCount)"
            timeCount = timeCount - 1;
            if timeCount == -1
            {
                self.removeAllActions()
                self.isTimeOver = true
                if self.scoreValue >= self.totalScore[self.currentRound-1]
                {
                    if self.currentRound == self.noOfRounds
                    {
                        self.congratulation()
                    }
                    else
                    {
                        self.moveToNextRound()
                    }
                }
                else{
                    self.showReplayButton()
                }
            }
        }
        
        run(SKAction.repeat(SKAction.sequence([waitTimer, actionTimer]) , count: totalTime[self.currentRound - 1] ))
    }
    
    //Function to Show the Congratulation Message if user clears all the round
    func congratulation()
    {
        currentRound = 1
        let namaste = SKLabelNode(fontNamed: "Helvetica Neue")
        namaste.text = "Congratulations!"
        namaste.name = initialTextNodes
        namaste.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: namaste.frame.width * 1.25 , height: namaste.frame.height * 2.5))
        namaste.physicsBody?.isDynamic = false
        namaste.fontSize = 30
        namaste.fontColor = SKColor.black
        namaste.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(namaste)
        namaste.alpha = 0
        
        var fadeOutAction = SKAction.fadeIn(withDuration: 1)
        fadeOutAction.timingMode = .easeInEaseOut
        namaste.run(fadeOutAction, completion: {
            namaste.alpha = 1
        })
        var movex : CGFloat = -10
        let movey : CGFloat = 20
        
        for _ in 0...5 {
            
            for _ in 0...2 {
                let randomTextureIndex = GKRandomSource.sharedRandom().nextInt(upperBound: self.flowerTextures.count)
                
                let person = TouchableSrpiteNode(texture: self.flowerTextures[randomTextureIndex])
                person.isUserInteractionEnabled = true
                person.name = "flowers"
                person.setScale(0.375)
                person.position = CGPoint(x: namaste.position.x + movex , y: namaste.position.y - 30)
                
                let maxRadius = max(person.frame.size.width/2, person.frame.size.height/2)
                let interPersonSeparationConstant: CGFloat = 1.25
                person.physicsBody = SKPhysicsBody(circleOfRadius: maxRadius*interPersonSeparationConstant)
                
                self.addChild(person)
                
                let flower = TouchableSrpiteNode(texture: self.flowerTextures[randomTextureIndex])
                flower.isUserInteractionEnabled = true
                flower.name = "flowers"
                flower.setScale(0.375)
                flower.position = CGPoint(x: namaste.position.x + movex , y: namaste.position.y + movey)
                
                flower.physicsBody = SKPhysicsBody(circleOfRadius: maxRadius*interPersonSeparationConstant)
                
                self.addChild(flower)
            }
            movex = movex + CGFloat(10)
        }
        
        
        let emoji = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        emoji.text = "You Won ❤️"
        emoji.name = initialTextNodes
        emoji.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: emoji.frame.width * 1.25 , height: emoji.frame.height * 2.5))
        emoji.physicsBody?.isDynamic = false
        emoji.fontSize = 45
        emoji.fontColor = SKColor.black
        emoji.position = CGPoint(x: frame.midX , y: frame.midY - (namaste.frame.height + 10) - 10)
        addChild(emoji)
    }
    
    //Function to show the Next Round Button
    func moveToNextRound()
    {
        
        let namaste = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        namaste.text = "You Won ❤️"
        namaste.name = initialTextNodes
        namaste.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: namaste.frame.width * 1.25 , height: namaste.frame.height * 2.5))
        namaste.physicsBody?.isDynamic = false
        namaste.fontSize = 30
        namaste.fontColor = SKColor.black
        namaste.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(namaste)
        var movex : CGFloat = -10
        let movey : CGFloat = 20
        
        for _ in 0...5 {
            
            for _ in 0...2 {
                let randomTextureIndex = GKRandomSource.sharedRandom().nextInt(upperBound: self.flowerTextures.count)
                
                let person = TouchableSrpiteNode(texture: self.flowerTextures[randomTextureIndex])
                person.isUserInteractionEnabled = true
                person.name = "flowers"
                person.setScale(0.375)
                person.position = CGPoint(x: namaste.position.x + movex , y: namaste.position.y - 30)
                
                let maxRadius = max(person.frame.size.width/2, person.frame.size.height/2)
                let interPersonSeparationConstant: CGFloat = 1.25
                person.physicsBody = SKPhysicsBody(circleOfRadius: maxRadius*interPersonSeparationConstant)
                
                self.addChild(person)
                
                let flower = TouchableSrpiteNode(texture: self.flowerTextures[randomTextureIndex])
                flower.isUserInteractionEnabled = true
                flower.name = "flowers"
                flower.setScale(0.375)
                flower.position = CGPoint(x: namaste.position.x + movex , y: namaste.position.y + movey)
                
                flower.physicsBody = SKPhysicsBody(circleOfRadius: maxRadius*interPersonSeparationConstant)
                
                self.addChild(flower)
            }
            movex = movex + CGFloat(10)
        }
        
        let button = NextButton()
        button.name = buttonNodeName
        button.position = CGPoint(x: frame.midX, y: frame.midY - (namaste.frame.height + 10))
        button.delegate = self
        button.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: button.frame.width * 1.25 , height: button.frame.height * 2.5))
        button.physicsBody?.isDynamic = false
        addChild(button)
    }
    
    //Function to Show Replay Button if user loses the round
    func showReplayButton()
    {
        
        let namaste = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        namaste.text = "You Lose 😭"
        namaste.name = initialTextNodes
        namaste.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: namaste.frame.width * 1.25 , height: namaste.frame.height * 2.5))
        namaste.physicsBody?.isDynamic = false
        namaste.fontSize = 30
        namaste.fontColor = SKColor.black
        namaste.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(namaste)
    }
    
    //Function to remove Emojis if they go out of the View
    override public func didSimulatePhysics() {
        super.didSimulatePhysics()
        
        // Remove nodes if they're outside the view
        enumerateChildNodes(withName: wwdcIconName) { (node, stop) in
            if node.position.y < -50 || node.position.y > self.frame.size.height + 50 || node.position.x < -50 || node.position.x > self.frame.size.width + 50 {
                node.removeFromParent()
            }
        }
    }
    
    //function to Detect the change in the view Size
    public override func didChangeSize(_ oldSize: CGSize) {
        resetButtonPosition()
    }
    
    func resetButtonPosition() {
        guard let button = childNode(withName: buttonNodeName) else { return }
        button.position = CGPoint(x: frame.width - 50, y: 50)
    }
    
    //Hides and show button function when user taps.
    func hideButton() {
        guard let button = childNode(withName: buttonNodeName) else { return }
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.25)
        fadeOutAction.timingMode = .easeInEaseOut
        button.run(fadeOutAction)
    }
    
    func showButton() {
        guard let button = childNode(withName: buttonNodeName) else { return }
        let fadeInAction = SKAction.fadeIn(withDuration: 0.25)
        fadeInAction.timingMode = .easeInEaseOut
        button.run(fadeInAction)
    }
    
    //Touch Handling
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        hideButton()
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        for touch in touches {
            let location = touch.location(in: self)
            if isInitialScene {
                createRandomEmoji(at: location)
            }
            
        }
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        showButton()
        
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        showButton()
    }
}

// MARK: ResetButtonDelegate
extension MainScene: ResetButtonDelegate {
    
    func didTapReset(sender: ResetButton) {
        self.isInitialScene = false
        self.scoreValue = 0
        self.isTimeOver = false
        self.setUpScene()
    }
}

//GameEmojiButtonDelegate
extension MainScene : TouchableSpriteTextNodeDelegate{
    
    //Handles when user clicks on the Emoji and adds an Animation.
    func didTap(sender: TouchableSpriteTextNode) {
        let value = Int(sender.name ?? "0")
        scoreValue = scoreValue + (value ?? 0)
        self.score.text = "Score : \(scoreValue)"
        
        if value! > 0
        {
            let namaste = SKLabelNode(fontNamed: "Helvetica Neue")
            namaste.text = "+\(value!)"
            namaste.name = initialTextNodes
            
            namaste.fontSize = 15
            namaste.fontColor = SKColor.blue
            namaste.position = CGPoint(x: sender.position.x, y: sender.position.y)
            addChild(namaste)
            
            var fadeOutAction = SKAction.fadeOut(withDuration: 1)
            fadeOutAction.timingMode = .easeInEaseOut
            namaste.run(fadeOutAction, completion: {
                namaste.removeFromParent()
            })
            
            let starEmoji = "🌟"
            let emoji1 = SKLabelNode(fontNamed: "Helvetica Neue")
            emoji1.text = starEmoji
            emoji1.name = initialTextNodes
            emoji1.fontSize = 20
            emoji1.fontColor = SKColor.black
            emoji1.position = CGPoint(x: sender.position.x + 20, y: sender.position.y)
            addChild(emoji1)
            fadeOutAction = SKAction.fadeOut(withDuration: 1)
            fadeOutAction.timingMode = .easeInEaseOut
            emoji1.run(fadeOutAction, completion: {
                emoji1.removeFromParent()
            })
            
            let emoji2 = SKLabelNode(fontNamed: "Helvetica Neue")
            emoji2.text = starEmoji
            emoji2.name = initialTextNodes
            emoji2.fontSize = 20
            emoji2.fontColor = SKColor.black
            emoji2.position = CGPoint(x: sender.position.x, y: sender.position.y + 20)
            addChild(emoji2)
            fadeOutAction = SKAction.fadeOut(withDuration: 1)
            fadeOutAction.timingMode = .easeInEaseOut
            emoji2.run(fadeOutAction, completion: {
                emoji2.removeFromParent()
            })
            
            let emoji3 = SKLabelNode(fontNamed: "Helvetica Neue")
            emoji3.text = starEmoji
            emoji3.name = initialTextNodes
            emoji3.fontSize = 20
            emoji3.fontColor = SKColor.black
            emoji3.position = CGPoint(x: sender.position.x - 20, y: sender.position.y)
            addChild(emoji3)
            fadeOutAction = SKAction.fadeOut(withDuration: 1)
            fadeOutAction.timingMode = .easeInEaseOut
            emoji3.run(fadeOutAction, completion: {
                emoji3.removeFromParent()
            })
            
        }
        else if value! < 0
        {
            let namaste = SKLabelNode(fontNamed: "Helvetica Neue")
            namaste.text = "\(value!)"
            namaste.name = initialTextNodes
            namaste.fontSize = 15
            namaste.fontColor = SKColor.red
            namaste.position = CGPoint(x: sender.position.x, y: sender.position.y)
            addChild(namaste)
            
            
            var fadeOutAction = SKAction.fadeOut(withDuration: 1)
            fadeOutAction.timingMode = .easeInEaseOut
            namaste.run(fadeOutAction, completion: {
                
                namaste.removeFromParent()
            })
            
            let heatEmoji = "💥"
            
            let emoji1 = SKLabelNode(fontNamed: "Helvetica Neue")
            emoji1.text = heatEmoji
            emoji1.name = initialTextNodes
            emoji1.fontSize = 20
            emoji1.fontColor = SKColor.black
            emoji1.position = CGPoint(x: sender.position.x + 20, y: sender.position.y)
            addChild(emoji1)
            fadeOutAction = SKAction.fadeOut(withDuration: 1)
            fadeOutAction.timingMode = .easeInEaseOut
            emoji1.run(fadeOutAction, completion: {
                emoji1.removeFromParent()
            })
            
            let emoji2 = SKLabelNode(fontNamed: "Helvetica Neue")
            emoji2.text = heatEmoji
            emoji2.name = initialTextNodes
            emoji2.fontSize = 20
            emoji2.fontColor = SKColor.black
            emoji2.position = CGPoint(x: sender.position.x, y: sender.position.y + 20)
            addChild(emoji2)
            fadeOutAction = SKAction.fadeOut(withDuration: 1)
            fadeOutAction.timingMode = .easeInEaseOut
            emoji2.run(fadeOutAction, completion: {
                emoji2.removeFromParent()
            })
            
            let emoji3 = SKLabelNode(fontNamed: "Helvetica Neue")
            emoji3.text = heatEmoji
            emoji3.name = initialTextNodes
            emoji3.fontSize = 20
            emoji3.fontColor = SKColor.black
            emoji3.position = CGPoint(x: sender.position.x - 20, y: sender.position.y)
            addChild(emoji3)
            fadeOutAction = SKAction.fadeOut(withDuration: 1)
            fadeOutAction.timingMode = .easeInEaseOut
            emoji3.run(fadeOutAction, completion: {
                emoji3.removeFromParent()
            })
            
        }
        
        let fadeOutActions = SKAction.fadeOut(withDuration: 0.05)
        fadeOutActions.timingMode = .easeInEaseOut
        sender.run(fadeOutActions, completion: {
            sender.removeFromParent()
            self.addEmojiOnRandomPlaces()
        })
    }
    
}

//NextButtonDelegate
extension MainScene : NextButtonDelegate
{
    func didTapNext(sender: NextButton) {
        self.currentRound = self.currentRound + 1
        self.isInitialScene = false
        self.scoreValue = 0
        self.isTimeOver = false
        self.setUpScene()
    }
}

//PlayButtonDelegate
extension MainScene: PlayButtonDelegate {
    
    func didTapPlay(sender: PlayButton) {
        //Changing Gravity to add the Initial Play Game button Click Animation when emoji drops.
        physicsWorld.gravity = CGVector.init(dx: 0, dy: -1)
        self.hideButton()
        let wait = SKAction.wait(forDuration: 4)
        let action = SKAction.run {
            self.enumerateChildNodes(withName: self.wwdcIconName) { (node, stop) in
                let fadeOutAction = SKAction.fadeOut(withDuration: 0.25)
                fadeOutAction.timingMode = .easeInEaseOut
                node.run(fadeOutAction, completion: {
                    node.removeFromParent()
                })
            }
            self.enumerateChildNodes(withName: self.initialTextNodes) { (node, stop) in
                let fadeOutAction = SKAction.fadeOut(withDuration: 1)
                fadeOutAction.timingMode = .easeInEaseOut
                node.run(fadeOutAction, completion: {
                    node.removeFromParent()
                })
            }
            
            self.enumerateChildNodes(withName: self.buttonNodeName) { (node, stop) in
                let fadeOutAction = SKAction.fadeOut(withDuration: 1)
                fadeOutAction.timingMode = .easeInEaseOut
                node.run(fadeOutAction, completion: {
                    node.removeFromParent()
                    self.removeAllActions()
                    self.isInitialScene = false
                    self.setEmojiArray()
                    self.setUpScene()
                    
                })
            }
        }
        
        run(SKAction.repeatForever(SKAction.sequence([wait, action])))
    }
}

protocol NextButtonDelegate: class {
    func didTapNext(sender: NextButton)
}

public class NextButton: SKSpriteNode {
    
    // MARK: Properties
    
    weak var delegate: NextButtonDelegate?
    
    // MARK: Lifecycle
    
    init() {
        let texture = SKTexture(imageNamed: "nextRound")
        
        let color = SKColor.red
        let size = CGSize(width: 120, height: 36)
        super.init(texture: texture, color: color, size: size)
        
        isUserInteractionEnabled = true
        zPosition = 1
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Touch Handling
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        alpha = 0.5
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        let location = touches.first!.location(in: self)
        if location.isInside(node: self) {
            let alphaAction = SKAction.fadeAlpha(to: 0.5, duration: 0.10)
            alphaAction.timingMode = .easeInEaseOut
            run(alphaAction)
        }
        else {
            performButtonAppearanceResetAnimation()
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        performButtonAppearanceResetAnimation()
        
        let location = touches.first!.location(in: self)
        if location.isInside(node: self) {
            // Touch Up Inside
            delegate?.didTapNext(sender: self)
        }
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        performButtonAppearanceResetAnimation()
    }
    
    // MARK: Helper Functions
    
    func performButtonAppearanceResetAnimation() {
        let alphaAction = SKAction.fadeAlpha(to: 1.0, duration: 0.10)
        alphaAction.timingMode = .easeInEaseOut
        run(alphaAction)
    }
    
}


// MARK: Play Button Delegate

protocol PlayButtonDelegate: class {
    func didTapPlay(sender: PlayButton)
}

public class PlayButton: SKSpriteNode {
    
    // MARK: Properties
    
    weak var delegate: PlayButtonDelegate?
    
    // MARK: Lifecycle
    
    init() {
        let texture = SKTexture(imageNamed: "playButton")
        
        let color = SKColor.red
        let size = CGSize(width: 120, height: 36)
        super.init(texture: texture, color: color, size: size)
        
        isUserInteractionEnabled = true
        zPosition = 1
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Touch Handling
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        alpha = 0.5
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        let location = touches.first!.location(in: self)
        if location.isInside(node: self) {
            let alphaAction = SKAction.fadeAlpha(to: 0.5, duration: 0.10)
            alphaAction.timingMode = .easeInEaseOut
            run(alphaAction)
        }
        else {
            performButtonAppearanceResetAnimation()
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        performButtonAppearanceResetAnimation()
        
        let location = touches.first!.location(in: self)
        if location.isInside(node: self) {
            // Touch Up Inside
            delegate?.didTapPlay(sender: self)
        }
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        performButtonAppearanceResetAnimation()
    }
    
    // MARK: Helper Functions
    
    func performButtonAppearanceResetAnimation() {
        let alphaAction = SKAction.fadeAlpha(to: 1.0, duration: 0.10)
        alphaAction.timingMode = .easeInEaseOut
        run(alphaAction)
    }
    
}

public class ResetButton: SKSpriteNode {
    
    // MARK: Properties
    
    weak var delegate: ResetButtonDelegate?
    
    // MARK: Lifecycle
    
    init() {
        let texture = SKTexture(imageNamed: "replay")
        let color = SKColor.red
        let size = CGSize(width: 120, height: 36)
        super.init(texture: texture, color: color, size: size)
        
        isUserInteractionEnabled = true
        zPosition = 1
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Touch Handling
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        alpha = 0.5
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        let location = touches.first!.location(in: self)
        if location.isInside(node: self) {
            let alphaAction = SKAction.fadeAlpha(to: 0.5, duration: 0.10)
            alphaAction.timingMode = .easeInEaseOut
            run(alphaAction)
        }
        else {
            performButtonAppearanceResetAnimation()
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        performButtonAppearanceResetAnimation()
        
        let location = touches.first!.location(in: self)
        if location.isInside(node: self) {
            // Touch Up Inside
            delegate?.didTapReset(sender: self)
        }
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        performButtonAppearanceResetAnimation()
    }
    
    // MARK: Helper Functions
    
    func performButtonAppearanceResetAnimation() {
        let alphaAction = SKAction.fadeAlpha(to: 1.0, duration: 0.10)
        alphaAction.timingMode = .easeInEaseOut
        run(alphaAction)
    }
    
}

// MARK: CGPoint Extension for Hit Testing

extension CGPoint {
    
    func isInside(node: SKSpriteNode) -> Bool {
        if self.x > -node.size.width/2, self.x < node.size.width/2, self.y > -node.size.height/2, self.y < node.size.height/2 { return true }
        return false
    }
}

// MARK: ResetButtonDelegate

protocol ResetButtonDelegate: class {
    func didTapReset(sender: ResetButton)
}




//Constant Values for the game.
let width = 480
let height = 540

// Code to bring the game
let spriteView = SKView(frame: CGRect(x: 0, y: 0, width: width, height: height))

//Debugging commands
//spriteView.showsDrawCount = true
//spriteView.showsNodeCount = true
//spriteView.showsFPS = true

// Adding game to playground so that we all can play
let scene = MainScene(size: CGSize(width: width, height: height))
spriteView.presentScene(scene)

// Show in Playground live view
PlaygroundPage.current.liveView = spriteView

