
# Sentiment analysis of tweets about Schitt's Creek

**Summary**: The goal of this project is to offer a dashboard for Social Media managers to analyse the tweets related to a specific brand in order to gain insights on people's engagement with the brand. They want to determine what and how much tweeters are talking about and how they feel about it. This example uses data related to Schitt's Creek.

The Shiny app display three main panels: 
- daily report: select a day to review daily engagement stats (number of tweets, percent positive sentiment, number of retweets and number of favorites) and word cloud,
- weekly engagement: tweet number and sentiment over the week, as well as words in tweets generating the most retweets and favorites.
- topic explorer: select a topic / keyword to examine its daily usage, engagement stats and related tweets.

**Insights**: 12,251 tweets (05 to 11 October) were collected via API call and analysed. 

- The proportion of positive and negative tweets is consistant from day to day, with approximately 2/3 of tweets expressing a positive sentiment.
- The number of tweets was between 689 and 804 per day, except for October 7: that day saw a peak at 1098.
- However, the highest retweet rate was seen on October 5 at 1.01. This is related to a tweet that was retweeted 653 times about the Lovecraft Country cast deserving as many Emmy's at the Schitt's Creek one.
oct 6: 22%
oct 11: 48%
oct 7: 55%
oct 5: 1.01
oct 8: 0.36
oct 9: 0.45%
oct 10: 0.30
The Shiny dashboard is live at https://raphaele.shinyapps.io/tw_sentiment_analysis/


- Add the retweet rate daily, with a line graph to see evolution.
- add a way to identify most retweeted and favorited tweets daily
