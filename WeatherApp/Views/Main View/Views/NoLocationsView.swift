//
//  NoLocationsView.swift
//  WeatherApp
//
//  Created by Dmytro Maksymyak on 05.04.2022.
//

import UIKit

class NoLocationsView: UIView {
    var settingsButton: UIButton = {
        let button = UIButton()
        
        button.setImage(UIImage(systemName: "list.bullet"), for: .normal)
        button.tintColor = .white
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        button.imageView?.contentMode = .scaleAspectFill
        button.imageView?.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1.2)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        
        pageControl.numberOfPages = 0
        pageControl.translatesAutoresizingMaskIntoConstraints = false

        return pageControl
    }()
    private var cancellable: Any? = nil

    lazy var groupView: UIView = {
        let view = UIView()
        let colorPublisher = ColorHelper.shared.passthroughtSubject

        view.backgroundColor = ColorHelper.shared.getBackgroundColor()
        view.translatesAutoresizingMaskIntoConstraints = false

        cancellable = colorPublisher.sink{color in
            UIView.animate(withDuration: 0.5) { view.backgroundColor = color }}

        return view
    }()
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 40)
        label.text = NSLocalizedString("title.text", comment: "")
        label.adjustsFontSizeToFitWidth = true

        label.textColor = .white
        label.textAlignment = .center
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 0.15
        label.layer.shadowOpacity = 0.1
        label.layer.shadowOffset = CGSize(width: 2, height: 2)
        label.layer.masksToBounds = false
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = NSLocalizedString("description.text", comment: "")
        label.numberOfLines = 5


        label.textColor = .white
        label.textAlignment = .center
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 0.15
        label.layer.shadowOpacity = 0.1
        label.layer.shadowOffset = CGSize(width: 2, height: 2)
        label.layer.masksToBounds = false
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    var pressAction: (() -> Void)?


    init(pressAction: @escaping () -> Void) {
        super.init(frame: .zero)
        self.pressAction = pressAction
        
        addSubview(groupView)
        groupView.addSubview(pageControl)
        groupView.addSubview(settingsButton)
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        configure()
    }
    
    private func configure() {
        NSLayoutConstraint.activate([
            groupView.bottomAnchor.constraint(equalTo: bottomAnchor),
            groupView.topAnchor.constraint(equalTo: pageControl.topAnchor, constant: -30),
            groupView.leftAnchor.constraint(equalTo: leftAnchor),
            groupView.rightAnchor.constraint(equalTo: rightAnchor),
            
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -70),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            descriptionLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            descriptionLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -30),
            descriptionLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 30),
            
            pageControl.centerXAnchor.constraint(equalTo: groupView.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            
            settingsButton.centerYAnchor.constraint(equalTo: pageControl.centerYAnchor),
            settingsButton.rightAnchor.constraint(equalTo: groupView.rightAnchor, constant: -15),
            settingsButton.widthAnchor.constraint(equalToConstant: 50),
            settingsButton.heightAnchor.constraint(equalTo: settingsButton.widthAnchor),
        ])
        settingsButton.addTarget(self, action: #selector(settingsButtonPressed), for: .touchUpInside)
    }
    @objc func settingsButtonPressed() {
        pressAction?()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
