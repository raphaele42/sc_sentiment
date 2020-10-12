
![Project banner](https://github.com/raphaele42/sentiment_a/blob/master/Sentiment.png "Tweets")
# Sentiment analysis of tweets about Schitt's Creek

## Summary
The goal of this project is to offer a dashboard for Social Media managers to analyse the tweets related to a specific brand in order to gain insights on people's engagement with the brand. They want to determine what and how much tweeters are talking about and how they feel about it. This example uses data related to Schitt's Creek.

The Shiny app display three main panels: 
- daily report: select a day to review daily engagement stats (number of tweets, percent positive sentiment, number of retweets and number of favorites) and word cloud,
- weekly engagement: tweet number and sentiment over the week, as well as words in tweets generating the most retweets and favorites.
- topic explorer: select a topic / keyword to examine its daily usage, engagement stats and related tweets.

The Shiny dashboard is live at https://raphaele.shinyapps.io/tw_sentiment_analysis/

![Preview of dashboard](https://github.com/raphaele42/sentiment_shiny/blob/main/sentiment_sh_preview.png "Preview")

**Technologies**: 
- R (ggplot2, dplyr, textdata)
- R Shiny

**Code**:
- [Data cleaning, preparation and wrangling](https://github.com/raphaele42/sentiment_shiny/blob/main/data_prep.R).
- [Shiny app](https://github.com/raphaele42/sentiment_shiny/blob/main/app.R).

## Insights

12,251 tweets (05 to 11 October) were collected via API call and analysed:

- The proportion of positive and negative tweets is consistant from day to day, with approximately 2/3 of tweets expressing a positive sentiment.
- The number of tweets is between 689 and 804 per day, except for October 7: that day saw a peak at 1098. This is related to Dan Levy calling out Comedy Central India for censoring Schitt's Creeks. This peak in engagement comes with an increase of positive sentiment to approximately 70%.
- The highest retweet rate was seen on October 5 at 1.01. This is related to a tweet that was retweeted 653 times about the Lovecraft Country cast deserving as many Emmy's at the Schitt's Creek one.
- David is the most popular character with 272 tweets during the week. 

## Methodology

### Data Preparation

- Stripped text from special characters, URLs and upper case.
- Tokenization at word granuarity level (list of all words, their tweet and frequency).
- Lemmatization to change all words to their base form.


### Sentiment

- Dictionary-based method with AFINN rated vocabulary.

### Topics

- Based on words frequency.







