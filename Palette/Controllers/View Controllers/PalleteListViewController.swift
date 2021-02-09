//
//  PalleteListViewController.swift
//  Palette
//
//  Created by River McCaine on 2/9/21.
//  Copyright © 2021 Cameron Stuart. All rights reserved.
//

import UIKit

class PalleteListViewController: UIViewController {
    
    // MARK: - Properties
    var safeArea: UILayoutGuide {
        return self.view.safeAreaLayoutGuide
    }
    
    var photos: [UnsplashPhoto] = []
    
    var buttons: [UIButton] {
        return [featuredButton, randomButton, doubleRainbowButton]
    }
    // MARK: - Lifecycle Methods
    /// Loadview has top down processing.
    override func loadView() {
        super.loadView()
        
        addAllSubViews()
        setupButtonStackView()
        constrainTableView()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = #colorLiteral(red: 0.1333333333, green: 0.1568627451, blue: 0.1921568627, alpha: 1)
        configureTableView()
        activateButtons()
        
        UnsplashService.shared.fetchFromUnsplash(for: .featured) { (photos) in
            DispatchQueue.main.async {
                guard let photos = photos else { return }
                self.photos = photos
                self.paletteTableView.reloadData()
            }
        }
        
    }
    
    // MARK: - Helper Methods
    func addAllSubViews() {
        /// Step 2 - Add the assets to the view.
        self.view.addSubview(featuredButton)
        self.view.addSubview(randomButton)
        self.view.addSubview(doubleRainbowButton)
        self.view.addSubview(buttonStackView)
        self.view.addSubview(paletteTableView)
    }
    
    func setupButtonStackView() {
        buttonStackView.addArrangedSubview(featuredButton)
        buttonStackView.addArrangedSubview(randomButton)
        buttonStackView.addArrangedSubview(doubleRainbowButton)
        
        /// Step 3 - Add constraints
        buttonStackView.topAnchor.constraint(equalTo: self.safeArea.topAnchor, constant: 16).isActive = true
        buttonStackView.leadingAnchor.constraint(equalTo: self.safeArea.leadingAnchor, constant: 8).isActive = true
        buttonStackView.trailingAnchor.constraint(equalTo: self.safeArea.trailingAnchor, constant: -8).isActive = true
    }
    
    func constrainTableView() {
        paletteTableView.anchor(top: buttonStackView.bottomAnchor, bottom: safeArea.bottomAnchor, leading: safeArea.leadingAnchor, trailing: safeArea.trailingAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 0)
    }
    
    func configureTableView() {
        paletteTableView.delegate = self
        paletteTableView.dataSource = self
        paletteTableView.register(PaletteTableViewCell.self, forCellReuseIdentifier: "photoCell")
    }
    
    @objc func selectButton(sender: UIButton) {
        buttons.forEach { $0.setTitleColor(.lightGray, for: .normal) }
        sender.setTitleColor(UIColor(named: "devmountainBlue"), for: .normal)
        
        switch sender {
        case featuredButton:
            searchForCategory(.featured)
            
        case randomButton:
            searchForCategory(.random)
            
        case doubleRainbowButton:
            searchForCategory(.doubleRainbow)
            
        default:
            searchForCategory(.featured)
        }
    }
    
    func activateButtons() {
        buttons.forEach { $0.addTarget(self, action: #selector(selectButton(sender:)), for: .touchUpInside) }
        featuredButton.setTitleColor(UIColor(named: "devmountainBlue"), for: .normal)
    }
    
    func searchForCategory(_ unsplashRoute: UnsplashRoute) {
        UnsplashService.shared.fetchFromUnsplash(for: unsplashRoute) { (unsplashPhotos) in
            DispatchQueue.main.async {
                guard let unsplashPhotos = unsplashPhotos else { return }
                self.photos = unsplashPhotos
                self.paletteTableView.reloadData()
            }
        }
    }
    
    // MARK: - Views
    /// Step 1 - Create the assets.
    /// Basic format of how we will be creating programmatic views/constraints.
    let featuredButton: UIButton = {
        let button = UIButton()
        button.setTitle("Featured", for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.contentHorizontalAlignment = .center
        
        return button
    }()
    
    let randomButton: UIButton = {
        let button = UIButton()
        button.setTitle("Random", for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.contentHorizontalAlignment = .center
        
        return button
    }()
    
    let doubleRainbowButton: UIButton = {
        let button = UIButton()
        button.setTitle("Double Rainbow", for: .normal )
        button.setTitleColor(.lightGray, for: .normal)
        button.contentHorizontalAlignment = .center
        
        return button
    }()
    
    let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .equalCentering
        /// If we leave this as true then we risk xcode trying to infer waht the auto layout version of your view will look like. Could look....unlucky.
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    let paletteTableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
} // END OF CLASS

// MARK: - Extensions
extension PalleteListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell", for: indexPath) as! PaletteTableViewCell
        
        let photo = photos[indexPath.row]
        
        cell.photo = photo
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let imageViewSpace: CGFloat = (view.frame.width - (2 * SpacingConstants.outerHorizontalPadding))
        let outerVerticalPadding: CGFloat = (2 * SpacingConstants.outerVerticalPadding)
        let labelSpace: CGFloat = SpacingConstants.smallElementHeight
        let objectBuffer = SpacingConstants.verticalObjectBuffer
        let colorPaletteViewSpace = SpacingConstants.mediumElementHeight
        let secondObjectBuffer = SpacingConstants.verticalObjectBuffer
        
        return imageViewSpace + outerVerticalPadding + labelSpace + objectBuffer + colorPaletteViewSpace + secondObjectBuffer
        
    }
} // END OF EXTENSION
