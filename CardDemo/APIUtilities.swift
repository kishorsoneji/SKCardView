//
//  APIUtilities.swift
//  AlamofireExample
//
//  Created by Harry on 2/24/17.
//  Copyright © 2017 Harry. All rights reserved.
//

import Foundation
import Alamofire
import SVProgressHUD

class APIUtilities : NSObject
{
    class var sharedInstance : APIUtilities {
        
        struct Static {
            
            static let instance : APIUtilities = APIUtilities()
            
        }
        return Static.instance
    }
    
    func request(url : String,method : Alamofire.HTTPMethod,parameters : [String: Any],parameterEncoding : ParameterEncoding, header : HTTPHeaders,completion: @escaping ((URLRequest?, HTTPURLResponse?, Result<Any>) -> Void)) {
        
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.light)
        SVProgressHUD.show()
        DispatchQueue.global(qos: .userInitiated).async {
       
        Alamofire.request(url, method: method, parameters: parameters, encoding: URLEncoding(destination: .httpBody), headers: header)
            .responseJSON { response in
                
                switch(response.result) {
                    case .success(_):
                        print(response.request as Any)  // original URL request
                        print(response.response as Any) // URL response
                        print(response.result.value as Any)
                        completion(response.request, response.response, response.result as Result<Any>)
                        SVProgressHUD.dismiss()
                       // completion(response.request,response.response,response.result as Result<Any>)
                        break
                    case .failure(_):
                        print(response.result.error)
                        SVProgressHUD.dismiss()
                        break
                }
            }
        }
        
    }
    
    func uploadWithAlamofire(image: UIImage, urlString: String,parameters:[String:Any]) {
    
        let imageData = UIImageJPEGRepresentation(image, 0.50)
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(imageData!, withName: "xyz", fileName: "file.jpeg", mimeType: "image/jpeg")
            }, to: urlString)
        { (result) in
            //result
            print(result)
        }
    }

    

}
