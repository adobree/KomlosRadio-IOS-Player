//
//  AppDelegate.swift
//  Komlós Rádió
//
//  Created by Kovács Ádám on 22/10/2023.
//

import UIKit
import AVFAudio

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let viewController = ViewController()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
        
        application.beginReceivingRemoteControlEvents()
        
        let session = AVAudioSession.sharedInstance()
          do {
              // Configure the audio session for playback
              try session.setCategory(AVAudioSession.Category.playback,
                                      mode: AVAudioSession.Mode.default,
                                      options: [])
              try session.setActive(true)
          } catch let error as NSError {
              print("Failed to set the audio session category and mode: \(error.localizedDescription)")
          }
        
                
        //let audioSession = AVAudioSession.sharedInstance()
        //do {
        //    try audioSession.setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default)
        //} catch let error as NSError {
        //    print("Setting category to AVAudioSessionCategoryPlayback failed: \(error)")
        //}
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        player.play(atTime: player.deviceCurrentTime + 1.0)
    }


}

