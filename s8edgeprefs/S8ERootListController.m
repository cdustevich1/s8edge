#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#include "S8ERootListController.h"
#import <objc/runtime.h>
#import <spawn.h>
#import <rootless.h>

// Images ship inside S8EdgePrefs.bundle; load them from the bundle instead of
// a hard-coded /Library path so they work under the rootless /var/jb prefix.
static UIImage *S8EPrefsImage(NSString *name) {
    NSBundle *bundle = [NSBundle bundleForClass:objc_getClass("S8ERootListController")];
    return [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
}

@implementation S8ERootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}
	return _specifiers;
}

- (void)viewWillAppear:(BOOL)animated{
    //[super viewWillAppear:animated];
    /*self.view.tintColor = [UIColor redColor];
    self.navigationController.navigationBar.tintColor = [UIColor redColor];*/
    [UISegmentedControl appearanceWhenContainedInInstancesOfClasses:@[self.class]].tintColor = [UIColor colorWithRed: 0.0/255.0 green: 0.0/255.0 blue: 0.0/255.0 alpha: 1.0];
    [[UISwitch appearanceWhenContainedInInstancesOfClasses:@[self.class]] setOnTintColor:[UIColor colorWithRed: 0.0/255.0 green: 0.0/255.0 blue: 0.0/255.0 alpha: 1.0]];
		//[[UIButton appearanceWhenContainedIn:self.class, nil] setOnTintColor:[UIColor colorWithRed: 0.0/255.0 green: 0.0/255.0 blue: 0.0/255.0 alpha: 1.0]];
    [super viewWillAppear:animated];

		UIBarButtonItem *respringButton = [[UIBarButtonItem alloc]
							   initWithTitle:@"Respring"
							   style:UIBarButtonItemStylePlain
                               target:self
                               action:@selector(respring)];

		self.navigationItem.rightBarButtonItem = respringButton;

		[respringButton release];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    settingsView = self.view.window;
    settingsView.tintColor = [UIColor whiteColor];
    self.navigationController.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.navigationController.navigationController.navigationBar.barTintColor = [UIColor colorWithRed: 0.0/255.0 green: 0.0/255.0 blue: 0.0/255.0 alpha: 0.5];
    // -[UIApplication setStatusBarStyle:] is a no-op on iOS 15+ (view-controller-based status bar), so it was removed.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    settingsView.tintColor = nil;
    self.navigationController.navigationController.navigationBar.titleTextAttributes = nil;
    self.navigationController.navigationController.navigationBar.barTintColor = nil;
    //SprevStatusStyle = [[UIApplication sharedApplication] statusBarStyle];
    //self.view.tintColor = nil;
    //self.view.navigationController.navigationBar.tintColor = nil;
}

-(void)respring {
    pid_t pid;
    const char* args[] = {"killall", "backboardd", NULL};
    // ROOT_PATH adds the rootless /var/jb prefix.
    posix_spawn(&pid, ROOT_PATH("/usr/bin/killall"), NULL, NULL, (char* const*)args, NULL);
    //system("killall -HUP backboardd");
    //[[objc_getClass("FBSystemService") sharedInstance] exitAndRelaunch:YES];
    //[[%c(FBSystemService) sharedInstance] exitAndRelaunch:YES];
    //[[FBSystemService sharedInstance] exitAndRelaunch:YES];

}

-(void)paypal {

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=RSSPVLYEBZTTY"] options:@{} completionHandler:nil];

}

