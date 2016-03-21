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
static NSInteger * const numTweetsToDownload = 10;

@implementation PeekFeedViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.date = [NSDate date];
    self.date  = [self.date dateByAddingTimeInterval: 86400];
    
    self.title = @"Peek Feed";
    self.navigationItem.hidesBackButton = true;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0 green:0.675 blue:0.929 alpha:1];
//    self.navigationItem.backgroundColor = [
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];

   
    self.tweets = [[NSMutableArray alloc]init];
    self.deletedTweets = [[NSMutableArray alloc]init];
    
    
    //Add right bar button item for refresh
    //get rid of back button
    
//    [self getPeekTweets];
    _allHasLoaded  = false;
    
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.tableView.estimatedRowHeight = 150;
    self.tableView.rowHeight = UITableViewAutomaticDimension; // Explicitly set on iOS 8 if using automatic row height calculation
    self.tableView.allowsSelection = NO;
    [self.tableView registerClass:[TWTRTweetTableViewCell class] forCellReuseIdentifier:TweetTableReuseIdentifier];
    
    [self getPeekTweets: true];
    

    
    
//    TWTRAPIClient *APIClient = [[TWTRAPIClient alloc] init];
    
    
//    self.dataSource = [[TWTRSearchTimelineDataSource alloc] initWithSearchQuery:@"%40peek" APIClient:APIClient languageCode:@"en" maxTweetsPerRequest:40];
//    self.dataSource = [[TWTRSearchTimelineDataSource alloc] initWithSearchQuery:@"%40peek" APIClient:APIClient languageCode:(twtr_nullable "@en")];
    
//    self.dataSource = [[TWTRUserTimelineDataSource alloc] initWithScreenName:@"Peek" APIClient:APIClient];
//    self.dataSource = [[TWTRSearchTimelineDataSource alloc] initWithSearchQuery:@"%40peek" APIClient:APIClient];
    
    

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
    
    //Convert NSDate to String for API call
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *stringFromDate = [formatter stringFromDate:self.date];
    
    NSLog(stringFromDate);
    
    
//
    TWTRAPIClient *client = [[TWTRAPIClient alloc] init];
    NSString *statusesShowEndpoint = @"https://api.twitter.com/1.1/search/tweets.json?q=%40peek";
    

    
    NSDictionary *params = @{@"count" : [NSString stringWithFormat:@"%i", numTweetsToDownload],@"lang" : @"en", @"until": stringFromDate};

    NSError *clientError;
    
    NSURLRequest *request = [[[Twitter sharedInstance] APIClient] URLRequestWithMethod:@"GET" URL:statusesShowEndpoint parameters:params error:&clientError];
    
    if (request) {
        [client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (data) {
                // handle the response data e.g.
                
//                [self.tweets removeAllObjects];
                
                NSError *jsonError;
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                
                NSLog(@"After request: %@", json);
                
                NSArray *statuses = [json valueForKey:@"statuses"];
                
                if (refresh) {
                    [self.tweets removeAllObjects];
                }
                
                
                for (NSDictionary* status in statuses)
                {
                    TWTRTweet *tweet = [[TWTRTweet alloc] initWithJSONDictionary:status];
                    
                    if ([self.deletedTweets containsObject:tweet.tweetID] != true) {
                        [self.tweets addObject:tweet];
                    }
                    
                    if (status == [statuses lastObject]) {
                        self.date = tweet.createdAt;
//                        NSLog(tweet.tweetID);/
                    }
                    
                }
                
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd"];
                NSString *stringFromDate = [formatter stringFromDate:self.date];
                
                NSLog(@"After request: %@", stringFromDate);
                
                if (self.tweets.count > 0) {
                    
                    if (self.tweets.count < numTweetsToDownload) {
                        _allHasLoaded  = true;
                    }
                    
                    [self.tableView reloadData];
                }
            
                
//                NSLog(@"count %lu", (unsigned long)self.tweets.count);
                
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
        NSLog(@"only once");
        [self getPeekTweets :false];
        //[self.tableView reloadData];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return YES - we will be able to delete all rows
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Perform the real delete action here. Note: you may need to check editing style
    //   if you do not perform delete only.
    
    TWTRTweet *tweet = self.tweets[indexPath.row];
    [self.deletedTweets addObject:tweet.tweetID];
    
    [self.tweets removeObjectAtIndex:indexPath.row];
    [self.tableView reloadData];
    
    NSLog(@"Deleted row.");
}




@end
