//
//  BYHttpTool.swift
//  BYHttpTool
//
//  Created by r on 2022/1/24.
//ceshiceshi2

import UIKit
import Alamofire

public protocol BYBaseModel: Codable {

}

public struct BYNormalModel: Codable{
    var resultCode: String?
    var resultMsg: String?
}

public struct BYNetToolConfig{
    var token : String =  ""{
        didSet{
            head["Authorization"] = "Bearer \(token)"
        }
    }

    var head = ["Accept": "application/json;text/html;charset=utf-8","Content-Type": "application/json;text/html;charset=utf-8"]
}

public class BYHttpTool: NSObject {
    
    public var config =  BYNetToolConfig()

    public static let shared = BYHttpTool()
    
    private lazy var manger: SessionManager = {
        let c = URLSessionConfiguration.default
        c.timeoutIntervalForRequest = 30
        c.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        
        let m = SessionManager.init(configuration: c)
        m.delegate.sessionDidReceiveChallenge = { session, challenge in
            var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling
            var credential: URLCredential?
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                disposition = URLSession.AuthChallengeDisposition.useCredential
                credential = URLCredential.init(trust: challenge.protectionSpace.serverTrust!)
            } else {
                if challenge.previousFailureCount > 0 {
                    disposition = .cancelAuthenticationChallenge
                } else {
                    credential = m.session.configuration.urlCredentialStorage?.defaultCredential(for: challenge.protectionSpace)
                    if credential != nil {
                        disposition = .useCredential
                    }
                }
            }
            return (disposition, credential)
        }
        return m
    }()
}

enum BYNetError: Error {
    //解析失败
    case decode
    //系统错误
    case system
    //token失效
    case tokenDisable
}

//不用返回Model的情况
extension BYHttpTool{
    public func getRequest(urlString: String,parms: [String: Any]? = nil ,cmpBlock:@escaping (Result<Bool>) -> Void){
        
        manger.request(urlString, method: .get, parameters: parms, encoding: URLEncoding.queryString, headers: self.config.head).responseData(queue: .main) { response in
            self.decodeFromData(res: response, cmpBlock: cmpBlock)
        }
        
    }
    
    public func postRequest(urlString: String,parms: [String: Any]? = nil ,cmpBlock:@escaping (Result<Bool>) -> Void){

        manger.request(urlString, method: .get, parameters: parms, encoding: JSONEncoding.default, headers: self.config.head).responseData(queue: .main) { response in
            self.decodeFromData(res: response, cmpBlock: cmpBlock)
        }
    }
    
//    public func deleteRequest(urlString: String,parms: [String: Any]? = nil ,cmpBlock:@escaping (Result<Bool>) -> Void){
//
//        manager.request(URLString, method: .delete, parameters: params,encoding: encod!,headers:head).responseString { (response) in
//
//        }
//    }
    

}

extension BYHttpTool{
    
    public func getRequest<T: BYBaseModel>(urlString: String,parms: [String: Any]? = nil ,returnModel: T,cmpBlock:@escaping (Result<T>) -> Void){
        
        manger.request(urlString, method: .get, parameters: parms, encoding: URLEncoding.queryString, headers: self.config.head).responseData(queue: .main) { response in
            self.decodeFromData(res: response,returnModel: returnModel, cmpBlock: cmpBlock)
        }
        
    }
    
    public func postRequest<T: BYBaseModel>(urlString: String,parms: [String: Any]? = nil,returnModel: T,cmpBlock:@escaping (Result<T>) -> Void){
        
        manger.request(urlString, method: .get, parameters: parms, encoding: JSONEncoding.default, headers: self.config.head).responseData(queue: .main) { response in
            self.decodeFromData(res: response,returnModel: returnModel, cmpBlock: cmpBlock)
        }
        
    }

}

//解析
extension BYHttpTool{
    public func decodeFromData(res: DataResponse<Data>,cmpBlock:@escaping (Result<Bool>) -> Void){
        guard let data = res.data else {
            cmpBlock(.failure(BYNetError.system))
            return
        }
        
        if let model = try? JSONDecoder().decode(BYNormalModel.self, from: data) {
            print("请求成功jsonstring---------------\(model)")
            
            guard model.resultCode == "0" else {
                if (model.resultCode == "6" || model.resultCode == "0113" ) {
                    cmpBlock(.failure(BYNetError.tokenDisable))
                    self.tokenDisable()
                }
                cmpBlock(.failure(BYNetError.system))
                return
            }
            
            cmpBlock(.success(true))

        }else{
            cmpBlock(.failure(BYNetError.system))
        }
    }
    
    public func decodeFromData<T: BYBaseModel>(res: DataResponse<Data>,returnModel: T,cmpBlock:@escaping (Result<T>) -> Void){
        
        guard let data = res.data else {
            cmpBlock(.failure(BYNetError.system))
            return
        }
        
        if let model = try? JSONDecoder().decode(BYNormalModel.self, from: data) {
            print("请求成功jsonstring---------------\(model)")
            
            guard model.resultCode == "0" else {
                if (model.resultCode == "6" || model.resultCode == "0113" ) {
                    cmpBlock(.failure(BYNetError.tokenDisable))
                    self.tokenDisable()
                }
                cmpBlock(.failure(BYNetError.system))
                return
            }
            
            do {
                let mode = try JSONDecoder().decode(T.self, from: data)
                cmpBlock(.success(mode))
            }catch DecodingError.keyNotFound(let key, let context) {
                print("Failed to decode from bundle due to missing key '\(key.stringValue)' not found – \(context.debugDescription)")
                cmpBlock(.failure(BYNetError.decode))
            } catch DecodingError.typeMismatch(_, let context) {
                print("Failed to decode  from bundle due to type mismatch – \(context.debugDescription)")
                cmpBlock(.failure(BYNetError.decode))
            } catch DecodingError.valueNotFound(let type, let context) {
                print("Failed to decode  from bundle due to missing \(type) value – \(context.debugDescription)")
                cmpBlock(.failure(BYNetError.decode))
            } catch DecodingError.dataCorrupted(_) {
                print("Failed to decode  from bundle because it appears to be invalid JSON")
                cmpBlock(.failure(BYNetError.decode))
            } catch {
                print("Failed to decode  from bundle: \(error.localizedDescription)")
                cmpBlock(.failure(BYNetError.decode))
            }
        }else{
            cmpBlock(.failure(BYNetError.system))
        }
    }
    
    //用户token失效
    public func tokenDisable(){
     
    }
}
