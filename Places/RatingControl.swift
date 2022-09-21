//
//  RatingControl.swift
//  Places
//
//  Created by Мирсаит Сабирзянов on 6/6/22.
//

import UIKit
import SwiftUI
import AuthenticationServices

@IBDesignable class RatingControl: UIStackView {
    
    private var arrBtn = [UIButton]()
    
    var rating = 0{
        didSet{
            updateRatingStatus()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    @IBInspectable var starSize :CGSize = CGSize(width: 44.0, height: 44.0){
        didSet{
            setupButton()
        }
    }
    @IBInspectable var starCount :Int = 5{
        didSet{
            setupButton()
        }
    }

    
    
    @objc func ratingTapped(button: UIButton){
        guard let index = arrBtn.firstIndex(of: button) else {return}

        let selectedRating = index + 1
        
        if selectedRating == rating {
            rating = 0
        } else {
            rating = selectedRating
        }
    }
    
    private func setupButton(){
        
        for btn in arrBtn{
            removeArrangedSubview(btn)
            btn.removeFromSuperview()
        }
        
        arrBtn.removeAll()

        
        let bundle = Bundle(for: type(of: self))
        let fillStar = UIImage(named: "filledStar", in:bundle, compatibleWith: self.traitCollection)
        let emptyStar = UIImage(named: "emptyStar", in:bundle, compatibleWith: self.traitCollection)
        let tapStar = UIImage(named: "highlightedStar", in:bundle, compatibleWith: self.traitCollection)

        
        for _ in 0..<starCount{
            let button = UIButton()
            
            button.setImage(emptyStar, for: .normal)
            button.setImage(fillStar, for: .selected)
            button.setImage(tapStar, for: .highlighted)
            button.setImage(tapStar, for: [.highlighted, .selected])


            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            
            button.addTarget(self, action: #selector(ratingTapped(button:)), for: .touchUpInside)
            
            addArrangedSubview(button)
            
            arrBtn.append(button)
        }
        
        updateRatingStatus()
    }
    
    private func updateRatingStatus(){
        for (index, button) in arrBtn.enumerated(){
            button.isSelected = index < rating
        }
    }
}
