//
//  ViewController.m
//  Peek Challenge
//
//  Created by Sampath Duddu on 3/20/16.
//  Copyright © 2016 dudduss. All rights reserved.
//

#import "ViewController.h"
#import <TwitterKit/TwitterKit.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    // Objective-C
    TWTRLogInButton* logInButton = [TWTRLogInButton buttonWithLogInCompletion:^(TWTRSession* session, NSError* error) {
        if (session) {
            NSLog(@"signed in as %@", [session userName]);
        } else {
            NSLog(@"error: %@", [error localizedDescription]);
        }
    }];
    logInButton.center = self.view.center;
    [self.view addSubview:logInButton];
    
    [logInButton addTarget:self
                 action:@selector(twitterLogin)
       forControlEvents:UIControlEventTouchUpInside];
//
//    // Objective-C
    TWTRSessionStore *store = [[Twitter sharedInstance] sessionStore];
    
    TWTRSession *lastSession = store.session;
    
    if (lastSession) {
        [self performSegueWithIdentifier:@"toPeekFeed" sender:self];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        
        NSLog(@"signed in as %@", [lastSession userName]);
        return;
        
    }
//

}

-(void)twitterLogin {
    


    [[Twitter sharedInstance] logInWithCompletion:^(TWTRSession *session, NSError *error) {
        if (session) {
            [self performSegueWithIdentifier:@"toPeekFeed" sender:self];
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
            
            NSLog(@"signed in as %@", [session userName]);
        } else {
            NSLog(@"error: %@", [error localizedDescription]);
        }
    }];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
