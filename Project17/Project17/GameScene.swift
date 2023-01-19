//
//  GameScene.swift
//  Project17
//
//  Created by Phillip Reynolds on 1/19/23.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!

    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var gameOverLabel: SKLabelNode!
    var gameResetLabel: SKLabelNode!
    
    let possibleEnemies = ["ball", "hammer", "tv"]
    var isGameOver = false
    var gameRestarted = false
    var gameTimer: Timer?
    var enemiesCreated: Int = 0
    var timeInterval: Double = 1.0
    
    override func didMove(to view: SKView) {
        backgroundColor = .black

            starfield = SKEmitterNode(fileNamed: "starfield")!
            starfield.position = CGPoint(x: 1024, y: 384)
            starfield.advanceSimulationTime(10)
            addChild(starfield)
            starfield.zPosition = -1

            player = SKSpriteNode(imageNamed: "player")
            player.position = CGPoint(x: 100, y: 384)
            player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
            player.physicsBody?.contactTestBitMask = 1
            addChild(player)

            scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
            scoreLabel.position = CGPoint(x: 16, y: 16)
            scoreLabel.horizontalAlignmentMode = .left
            addChild(scoreLabel)

            score = 0
        
            gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")
            gameOverLabel.text = "Game Over"
            gameOverLabel.position = CGPoint(x: 512, y: 384)
            gameOverLabel.horizontalAlignmentMode = .center
            gameOverLabel.fontSize = 72
            addChild(gameOverLabel)
            
            gameResetLabel = SKLabelNode(fontNamed: "Chalkduster")
            gameResetLabel.text = "Restart Game"
            gameResetLabel.position = CGPoint(x: 512, y: 340)
            gameResetLabel.horizontalAlignmentMode = .center
            gameResetLabel.fontSize = 42
            addChild(gameResetLabel)
        
            gameOverLabel.isHidden = true
            gameResetLabel.isHidden = true

            physicsWorld.gravity = CGVector(dx: 0, dy: 0)
            physicsWorld.contactDelegate = self
        
        gameTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        var location = touch.location(in: self)

        if location.y < 100 {
            location.y = 100
        } else if location.y > 668 {
            location.y = 668
        }

        player.position = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameRestarted {
            gameRestarted = false
            return
        }
        
        if !isGameOver {
            endGame()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let objects = nodes(at: location)

            if objects.contains(gameResetLabel) {
                restartGame()
            }
        }
    }
    
    func restartGame() {
        gameOverLabel.isHidden = true
        gameResetLabel.isHidden = true
        gameRestarted = true
        
        isGameOver = false
        
        score = 0
        gameTimer?.invalidate()
        
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: 384)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.contactTestBitMask = 1
        addChild(player)
        
        timeInterval = 1.0
        gameTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
    }
    
    @objc func createEnemy() {
        guard let enemy = possibleEnemies.randomElement() else { return }
        
        enemiesCreated += 1
        
        if enemiesCreated == 20 {
            enemiesCreated = 0
            
            gameTimer?.invalidate()
            
            timeInterval -= 0.1
            
            if timeInterval < 0 {
                timeInterval = 0
            }
            
            gameTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
        }

        let sprite = SKSpriteNode(imageNamed: enemy)
        sprite.position = CGPoint(x: 1200, y: Int.random(in: 50...736))
        addChild(sprite)

        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.categoryBitMask = 1
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        sprite.physicsBody?.angularVelocity = 5
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.angularDamping = 0
    }
    
    override func update(_ currentTime: TimeInterval) {
        for node in children {
            if node.position.x < -300 {
                node.removeFromParent()
            }
        }

        if !isGameOver {
            score += 1
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        endGame()
    }
    
    func endGame() {
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = player.position
        addChild(explosion)

        player.removeFromParent()

        isGameOver = true
        
        gameTimer?.invalidate()
        
        showGameOverScreen()
    }
    
    func showGameOverScreen() {
        gameOverLabel.isHidden = false
        gameResetLabel.isHidden = false
    }
}
