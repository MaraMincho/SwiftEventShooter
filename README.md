# SwiftErrorArchiver

SwiftErrorArchiver is focused on transmitting errors that occur on the client-side via platforms such as Discord or Slack. 
The features are designed for personal apps or applications with a small user base in the early stages. 
It offers a simple way to design and view platform-specific logging objects or messages. Currently, Discord and Slack are supported.

<br/>

# Usage
### Slack
```swift
let slackSDK = SwiftErrorArchiverSDK(type:
    .slack(.init(slackWebHookURL: "SlackURL"))
)

slackSDK.sendMessage(event: TestEventObject(message: "Hello slack"))
slackSDK.sendMessage(event: "Hello world")
```

### Discord

```swift
let discordSDK = SwiftErrorArchiverSDK(type: 
    .discord(.init(discordNetworkURL: "DiscordWebHookURL"))
)
discordSDK.sendMessage(event: TestEventObject(message: "Hello Discord"))
discordSDK.sendMessage(event: "Hello world")
```


<br/>

# Installation

```swift
dependencies: [
    .package(url: "https://github.com/MaraMincho/SwiftErrorArchiver", .upToNextMajor(from: "1.0.0"))
]
```

<br/><br/>
