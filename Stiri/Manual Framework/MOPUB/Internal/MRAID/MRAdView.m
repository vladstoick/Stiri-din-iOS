//
//  MRAdView.m
//  MoPub
//
//  Created by Andrew He on 12/20/11.
//  Copyright (c) 2011 MoPub, Inc. All rights reserved.
//

#import "MRAdView.h"
#import "UIWebView+MPAdditions.h"
#import "MPGlobal.h"
#import "MPLogging.h"
#import "MRAdViewDisplayController.h"
#import "MRCommand.h"
#import "MRProperty.h"
#import "MPInstanceProvider.h"
#import "MRCalendarManager.h"
#import "MRJavaScriptEventEmitter.h"
#import "UIViewController+MPAdditions.h"
#import "MRBundleManager.h"

static NSString *const kExpandableCloseButtonImageName = @"MPCloseButtonX.png";
static NSString *const kMraidURLScheme = @"mraid";

@interface MRAdView ()

@property (nonatomic, retain) NSMutableData *data;
@property (nonatomic, retain) MPAdDestinationDisplayAgent *destinationDisplayAgent;
@property (nonatomic, retain) MRCalendarManager *calendarManager;
@property (nonatomic, retain) MRPictureManager *pictureManager;
@property (nonatomic, retain) MRVideoPlayerManager *videoPlayerManager;
@property (nonatomic, retain) MRJavaScriptEventEmitter *jsEventEmitter;

- (void)loadRequest:(NSURLRequest *)request;
- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL;

- (NSMutableString *)HTMLWithJavaScriptBridge:(NSString *)HTML;
- (BOOL)HTMLStringIsMRAIDFragment:(NSString *)string;
- (NSMutableString *)fullHTMLFromMRAIDFragment:(NSString *)fragment;
- (NSString *)MRAIDScriptPath;

- (void)layoutCloseButton;
- (void)initializeJavascriptState;

// Delegate callback methods wrapped with -respondsToSelector: checks.
- (void)adDidLoad;
- (void)adDidFailToLoad;
- (void)adWillClose;
- (void)adDidClose;
- (void)adDidRequestCustomCloseEnabled:(BOOL)enabled;
- (void)adWillExpandToFrame:(CGRect)frame;
- (void)adDidExpandToFrame:(CGRect)frame;
- (void)adWillPresentModalView;
- (void)adDidDismissModalView;
- (void)appShouldSuspend;
- (void)appShouldResume;
- (void)adViewableDidChange:(BOOL)viewable;

@end

@implementation MRAdView

@synthesize delegate = _delegate;
@synthesize usesCustomCloseButton = _usesCustomCloseButton;
@synthesize expanded = _expanded;
@synthesize data = _data;
@synthesize displayController = _displayController;
@synthesize destinationDisplayAgent = _destinationDisplayAgent;
@synthesize calendarManager = _calendarManager;
@synthesize pictureManager = _pictureManager;
@synthesize videoPlayerManager = _videoPlayerManager;
@synthesize jsEventEmitter = _jsEventEmitter;

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame
               allowsExpansion:YES
              closeButtonStyle:MRAdViewCloseButtonStyleAdControlled
                 placementType:MRAdViewPlacementTypeInline];
}

- (id)initWithFrame:(CGRect)frame allowsExpansion:(BOOL)expansion
   closeButtonStyle:(MRAdViewCloseButtonStyle)style placementType:(MRAdViewPlacementType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;

        _webView = [[[MPInstanceProvider sharedProvider] buildUIWebViewWithFrame:frame] retain];
        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                UIViewAutoresizingFlexibleHeight;
        _webView.backgroundColor = [UIColor clearColor];
        _webView.clipsToBounds = YES;
        _webView.delegate = self;
        _webView.opaque = NO;
        [_webView mp_setScrollable:NO];

        if ([_webView respondsToSelector:@selector(setAllowsInlineMediaPlayback:)]) {
            [_webView setAllowsInlineMediaPlayback:YES];
        }

        if ([_webView respondsToSelector:@selector(setMediaPlaybackRequiresUserAction:)]) {
            [_webView setMediaPlaybackRequiresUserAction:NO];
        }

        [self addSubview:_webView];

        _closeButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        _closeButton.frame = CGRectMake(0, 0, 50, 50);
        UIImage *image = [UIImage imageNamed:kExpandableCloseButtonImageName];
        [_closeButton setImage:image forState:UIControlStateNormal];

        _allowsExpansion = expansion;
        _closeButtonStyle = style;
        _placementType = type;

        _displayController = [[MRAdViewDisplayController alloc] initWithAdView:self
                                                               allowsExpansion:expansion
                                                              closeButtonStyle:style
                                                               jsEventEmitter:[[MPInstanceProvider sharedProvider] buildMRJavaScriptEventEmitterWithWebView:_webView]];

        [_closeButton addTarget:_displayController action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside];

        _destinationDisplayAgent = [[[MPInstanceProvider sharedProvider]
                                    buildMPAdDestinationDisplayAgentWithDelegate:self] retain];
        _calendarManager = [[[MPInstanceProvider sharedProvider]
                             buildMRCalendarManagerWithDelegate:self] retain];
        _pictureManager = [[[MPInstanceProvider sharedProvider]
                             buildMRPictureManagerWithDelegate:self] retain];
        _videoPlayerManager = [[[MPInstanceProvider sharedProvider]
                                buildMRVideoPlayerManagerWithDelegate:self] retain];
        _jsEventEmitter = [[[MPInstanceProvider sharedProvider]
                             buildMRJavaScriptEventEmitterWithWebView:_webView] retain];
    }
    return self;
}

