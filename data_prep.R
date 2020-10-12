# project: data vizualisation of tweet sentiments
# Oct 1, 2020

# Question: what are people's feelings about Schitt's Creek on Twitter?

#rtweet doc: https://cran.r-project.org/web/packages/rtweet/rtweet.pdf

# load twitter library - the rtweet library is recommended now over twitteR
library(rtweet)
# text mining library
library(tidytext)
library(stringr)
library(plyr)
library(tidyr)
library(tidyverse)
library(textdata) # for sentiment lexicons
library(textstem)  # for lemmatization
library(lubridate)  # dates manipulation


### Twitter API connection

# twitter app details
appname <- 'xxxxxxxx'
key <- 'xxxxxxxxxxx'
secret <- 'xxxxxxxxxxxxxxxxxxxxxxxxxx'

# create token named "twitter_token"
twitter_token <- create_token(
  app = appname,
  consumer_key = key,
  consumer_secret = secret,
  access_token = 'xxxxxxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxx',
  access_secret = 'xxxxxxxxxxxxxxxxxxxxxxxxxx')

#####################

## search for up to 30,000 tweets about schitt's creek
# API search is limited to 6-9 previous days
# search for 30000 tweets
# as this is  more than 18000, retryonratelimit = TRUE
# type of search results to return type = "mixed" (mix of recent and popular).
# include_rts = FALSE to exclude RT without comment
collected_tweets <- search_tweets(q = "schitt's creek", n = 30000, type = "mixed", include_rts = FALSE,
                           retryonratelimit = TRUE)  #13,724 tweets


# coerce the data.frame to all-character so it can be written as csv
collected_tweets <- data.frame(lapply(collected_tweets, as.character), stringsAsFactors=FALSE)

# export bk data to csv so there is no need to run the twitter search again if need backup
write.csv(collected_tweets, "collected_tweets.csv", 
          row.names = FALSE)

# data set for analysis
sc_tweets <- collected_tweets

# type of object
class(sc_tweets)   # dataframe

# number of tweets collected
nrow(sc_tweets)   #12251

# see all variables
dimnames(sc_tweets)

# preview text content
head(sc_tweets$text, 10)

# convert created_at to date format
sc_tweets$created_at <- as.Date(sc_tweets$created_at)
#view date range
unique(round_time(sc_tweets$created_at, "1 day")) # Oct 3 to Oct 11

#trim the dates to have only 7 days
sc_tweets <- sc_tweets %>%
  filter(created_at != "2020-10-04" & created_at != "2020-10-12")

# change RT and fav counts from char to dbl
sc_tweets$retweet_count <- as.numeric(sc_tweets$retweet_count)
sc_tweets$favorite_count <- as.numeric(sc_tweets$favorite_count)

# examine some other variables of interest
# decide which to keep for the analysis
head(sc_tweets$status_id, 10)  #yes, tweet ID
head(sc_tweets$source, 10) # no
head(sc_tweets$is_quote, 50)   # no
head(sc_tweets$is_retweet, 10) #no
head(sc_tweets$favorite_count, 10) #yes
head(sc_tweets$retweet_count, 10)  #yes
head(sc_tweets$quote_count, 10)  #no, only NA
head(sc_tweets$reply_count, 10)    #no, only NA
head(sc_tweets$hashtags, 10)   #yes
head(sc_tweets$symbols, 10)   #no, only NA
head(sc_tweets$lang, 10)   #yes
head(sc_tweets$retweet_text, 10)   #no, only NA
head(sc_tweets$place_name, 10)  #no, 97% NA
head(sc_tweets$country, 10)  #no, 97% NA
head(sc_tweets$country_code, 10)  #no, redundant with country
head(sc_tweets$geo_coords, 10)  # remove after using with lat_lng function
head(sc_tweets$coords_coords, 10)  # remove after using with lat_lng function
head(sc_tweets$bbox_coords, 10)   # remove after using with lat_lng function
head(sc_tweets$location, 10)  #no, user edited field, inconsistant location info
head(sc_tweets$description, 10) #no, user related. we look only at tweets level

# add latitude and longitude for each tweet : 
# two new columns in new object: lat and lng
sc_tweets <- lat_lng(sc_tweets, coords = c("bbox_coords", "geo_coords", "coords_coords"))

# view number of NA latitude
sc_tweets %>%
  plyr::count('lng') %>%
  tail
  # returns 9853, which is ~97% of the data set
  # this variable is not populated enough to be used to plot

# Conclusion
# No another relevant location variable has better population rate (eg country, place_name. We will use lat and lgn to plot a map
# with caveat it represents only 3% of the population.
# Idea: can we extrapolate the country by processing the location? However this a user free input field + populated at ~78%


########
# Clean up 
########

# columns we keep:
# "created_at", "text", "favorite_count", "retweet_count", "hashtags", "lang" , "status_id", 'lat', 'lng'
sc_tweets <- sc_tweets %>%
  select(one_of(c("status_id", "created_at", "text", "favorite_count", "retweet_count", "hashtags", "lang", 'lat', 'lng')))

