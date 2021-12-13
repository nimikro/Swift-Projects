//
//  ViewController.swift
//  RandomPhoto
//
//  Created by Nikolaos Mikrogeorgiou on 13/11/21.
//

import UIKit
import SwiftUI

class ViewController: UIViewController
{
    // Define imageView
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .gray
        return imageView
    }()
    
    // Define button
    private let button: UIButton = {
        let button  = UIButton()
        button.backgroundColor = .white
        button.setTitle("Random Photo", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    // Define colors
    let colors: [UIColor] = [.systemTeal, .systemBlue, .systemPink, .systemRed, .systemOrange, .systemPurple, .systemYellow, .systemGreen, .systemIndigo]
    
    // Show random photo and button
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemTeal
        view.addSubview(imageView)
        imageView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        imageView.center = view.center
        view.addSubview(button)
        getRandomPhoto()
        // Attach button to get a Random Photo at touchUpInside
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    // Add tap functionality to button -> attach to button
    @objc func didTapButton(){
        getRandomPhoto()
        // Get a random background color
        view.backgroundColor = colors.randomElement()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        button.frame = CGRect(x: 30, y:view.frame.size.height-150-view.safeAreaInsets.bottom, width:view.frame.size.width-60, height: 55)
        
    }
    
    // Get a random photo from url
    func getRandomPhoto() {
        let urlstring = "https://source.unsplash.com/random/600x600"
        let url = URL(string: urlstring)!
        guard let data = try? Data(contentsOf: url) else {
            return
        }
        imageView.image = UIImage(data: data)
    }

}

