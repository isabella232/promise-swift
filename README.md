# Promise
[![Build Status](https://travis-ci.org/Shopify/promise-swift.svg?branch=master)](https://travis-ci.org/Shopify/promise-swift)

This is a swift framework implementing [promise](https://en.wikipedia.org/wiki/Futures_and_promises) pattern.

## What is Promise?
Promise represents a value that may be available in future. Technically, it's a wrapper for an async function with result returned via callback. Besides being an async computation wrapper, Promise can also act as [continuation monad](https://en.wikipedia.org/wiki/Monad_(functional_programming)#Continuation_monad) opening up a new way of solving many problems related to async computations.

## Features
`Promise-swift` is heavily influenced by Node.js `Promise` implementation in terms of API and by [ReactiveSwift](https://github.com/ReactiveCocoa/ReactiveSwift)'s `Signal` implementation in internal design. Notably:
1. `Promise-swift` is cold: the async computation that the promise represents will only start execution when promise is first observed using `whenComplete` method. This allows the promise to be created in one place but triggered in another.
2. `Promise-swift` is buffered: once value computed subsequent calls to `whenComplete` will not trigger async computation again.
3. `Promise-swift` is parameterized with both value _and_ error: `Promise<Int, SomeError>`
4. `Promise-swift` is thread-safe: async computations and observing can be triggered from different threads.
5. `Promise-swift` is cancelable: async computation wrapper API provides a way to retain canceling action.
6. `Promise-swift` is a continuation monad: you can use `then` and to chain multiple async computations.
7. Last but not least: `Promise-swift` is very lightweight, built on top of GCD.

## Basic usage

### Creation
There are 2 ways of creating a promise instance:

1. With fixed value of computations result, as if computation was already done:
```swift
let valuePromise = Promise<Int, NoError>(value: 42)
```
2. with async computation provided as parameter:
```swift
let asyncValuePromise = Promise<Int, NoError> { resolver in
    //pretend we do something heavy
    DispatchQueue.main.after(.now() + .seconds(3)) {
        // done, return result
        resolver.resolve(with: 42)
    }
}
```

### Cancellation
Promise can be canceled by calling `cancel` on it. That guarantees that after this promise will not resolve with any value on observers regardless of whether running computation completed or not.

You can also provide custom logic for what to do when `cancel` was called:
```swift
let cancellablePromise = Promise<Int, NoError> { resolver in
    var cancelled = false
    DispatchQueue.main.after(.now() + .seconds(3)) {
        guard cancelled == false else { return }
        resolver.resolve(with: 42)
    }
    resolver.onCancel = { 
        // cancel may be called on any thread, this makes sure we're thread-safe
        DispatchQueue.main.async { cancelled = true}
    }
}
```

### Observing
`Promise` can be observed for resolution using `whenComplete`:
```swift
let p: Promise<Int, SomeError> = ...

p.whenComplete { result in
    switch result {
        case .success(let value):
            print("Resovled with value \(value)")
        case .error(let error):
            print("Rejected with error \(error)")
    }
}
```

### Chaining and Composition
Series of async computations where each next step requires input computed on the previous step can represented as chain of `Promise`s. To chain one `Promise` with another use `then` method:
```swift
let step1Promise = Promise <Int, NoError> { resolver in
    DispatchQueue.main.after(.now() + .seconds(3)) {
        resolver.resolve(with: 42)
    }
}

let finalResultPromise<String, NoError> = step1Promise
    .then { step1Value in
        // now that we have step1 value calculated make promise calculating step2
        let step2Promise = Promise { resolver in
            DispatchQueue.main.after(.now() + .seconds(3)) {
                resolver.resolve("\(step1Value)")
            }
    }
}
```
**Note**: Next promise in the chain can transform type of the value, but not type of the error.



# Credits
`Promise-swift` created by Sergey Gavrilyuk [@octogavrix](http://twitter.com/octogavrix).


## License
`Promise-swift` is distributed under MIT license. See LICENSE for more info.

## Contributing
Fork, branch & pull request.