- (void)dealloc
{
    _webView.delegate = nil;
    [_webView release];
    [_closeButton release];
    [_data release];
    [_displayController release];
    [_destinationDisplayAgent setDelegate:nil];
    [_destinationDisplayAgent release];
    [_calendarManager setDelegate:nil];
    [_calendarManager release];
    [_pictureManager setDelegate:nil];
    [_pictureManager release];
    [_videoPlayerManager setDelegate:nil];
    [_videoPlayerManager release];
    [_jsEventEmitter release];
    [super dealloc];
}

#pragma mark - Public

- (void)setDelegate:(id<MRAdViewDelegate>)delegate
{
    [_closeButton removeTarget:delegate
                        action:NULL
              forControlEvents:UIControlEventTouchUpInside];

    _delegate = delegate;

    [_closeButton addTarget:_delegate
                     action:@selector(closeButtonPressed)
           forControlEvents:UIControlEventTouchUpInside];
}

- (void)setExpanded:(BOOL)expanded
{
    _expanded = expanded;
    [self layoutCloseButton];
}

- (void)setUsesCustomCloseButton:(BOOL)shouldUseCustomCloseButton
{
    _usesCustomCloseButton = shouldUseCustomCloseButton;
    [self layoutCloseButton];
}

- (BOOL)isViewable
{
    return MPViewIsVisible(self);
}

- (void)loadCreativeFromURL:(NSURL *)url
{
    [_displayController revertViewToDefaultState];
    _isLoading = YES;
    [self loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)loadCreativeWithHTMLString:(NSString *)html baseURL:(NSURL *)url
{
    [_displayController revertViewToDefaultState];
    _isLoading = YES;
    [self loadHTMLString:html baseURL:url];
}

- (void)rotateToOrientation:(UIInterfaceOrientation)newOrientation
{
    [_displayController rotateToOrientation:newOrientation];
}

- (NSString *)placementType
{
    switch (_placementType) {
        case MRAdViewPlacementTypeInline:
            return @"inline";
        case MRAdViewPlacementTypeInterstitial:
            return @"interstitial";
        default:
            return @"unknown";
    }
}

- (void)handleMRAIDOpenCallForURL:(NSURL *)URL
{
    [self.destinationDisplayAgent displayDestinationForURL:URL];
}

#pragma mark - Private

- (void)loadRequest:(NSURLRequest *)request
{
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    if (connection) {
        self.data = [NSMutableData data];
    }
}

- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL
{
    // Bail out if we can't locate mraid.js.
    if (![self MRAIDScriptPath]) {
        [self adDidFailToLoad];
        return;
    }

    NSString *HTML = [self HTMLWithJavaScriptBridge:string];
    if (HTML) {
        [_webView loadHTMLString:HTML baseURL:baseURL];
    }
}

- (NSMutableString *)HTMLWithJavaScriptBridge:(NSString *)HTML
{
    NSMutableString *resultHTML = [[HTML mutableCopy] autorelease];

    if ([self HTMLStringIsMRAIDFragment:HTML]) {
        MPLogDebug(@"Fragment detected: converting to full payload.");
        resultHTML = [self fullHTMLFromMRAIDFragment:resultHTML];
    }

    NSURL *MRAIDScriptURL = [NSURL fileURLWithPath:[self MRAIDScriptPath]];

    NSRange headTagRange = [resultHTML rangeOfString:@"<head>"];
    NSString *MRAIDScriptTag = [NSString stringWithFormat:@"<script src='%@'></script>",
                                [MRAIDScriptURL absoluteString]];
    [resultHTML insertString:MRAIDScriptTag atIndex:headTagRange.location + headTagRange.length];

    return resultHTML;
}

- (BOOL)HTMLStringIsMRAIDFragment:(NSString *)string
{
    return ([string rangeOfString:@"<html>"].location == NSNotFound ||
            [string rangeOfString:@"<head>"].location == NSNotFound);
}

- (NSMutableString *)fullHTMLFromMRAIDFragment:(NSString *)fragment
{
    NSMutableString *result = [fragment mutableCopy];

    NSString *prepend = @"<html><head>"
        @"<meta name='viewport' content='user-scalable=no; initial-scale=1.0'/>"
        @"</head>"
        @"<body style='margin:0;padding:0;overflow:hidden;background:transparent;'>";
    [result insertString:prepend atIndex:0];
    [result appendString:@"</body></html>"];

    return [result autorelease];
}

- (NSString *)MRAIDScriptPath
{
    MRBundleManager *bundleManager = [[MPInstanceProvider sharedProvider] buildMRBundleManager];
    return [bundleManager mraidPath];
}

- (void)layoutCloseButton
{
    if (!_usesCustomCloseButton) {
        CGRect frame = _closeButton.frame;
        frame.origin.x = CGRectGetWidth(CGRectApplyAffineTransform(self.frame, self.transform)) -
                _closeButton.frame.size.width;
        _closeButton.frame = frame;
        _closeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:_closeButton];
        [self bringSubviewToFront:_closeButton];
    } else {
        [_closeButton removeFromSuperview];
    }
}

