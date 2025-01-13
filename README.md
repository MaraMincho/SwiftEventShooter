# SwiftEventShotter

SwiftEventShotter is focused on transmitting errors that occur on the client-side via platforms such as Discord or Slack. 
SDK detect the client's network status, store events in local storage if they cannot be sent. And transmit the events once the client regains network connectivity.
The features are designed for personal apps or applications with a small user base in the early stages. 
It offers a simple way to design and view platform-specific logging objects or messages. Currently, Discord and Slack are supported.

<br/>

# Usage

### Slack

To send Slack message, you must know Slack webhookURL. Then, SDK send the event to Slack.

```swift
let slackSDK = SwiftEventShooterSDK(type:.slack(.init(slackWebHookURL: "SlackURL")))

slackSDK.sendMessage(event: TestEventObject(message: "Hello slack"))
slackSDK.sendMessage(event: "Hello world")
```

<br/><br/>

### Discord

To send Discord message, you must know Discord webhookURL. Then, SDK send the event to Discord.

```swift
let discordSDK = SwiftEventShooterSDK(type: .discord(.init(discordNetworkURL: "DiscordWebHookURL")))

discordSDK.sendMessage(event: TestEventObject(message: "Hello Discord"))
discordSDK.sendMessage(event: "Hello world")
```

<br/><br/>

### Custom server

To send server event message, you must know server event url. Then, SDK send the event to server.

```swift
let serverEventSDK = SwiftEventShooterSDK(
    targetType: CustomEventStreamControllerTargetType(...),
    type: .discord(.init(discordNetworkURL: "DiscordWebHookURL"))
)

serverEventSDK.sendMessage(event: TestEventObject(message: "Hello Discord"))
serverEventSDK.sendMessage(event: "Hello world")
```

<br/><br/>

### Configure

If you want to save the failed network or failed to transmit event, call `configure` method.

``` swift
let sdk = SwiftEventShotter(...)
sdk.configure()
``` 


<br/><br/>

# Installation

```swift
dependencies: [
    .package(url: "https://github.com/MaraMincho/SwiftEventShooter", .upToNextMajor(from: "1.0.0"))
]
```

<br/><br/>
