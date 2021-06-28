# TweetView

![TweetView CI](https://github.com/estampworld/tweetview-ios/workflows/TweetView%20CI/badge.svg)
[![codebeat badge](https://codebeat.co/badges/bd881f0e-80eb-4973-99bf-f86165ccfde6)](https://codebeat.co/projects/github-com-estampworld-tweetview-ios-main)

Display a Tweet in a TweetView using the Tweet's id.

## Features

## Install

### Swift Package Manager

#### Adding it to an existent iOS Project via Swift Package Manager

- Using Xcode 11+ go to File > Swift Packages > Add Package Dependency
- Paste the project URL: https://github.com/estampworld/tweetview-ios
- Click on next and select the project target

## Usage

### Swift

#### Creating a Tweet View

```

TweetView.prepare()

let width = view.frame.width - 32.0

let tweetView = TweetView(id:"1345021162959503360")

tweetView.frame = CGRect(x: 16, y: 16, width: width, height: width)
tweetView.delegate = self

self.view.addSubview(tweetView)

tweetView.load()

```

#### Delegate

```
extension ...: TweetViewDelegate {
    func tweetView(_ tweetView: TweetView, didUpdatedHeight height: CGFloat) {
        tweetView.frame.size = CGSize(width: tweetView.frame.width, height: height)
    }
    
    func tweetView(_ tweetView: TweetView, shouldOpenURL url: URL) {
    }
}
```

#### SwiftUI

```
struct SwiftUITweetView: View {
    @State var id: String
    @State var height: CGFloat = 200
    
    var body: some View {
        TweetViewAdapter(id: $id, height: $height)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: height, maxHeight: .infinity)
    }
}

struct TweetViewAdapter: UIViewRepresentable {
    @Binding var id: String
    @Binding var height: CGFloat
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(height: $height)
    }
    
    func makeUIView(context: Context) -> TweetView {
        TweetView.prepare()
        let tweetView = TweetView(id: id)
        tweetView.delegate = context.coordinator
        tweetView.load()
        return tweetView
    }
    
    func updateUIView(_ uiView: TweetView, context: Context) {
    }
}

class Coordinator: NSObject, TweetViewDelegate {
    @Binding var updatedHeight: CGFloat
    
    init(height: Binding<CGFloat>, showWebView: Binding<Bool>, urlToShow: Binding<URL?>) {
        _updatedHeight = height
    }
    
    func tweetView(_ tweetView: TweetView, didUpdatedHeight height: CGFloat) {
        tweetView.frame.size = CGSize(width: tweetView.frame.width, height: height)
        updatedHeight = height
    }
    
    func tweetView(_ tweetView: TweetView, shouldOpenURL url: URL) {
    }
}
```

### Based on

https://blog.twitter.com/developer/en_us/topics/tips/2019/displaying-tweets-in-ios-apps.html

### Maintainers

[Eduardo Irias](https://github.com/eduardo22i), creator.

### Contributing

1. Fork it ( https://github.com/estampworld/tweetview-ios/fork )
2. Create your feature branch (git checkout -b feature/[my-new-feature])
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin feature/[my-new-feature])
5. Create a new Pull Request

### License

Toast Alert Views is available under the MIT license. See the LICENSE file for more info.
