/// Copyright (c) 2018 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

/// Par Dave-Enrick Proulx
/// Pour Christopher Proulx
/// 6 janvier 2021

struct PhysicsCategory {
  static let none      : UInt32 = 0
  static let all       : UInt32 = UInt32.max
  static let shell   : UInt32 = 0b1       // 1
  static let projectile: UInt32 = 0b10      // 2
}


import SpriteKit

// Calculs en lien avec le lancer des boules de feu
func +(left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func -(left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func *(point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func /(point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
  func sqrt(a: CGFloat) -> CGFloat {
    return CGFloat(sqrtf(Float(a)))
  }
#endif

extension CGPoint {
  func length() -> CGFloat {
    return sqrt(x*x + y*y)
  }
  
  func normalized() -> CGPoint {
    return self / length()
  }
}

class GameScene: SKScene {
  // Récupération de l'image du joueur
  let player = SKSpriteNode(imageNamed: "player")
  
  // Initialisation du score
  var shellsDestroyed = 0
    
  override func didMove(to view: SKView) {
    // Positionnement du joueur dans la scène
    player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
    
    // Insertion du joueur dans la scène
    addChild(player)
    
    // Régles de physique de la scène
    physicsWorld.gravity = .zero
    physicsWorld.contactDelegate = self
    
    // Apparition des carapaces
    run(SKAction.repeatForever(
          SKAction.sequence([
            SKAction.run(addShell),
            SKAction.wait(forDuration: 1.0)
            ])
        ))
    
    // Chanson thème
    let backgroundMusic = SKAudioNode(fileNamed: "super-mario-theme.caf")
    backgroundMusic.autoplayLooped = true
    addChild(backgroundMusic)

  }
  
  func random() -> CGFloat {
    return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
  }

  func random(min: CGFloat, max: CGFloat) -> CGFloat {
    return random() * (max - min) + min
  }

  func addShell() {
    
    // 1 - Création du sprite
    let shell = SKSpriteNode(imageNamed: "shell")
    
    // 2 - Règles de la physique entourant les carapaces
    shell.physicsBody = SKPhysicsBody(rectangleOf: shell.size)
    shell.physicsBody?.isDynamic = true
    shell.physicsBody?.categoryBitMask = PhysicsCategory.shell
    shell.physicsBody?.contactTestBitMask = PhysicsCategory.projectile
    shell.physicsBody?.collisionBitMask = PhysicsCategory.none
    
    // 3 - Identification d'un point aléatoire sur l'axe Y
    let actualY = random(min: shell.size.height/2, max: size.height - shell.size.height/2)
    
    // 4 - Positionnement de la carapace sur le point identifié
    shell.position = CGPoint(x: size.width + shell.size.width/2, y: actualY)
    
    // 5 - Insertion de la carapace dans la scène
    addChild(shell)
    
    // 6 - Vitesse de la carapace
    let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
    
    // 7 - Création de l'action du déplacement de la carapace
    let actionMove = SKAction.move(to: CGPoint(x: -shell.size.width/2, y: actualY),
                                   duration: TimeInterval(actualDuration))
    
    // 8 - Disparition de la carapace de la scène après l'action du déplacement
    let actionMoveDone = SKAction.removeFromParent()
    
    // 9 - Affichage de l'écran de fin de partie en cas de défaite
    let loseAction = SKAction.run() { [weak self] in
      guard let `self` = self else { return }
      let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
      let gameOverScene = GameOverScene(size: self.size, won: false)
      self.view?.presentScene(gameOverScene, transition: reveal)
    }
    
    // 10 - Exécution de la séquence : déplacement -> défaite ou non -> disparition
    shell.run(SKAction.sequence([actionMove, loseAction, actionMoveDone]))

  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    // 1 - Identification et localisation d'une touche de l'usager
    guard let touch = touches.first else {
      return
    }
    let touchLocation = touch.location(in: self)
    
    // 2 - Positionnement initial du projectile
    let projectile = SKSpriteNode(imageNamed: "projectile")
    projectile.position = player.position
    
    // 3 - Règles de la physique entourant les projectiles
    projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
    projectile.physicsBody?.isDynamic = true
    projectile.physicsBody?.categoryBitMask = PhysicsCategory.projectile
    projectile.physicsBody?.contactTestBitMask = PhysicsCategory.shell
    projectile.physicsBody?.collisionBitMask = PhysicsCategory.none
    projectile.physicsBody?.usesPreciseCollisionDetection = true
    
    // 4 - Calcul du vecteur entre le positionnement initial du projectile et la touche de l'usager
    let offset = touchLocation - projectile.position
    
    // 5 - Restriction dans le cas où l'usager tente de lancer derrière le joueur
    if offset.x < 0 { return }
    
    // 6 - Insertion du projectile dans la scène
    addChild(projectile)
    
    // 7 - Identification de la direction du lancer
    let direction = offset.normalized()
    
    // 8 - Calcul de la distance du lancer
    let shootAmount = direction * 1000
    
    // 9 - Calcul du positionnement final du projectile
    let realDest = shootAmount + projectile.position
    
    // 10 - Création de l'action de déplacement du projectile
    let actionMove = SKAction.move(to: realDest, duration: 2.0)
    
    // 11 - Disparition du projectile de la scène après l'action de déplacement
    let actionMoveDone = SKAction.removeFromParent()
    
    // 12 - Exécution de la séquence : déplacement -> disparition
    projectile.run(SKAction.sequence([actionMove, actionMoveDone]))
  }

  // Fonction appelée en cas de collision entre un projectile et une carapace
  func projectileDidCollideWithShell(projectile: SKSpriteNode, shell: SKSpriteNode) {
    // Effet sonore
    run(SKAction.playSoundFileNamed("fireball-sound.caf", waitForCompletion: false))
    projectile.removeFromParent()
    shell.removeFromParent()

    // Incrémentation du score
    shellsDestroyed += 1
    
    // Définition des actions en cas victoire
    if shellsDestroyed > 30 {
      let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
      let gameOverScene = GameOverScene(size: self.size, won: true)
      view?.presentScene(gameOverScene, transition: reveal)
    }

  }

}

extension GameScene: SKPhysicsContactDelegate {
  func didBegin(_ contact: SKPhysicsContact) {
    // 1 - Identification des objets entrés en collision
    var firstBody: SKPhysicsBody
    var secondBody: SKPhysicsBody
    if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
      firstBody = contact.bodyA
      secondBody = contact.bodyB
    } else {
      firstBody = contact.bodyB
      secondBody = contact.bodyA
    }
   
    // 2 - Vérification si les objets entrés en collision sont un projectile et une carapace
    if ((firstBody.categoryBitMask & PhysicsCategory.shell != 0) &&
        (secondBody.categoryBitMask & PhysicsCategory.projectile != 0)) {
      if let shell = firstBody.node as? SKSpriteNode,
        let projectile = secondBody.node as? SKSpriteNode {
        projectileDidCollideWithShell(projectile: projectile, shell: shell)
      }
    }
  }

}