-(void)creator {

    CGRect screenRect = [[UIScreen mainScreen] bounds];
    NSDate *currentDate = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:currentDate];
    int age = (int)([components year] - 1995);

    self.view.backgroundColor = [UIColor clearColor];

    //UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    //UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    /*UIView *blurEffectView = [UIView alloc];
    blurEffectView.backgroundColor = [UIColor whiteColor];
    blurEffectView.frame = self.view.bounds;
    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    blurEffectView.tag = 12345;
    blurEffectView.layer.zPosition = MAXFLOAT;
    [blurEffectView setAlpha:0.0];*/

    blurEffectView = [[UIView alloc] initWithFrame:screenRect];
    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    blurEffectView.layer.zPosition = MAXFLOAT;
    blurEffectView.backgroundColor = [UIColor clearColor];
    blurEffectView.tag = 12345;
    [blurEffectView setAlpha:0.0];

    back=[[objc_getClass("_UIBackdropView") alloc] initWithStyle:0];
  	//[backgroundView2 setAutosizesToFitSuperview:NO];
    back.tag = 123456;
  	[back setFrame:screenRect];
  	[back setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [back setAlpha:0.0];
    [blurEffectView addSubview:back];

    //start image
    basePic = [[UIImageView alloc] init];
    [basePic setImage:S8EPrefsImage(@"FotoBrunoApp")];
    basePic.frame = CGRectMake (blurEffectView.frame.size.width/2 - 90/2, blurEffectView.frame.size.height-490, 90, 90);
    [blurEffectView addSubview:basePic];
    [basePic release];
    //end image

    //start label
    CGRect creatorTitleFrame = CGRectMake(blurEffectView.frame.size.width/2 - 250/2, 85, 250, 60);
    CGRect creatorSubtitleFrame = CGRectMake(blurEffectView.frame.size.width/2 - 350/2, 125, 350, 60);
    CGRect brunoAndradeFrame = CGRectMake(blurEffectView.frame.size.width/2 - 250/2, blurEffectView.frame.size.height-405, 250, 60);
    CGRect brunoAndradeDescriptionFrame = CGRectMake(blurEffectView.frame.size.width/2 - 250/2, blurEffectView.frame.size.height-355, 250, 150);
    //CGRect randFrame = CGRectMake(0, 40, width, 60);

    creatorTitle = [[UILabel alloc] initWithFrame:creatorTitleFrame];
    [creatorTitle setNumberOfLines:1];
    creatorTitle.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:48];
    [creatorTitle setText:@"The Creators"];
    [creatorTitle setBackgroundColor:[UIColor clearColor]];
    creatorTitle.textColor = [UIColor blackColor];
    creatorTitle.textAlignment = NSTextAlignmentCenter;

    creatorSubtitle = [[UILabel alloc] initWithFrame:creatorSubtitleFrame];
    [creatorSubtitle setNumberOfLines:1];
    creatorSubtitle.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    [creatorSubtitle setText:@"After all somebody had to do the dirty work..."];
    [creatorSubtitle setBackgroundColor:[UIColor clearColor]];
    creatorSubtitle.textColor = [UIColor grayColor];
    creatorSubtitle.textAlignment = NSTextAlignmentCenter;

    brunoAndrade = [[UILabel alloc] initWithFrame:brunoAndradeFrame];
    [brunoAndrade setNumberOfLines:1];
    brunoAndrade.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:30];
    [brunoAndrade setText:@"Bruno Andrade"];
    [brunoAndrade setBackgroundColor:[UIColor clearColor]];
    brunoAndrade.textColor = [UIColor blackColor];
    brunoAndrade.textAlignment = NSTextAlignmentCenter;

    brunoAndradeDescription = [[UILabel alloc] initWithFrame:brunoAndradeDescriptionFrame];
    [brunoAndradeDescription setNumberOfLines:9];
    brunoAndradeDescription.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    [brunoAndradeDescription setText:[NSString stringWithFormat:@"I'm %d, Mechatronic Engineer\nwho likes coding a lot and make tweaks\nin my free time. This is also my\nthird public tweak, enjoy!\nFind me on reddit: /u/BrunoNFL", age]];
    [brunoAndradeDescription setBackgroundColor:[UIColor clearColor]];
    brunoAndradeDescription.textColor = [UIColor grayColor];
    brunoAndradeDescription.textAlignment = NSTextAlignmentCenter;

    [blurEffectView addSubview:creatorTitle];
    [blurEffectView addSubview:creatorSubtitle];
    [blurEffectView addSubview:brunoAndrade];
    [blurEffectView addSubview:brunoAndradeDescription];
    //end label



    UIButton *but= [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [but addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [but setFrame:CGRectMake(blurEffectView.frame.size.width/2 - 70/2, blurEffectView.frame.size.height-100, 70, 70)];
    but.layer.cornerRadius = 35;
    but.layer.borderWidth =1.0;
    but.layer.borderColor = [UIColor grayColor].CGColor;
    [but setTitle:@"Dismiss" forState:UIControlStateNormal];
    [but setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [but setExclusiveTouch:YES];
    [blurEffectView addSubview:but];
    // if you like to add backgroundImage else no need
    //[but setbackgroundImage:[UIImage imageNamed:@"XXX.png"] forState:UIControlStateNormal];

    [self.view addSubview:blurEffectView];
    [UIView animateWithDuration:0.3 animations:^{
        [blurEffectView setAlpha:1.0];
        [back setAlpha:1.0];
    }];


    //} else {
    //  self.view.backgroundColor = [UIColor blackColor];
    //}
}

-(void)dismiss {
    [UIView animateWithDuration:0.3 animations:^{
        [[self.view viewWithTag:12345] setAlpha:0.0];
        [[self.view viewWithTag:123456] setAlpha:0.0];
    } completion:^(BOOL finished) {
        [self finshedFadeOut];
    }];
}

-(void)finshedFadeOut{
    [[self.view viewWithTag:12345] removeFromSuperview];
    [[self.view viewWithTag:123456] removeFromSuperview];
}
@end

@implementation S8EdgeCustomCell
- (id)initWithSpecifier:(PSSpecifier *)specifier
{
    int width = [[UIScreen mainScreen] bounds].size.width;

    UILabel *_label;
    UILabel *underLabel;
    //UILabel *randLabel;

    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    CGRect frame = CGRectMake(width/2-55, -15, 165, 60);
    CGRect picFrame = CGRectMake(width/2-110, -10, 50, 50);
    CGRect botFrame = CGRectMake(0, 20, width, 60);
    //CGRect randFrame = CGRectMake(0, 40, width, 60);

    UIImageView *basePic = [[UIImageView alloc] init];
    [basePic setImage:S8EPrefsImage(@"S8Edge")];
    basePic.frame = picFrame;

    _label = [[UILabel alloc] initWithFrame:frame];
    [_label setNumberOfLines:1];
    _label.font = [UIFont systemFontOfSize:48 weight:UIFontWeightUltraLight];//[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:48];
    [_label setText:@"S8Edge"];
    [_label setBackgroundColor:[UIColor clearColor]];
    _label.textColor = [UIColor blackColor];
    //[_label setShadowColor:[UIColor blackColor]];
    //[_label setShadowOffset:CGSizeMake(1,1)];
    _label.textAlignment = NSTextAlignmentCenter;

    underLabel = [[UILabel alloc] initWithFrame:botFrame];
    [underLabel setNumberOfLines:1];
    underLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    [underLabel setText:@"That unique feeling..."];
    [underLabel setBackgroundColor:[UIColor clearColor]];
    underLabel.textColor = [UIColor grayColor];
    underLabel.textAlignment = NSTextAlignmentCenter;

    [self addSubview:basePic];
    [self addSubview:_label];
    [self addSubview:underLabel];
    [basePic release];
    //[self addSubview:randLabel];

    return self;

}
@end
