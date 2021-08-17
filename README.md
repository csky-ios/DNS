#  DNS
> make DNS query to any DNS sever directly in iOS and MacOS with Swift

## Installation

### Swift Package Manager
```
dependencies: [
	.package(url: "https://github.com/csky-ios/DNS.git", .upToNextMajor(from: "1.0.0"))
]
```

## Quick Start
```swift
DNSService.query(domain: "vincent178.site", queue: .global(), completion: { (rr, err) in
  print(rr!.Answers.map { $0.RData }) // Get ip list 
})
```
You can also make dns query to a custom name server
```swift
DNSService.query(host: "8.8.8.8", domain: "api.disco.goateng.com", queue: .global(), completion: { (rr, err) in
  print(rr!.Answers.map { $0.RData }) // this could be CName list as well
})
```
Make a txt type dns query
```swift
DNSService.query(domain: "goat.disco.goateng.com", type: .TXT, queue: .global(), completion: { (rr, err) in
  print(rr!.Answers.map { $0.RData })
})
        
```
Use Combine instead of completion handlers
```swift
DNSService.query(domain: "vincent178.site", queue: .global()).sink { completion in
	print("DNS query completed")
} receiveValue: { rr in
	print("DNS query returned values \(rr.Answers.map { $0.RData })")
}
```
