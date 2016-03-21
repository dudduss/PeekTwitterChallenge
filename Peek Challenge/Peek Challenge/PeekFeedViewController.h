//
//  PeekFeedViewController.h
//  Peek Challenge
//
//  Created by Sampath Duddu on 3/20/16.
//  Copyright © 2016 dudduss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TwitterKit/TwitterKit.h>



@interface PeekFeedViewController : UIViewController  <UITableViewDelegate>

@property (nonatomic,retain) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *tweets;
@property (nonatomic, strong) NSMutableArray *deletedTweets;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, assign) NSString *lastTweetID;
@property (nonatomic, assign) BOOL allHasLoaded;



@end
