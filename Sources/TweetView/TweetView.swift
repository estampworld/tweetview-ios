#if canImport(UIKit)
import UIKit
import WebKit
import SafariServices

private let DefaultCellHeight: CGFloat = 20
private let TweetPadding: CGFloat = 30

private let HeightCallback = "heightCallback"
private let ClickCallback = "clickCallback"
private let HtmlTemplate = "<html><head><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></head><body><div id='wrapper'></div></body></html>"


@objc
protocol TweetViewDelegate: AnyObject {
    func tweetView(_ tweetView: TweetView, didUpdatedHeight height: CGFloat)
    func tweetView(_ tweetView: TweetView, shouldOpenURL url: URL)
}

public class TweetView: UIView {
    
    // The WKWebView we'll use to display the Tweet
    private var webView: WKWebView!
    
    /// The TweetView Delegate
    @IBInspectable weak var delegate: TweetViewDelegate?
    
    /// The Tweet ID
    @IBInspectable var id: String
    
    /// The height of the TweetView
    private(set) var height: CGFloat {
        didSet {
            delegate?.tweetView(self, didUpdatedHeight: height)
        }
    }
    
    /// Initializes and returns a newly allocated tweet view object with the specified id
    /// - Parameter id: Tweet's id
    init(id: String) {
        self.id = id
        self.height = DefaultCellHeight
        
        super.init(frame: CGRect.zero)
        
        webView = self.createWebView()
        
        addSubview(webView)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        webView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        webView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        
        self.id = ""
        self.height = DefaultCellHeight
                
        super.init(coder: coder)

        webView = self.createWebView()
        addSubview(webView)

        webView.translatesAutoresizingMaskIntoConstraints = false
        
        webView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        webView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
    
    private func createWebView() -> WKWebView {
        let webView = WKWebView()
        
        // Set delegates
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        // Register callbacks
        webView.configuration.userContentController.add(self, name: ClickCallback)
        webView.configuration.userContentController.add(self, name: HeightCallback)
        
        // Set initial frame
        webView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: CGFloat(DefaultCellHeight))
        
        // Prevent scrolling
        webView.scrollView.isScrollEnabled = false
        
        return webView
    }
    
    // MARK: Methods
    
    /// Load the Tweet's HTML template
    public func load() {
        webView.loadHTMLString(HtmlTemplate, baseURL: nil)
    }
    
}

// MARK: - WKNavigationDelegate
extension TweetView: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, navigationAction.navigationType == .linkActivated {
            delegate?.tweetView(self, shouldOpenURL: url)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadTweetInWebView(webView)
    }
    
    // Tweet Loader
    func loadTweetInWebView(_ webView: WKWebView) {
        if let widgetsJSScript = WidgetsJsManager.shared.getScriptContent() {
            
            webView.evaluateJavaScript(widgetsJSScript)
            webView.evaluateJavaScript("twttr.widgets.load();")
            
            // Documentation:
            // https://developer.twitter.com/en/docs/twitter-for-websites/embedded-tweets/guides/embedded-tweet-javascript-factory-function
            webView.evaluateJavaScript("""
                twttr.widgets.createTweet(
                    '\(id)',
                    document.getElementById('wrapper'),
                    { align: 'center', theme: 'dark' }
                ).then(el => {
                    window.webkit.messageHandlers.heightCallback.postMessage(el.offsetHeight.toString())
                });
            """)
        }
    }
}

// MARK: - WKUIDelegate
extension TweetView: WKUIDelegate {
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        // Allow links with target="_blank" to open in SafariViewController
        //   (includes clicks on the background of Embedded Tweets
        if let url = navigationAction.request.url, navigationAction.targetFrame == nil {
            delegate?.tweetView(self, shouldOpenURL: url)
        }
        
        return nil
    }
}

// MARK: - WKScriptMessageHandler
extension TweetView: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case HeightCallback:
            guard let message = message.body as? String, let intHeight = Int(message) else { return }
            self.height = CGFloat(intHeight) + TweetPadding
        default:
            print("Unhandled callback")
        }
    }
}

#endif
