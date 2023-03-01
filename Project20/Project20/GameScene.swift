//
//  GameScene.swift
//  Project20
//
//  Created by Phillip Reynolds on 2/28/23.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var gameTimer: Timer?
    var fireworks = [SKNode]()
    var fireworksLaunched = 0

    let leftEdge = -22
    let bottomEdge = -22
    let rightEdge = 1024 + 22

    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var scoreLabel: SKLabelNode!
    var gameOverLabel: SKLabelNode!
    var finalScoreLabel: SKLabelNode!
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.position = CGPoint(x: 8, y: 8)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.fontSize = 48
        addChild(scoreLabel)
        
        gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize = 64
        gameOverLabel.position = CGPoint(x: 512, y: 320)
        gameOverLabel.horizontalAlignmentMode = .center
        gameOverLabel.zPosition = 1
        gameOverLabel.isHidden = true
        addChild(gameOverLabel)
        
        finalScoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        finalScoreLabel.text = "Final Score: \(score)"
        finalScoreLabel.position = CGPoint(x: 512, y: 280)
        finalScoreLabel.fontSize = 36
        finalScoreLabel.horizontalAlignmentMode = .center
        finalScoreLabel.zPosition = 1
        finalScoreLabel.isHidden = true
        addChild(finalScoreLabel)

        gameTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
            checkTouches(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        checkTouches(touches)
    }
    
    func createFirework(xMovement: CGFloat, x: Int, y: Int) {
        // 1
        let node = SKNode()
        node.position = CGPoint(x: x, y: y)

        // 2
        let firework = SKSpriteNode(imageNamed: "rocket")
        firework.colorBlendFactor = 1
        firework.name = "firework"
        node.addChild(firework)

        // 3
        switch Int.random(in: 0...2) {
        case 0:
            firework.color = .cyan

        case 1:
            firework.color = .green

        case 2:
            firework.color = .red

        default:
            break
        }

        // 4
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: xMovement, y: 1000))

        // 5
        let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200)
        node.run(move)

        // 6
        if let emitter = SKEmitterNode(fileNamed: "fuse") {
            emitter.position = CGPoint(x: 0, y: -22)
            node.addChild(emitter)
        }

        // 7
        fireworks.append(node)
        addChild(node)
        
        fireworksLaunched += 1
    }
    
    @objc func launchFireworks() {
        let movementAmount: CGFloat = 1800
        
        if fireworksLaunched > 60 {
            endGame()
            return
        }

        switch Int.random(in: 0...3) {
        case 0:
            // fire five, straight up
            createFirework(xMovement: 0, x: 512, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 - 200, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 - 100, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 + 100, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 + 200, y: bottomEdge)

        case 1:
            // fire five, in a fan
            createFirework(xMovement: 0, x: 512, y: bottomEdge)
            createFirework(xMovement: -200, x: 512 - 200, y: bottomEdge)
            createFirework(xMovement: -100, x: 512 - 100, y: bottomEdge)
            createFirework(xMovement: 100, x: 512 + 100, y: bottomEdge)
            createFirework(xMovement: 200, x: 512 + 200, y: bottomEdge)

        case 2:
            // fire five, from the left to the right
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 400)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 300)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 200)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 100)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge)

        case 3:
            // fire five, from the right to the left
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 400)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 300)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 200)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 100)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge)

        default:
            break
        }
    }
    
    func endGame() {
        gameTimer?.invalidate()
        gameOverLabel.isHidden = false
        finalScoreLabel.text = "Final Score: \(score)"
        finalScoreLabel.isHidden = false
        scoreLabel.isHidden = true
    }
    
    func checkTouches(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }

        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)

        for case let node as SKSpriteNode in nodesAtPoint {
            guard node.name == "firework" else { continue }
            for parent in fireworks {
                guard let firework = parent.children.first as? SKSpriteNode else { continue }

                if firework.name == "selected" && firework.color != node.color {
                    firework.name = "firework"
                    firework.colorBlendFactor = 1
                }
            }
            node.name = "selected"
            node.colorBlendFactor = 0
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        for (index, firework) in fireworks.enumerated().reversed() {
            if firework.position.y > 900 {
                // this uses a position high above so that rockets can explode off screen
                fireworks.remove(at: index)
                firework.removeFromParent()
            }
        }
    }
    
    func explode(firework: SKNode) {
        if let emitter = SKEmitterNode(fileNamed: "explode") {
            emitter.position = firework.position
            addChild(emitter)
            let delay = SKAction.wait(forDuration: 0.6)
            let removeEmitter = SKAction.run { emitter.removeFromParent()}
            emitter.run(SKAction.sequence([delay, removeEmitter]))
        }
        
        firework.removeFromParent()
    }
    
    func explodeFireworks() {
        var numExploded = 0

        for (index, fireworkContainer) in fireworks.enumerated().reversed() {
            guard let firework = fireworkContainer.children.first as? SKSpriteNode else { continue }

            if firework.name == "selected" {
                // destroy this firework!
                explode(firework: fireworkContainer)
                fireworks.remove(at: index)
                numExploded += 1
            }
        }

        switch numExploded {
        case 0:
            // nothing – rubbish!
            break
        case 1:
            score += 200
        case 2:
            score += 500
        case 3:
            score += 1500
        case 4:
            score += 2500
        default:
            score += 4000
        }
    }
}
