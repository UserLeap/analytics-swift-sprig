# Analytics-Swift Sprig
Add Sprig `device-mode` support to your application via this plugin

## Adding the dependency
### via Xcode
In the Xcode `File` menu, click `Add Packages`.  You'll see a dialog where you can search for Swift packages.  In the search field, enter the URL to this repo.

`https://github.com/UserLeap/analytics-swift-sprig`

<img width="202" alt="image" src="https://user-images.githubusercontent.com/73458232/180099287-de18ce96-0e7b-4587-a0a5-a71ada3b8d72.png">
<img width="1075" alt="image" src="https://user-images.githubusercontent.com/73458232/180099361-94cdcbec-8f00-4cc2-9e2b-a16cd62dd8e0.png">

You'll then have the option to pin to a version, or specific branch, as well as which project in your workspace to add it to.  Once you've made your selections, click the `Add Package` button.  

### via Package.swift

Open your Package.swift file and add the following do your the `dependencies` section:

```
.package(
            name: "Segment",
            url: "https://github.com/UserLeap/analytics-swift-sprig.git",
            from: "1.1.3"
        ),
```


*Note the Sprig library itself will be installed as an additional dependency.*


## Using the Plugin in your App

Select your iOS Source from `My Sources` dashboard on segment, and get the value for `Write Key` from `Settings -> API Keys`

Open the file where you setup and configure the Analytics-Swift library.  Add this plugin to the list of imports. Replace the write key value.

```
import Segment
import SegmentSprig // <-- Add this line
```

Just under your Analytics-Swift library setup, call `analytics.add(plugin: ...)` to add an instance of the plugin to the Analytics timeline.

```
let analytics = Analytics(configuration: Configuration(writeKey: "<YOUR WRITE KEY>")
                    .flushAt(3)
                    .trackApplicationLifecycleEvents(true))
analytics.add(plugin: SprigDestination())
```

Your events will now begin to flow to Sprig in device mode. 
When you track an event and receives a survey, the survey will show on the top view controller.
To record attributes, you can make use of the traits parameter when you call [identify](https://segment.com/docs/connections/sources/catalog/libraries/mobile/swift-ios/#identify) function.
Download [Basic Example](https://github.com/UserLeap/analytics-swift-sprig/tree/main/Example/BasicExample) app for reference.

## Support

Please use Github issues, Pull Requests, or feel free to reach out to our [support team](https://segment.com/help/).