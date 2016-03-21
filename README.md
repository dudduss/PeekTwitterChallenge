# PeekTwitterChallenge

This challenge consisted of displaying all tweets with the mention of @Peek with pull to refresh and infinite scrolling capabilities. 


## How It Works

This app uses the Twitter Search API to find tweets with mention of @Peek. It loads a couple of tweets at first and as the user scrolls down, the next batch of tweets load. This is done by keeping track of the twitter id of the oldest tweet that was shown. 

To delete a tweet, a user simply swipes and clicks. The app keeps track of the twitter ids that have been deleted so when a user refreshes, the tweets that have been deleted will not show up again.

## Demo Video

See [Peek Twitter Demo] (https://youtu.be/NGriq5M4LlM)
