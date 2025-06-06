//
//  SingleImageViewController.swift
//  ImageView
//
//  Created by Temurbek Uzakov on 01/06/2025.
//

import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage? {
        didSet{
            guard isViewLoaded else { return }
            imageView.image = image
        }
    }
    @IBOutlet private weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        imageView.image = image
    }
}
