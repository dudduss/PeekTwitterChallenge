//
//  PeekFeedViewController.m
//  Peek Challenge
//
//  Created by Sampath Duddu on 3/20/16.
//  Copyright © 2016 dudduss. All rights reserved.
//

#import "PeekFeedViewController.h"
#import <TwitterKit/TwitterKit.h>

static NSString * const TweetTableReuseIdentifier = @"TweetCell";
static NSInteger * const numTweetsToDownload = 5;

@implementation PeekFeedViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.date = [NSDate date];
    self.date  = [self.date dateByAddingTimeInterval: 86400];
    self.tweets = [[NSMutableArray alloc]init];
    self.deletedTweets = [[NSMutableArray alloc]init];
    _allHasLoaded  = false;
    
    //Setting nav bar characteristics
    self.title = @"@Peek";
    self.navigationItem.hidesBackButton = true;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0 green:0.675 blue:0.929 alpha:1];
    
    //Setting refresh control characteristics
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];

    //Setting table view characteristics
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.tableView.estimatedRowHeight = 150;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.allowsSelection = NO;
    [self.tableView registerClass:[TWTRTweetTableViewCell class] forCellReuseIdentifier:TweetTableReuseIdentifier];
    
    //Function to get tweets
    [self getPeekTweets: true];

}

-(void) getPeekTweets:(bool*)refresh {
    
    if (refresh) {
        self.date = [NSDate date];
        self.date  = [self.date dateByAddingTimeInterval: 86400];
        _allHasLoaded = false;
    } else {
        if (_allHasLoaded) {
            return;
        }
    }
    
    TWTRAPIClient *client = [[TWTRAPIClient alloc] init];
    NSString *statusesShowEndpoint = @"https://api.twitter.com/1.1/search/tweets.json?q=%40peek";

    NSMutableDictionary *params=[[NSMutableDictionary alloc]init];

    [params setValue:[NSString stringWithFormat:@"%i", numTweetsToDownload] forKey:@"count"];
    [params setValue:@"en" forKey:@"lang"];
    
    if (!refresh) {
        [params setValue:self.lastTweetID forKey:@"max_id"];
    }

    NSError *clientError;
    
    NSURLRequest *request = [[[Twitter sharedInstance] APIClient] URLRequestWithMethod:@"GET" URL:statusesShowEndpoint parameters:params error:&clientError];
    
    if (request) {
        [client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (data) {

                NSError *jsonError;
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                
//                NSLog(@"JSON: %@", json);
                
                NSArray *statuses = [json valueForKey:@"statuses"];
                
                if (refresh) {
                    [self.tweets removeAllObjects];
                } else {
                    [self.tweets removeLastObject];
                }
                
                
                for (NSDictionary* status in statuses)
                {
                    TWTRTweet *tweet = [[TWTRTweet alloc] initWithJSONDictionary:status];
                    
                    if ([self.deletedTweets containsObject:tweet.tweetID] != true) {
                        [self.tweets addObject:tweet];
                    }
                    
                    if (status == [statuses lastObject]) {
                        self.date = tweet.createdAt;
                        self.lastTweetID = tweet.tweetID;
                    }
                    
                }
                
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd"];
                NSString *stringFromDate = [formatter stringFromDate:self.date];
                
                if (self.tweets.count > 0) {

                    if (statuses.count < numTweetsToDownload) {
                        _allHasLoaded  = true;
                    }
                    
                    [self.tableView reloadData];
                }
                
            }
            else {
                NSLog(@"Connection Error: %@", connectionError);
            }
        }];
    }
    else {
        NSLog(@"Client Error: %@", clientError);
    }
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tweets count];
}

- (TWTRTweetTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.tableView = tableView ;
    
    TWTRTweet *tweet = self.tweets[indexPath.row];
    
    TWTRTweetTableViewCell *cell = (TWTRTweetTableViewCell *) [tableView dequeueReusableCellWithIdentifier:TweetTableReuseIdentifier forIndexPath:indexPath];
    [cell configureWithTweet:tweet];
    cell.tweetView.delegate = self;

    //Alternating between yellow and white
    [cell.tweetView setBackgroundColor:([indexPath row]%2)?[UIColor colorWithRed:0.961 green:0.929 blue:0.078 alpha:1]:[UIColor whiteColor]];
    
    
    return cell;
}

// Calculate the height of each row
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    TWTRTweet *tweet = self.tweets[indexPath.row];
    
    return [TWTRTweetTableViewCell heightForTweet:tweet width:CGRectGetWidth(self.view.bounds)];
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = ([indexPath row]%2)?[UIColor blueColor]:[UIColor whiteColor];
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    // Do your job, when done:
    [self getPeekTweets: true];
    [refreshControl endRefreshing];
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate {
    CGFloat actualPosition = scrollView.contentOffset.y;
    CGFloat contentHeight = scrollView.contentSize.height - (self.tableView.frame.size.height);
    if (actualPosition >= contentHeight) {
        // fetch resources
        
        if (_allHasLoaded) {
            return;
        }
        
        //Each time you scroll down, fetch the next set of tweets
        [self getPeekTweets :false];
        
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return YES - we will be able to delete all rows
    return YES;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"Slected row.");
    
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
    {
        // Delete something here
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Delete Tweet"
                                              message:@"Are you sure you want to delete this tweet from your feed?"
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction *action)
                                       {
                                           NSLog(@"Cancel action");
                                       }];
        
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Yes", @"OK action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       TWTRTweet *tweet = self.tweets[indexPath.row];
                                       [self.deletedTweets addObject:tweet.tweetID];
                                       
                                       [self.tweets removeObjectAtIndex:indexPath.row];
                                       [self.tableView reloadData];
                                       
                                       NSLog(@"Deleted row.");
                                   }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        
        [self presentViewController:alertController animated:YES completion:nil];

    }];
    
    UITableViewRowAction *retweet = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Retweet" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
    {
        TWTRTweet *tweet = self.tweets[indexPath.row];
        [self retweetTweet :tweet.tweetID];
        
    }];
    
    delete.backgroundColor = [UIColor redColor];
    retweet.backgroundColor = [UIColor colorWithRed:0 green:0.675 blue:0.929 alpha:1];
    
    return @[delete];
}

// Code for retweeting a tweet.
-(void) retweetTweet:(NSString*)tweetID {
    
    TWTRAPIClient *client = [[TWTRAPIClient alloc] init];
    NSString *statusesShowEndpoint =[NSString stringWithFormat:@"https://api.twitter.com/1.1/statuses/retweet/%@.json", tweetID];
    
    NSError *clientError;
    
    NSURLRequest *request = [[[Twitter sharedInstance] APIClient] URLRequestWithMethod:@"POST" URL:statusesShowEndpoint parameters:NULL error:&clientError];

    
    if (request) {
        [client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (data) {
                
                NSLog(@"success");
            }
        }];
    } else {
        NSLog(@"Client Error: %@", clientError);
    }
}

@end
