#import "CustoWindow.h"

// S8Edge — Galaxy S8 "Infinity" look for iOS (rootless, iOS 15+).
//
// iOS 16 moved SpringBoard to scene-based windows (SBWindowScene). A window
// created with -initWithFrame: and no scene is never shown there, so the
// overlay window is now created with -initWithWindowScene: on the main
// display's scene. If that scene hasn't connected yet when SpringBoard
// finishes launching, we wait for it via UIScene notifications.

#define S8E_PREFS_DOMAIN @"com.cdustevich1.s8edgeprefs"
#define S8E_PREFS_PATH   @"/var/mobile/Library/Preferences/com.cdustevich1.s8edgeprefs.plist"

// Debug logging. View in Console.app (filter "S8Edge"). Set to 0 to silence.
#define S8E_DEBUG 0
#if S8E_DEBUG
#define S8ELog(fmt, ...) NSLog(@"[S8Edge] " fmt, ##__VA_ARGS__)
#else
#define S8ELog(fmt, ...)
#endif

// Very high so the overlay sits above SpringBoard's own windows (lock screen,
// Control Center, banners, alerts). The pre-1.3 value was 5555555555555.
static const UIWindowLevel kS8EWindowLevel = 10000000.0;

#pragma mark - Preferences

static BOOL   tweakEnabled         = YES;
static BOOL   enableRoundedCorners = YES;
static BOOL   enableEdgeOverlay    = YES;
static BOOL   whitePhone           = NO;
static double cornerRadius         = 24.0; // matches Root.plist default
static double overlayOpacity       = 0.2;  // Root.plist default 20 (%)

static void S8ELoadPrefs(void) {
  // Prefer cfprefsd (always current), fall back to reading the plist directly.
  NSDictionary *prefs = nil;
  CFArrayRef keyList = CFPreferencesCopyKeyList((CFStringRef)S8E_PREFS_DOMAIN, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
  if (keyList) {
    CFDictionaryRef dict = CFPreferencesCopyMultiple(keyList, (CFStringRef)S8E_PREFS_DOMAIN, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    if (dict) prefs = [(NSDictionary *)dict autorelease];
    CFRelease(keyList);
  }
  if (prefs.count == 0) prefs = [NSDictionary dictionaryWithContentsOfFile:S8E_PREFS_PATH];

  id v;
  v = [prefs objectForKey:@"Status"];               tweakEnabled         = v ? [v boolValue] : YES;
  v = [prefs objectForKey:@"enableRoundedCorners"]; enableRoundedCorners = v ? [v boolValue] : YES;
  v = [prefs objectForKey:@"enableEdgeOverlay"];    enableEdgeOverlay    = v ? [v boolValue] : YES;
  v = [prefs objectForKey:@"whitePhone"];           whitePhone           = v ? [v boolValue] : NO;
  v = [prefs objectForKey:@"sliderRadius"];         cornerRadius         = v ? [v doubleValue] : 24.0;
  v = [prefs objectForKey:@"sliderOpacity"];        overlayOpacity       = v ? ([v doubleValue] / 100.0) : 0.2;

  S8ELog(@"prefs: enabled=%d corners=%d radius=%.1f white=%d edges=%d opacity=%.2f",
         tweakEnabled, enableRoundedCorners, cornerRadius, whitePhone, enableEdgeOverlay, overlayOpacity);
}

#pragma mark - Overlay view controller

// Transparent root view controller that hosts the corner mask and edge glow.
// Locked to portrait so the glow stays on the physical long edges of the
// phone, like the original tweak.
@interface S8EOverlayViewController : UIViewController {
  UIView *edgeView;
  CAGradientLayer *leftGradient;
  CAGradientLayer *rightGradient;
  UIView *cornerView;
  CAShapeLayer *cornerMask;
}
@end

@implementation S8EOverlayViewController

- (void)loadView {
  UIView *root = [[UIView alloc] initWithFrame:CGRectZero];
  root.backgroundColor = [UIColor clearColor];
  root.userInteractionEnabled = NO;
  self.view = root;
  [root release];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  // Edge overlay: white -> clear gradients on ~5% of each side.
  if (enableEdgeOverlay) {
    edgeView = [[UIView alloc] initWithFrame:self.view.bounds];
    edgeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    edgeView.backgroundColor = [UIColor clearColor];
    edgeView.userInteractionEnabled = NO;
    edgeView.alpha = overlayOpacity;

    NSArray *colors = @[(id)[UIColor whiteColor].CGColor, (id)[UIColor clearColor].CGColor];

    leftGradient = [[CAGradientLayer layer] retain];
    leftGradient.colors = colors;
    leftGradient.startPoint = CGPointMake(0.0, 0.5);
    leftGradient.endPoint = CGPointMake(0.05, 0.5);

    rightGradient = [[CAGradientLayer layer] retain];
    rightGradient.colors = colors;
    rightGradient.startPoint = CGPointMake(1.0, 0.5);
    rightGradient.endPoint = CGPointMake(0.95, 0.5);

    [edgeView.layer addSublayer:leftGradient];
    [edgeView.layer addSublayer:rightGradient];
    [self.view addSubview:edgeView];
  }

  // Rounded corners: solid black/white view, masked so only the corners
  // (full rect minus rounded rect, even-odd fill) stay visible.
  if (enableRoundedCorners) {
    cornerView = [[UIView alloc] initWithFrame:self.view.bounds];
    cornerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    cornerView.userInteractionEnabled = NO;
    cornerView.backgroundColor = whitePhone ? [UIColor whiteColor] : [UIColor blackColor];

    cornerMask = [[CAShapeLayer layer] retain];
    cornerMask.fillColor = [UIColor blackColor].CGColor;
    cornerMask.fillRule = kCAFillRuleEvenOdd;
    cornerView.layer.mask = cornerMask;

    [self.view addSubview:cornerView];
  }
}

// Recompute layer frames and the mask path whenever the size changes.
- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  CGRect bounds = self.view.bounds;

  [CATransaction begin];
  [CATransaction setDisableActions:YES];
  if (edgeView) {
    leftGradient.frame = edgeView.bounds;
    rightGradient.frame = edgeView.bounds;
  }
  if (cornerView) {
    cornerMask.frame = cornerView.bounds;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:bounds cornerRadius:cornerRadius];
    [path appendPath:[UIBezierPath bezierPathWithRect:bounds]];
    cornerMask.path = path.CGPath;
  }
  [CATransaction commit];
}

