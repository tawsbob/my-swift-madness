//
//  Promise.swift
//  NaHora
//
//  Created by Dellean Santos Teixeira on 16/11/24.
//

import Foundation

class Promise<Value, Failure: Error> {
    private var successCallback: ((Value) -> Void)?
    private var failureCallback: ((Failure) -> Void)?
    private var finallyCallback: (() -> Void)?
    
    private var result: Result<Value, Failure>? {
        didSet {
            // Automatically trigger the appropriate callback when the result is set
            switch result {
            case .success(let value):
                successCallback?(value)
                finallyCallback?()
            case .failure(let error):
                failureCallback?(error)
                finallyCallback?()
            case .none:
                break
            }
        }
    }
    
    init(_ executor: (@escaping (Value) -> Void, @escaping (Failure) -> Void) -> Void) {
        executor({ value in
            self.result = .success(value)
        }, { error in
            self.result = .failure(error)
        })
    }
    
    func then(_ onSuccess: @escaping (Value) -> Void) -> Promise<Value, Failure> {
        self.successCallback = onSuccess
        // Trigger the callback if the promise is already resolved
        if case .success(let value)? = result {
            onSuccess(value)
        }
        return self
    }
    
    func `catch`(_ onFailure: @escaping (Failure) -> Void) -> Promise<Value, Failure> {
        self.failureCallback = onFailure
        // Trigger the callback if the promise is already resolved
        if case .failure(let error)? = result {
            onFailure(error)
        }
        return self
    }
    
    func finally(_ onFinally: @escaping () -> Void) -> Promise<Value, Failure> {
        self.finallyCallback = onFinally
        // Trigger the callback if the promise is already resolved
        if result != nil {
            onFinally()
        }
        return self
    }
}

