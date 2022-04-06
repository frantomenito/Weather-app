//
//  MainView.swift
//  WeatherApp
//
//  Created by Dmytro Maksymyak on 29.03.2022.
//

import UIKit
import MapKit

class MainView: UIView {
    
    //MARK: Variables
    
    var scrollView: UIScrollView = {
        let scrollView = UIScrollView()

        scrollView.isPagingEnabled = true
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        return scrollView
    }()
    var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        
        pageControl.numberOfPages = 1
        if LocationManager.isEnabled {pageControl.setIndicatorImage(UIImage(systemName: "location"), forPage: 0)}
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
    
    var scrollViewDelegate: ScrollViewDelegate!
    
    var locations: [MKMapItem]!
    var pressAction: (() -> Void)?
    var scrolledAction: ((Int) -> Void)?
    var gotCurrentWeather: (([CurrentWeather]) -> Void)?

    //MARK: Init
    init(locations: [MKMapItem], pressAction: @escaping () -> Void, scrolledAction: @escaping (Int) -> Void, currentWeather: @escaping ([CurrentWeather]) -> Void) {
        self.pressAction = pressAction
        self.scrolledAction = scrolledAction
        self.locations = locations
        self.gotCurrentWeather = currentWeather
            
        super.init(frame: UIScreen.main.bounds)
        
        scrollViewDelegate = ScrollViewDelegate(scrollAction: pageChangedAction(page:))
        scrollView.delegate = scrollViewDelegate

        addSubview(groupView)
        addSubview(scrollView)
        groupView.addSubview(settingsButton)
        groupView.addSubview(pageControl)
        
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width * CGFloat(locations.count),
                                        height: UIScreen.main.bounds.height)
        
        configure()
        addWeatherInfoViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Configure function
    private func configure() {
        pageControl.numberOfPages = locations.count
        
        NSLayoutConstraint.activate([
            groupView.bottomAnchor.constraint(equalTo: bottomAnchor),
            groupView.topAnchor.constraint(equalTo: pageControl.topAnchor, constant: -10),
            groupView.leftAnchor.constraint(equalTo: leftAnchor),
            groupView.rightAnchor.constraint(equalTo: rightAnchor),
            
            scrollView.leftAnchor.constraint(equalTo: leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: rightAnchor),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: groupView.topAnchor),
            
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
    
    private func pageChangedAction(page: Int) {
        scrolledAction?(page)
    }
    
    //MARK: Helper functions
    private func addWeatherInfoViews() {
        let group = DispatchGroup()
        var currentWeather: [CurrentWeather] = []
        if locations.count != 0 {
            for i in 0...locations.count - 1 {
                group.enter()
                let weatherInfoView = WeatherInfoView(frame: CGRect(x: self.frame.width * CGFloat(i), y: 0, width: self.frame.width, height: self.frame.height), location: locations[i], {
                    currentWeather.append($0)
                    group.leave()
                })
                scrollView.addSubview(weatherInfoView)
            }
            group.notify(queue: .main) {
                self.gotCurrentWeather?(currentWeather)
            }
        }
    }
}

class ScrollViewDelegate: NSObject, UIScrollViewDelegate {
    private var currentPage: Int = 0 {
        didSet {
            if oldValue != currentPage {
                scrollAction?(currentPage)
            }
        }
    }
    
    var scrollAction: ((Int) -> Void)?
    init(scrollAction: @escaping (Int) -> Void) {
        self.scrollAction = scrollAction
    }
    override init() {}
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.y = 0
        currentPage = Int(round(scrollView.contentOffset.x/scrollView.frame.width))
    }
}
