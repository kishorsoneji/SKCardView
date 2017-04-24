//
//  ViewController.swift
//  CardDemo
//
//  Created by Harry on 4/21/17.
//  Copyright © 2017 Harry. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var cardView1: UIView!
    var panGestureRecognizer:UIPanGestureRecognizer!
    var originalPoint: CGPoint!
    var arrayCardModel = [ModelCard]()
    var index = 0
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var lblName1: UILabel!
    
    var isActiveChange = true
    override func viewDidLoad() {
        super.viewDidLoad()
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action:#selector(ViewController.panGestureRecogn(gestureRecognizer:)))
        cardView.addGestureRecognizer(panGestureRecognizer)
        
        
        self.addCard()
        //set front card data
        self.setData(index: index)
        index = index + 1
        
        //set previous card data
        self.setData(index: index)
    }
    
    
//MARK: Add card
    func addCard(){
        
        // add data in array
        let card1 = ModelCard()
        card1.image = "img1.jpg"
        card1.name = " Tester"
        arrayCardModel.append(card1)
        
        let card2 = ModelCard()
        card2.image = "img2.jpg"
        card2.name = " Tester1"
        arrayCardModel.append(card2)
        
        let card3 = ModelCard()
        card3.image = "img3.jpg"
        card3.name = " Jatin"
        arrayCardModel.append(card3)
        
    
    }
    
//MARK : Set card data
    func setData(index:Int){
    
        if(isActiveChange){
            imageView.image = UIImage(named: arrayCardModel[index].image)
            lblName.text = arrayCardModel[index].name
            isActiveChange = false
        } else {
            imageView1.image = UIImage(named: arrayCardModel[index].image)
            lblName1.text = arrayCardModel[index].name
            isActiveChange = true
        }
        self.view.layoutIfNeeded()
    }
    
    override func viewWillLayoutSubviews() {
        cardView.center = cardView.center
    }
    
    
//MARK: create card view dynamic
    func createCardView() -> UIView {
        let width = self.view.frame.width * 0.5
        let height = self.view.frame.height * 0.5
        let rect = CGRect(x:0,y: 0,width: width,height: height)
        
        let tempCardView = UIView(frame: rect)
        tempCardView.backgroundColor = UIColor.blue
        tempCardView.layer.cornerRadius = 8;
        tempCardView.layer.shadowOffset = CGSize(width:7,height: 7);
        tempCardView.layer.shadowRadius = 5;
        tempCardView.layer.shadowOpacity = 0.5;
        return tempCardView
    }
    
//MARK: Pan Gesture Recognizer
    func panGestureRecogn(gestureRecognizer: UIPanGestureRecognizer) {
        let xDistance = gestureRecognizer.translation(in: self.view).x
        let yDistance = gestureRecognizer.translation(in: self.view).y
        
        print("xDistance : ",xDistance)
        print("yDistance : ",yDistance)
        switch gestureRecognizer.state {
        case .began:
            self.originalPoint = self.view.center
            break
            
        case .changed:
            updateCardViewWithDistances(xDistance: xDistance, yDistance)
            break
            
        case .ended:
            if(xDistance >= 200 || (xDistance <= -180)) {
                if(index >= self.arrayCardModel.count-1){
                    index = 0
                } else {
                    index = index + 1
                }
                if(isActiveChange){
                    cardView.isHidden = true;
                    self.view.sendSubview(toBack: cardView)
                    cardView.removeGestureRecognizer(panGestureRecognizer)
                    cardView1.addGestureRecognizer(panGestureRecognizer)
                    cardView.isHidden = false;
                    self.cardView.transform = CGAffineTransform(rotationAngle: 0);
                } else {
                    cardView1.isHidden = true;
                    self.view.sendSubview(toBack: cardView1)
                    cardView1.removeGestureRecognizer(panGestureRecognizer)
                    cardView.addGestureRecognizer(panGestureRecognizer)
                    cardView1.isHidden = false;
                    self.cardView1.transform = CGAffineTransform(rotationAngle: 0);
                }
                setData(index: index)
            }
           resetViewPositionAndTransformations()
            break
            
        default:
            break
        }
    }
    
//MARK: Update view distance
    
    func updateCardViewWithDistances(xDistance:CGFloat, _ yDistance:CGFloat) {
        let rotationStrength = min(xDistance / 320, 1)
        let fullCircle = (CGFloat)(2*M_PI)
        
        let rotationAngle:CGFloat = fullCircle * rotationStrength / 16
        let scaleStrength:CGFloat = (CGFloat) (1 - fabsf(Float(rotationStrength)) / 2)
        let scale = max(scaleStrength, 0.93)
        
        let newX = self.originalPoint.x + xDistance
        let newY = self.originalPoint.y + yDistance
        
        let transform = CGAffineTransform(rotationAngle: rotationAngle)
        let scaleTransform = transform.scaledBy(x: scale, y: scale)
        
        if(self.isActiveChange){
            self.cardView.center = CGPoint(x:newX,y: newY)
            self.cardView.transform = scaleTransform
        } else {
            self.cardView1.center = CGPoint(x:newX,y: newY)
            self.cardView1.transform = scaleTransform
        }
    }
    
//MARK: ResetViewPositionAndTransformations
    func resetViewPositionAndTransformations() {
        UIView.animate(withDuration: 0.2, animations: {
            if(self.isActiveChange){
                self.cardView.center = self.originalPoint;
            } else {
                self.cardView1.center = self.originalPoint;
            }
            self.cardView.transform = CGAffineTransform(rotationAngle: 0);
            self.cardView1.transform = CGAffineTransform(rotationAngle: 0);
        })
    }
}
