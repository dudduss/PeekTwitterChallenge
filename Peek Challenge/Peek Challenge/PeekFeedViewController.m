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

@implementation PeekFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Peek Feed";
    
    //Add right bar button item for refresh
    //get rid of back button
    
//    [self getPeekTweets];
    
//    TWTRTweet *t = [[TWTRTweet alloc] initWithJSONDictionary:<#(NSDictionary *)#>
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.tableView.estimatedRowHeight = 150;
    self.tableView.rowHeight = UITableViewAutomaticDimension; // Explicitly set on iOS 8 if using automatic row height calculation
    self.tableView.allowsSelection = NO;
    [self.tableView registerClass:[TWTRTweetTableViewCell class] forCellReuseIdentifier:TweetTableReuseIdentifier];
    
    [self getPeekTweets];
    
    
    
//    TWTRAPIClient *APIClient = [[TWTRAPIClient alloc] init];
    
    
//    self.dataSource = [[TWTRSearchTimelineDataSource alloc] initWithSearchQuery:@"%40peek" APIClient:APIClient languageCode:@"en" maxTweetsPerRequest:40];
//    self.dataSource = [[TWTRSearchTimelineDataSource alloc] initWithSearchQuery:@"%40peek" APIClient:APIClient languageCode:(twtr_nullable "@en")];
    
//    self.dataSource = [[TWTRUserTimelineDataSource alloc] initWithScreenName:@"Peek" APIClient:APIClient];
//    self.dataSource = [[TWTRSearchTimelineDataSource alloc] initWithSearchQuery:@"%40peek" APIClient:APIClient];
    
    

}

-(void) getPeekTweets {
    
    TWTRAPIClient *client = [[TWTRAPIClient alloc] init];
    NSString *statusesShowEndpoint = @"https://api.twitter.com/1.1/search/tweets.json?q=%40peek";
    NSDictionary *params = @{@"count" : @"20",@"lang" : @"en" };

    NSError *clientError;
    
    NSURLRequest *request = [[[Twitter sharedInstance] APIClient] URLRequestWithMethod:@"GET" URL:statusesShowEndpoint parameters:params error:&clientError];
    
    if (request) {
        [client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (data) {
                // handle the response data e.g.
                
                [self.tweets removeAllObjects];
                
                NSError *jsonError;
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                
                NSArray *statuses = [json valueForKey:@"statuses"];
                
                self.tweets = [[NSMutableArray alloc]init];
                
                for (NSDictionary* status in statuses)
                {
                    TWTRTweet *tweet = [[TWTRTweet alloc] initWithJSONDictionary:status];
                    [self.tweets addObject:tweet];
                    
                }
                
                NSLog(@"tableView is '%@'",_tableView);
                [self.tableView reloadData];
                NSLog(@"count %lu", (unsigned long)self.tweets.count);
                
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
    
    
    
//    [cell setBackgroundColor:[UIColor lightGrayColor]];
    
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


@end
