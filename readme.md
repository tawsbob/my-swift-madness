
# Using Swift Promises like JavaScript

## Overview

The Promise class is a Swift implementation of the Promise pattern, similar to JavaScript promises. It allows for asynchronous operations to be handled in a more manageable way.

### Basic Usage

```swift
// Create a promise that resolves after 2 seconds
let promise = Promise<String, Error> { resolve, reject in
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        resolve("Hello, World!")
    }
}

// Attach callbacks
promise
    .then { value in
        print("Success:", value)
    }
    .catch { error in
        print("Error:", error)
    }
    .finally {
        print("Finally")
    }
```

### Basic Error Handling

```swift
// Create a promise that rejects with an error
let promise = Promise<String, Error> { resolve, reject in
    reject(Error("Something went wrong"))
}

// Catch the error
promise
    .then { value in
        print("Success:", value)
    }
    .catch { error in
        print("Error:", error)
    }
    .finally {
        print("Finally")
    }
```

### Making HTTP Calls

```swift
import Foundation

// Create a promise that performs a GET request
func fetchUserData() -> Promise<Data, Error> {
    return Promise<Data, Error> { resolve, reject in
        guard let url = URL(string: "https://api.example.com/user") else {
            reject(Error("Invalid URL"))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                reject(error)
                return
            }
            
            guard let data = data else {
                reject(Error("No data returned"))
                return
            }
            
            resolve(data)
        }.resume()
    }
}

// Use the promise
fetchUserData()
    .then { data in
        print("User data:", String(data: data, encoding: .utf8) ?? "")
    }
    .catch { error in
        print("Error:", error)
    }
    .finally {
        print("Finally")
    }
```