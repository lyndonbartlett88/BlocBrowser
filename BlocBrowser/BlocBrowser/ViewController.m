//
//  ViewController.m
//  BlocBrowser
//
//  Created by Lyndon Bartlett on 9/29/15.
//  Copyright © 2015 Lyndon Bartlett. All rights reserved.
//

#import "ViewController.h"
#import "AwesomeFloatingToolbar.h"
#import <WebKit/WebKit.h>

#define kWebBrowserBackString NSLocalizedString(@"Back", @"Back command")
#define kWebBrowserForwardString NSLocalizedString(@"Forward", @"Forward command")
#define kWebBrowserStopString NSLocalizedString(@"Stop", @"Stop command")
#define kWebBrowserRefreshString NSLocalizedString(@"Refresh", @"Reload command")

@interface ViewController () <WKNavigationDelegate, UITextFieldDelegate, AwesomeFloatingToolbarDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) AwesomeFloatingToolbar *awesomeToolbar;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
//@property (nonatomic, assign) NSUInteger frameCount;

@end

@implementation ViewController

- (void) resetWebView {
    [self.webView removeFromSuperview];
    
    WKWebView *newWebView = [[WKWebView alloc] init];
    newWebView.navigationDelegate = self;
    [self.view addSubview:newWebView];
    
    self.webView = newWebView;
    
    self.textField.text = nil;
    [self updateButtonsAndTitle];
}


#pragma mark - UIViewController

-(void)loadView {
    
    UIAlertController *welcome = [UIAlertController
                                  alertControllerWithTitle:@"Welcome" message:@"Enjoy your browsing" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                         {
                             [welcome dismissViewControllerAnimated:YES completion:nil];
                         }];
    [welcome addAction:ok];
    
    [self presentViewController:welcome animated:YES completion:nil];
    
    UIView *mainView = [UIView new];
    
    self.webView = [[WKWebView alloc] init];
    self.webView.navigationDelegate = self;
    
    self.textField = [[UITextField alloc] init];
    self.textField.keyboardType = UIKeyboardTypeURL;
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.placeholder = NSLocalizedString(@"Website URL or Search", @"Placeholder text for web browser URL field");
    self.textField.backgroundColor = [UIColor colorWithWhite:220/255.0f alpha:1];
    self.textField.delegate = self;
    
    self.awesomeToolbar = [[AwesomeFloatingToolbar alloc] initWithFourTitles:@[kWebBrowserBackString, kWebBrowserForwardString, kWebBrowserStopString, kWebBrowserRefreshString]];
    self.awesomeToolbar.delegate = self;
    
   
    
    

    
     for (UIView *viewToAdd in @[self.webView, self.textField, self.awesomeToolbar]) {
        [mainView addSubview:viewToAdd];
    }
        
    self.view = mainView;

    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
    
    // Do any additional setup after loading the view, typically from a nib.
}

-(void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    
    // First, calculate some dimensions.
    static const CGFloat itemHeight = 50;
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - itemHeight;
    
    // Now, assign the frames
    self.textField.frame = CGRectMake(0, 0, width, itemHeight);
    self.webView.frame =CGRectMake(0, CGRectGetMaxY(self.textField.frame), width, browserHeight);

    
    self.awesomeToolbar.frame = CGRectMake(20, 100, 280, 60);
}

#pragma mark - AwesomeFloatingToolbarDelegate

- (void) floatingToolbar:(AwesomeFloatingToolbar *)toolbar didSelectButtonWithTitle:(NSString *)title {
    if ([title isEqual:NSLocalizedString(@"Back", @"Back command")]) {
        [self.webView goBack];
    } else if ([title isEqual:NSLocalizedString(@"Forward", @"Forward command")]) {
        [self.webView goForward];
    } else if ([title isEqual:NSLocalizedString(@"Stop", @"Stop command")]) {
        [self.webView stopLoading];
    } else if ([title isEqual:NSLocalizedString(@"Refresh", @"Reload command")]) {
        [self.webView reload];
    }
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    NSString *URLString = textField.text;
    
    NSURL *URL = [NSURL URLWithString:URLString];
    
    if (!URL.scheme)
    {
        NSRange urlSpace = [URLString rangeOfString:@" "];
        NSString *urlNoSpace = [URLString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        
        if (urlSpace.location != NSNotFound) {
            URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.google.com/search?q=%@", urlNoSpace]];
        }
        else
        {
            URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", URLString]];
        }
    }
    
    if (URL) {
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        [self.webView loadRequest:request];
    }
    
//    NSRange urlSpace = [URLString rangeOfString:@" "];
//    NSString *urlNoSpace = [URLString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
//    
//    if (!URL.scheme) {
//        // The user didn't type http: or https:
//      
//        URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", URLString]];
//    }
//    
//    if (URL) {
//        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
//        [self.webView loadRequest:request];
//    }
////    NSRange urlSpace = [URLString rangeOfString:@" "];
////    NSString *urlNoSpace = [URLString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
//    if (urlSpace.location != NSNotFound) {
//        URL = [NSURL URLWithString:[NSString stringWithFormat:@"http//www.google.com/search?q=%@", urlNoSpace]];
//    }
    
    return NO;
}

#pragma mark - WKNavigationDelegate

-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [self updateButtonsAndTitle];
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self updateButtonsAndTitle];
}

-(void)webView:(WKWebView *)webView didfailProvisionalNavigation:(WKNavigation *) navigation withError:(NSError *)error {
    [self webView:webView didFailNavigation:navigation withError:error];
}
-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    if (error.code != NSURLErrorCancelled) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", @"Error")
                                                                       message: [error localizedDescription]
                                                                preferredStyle:UIAlertControllerStyleAlert];
                                    
                                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                                                       style:UIAlertActionStyleCancel handler:nil];
                                    
                                    [alert addAction:okAction];
                                    
                                    [self presentViewController:alert animated:YES completion:nil];
                                    
                                    
    }
    
    [self updateButtonsAndTitle];
}

#pragma mark - Miscellaneous

-(void) updateButtonsAndTitle {
    NSString *webpageTitle = [self.webView.title copy];
    if ([webpageTitle length]) {
        self.title =webpageTitle;
    }
    else
    {
        self.title = self.webView.URL.absoluteString;
    }
    
    if (self.webView.isLoading) {
        [self.activityIndicator startAnimating];
    }
    else
    {
        [self.activityIndicator stopAnimating];
    }
    
    [self.awesomeToolbar setEnabled:[self.webView canGoBack] forButtonWithTitle:kWebBrowserBackString];
    [self.awesomeToolbar setEnabled:[self.webView canGoForward] forButtonWithTitle:kWebBrowserForwardString];
    [self.awesomeToolbar setEnabled:[self.webView isLoading] forButtonWithTitle:kWebBrowserStopString];
    [self.awesomeToolbar setEnabled:![self.webView isLoading] && self.webView.URL forButtonWithTitle:kWebBrowserRefreshString];
}

@end
