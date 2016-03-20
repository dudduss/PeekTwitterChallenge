//
//  PeekFeedViewController.h
//  Peek Challenge
//
//  Created by Sampath Duddu on 3/20/16.
//  Copyright © 2016 dudduss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TwitterKit/TwitterKit.h>

@interface PeekFeedViewController : UIViewController  <TWTRTweetViewDelegate>

@property (nonatomic,retain) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *tweets;


@end
