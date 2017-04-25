//
//  ViewController.swift
//  CardDemo
//
//  Created by Harry on 4/21/17.
//  Copyright © 2017 Harry. All rights reserved.
//

import UIKit
import SVProgressHUD
import Alamofire
import AlamofireImage
import MediaPlayer


class ViewController: UIViewController {
    
    var arrEvent = NSMutableArray()
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var cardView1: UIView!
    
    @IBOutlet weak var webView1: UIWebView!
    @IBOutlet weak var webView: UIWebView!
    
    var panGestureRecognizer:UIPanGestureRecognizer!
    var originalPoint: CGPoint!
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
        //cardView.addSubview(cardView)
        
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        
        webView1.scrollView.isScrollEnabled = false
        webView1.scrollView.bounces = false
        
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.light)
        SVProgressHUD.show()
        
        let url = "http://data.in.bookmyshow.com/getData.aspx?cc=&cmd=GETEVENTLIST&dt=&et=MT&f=json&lg=72.842588&lt=19.114186&rc=MUMBAI&sr=&t=a54a7b3aba576256614a"
        
        self.setBlur(view: self.cardView)
        self.setBlur(view: self.cardView1)
        APIUtilities.sharedInstance.request(url: url, method: .get, parameters: [:], parameterEncoding: JSONEncoding.default, header: [:],completion: {(request,response,data) in
            let bookMyShow =  data.value as! NSDictionary
            let movieArray = bookMyShow.value(forKeyPath: "BookMyShow.arrEvent") as! NSArray
           
            self.arrEvent = NSMutableArray()
            for event in movieArray {
                let e = event as! NSDictionary
                let objEvent = ArrEvent()
                objEvent.eventTitle = e.value(forKey: "EventTitle") as! NSString
                objEvent.bannerURL = e.value(forKey: "BannerURL") as! NSString
                objEvent.director = e.value(forKey: "Director") as! NSString
                objEvent.actors = e.value(forKey: "Actors") as! NSString
                objEvent.trailerURL = e.value(forKey: "TrailerURL") as! NSString
                self.arrEvent.add(objEvent)
            }
            
            self.setData(index: self.index)
            self.index = self.index + 1
            self.setData(index: self.index)
            SVProgressHUD.dismiss()
        });
        
        self.cardView.transform = CGAffineTransform(rotationAngle: 0);
        self.cardView1.transform = CGAffineTransform(rotationAngle: 0.05);
    }
    
   
//MARK: set blur view
    func setBlur(view : UIView){
        view.layer.cornerRadius = 8;
        view.layer.shadowOffset = CGSize(width:7,height: 7);
        view.layer.shadowRadius = 5;
        view.layer.shadowOpacity = 0.5;
    }
    
//MARK: set data for views
    func setData(index:Int){
        print(index)
        if(isActiveChange){
            let objEvent = self.arrEvent.object(at: index) as! ArrEvent
            imageView.af_setImage(withURL: URL(string: objEvent.bannerURL as String)!)
            lblName.text = objEvent.eventTitle as String
            if(objEvent.trailerURL.length > 0){
                webView.loadRequest(URLRequest(url: URL(string: objEvent.trailerURL as String)!))
            }
            print(objEvent.eventTitle)
            print(objEvent.trailerURL)
            self.imageView.isHidden = false;
            isActiveChange = false
        } else {
            let objEvent = self.arrEvent.object(at: index) as! ArrEvent
            imageView1.af_setImage(withURL: URL(string: objEvent.bannerURL as String)!)
            lblName1.text =  objEvent.eventTitle as String
            if(objEvent.trailerURL.length > 0){
                webView1.loadRequest(URLRequest(url: URL(string: objEvent.trailerURL as String)!))
            }
            print(objEvent.eventTitle)
            print(objEvent.trailerURL)
            self.imageView1.isHidden = false;
            isActiveChange = true
        }
        webView.isHidden = true;
        webView1.isHidden = true;
        self.view.layoutIfNeeded()
    }
    
    override func viewWillLayoutSubviews() {
        cardView.center = cardView.center
    }
    
//MARK: Create dynamic card view
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
    
//MARK: UIPanGestureRecognizer handling
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
                if(self.index >= self.arrEvent.count-1){
                    self.index = 0
                } else {
                    self.index = self.index + 1
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
                
                setData(index: self.index)
            }
           resetViewPositionAndTransformations()
            break
            
        default:
            break
        }
    }
    
    
//MARK: handle distance of card with cardview with main view
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
    
//MARK: handle youtube video url.
    @IBAction func watchYoutubeTrailer(_ sender: AnyObject) {
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.light)
        SVProgressHUD.show()
         if(isActiveChange){
            webView.isHidden = false
            let objEvent = self.arrEvent.object(at: self.index) as! ArrEvent
            if(objEvent.trailerURL.length > 0){
                UIView.transition(with: imageView, duration: 0.4, options: .transitionCrossDissolve, animations: {() -> Void in
                    self.imageView.isHidden = true
                }, completion: { _ in
                    self.webView1.isHidden = false;
                })
                //imageView.isHidden = true
            }
         }else {
            
            let objEvent = self.arrEvent.object(at: self.index) as! ArrEvent
            if(objEvent.trailerURL.length > 0){
                UIView.transition(with: imageView1, duration: 0.4, options: .transitionCrossDissolve, animations: {() -> Void in
                    self.imageView1.isHidden = true
                    }, completion: { _ in
                            self.webView1.isHidden = false;
                })
            }
         }
        SVProgressHUD.dismiss()
    }
    
//MARK: reset the view postions. 
    func resetViewPositionAndTransformations() {
        UIView.animate(withDuration: 0.2, animations: {
            if(self.isActiveChange){
                self.cardView.center = self.originalPoint;
                self.cardView.transform = CGAffineTransform(rotationAngle: 0);
                self.cardView1.transform = CGAffineTransform(rotationAngle: 0.05);
            } else {
                self.cardView1.center = self.originalPoint;
                self.cardView.transform = CGAffineTransform(rotationAngle: 0.05);
                self.cardView1.transform = CGAffineTransform(rotationAngle: 0);
            }
            
           
        })
    }
}