- (BOOL)shouldAutorotate {
  return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskPortrait;
}

- (void)dealloc {
  [edgeView release];
  [leftGradient release];
  [rightGradient release];
  [cornerView release];
  [cornerMask release];
  [super dealloc];
}

@end

#pragma mark - Window management

@interface s8EdgeUI : NSObject {
  CustoWindow *s8EdgeWindow;
  BOOL observingScenes;
}
- (void)initializeS8EdgeWindow;
@end

@implementation s8EdgeUI

// The UIWindowScene for the built-in display. Prefers SpringBoard's own
// SBWindowScene (iOS 16+); falls back to any window scene on the main screen.
static UIWindowScene *S8EFindMainWindowScene(void) {
  Class sbWindowSceneClass = NSClassFromString(@"SBWindowScene");
  UIWindowScene *fallback = nil;
  for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
    if (![scene isKindOfClass:[UIWindowScene class]]) continue;
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    if (windowScene.screen != [UIScreen mainScreen]) continue;
    if (sbWindowSceneClass && [windowScene isKindOfClass:sbWindowSceneClass]) return windowScene;
    if (!fallback) fallback = windowScene;
  }
  return fallback;
}

static void S8ELogScenes(NSString *when) {
#if S8E_DEBUG
  NSSet *scenes = [UIApplication sharedApplication].connectedScenes;
  S8ELog(@"%@: %lu connected scene(s)", when, (unsigned long)scenes.count);
  for (UIScene *scene in scenes) {
    NSString *screenInfo = @"";
    if ([scene isKindOfClass:[UIWindowScene class]]) {
      UIWindowScene *ws = (UIWindowScene *)scene;
      screenInfo = [NSString stringWithFormat:@" mainScreen=%d", ws.screen == [UIScreen mainScreen]];
    }
    S8ELog(@"  - %@ <%p> state=%ld%@", NSStringFromClass([scene class]), scene, (long)scene.activationState, screenInfo);
  }
#endif
}