- (void)initializeJavascriptState
{
    MPLogDebug(@"Injecting initial JavaScript state.");
    [_displayController initializeJavascriptStateWithViewProperties:@[
            [MRPlacementTypeProperty propertyWithType:_placementType],
            [MRSupportsProperty defaultProperty]]];
}

- (void)handleCommandWithURL:(NSURL *)URL
{
    NSString *command = URL.host;
    NSDictionary *parameters = MPDictionaryFromQueryString(URL.query);
    BOOL success = YES;

    if ([command isEqualToString:@"createCalendarEvent"]) {
        [self.calendarManager createCalendarEventWithParameters:parameters];
    } else if ([command isEqualToString:@"playVideo"]) {
        [self.videoPlayerManager playVideo:parameters];
    } else if ([command isEqualToString:@"storePicture"]) {
        [self.pictureManager storePicture:parameters];
    } else {
        // TODO: Refactor legacy MRAID command handling.
        MRCommand *cmd = [MRCommand commandForString:command];
        cmd.parameters = parameters;
        cmd.view = self;
        success = [cmd execute];
    }

    [self.jsEventEmitter fireNativeCommandCompleteEvent:command];
    
    if (!success) {
        MPLogDebug(@"Unknown command: %@", command);
        [self.jsEventEmitter fireErrorEventForAction:command withMessage:@"Specified command is not implemented."];
    }
}


#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.data setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.data appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self adDidFailToLoad];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *str = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
    [self loadHTMLString:str baseURL:nil];
    [str release];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = [request URL];
    NSMutableString *urlString = [NSMutableString stringWithString:[url absoluteString]];
    NSString *scheme = url.scheme;

    if ([scheme isEqualToString:kMraidURLScheme]) {
        MPLogDebug(@"Trying to process command: %@", urlString);
        [self handleCommandWithURL:url];
        return NO;
    } else if ([scheme isEqualToString:@"mopub"]) {
        return NO;
    } else if ([scheme isEqualToString:@"ios-log"]) {
        [urlString replaceOccurrencesOfString:@"%20"
                                   withString:@" "
                                      options:NSLiteralSearch
                                        range:NSMakeRange(0, [urlString length])];
        MPLogDebug(@"Web console: %@", urlString);
        return NO;
    }

    if (!_isLoading && (navigationType == UIWebViewNavigationTypeOther ||
            navigationType == UIWebViewNavigationTypeLinkClicked)) {
        BOOL iframe = ![request.URL isEqual:request.mainDocumentURL];
        if (iframe) return YES;

        [self.destinationDisplayAgent displayDestinationForURL:url];
        return NO;
    }

    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (_isLoading) {
        _isLoading = NO;
        [self adDidLoad];
        [self initializeJavascriptState];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (error.code == NSURLErrorCancelled) return;
    _isLoading = NO;
    [self adDidFailToLoad];
}

#pragma mark - <MPAdDestinationDisplayAgentDelegate>

