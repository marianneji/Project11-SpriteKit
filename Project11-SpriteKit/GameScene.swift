//
//  GameScene.swift
//  Project11-SpriteKit
//
//  Created by Graphic Influence on 29/07/2019.
//  Copyright © 2019 marianne massé. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let location = SKView(frame: CGRect(x: 0, y: -560, width: 1024, height: 760))
    
    var numberOfBallsLabel: SKLabelNode!
    
    var boxes = [SKSpriteNode]()
    
    var numberOfBalls = 5 {
        didSet {
            numberOfBallsLabel.text = "Balls left: \(numberOfBalls)"
        }
    }
    
    
    
    var scoreLabel: SKLabelNode!
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var editLabel: SKLabelNode!
    
    var editingMode: Bool = false {
        didSet {
            if editingMode {
                editLabel.text = "Edit"
            } else {
                editLabel.text = "Done"
            }
        }
    }
    
    
    
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        numberOfBallsLabel = SKLabelNode(fontNamed: "Chalkduster")
        numberOfBallsLabel.position = CGPoint(x: 980, y: 650)
        numberOfBallsLabel.horizontalAlignmentMode = .right
        numberOfBallsLabel.text = "Balls Left: 5"
        addChild(numberOfBallsLabel)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 980, y: 700)
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.text = "Score: 0"
        addChild(scoreLabel)
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.position = CGPoint(x: 80, y: 700)
        editLabel.horizontalAlignmentMode = .left
        editLabel.text = "Tap to Edit"
        addChild(editLabel)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))
        
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
        
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA.name == "ball" {
            collision(between: nodeA, object: nodeB)
        } else if nodeB.name == "ball" {
            collision(between: nodeB, object: nodeA)
        }
        
        endGame()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let position = touch.location(in: self)
        let objects = nodes(at: position)
        if objects.contains(editLabel) {
            editingMode.toggle()
        } else {
            if editingMode {
                
                let boxSize = CGSize(width: Int.random(in: 16...128), height: 16)
                let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: boxSize)
                box.zRotation = CGFloat.random(in: 0...3)
                box.position = position
                
                box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                box.physicsBody?.isDynamic = false
                
                addChild(box)
                boxes.append(box)
                
            } else {
                var balls = [SKSpriteNode(imageNamed: "ballRed"),
                             SKSpriteNode(imageNamed: "ballBlue"),
                             SKSpriteNode(imageNamed: "ballYellow"),
                             SKSpriteNode(imageNamed: "ballGrey"),
                             SKSpriteNode(imageNamed: "ballCyan"),
                             SKSpriteNode(imageNamed: "ballPurple"),
                             SKSpriteNode(imageNamed: "ballGreen")]
                balls.shuffle()
                let randomBall = balls.randomElement()
                guard let ball = randomBall else { return }
                ball.name = "ball"
                ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
                ball.physicsBody?.restitution = 0.4
                ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0
                ball.position = CGPoint(x: position.x, y: 700)
                addChild(ball)
                numberOfBalls -= 1
            }
        }
    }
    
    fileprivate func makeBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.name = "bouncer"
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2)
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }
    func makeSlot(at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
            
        }
        
        slotBase.position = position
        slotGlow.position = position
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        
        addChild(slotBase)
        addChild(slotGlow)
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    func collision(between ball: SKNode, object: SKNode) {
        if object.name == "good" {
            destroy(ball: ball)
            score += 1
            numberOfBalls += 1
        } else if object.name == "bad" {
            destroy(ball: ball)
            
        }
    }
    
    func destroyBoxes(box: SKNode) {
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = box.position
            addChild(fireParticles)
        }
        box.removeFromParent()
    }
    
    func endGame() {
        if numberOfBalls == 0 {
            for box in boxes {
                destroyBoxes(box: box)
            }
            let ac = UIAlertController(title: "End of game", message: "Your score: \(score)", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Play New Game", style: .default) {
                [weak self] _ in
                self?.score = 0
                self?.numberOfBalls = 5
                self?.editLabel.text = "Tap here to edit"
            })
            
            self.view?.window?.rootViewController?.present(ac, animated: true, completion: nil)
        }
//        let alertView = UIAlertView(title: "Edess!!", andMessage: "Congratulations! test testing bla bla bla")
//
//        alertView.addButtonWithTitle("OK", type: .Default) { (alertView) -> Void in
//            print("ok was pushed")
//        }
//
//        alertView.show()
//    }
    }
    
    func destroy(ball: SKNode) {
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = ball.position
            addChild(fireParticles)
        }
        ball.removeFromParent()
    }
}