#round the date field to the day granularity level
sc_tweets$created_at <- round_time(sc_tweets$created_at, "1 day")
# change from numeric to date format
sc_tweets$created_at <- ymd(sc_tweets$created_at)

# clean the hashtags variable
# 1. change into comma separated string 
sc_tweets$hashtags <- lapply(sc_tweets$hashtags, toString)
# 2. split each hashtag to an individual column and remove the hashtags col
sc_tweets <- sc_tweets %>% 
  separate(col = hashtags, c("tag1", "tag2", "tag3", "tag4"), sep = ", ", extra = "drop", fill = "right")


################
# text pre processing
###############

# remove URLS, copy text to new stripped text col
sc_tweets$stripped_text <- gsub("http.*","",  sc_tweets$text)
sc_tweets$stripped_text <- gsub("https.*","", sc_tweets$stripped_text)
#remove punctuation - using global substitute
sc_tweets$stripped_text <- gsub("[[:punct:]]", "", sc_tweets$stripped_text)
# remove control characters
sc_tweets$stripped_text <- gsub("[[:cntrl:]]", "", sc_tweets$stripped_text)
# remove digits
sc_tweets$stripped_text <- gsub("\\d+", "", sc_tweets$stripped_text)


#Create a list of words by copying each individual word to new object, 
# convert text to lowercase, remove punctuation and add tweet unique id to the word:
sc_tweets_clean <- sc_tweets %>%
  select(status_id, created_at, stripped_text) %>%
  unnest_tokens(word, stripped_text)
# sc_tweets_clean is in tidy format, ready for sentiment analysis

# remove stop words
# load the list of stop words
data("stop_words")

# remove stop words from your list of words
sc_tweets_clean <- sc_tweets_clean %>%
  anti_join(stop_words)
  # there are now 87 474 words in our list of words

# reviewing the top 40 words shows some other stop words that should be excluded from the list of words
# as they won't add to the sentiment analysis or don't carry meaning
add_stop_words <- c('creek', 'schitts', 'do', 'schittscreek', 'im', 'de', 'ive', 'amp', 'se', 'la', 'en')
add_stop_words <- as_tibble(add_stop_words)
colnames(add_stop_words) <- c('word')

# remove the additional stop words from the corpus
sc_tweets_clean <- sc_tweets_clean %>%
  anti_join(add_stop_words)
# there are now 68024 words in our list of words
nrow(sc_tweets_clean)  #68024

# lemmatization to group all word forms to their base form
# will reduce the number of unique words
sc_tweets_clean$word <- lemmatize_words(sc_tweets_clean$word)
# additional lemmatization
# emmys is base form for emmy
sc_tweets_clean$word[sc_tweets_clean$word=='emmy']<-'emmys'


################
# sentiment analysis
###############

# Dictionary-based methods: comparing content to tweet with vocabulary annotated with sentiment
# works on unigrams

# assign sentiment at word level
sent_afinn_word <- sc_tweets_clean %>% 
  inner_join(get_sentiments("afinn")) 

# compute sentiment for each tweet
sent_afinn_tweet <- aggregate(sent_afinn_word$value, 
                              by=list(status_id=sent_afinn_word$status_id), FUN=sum)

# reconcile tweets with their sentiment.
# not all tweets have a sentiment, depending on the words in their text
# match sent_afinn_tweet and sc_tweets bu status_id
sc_tweets <- sc_tweets %>% 
  inner_join(sent_afinn_tweet)
sc_tweets <- sc_tweets %>% 
  dplyr::rename(sent_value = x)

# add a column with discrete sentiment: neg, neutral or pos
sc_tweets <- sc_tweets %>% 
  mutate(sentiment = ifelse(sent_value == 0 , 'neutral', ifelse(sent_value >0 , 'positive', 'negative')))

full_sc_tweets_clean <- sc_tweets_clean %>%
  inner_join(sc_tweets)


#########
#  data for plots
#########

# median number of retweets for each word
#####################################
 
retweets_per_word <- full_sc_tweets_clean %>%
  filter(retweet_count !=0) %>%
  dplyr::group_by(word) %>%
  dplyr::summarise(retweets = median(retweet_count), uses = n()) %>%
  arrange(desc(retweets)) %>%
  head(n = 5L) 


# median number of favorite for each word
########################

fav_per_word <- full_sc_tweets_clean %>%
  filter(retweet_count !=0) %>%
  dplyr::group_by(word) %>%
  dplyr::summarise(favorites = median(favorite_count), uses = n()) %>%
  arrange(desc(favorites)) %>%
  head(n = 5L) 


##########
# data to export for reuse by the shiny app
#########

# one line per tweet: sc_tweets
write.csv(sc_tweets, "sc_tweets.csv", 
          row.names = FALSE)

# one line per word, tidy format: full_sc_tweets_clean
write.csv(full_sc_tweets_clean, "full_sc_tweets_clean.csv", 
          row.names = FALSE)

# retweets per word
write.csv(retweets_per_word, "retweets_per_word.csv", 
          row.names = FALSE)

# favorite per word
write.csv(fav_per_word, "fav_per_word.csv", 
          row.names = FALSE)
