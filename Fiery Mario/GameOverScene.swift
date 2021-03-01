/// Copyright (c) 2021 Razeware LLC
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

import Foundation

import SpriteKit

class GameOverScene: SKScene {
  init(size: CGSize, won:Bool) {
    super.init(size: size)
    
    // 1 - Définition de la couleur d'arrière-plan
    backgroundColor = SKColor.black
    
    // 2 - Définition du message de fin de partie selon le résultat
    let win = "Bravo! Joyeux anniversaire!"
    
    let loss = "Bouuu! Bonne fête quand même!"
    
    let message = won ? win : loss
    
    // 3 - Sélection de la musique de fin de partie
    let gameOverMusic = won ? SKAudioNode(fileNamed: "victory.caf") : SKAudioNode(fileNamed: "defeat.caf")

    addChild(gameOverMusic)
    
    // 4 - Stylisation du message de fin de partie
    let label = SKLabelNode(fontNamed: "GillSans-Bold")
    label.text = message
    label.fontSize = 40
    label.fontColor = SKColor.white
    label.position = CGPoint(x: size.width/2, y: size.height/2)
    addChild(label)
    
    // 5 - Délai avant de procéder à une nouvelle partie
    let delay = won ? 8.0 : 4.5
    
    run(SKAction.sequence([
      SKAction.wait(forDuration: delay),
      SKAction.run() { [weak self] in
        // 6 - Transition de l'écran de fin de partie vers une nouvelle partie
        guard let `self` = self else { return }
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        let scene = GameScene(size: size)
        self.view?.presentScene(scene, transition:reveal)
      }
      ]))
   }
  
  // 6
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
