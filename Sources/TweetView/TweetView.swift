#if canImport(UIKit)
import UIKit
import WebKit
import SafariServices

private let DefaultCellHeight: CGFloat = 20
private let TweetPadding: CGFloat = 20
private let HeightCallback = "heightCallback"
private let ClickCallback = "clickCallback"
private let HtmlTemplate = "<html><head><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></head><body><div id='wrapper'></div></body></html>"

public class TweetView: UIView {
    
    // The WKWebView we'll use to display the Tweet
    private var webView: WKWebView!
    
    // The Tweet ID
    @IBInspectable var id: String
    
    // The height of the TweetView
    private(set) var height: CGFloat
    
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
        
        self.id = "736726372966502400"
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
}


extension TweetView: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, navigationAction.navigationType == .linkActivated {
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
        
    }
}


extension TweetView: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        // Allow links with target="_blank" to open in SafariViewController
        //   (includes clicks on the background of Embedded Tweets
        if let url = navigationAction.request.url, navigationAction.targetFrame == nil {
        }
        
        return nil
    }
}

extension TweetView: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case HeightCallback:
            guard let message = message.body as? String, let intHeight = Int(message) else { return }
            self.height = CGFloat(intHeight) + 20.0
        default:
            print("Unhandled callback")
        }
    }
    
}

#endif