- (void)initializeS8EdgeWindow {
  S8ELoadPrefs();
  if (!tweakEnabled) {
    S8ELog(@"disabled in settings; not creating overlay");
    return;
  }
  if (!enableRoundedCorners && !enableEdgeOverlay) {
    S8ELog(@"corners and edges both off; not creating overlay");
    return;
  }

  S8ELogScenes(@"applicationDidFinishLaunching");
  if (![self tryCreateWindow]) {
    S8ELog(@"main window scene not available yet; waiting for it to connect");
    [self startObservingScenes];
  }

#if S8E_DEBUG
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    S8ELogScenes(@"+2s");
    [self logWindowState:@"+2s"];
  });
#endif
}

// Creates the overlay if it doesn't exist and the main scene is available.
// Returns YES if the overlay exists afterwards.
- (BOOL)tryCreateWindow {
  if (s8EdgeWindow) return YES;

  UIWindowScene *scene = S8EFindMainWindowScene();
  if (!scene) {
    if (@available(iOS 16.0, *)) {
      return NO; // Must wait for the SBWindowScene.
    }
    // iOS 15: SpringBoard may not expose a window scene; a screen-based
    // window still renders there.
    S8ELog(@"no window scene on iOS 15; using screen-based window");
    s8EdgeWindow = [[CustoWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  } else {
    s8EdgeWindow = [[CustoWindow alloc] initWithWindowScene:scene];
    s8EdgeWindow.frame = scene.coordinateSpace.bounds;
  }

  if ([s8EdgeWindow respondsToSelector:@selector(_setSecure:)]) [s8EdgeWindow _setSecure:YES];
  s8EdgeWindow.windowLevel = kS8EWindowLevel;
  s8EdgeWindow.backgroundColor = [UIColor clearColor];
  s8EdgeWindow.userInteractionEnabled = NO;

  S8EOverlayViewController *overlay = [[S8EOverlayViewController alloc] init];
  s8EdgeWindow.rootViewController = overlay;
  [overlay release];

  // Show without making it key, so SpringBoard keeps keyboard focus.
  s8EdgeWindow.hidden = NO;

  [self logWindowState:@"created"];
  return YES;
}

- (void)destroyWindow {
  if (!s8EdgeWindow) return;
  s8EdgeWindow.hidden = YES;
  [s8EdgeWindow release];
  s8EdgeWindow = nil;
}

- (void)logWindowState:(NSString *)when {
  if (!s8EdgeWindow) {
    S8ELog(@"%@: no overlay window", when);
    return;
  }
  UIWindowScene *scene = s8EdgeWindow.windowScene;
  S8ELog(@"%@: window=%p scene=%@ <%p> hidden=%d level=%.0f frame=%@",
         when, s8EdgeWindow, scene ? NSStringFromClass([scene class]) : @"(nil)", scene,
         s8EdgeWindow.hidden, s8EdgeWindow.windowLevel, NSStringFromCGRect(s8EdgeWindow.frame));
}

#pragma mark Scene notifications

- (void)startObservingScenes {
  if (observingScenes) return;
  observingScenes = YES;
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc addObserver:self selector:@selector(sceneDidChange:) name:UISceneWillConnectNotification object:nil];
  [nc addObserver:self selector:@selector(sceneDidChange:) name:UISceneDidActivateNotification object:nil];
  [nc addObserver:self selector:@selector(sceneDidDisconnect:) name:UISceneDidDisconnectNotification object:nil];
}

- (void)sceneDidChange:(NSNotification *)note {
  if (s8EdgeWindow) return;
  S8ELog(@"scene event %@ from %@", note.name, NSStringFromClass([note.object class]));
  // Let the scene finish connecting before attaching a window to it.
  dispatch_async(dispatch_get_main_queue(), ^{
    [self tryCreateWindow];
  });
}

- (void)sceneDidDisconnect:(NSNotification *)note {
  if (s8EdgeWindow && s8EdgeWindow.windowScene == note.object) {
    S8ELog(@"overlay's scene disconnected; waiting for a new one");
    [self destroyWindow];
  }
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [self destroyWindow];
  [super dealloc];
}

@end

#pragma mark - Hooks

static s8EdgeUI *s8EdgeUIvar;

%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)arg1
{
  %orig();
  S8ELog(@"loaded into SpringBoard (iOS %@)", [UIDevice currentDevice].systemVersion);
  s8EdgeUIvar = [[s8EdgeUI alloc] init];
  [s8EdgeUIvar initializeS8EdgeWindow];
}
%end
