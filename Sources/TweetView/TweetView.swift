#if canImport(UIKit)
import UIKit
import WebKit
import SafariServices

private let DefaultCellHeight: CGFloat = 20
private let TweetPadding: CGFloat = 40

private let HeightCallback = "heightCallback"
private let ClickCallback = "clickCallback"
private let HtmlTemplate = "<html><head><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'><style>* { margin: 0; padding: 0; } </style></head><body><div id='wrapper'></div></body></html>"

@objc
public protocol TweetViewDelegate: AnyObject {
    func tweetView(_ tweetView: TweetView, didUpdatedHeight height: CGFloat)
    func tweetView(_ tweetView: TweetView, shouldOpenURL url: URL)
}

public class TweetView: UIView {
    
    public static func prepare() {
        WidgetsJSManager.shared.load()
    }
    
    // The WKWebView we'll use to display the Tweet
    private lazy var webView: WKWebView! = {
        let webView = WKWebView()
        
        webView.isOpaque = false
        
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
    }()
    
    /// The TweetView Delegate
    @IBInspectable public weak var delegate: TweetViewDelegate?
    
    /// The Tweet ID
    @IBInspectable public  var id: String
    
    /// The height of the TweetView
    public private(set) var state: State = .idle
    
    /// The height of the TweetView
    public private(set) var height: CGFloat {
        didSet {
            delegate?.tweetView(self, didUpdatedHeight: height)
        }
    }
    
    /// Initializes and returns a newly allocated tweet view object with the specified id
    /// - Parameter id: Tweet's id
    public init(id: String) {
        self.id = id
        self.height = DefaultCellHeight
        
        super.init(frame: CGRect.zero)
    }
    
    public required init?(coder: NSCoder) {
        
        self.id = ""
        self.height = DefaultCellHeight
                
        super.init(coder: coder)
    }
    
    // MARK: Methods
    
    /// Load the Tweet's HTML template
    public func load() {
        guard state != .loading else { return }
        state = .loading
        addWebViewToSubviews()

        webView.loadHTMLString(HtmlTemplate, baseURL: nil)
    }
    
    fileprivate func addWebViewToSubviews() {
        addSubview(webView)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        webView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        webView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
    
    // Tweet Loader
    private func loadTweetInWebView(_ webView: WKWebView) {
        if let widgetsJSScript = WidgetsJSManager.shared.content {
            
            webView.evaluateJavaScript(widgetsJSScript)
            webView.evaluateJavaScript("twttr.widgets.load();")
            
            var theme = "light"
            if #available(iOS 13.0, *), UITraitCollection.current.userInterfaceStyle == .dark {
                theme = "dark"
            }
            
            // Documentation:
            // https://developer.twitter.com/en/docs/twitter-for-websites/embedded-tweets/guides/embedded-tweet-javascript-factory-function
            webView.evaluateJavaScript("""
                twttr.widgets.createTweet(
                    '\(id)',
                    document.getElementById('wrapper'),
                    { align: 'center', theme: '\(theme)' }
                ).then(el => {
                    window.webkit.messageHandlers.heightCallback.postMessage(el.offsetHeight.toString())
                });
            """)
        }
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
        state = .loaded
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        state = .failed
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

extension TweetView {
    public enum State {
        case idle, loading, loaded, failed
    }
}

#endif
