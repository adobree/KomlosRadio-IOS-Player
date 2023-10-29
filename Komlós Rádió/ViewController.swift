//
//  ViewController.swift
//  Komlós Rádió
//
//  Created by Kovács Ádám on 22/10/2023.
//

import UIKit
import AVFoundation
import AVKit
import UserNotifications
import MediaPlayer
import CoreImage

// Az Icecast stream URL-je
let icecastStreamURL = URL(string: "https://streaming4u.synology.me:8443/KomlosRadio")

// Inicializáld az AVPlayer objektumot az Icecast stream URL-jével
let player = AVPlayer(url: icecastStreamURL!)

class ViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var playPauseButton: UIButton?
    @IBOutlet weak var coverImageView: UIImageView?
    
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assignbackground()

            // "Play" gomb nyomásának figyelése
            MPRemoteCommandCenter.shared().playCommand.addTarget { event in
                if player.rate == 0.0 { // A lejátszás leállt
                    player.play()
                    self.playPauseButton?.setTitle("Pause", for: .normal)
                    return .success
                }
                return .commandFailed
            }

            // "Pause" gomb nyomásának figyelése
            MPRemoteCommandCenter.shared().pauseCommand.addTarget { event in
                if player.rate == 1.0 { // A lejátszás aktív
                    player.pause()
                    self.playPauseButton?.setTitle("Play", for: .normal)
                    return .success
                }
                return .commandFailed
            }

        setupNowPlayingInfo()
        
        // Elindítjuk az időzített futtatást 5 másodpercenként
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(downloadDataAndRefresh), userInfo: nil, repeats: true)
        downloadDataAndRefresh()
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    func assignbackground(){
        let background = UIImage(named: "bg")
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }
    
    func setupNowPlayingInfo() {
        let title = "Komlós Rádió"
        let artist = "Egy hét együtt!"
        let albumTitle = "komlosradio.hu"
        let image = UIImage(named: "Logo")!
        let artwork = MPMediaItemArtwork.init(boundsSize: image.size, requestHandler: { (size) -> UIImage in
            return image
        })
        
        var nowPlayingInfo: [String: Any] = [:]
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyArtist] = artist
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = albumTitle
        nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = true
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    func updateDataAndRefresh(_ title: String) {
        if let url = URL(string: "https://itunes.apple.com/search?term=\(title)&media=music&limit=1") {
            let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
                if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let results = json["results"] as? [[String: Any]], let result = results.first, let coverUrlString = result["artworkUrl100"] as? String, let coverUrl = URL(string: coverUrlString) {
                        if let title2 = result["trackName"] as? String {
                            DispatchQueue.main.async {
                                self?.updateUI(title, coverUrl, coverUrlString, title2)
                            }
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    func updateUI(_ title: String, _ coverUrl: URL, _ coverUrlString: String, _ title2: String) {
        let urlString = coverUrl.absoluteString
        var originalString = urlString
        let wordToReplace = "100x100bb.jpg"
        let replacementWord = "300x300bb.jpg"

        originalString = originalString.replacingOccurrences(of: wordToReplace, with: replacementWord)
        
        if let url2 = URL(string: originalString) {
            downloadCoverImage(url2)
        }
    }

    func downloadCoverImage(_ url: URL) {
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            if let data = data, let coverImage = UIImage(data: data) {
                DispatchQueue.main.async {

                    self?.coverImageView?.image = coverImage
                    self?.coverImageView?.contentMode = .scaleToFill
                }
            }
        }
        task.resume()
    }
    
    @objc func downloadDataAndRefresh() {
        if let url = URL(string: "https://streaming4u.synology.me:8443/status-json.xsl") {
            let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
                if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let icestats = json["icestats"] as? [String: Any], let source = icestats["source"] as? [[String: Any]], source.count >= 2 {
                        if let title = source[1]["title"] as? String {
                            DispatchQueue.main.async {
                                self?.updateTitleLabel(title)
                                self?.updateDataAndRefresh(title)
                                
                                let content = UNMutableNotificationContent()
                                content.title = "Komlós Rádió"
                                content.body = "Egy hét együtt!"

                                let request = UNNotificationRequest(identifier: "MusicNotification", content: content, trigger: nil)

                                UNUserNotificationCenter.current().add(request)
                            }
                        }
                    }
                }
            }
            task.resume()
        }
    }

    func updateTitleLabel(_ title: String) {
        titleLabel?.text = title
    }
    
    
    @IBAction func playButtonPressed(_ sender: UIButton) {
        
        if player.timeControlStatus == .playing {
            player.pause()
            sender.setTitle("Play", for: .normal) // A gomb feliratát "Play"-re változtatjuk
        } else {
            player.play()
            sender.setTitle("Pause", for: .normal) // A gomb feliratát "Pause"-ra változtatjuk
        }
    }
}