- (UIViewController *)viewControllerForPresentingModalView
{
    return [self.delegate viewControllerForPresentingModalView];
}

- (void)displayAgentWillPresentModal
{
    [self adWillPresentModalView];
}

- (void)displayAgentDidDismissModal
{
    [self adDidDismissModalView];
}

- (void)displayAgentWillLeaveApplication
{
    // Do nothing.
}

#pragma mark - <MRCalendarManagerDelegate>

- (void)calendarManager:(MRCalendarManager *)manager
        didFailToCreateCalendarEventWithErrorMessage:(NSString *)message
{
    [self.jsEventEmitter fireErrorEventForAction:@"createCalendarEvent"
                                      withMessage:message];
}

- (void)calendarManagerWillPresentCalendarEditor:(MRCalendarManager *)manager
{
    [self adWillPresentModalView];
}

- (void)calendarManagerDidDismissCalendarEditor:(MRCalendarManager *)manager
{
    [self adDidDismissModalView];
}

- (UIViewController *)viewControllerForPresentingCalendarEditor
{
    return [self viewControllerForPresentingModalView];
}

#pragma mark - <MRPictureManagerDelegate>

- (void)pictureManager:(MRPictureManager *)manager didFailToStorePictureWithErrorMessage:(NSString *)message
{
    [self.jsEventEmitter fireErrorEventForAction:@"storePicture"
                                     withMessage:message];
}

#pragma mark - <MRVideoPlayerManagerDelegate>

- (void)videoPlayerManager:(MRVideoPlayerManager *)manager didFailToPlayVideoWithErrorMessage:(NSString *)message
{
    [self.jsEventEmitter fireErrorEventForAction:@"playVideo"
                                     withMessage:message];
}

- (void)videoPlayerManagerWillPresentVideo:(MRVideoPlayerManager *)manager
{
    [self adWillPresentModalView];
}

- (void)videoPlayerManagerDidDismissVideo:(MRVideoPlayerManager *)manager
{
    [self adDidDismissModalView];
}

- (UIViewController *)viewControllerForPresentingVideoPlayer
{
    return [self viewControllerForPresentingModalView];
}

#pragma mark - Delegation Wrappers

- (void)adDidLoad
{
    if ([self.delegate respondsToSelector:@selector(adDidLoad:)]) {
        [self.delegate adDidLoad:self];
    }
}

- (void)adDidFailToLoad
{
    if ([self.delegate respondsToSelector:@selector(adDidFailToLoad:)]) {
        [self.delegate adDidFailToLoad:self];
    }
}

- (void)adWillClose
{
    if ([self.delegate respondsToSelector:@selector(adWillClose:)]) {
        [self.delegate adWillClose:self];
    }
}

- (void)adDidClose
{
    if ([self.delegate respondsToSelector:@selector(adDidClose:)]) {
        [self.delegate adDidClose:self];
    }
}

- (void)adWillExpandToFrame:(CGRect)frame
{
    if ([self.delegate respondsToSelector:@selector(willExpandAd:toFrame:)]) {
        [self.delegate willExpandAd:self toFrame:frame];
    }
}

- (void)adDidExpandToFrame:(CGRect)frame
{
    if ([self.delegate respondsToSelector:@selector(didExpandAd:toFrame:)]) {
        [self.delegate didExpandAd:self toFrame:frame];
    }
}

- (void)adDidRequestCustomCloseEnabled:(BOOL)enabled
{
    if ([self.delegate respondsToSelector:@selector(ad:didRequestCustomCloseEnabled:)]) {
        [self.delegate ad:self didRequestCustomCloseEnabled:enabled];
    }
}

- (void)adWillPresentModalView
{
    [_displayController additionalModalViewWillPresent];

    _modalViewCount++;
    if (_modalViewCount == 1) [self appShouldSuspend];
}

- (void)adDidDismissModalView
{
    [_displayController additionalModalViewDidDismiss];

    _modalViewCount--;
    if (_modalViewCount == 0) [self appShouldResume];
}

- (void)appShouldSuspend
{
    if ([self.delegate respondsToSelector:@selector(appShouldSuspendForAd:)]) {
        [self.delegate appShouldSuspendForAd:self];
    }
}

- (void)appShouldResume
{
    if ([self.delegate respondsToSelector:@selector(appShouldResumeFromAd:)]) {
        [self.delegate appShouldResumeFromAd:self];
    }
}

- (void)adViewableDidChange:(BOOL)viewable
{
    [self.jsEventEmitter fireChangeEventForProperty:[MRViewableProperty propertyWithViewable:viewable]];
}

@end
