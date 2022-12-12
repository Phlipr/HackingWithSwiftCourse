//
//  ViewController.swift
//  Project1
//
//  Created by Phillip Reynolds on 11/3/22.
//

import UIKit

class ViewController: UICollectionViewController {
    
    var pictures = [ImageFile]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Storm Viewer"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(recommendToOthers))
        
        performSelector(inBackground: #selector(fetchPictures), with: nil)
    }
    
    @objc func fetchPictures() {
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)
        
        for item in items {
            if item.hasPrefix("nssl") {
                let image = ImageFile(fileName: item)
                pictures.append(image)
            }
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pictures.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Picture", for: indexPath) as? ImageCell else {
            fatalError("Unable to dequeue ImageCell")
        }
        
        let imageFile = pictures[indexPath.item]
        
        cell.fileName.text = imageFile.fileName
        
        cell.imageView.image = UIImage(named: imageFile.fileName)
        
        cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("item selected...")
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            vc.selectedImage = pictures[indexPath.item].fileName
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func recommendToOthers() {
        let vc = UIActivityViewController(activityItems: ["You have to try out this cool app!"], applicationActivities: nil)
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
}

