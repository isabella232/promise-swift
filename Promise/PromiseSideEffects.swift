//
//  PromiseSideEffects.swift
//  Promise
//
//  Created by Sergey Gavrilyuk on 2017-07-12.
//  Copyright © 2017 Shopify. All rights reserved.
//

import Foundation


extension Promise {
    
    public func onStart(do action: @escaping () -> Void) -> Promise {
        return Promise { complete, cancel in
            action()
            self.whenComplete(callback: complete)
            cancel = { self.cancel() }
        }
    }
    
    public func onComplete(do action: @escaping (Result<T, E>) -> Void) -> Promise {
        return Promise { complete, cancel in
            self.whenComplete { result in
                action(result)
                complete(result)
            }
            cancel = { self.cancel() }
        }
    }
    
    public func onSuccess(do action: @escaping (T) -> Void) -> Promise {
        return self.onComplete { result in
            switch result {
            case .success(let value): action(value)
            case .error: break
            }
        }
    }
    
    public func onError(do action: @escaping (E) -> Void) -> Promise {
        return self.onComplete { result in
            switch result {
            case .error(let error): action(error)
            case .success: break
            }
        }
    }    
}

