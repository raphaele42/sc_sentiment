# Sentiment Analysis on a Corpus of Tweets 
# Raphaele Lamaze
# October 2020

# published app is here: https://raphaele.shinyapps.io/tw_sentiment_analysis/

library(shiny)
library(ggplot2)
library(DT)
library(gridExtra)
library(wordcloud2)
library(dplyr)
library(plotly)

# load the data sets
# to be used in the select input for the keyword tweet table
filter_picker <- read.csv("sc_tweets.csv")


# Define UI for dashboard application 
ui <- fluidPage(theme = "style.css",
    
    # row 1
    fluidRow(

        # title
        column(6,
               tags$br(),
               tags$br(),
               tags$br(),
               h2("Sentiment Analysis of a Sample of Tweets", icon("twitter", class = NULL, lib = "font-awesome"))

        ),
        
        # about the project
        column(6,
               tags$br(),
               tags$div(class = "about-box",
                        h3("About this dashboard"),
                        p("Explore sentiment and engagement in tweets about Schitt's Creek. The tweets were collected between October 03 and October 09 2020. The corpus includes 13724 tweets and excludes retweets. The code and readme are avalaible on ", a(href="https://github.com/raphaele42/sc_sentiment", "GitHub", target="_blank"), "."))
        )
        
    ), # end row 1

    
    #  row 2
    fluidRow(
        
        # col 1/2
        column(6,
               
               # title row daily report
               fluidRow(
                   column(12,
                          tags$div(class = "title-bar",
                          h3("Daily report"))
               )),
               
               # day picker
               fluidRow(
                   column(12,
                          dateInput("pick_day", "Select a day:",
                              value = "2020-10-08",
                              min = "2020-10-05",
                              max = "2020-10-11")
                    )
                 ),
                
               # subtitle row daily engagement
               fluidRow(
                   
                   column(12,
                          tags$div(class = "sub-title-bar",
                                   h4("Daily engagement"))
                   )),
               
               # daily engagement cards
               fluidRow(
                    
                   # number of tweets          
                   column(3,
                                    tags$div(class = "icon-fig",
                                    icon("twitter", class = NULL, lib = "font-awesome"),
                                    textOutput("daily_vol")
                             )),
                    
                   # percentage of positive tweets
                  column(3,
                                    tags$div(class = "icon-fig",
                                    icon("smile", class = NULL, lib = "font-awesome"),
                                    textOutput("daily_sent")
                             )),
                    
                   # number of retweets
                  column(3,
                                    tags$div(class = "icon-fig",
                                    icon("retweet", class = NULL, lib = "font-awesome"),
                                    textOutput("daily_retweets")
                             )),
                    
                   # number of favorites
                    column(3,
                                    tags$div(class = "icon-fig",
                                    icon("heart", class = NULL, lib = "font-awesome"),
                                    textOutput("daily_fav")
                             ))
                ),
                
               # word cloud row
               # won't display if in a fluidRow
               tags$div(class = "sub-title-bar",
               h4("Most used words")),
               tags$div(class = "chart",    
                        wordcloud2Output("daily_word_use")
               ),
            
                
               # subtitle row Weekly engagement
               fluidRow(
                   column(12,
                          tags$div(class = "title-bar",
                          h3("Weekly Engagement"))
               )),
               
               fluidRow(
                   
                   # daily volume and sentiment chart
                   column(7,
                          tags$div(class = "chart",
                          h4("Daily tweets volume and sentiment"),
                          plotlyOutput("daily_sentiment")
                   )),
                   
                   # median rewteets and fav charts
                   column(5,
                          tags$div(class = "chart",
                          h4("Median number of retweets and favorites for words in most popular tweets"),
                          plotOutput("retweet_words")
                    ))
               )
        ),  # close col 1
        
        # open col 2/2
        column(6,
               
               # title row topic explorer
               fluidRow(
                   column(12,
                          tags$div(class = "title-bar",
                          h3("Topic explorer"))
                   )),
               
               
               # topic / keyword picker
               fluidRow(
                   column(4,
                          textInput("keyword", label = "Type a word:", value = "moira") 
                          )),
                   
               # subtitle row topic engagement
               fluidRow(
                   
                   column(12,
                          tags$div(class = "sub-title-bar",
                                   h4("Topic engagement"))
                   )),
               
               
               # engagement cards
               fluidRow(          
                   
                   # number of tweets
                   column(3,
                          tags$div(class = "icon-fig",
                          icon("twitter", class = NULL, lib = "font-awesome"),
                          textOutput("key_vol")
                          )),
                   
                   # percent pos sentiment        
                   column(3,
                          tags$div(class = "icon-fig",  
                          icon("smile", class = NULL, lib = "font-awesome"),
                          textOutput("key_sent_perc")
                          )),
                   
                    # number of retweets
                   column(3,
                          tags$div(class = "icon-fig",    
                          icon("retweet", class = NULL, lib = "font-awesome"),
                          textOutput("key_med_retweets")
                          )),
                   
                    # number of favorites      
                   column(3,
                          tags$div(class = "icon-fig",
                          icon("heart", class = NULL, lib = "font-awesome"),
                          textOutput("key_med_favorites")
                          ))
                
                   ),
               
               # subtitle row topic usage
               fluidRow(
                   
                   column(12,
                          tags$div(class = "sub-title-bar",
                                   h4("Topic use and retweet volume"))
                   )),
               
               # word daily use chart
               fluidRow(
                   column(12,
                          plotlyOutput("key_daily_word_use")
                   )),
               
               
               # subtitle row tweet viewer
               fluidRow(
                   
                   column(12,
                          tags$div(class = "sub-title-bar",
                                   h4("Tweet viewer"))
                   )),
               
               # new row to select tweets criterias
               fluidRow(
                   
                   # tweet date
                   column(6,
                          selectInput("tweet_date",
                                      "Date:",
                                      c("All",
                                        unique(as.character(filter_picker$created_at))))
                   ),
                   
                   # tweet sentiment
                   column(6,
                          selectInput("tweet_sentiment",
                                      "Sentiment:",
                                      c("All",
                                        unique(as.character(filter_picker$sentiment))))
                   )
               ),
               
               # Create a new row for the table.
               DT::dataTableOutput("key_tweets")
        
        ) # end col 2  
        
     ) # end  row 2

      
 )  # end fluid page


# Define server logic 
server <- function(input, output) {
    
    
    ########start specific data loading #######

    # load all tweets data
    sc_tweets <- reactive({
        read.csv("sc_tweets.csv")
    })
    
    # load and cache words data
    full_sc_tweets_clean <- reactive({
        read.csv("full_sc_tweets_clean.csv")
    })
    
    
    # load and cache retweets per word data
    retweets_per_word <- reactive({
        read.csv("retweets_per_word.csv")
    })
    
    # load and cache favorites per word data
    fav_per_word <- reactive({
        read.csv("fav_per_word.csv")
    })
    
    ########end specific data loading #######
    
    
    ########
    # column 1
    #########
    
    
    ####### daily ######
    
    
    # filtered data for daily volume
    vol_day_filter <- reactive({
        
        sel_day <- input$pick_day
        
        sc_tweets() %>%
            filter(created_at == sel_day) 
        
        
    })
    
    # daily volume
    output$daily_vol <- renderText({ 
        
        day_vol <- vol_day_filter()
        
        paste(nrow(day_vol))
        
    })
    
    
    
    # filtered data for daily sentiment
    sent_day_filter <- reactive({
        
        sel_day <- input$pick_day
        
        pos <- sc_tweets() %>%
            filter(created_at == sel_day) %>%
            filter(sentiment == 'positive') 
        
        total <- sc_tweets() %>%
            filter(created_at == sel_day)
        
        perc_positive <- round(nrow(pos) / nrow(total) * 100, 2)
        paste(perc_positive, "%")
        
    })
    
    # daily sentiment
    output$daily_sent <- renderText({ 
        
        day_pos <- sent_day_filter()
        
        paste( day_pos)
        
    })
    
    
    # filtered data for daily retweets
    retweets_day_filter <- reactive({
        
        sel_day <- input$pick_day
        
        sc_tweets() %>%
            filter(created_at == sel_day) %>%
            filter(retweet_count !=0) %>%
            dplyr::summarise(retweets = sum(retweet_count)) 

        
    })
    
    # daily retweets
    output$daily_retweets <- renderText({ 
        
        day_retweets <- retweets_day_filter()
        
        paste( day_retweets[1,1])
        
    })
    
    
    # filtered data for daily fav
    fav_day_filter <- reactive({
        
        sel_day <- input$pick_day
        
        sc_tweets() %>%
            filter(created_at == sel_day) %>%
            filter(favorite_count !=0) %>%
            dplyr::summarise(favorites = sum(favorite_count)) 
        
        
    })
    
    # daily fav
    output$daily_fav <- renderText({ 
        
        day_fav <- fav_day_filter()
        
        paste(day_fav[1,1])
        
    })
    
    
    
    # wordcloud data
    cloud_day_filter <- reactive({
        
        sel_day <- input$pick_day
        
        full_sc_tweets_clean() %>%
            filter(created_at == sel_day) %>%
            group_by(word) %>% 
            tally() %>% 
            arrange(desc(n)) 
        
    })
    
    # wordcloud
    output$daily_word_use <- renderWordcloud2({ 
        
        mots <- cloud_day_filter()
        limit_word <- mots[1:100, ]
        wordcloud <- wordcloud2(limit_word, size=0.9, color = "random-light", 
                                backgroundColor = "white")
        wordcloud
        
        
        })
    
    ####### weekly ######
    
    output$daily_sentiment <- renderPlotly({ 
        
        s_plot <- ggplot(sc_tweets(), aes(x = as.Date(created_at), fill = sentiment,
                                          text=paste(sentiment)) ) +
            geom_bar(stat = "count", width=0.9) +
            labs(x = "",
                 y = "Tweets",
                 title = "") +
            theme(legend.position='none', 
                  legend.title = element_blank(),
                  axis.text.x = element_text(angle = 45),
                  panel.background = element_rect(colour = "gray93",
                                                  size = 0.5, linetype = "solid"),
                  panel.grid.major = element_line(size = 0.5, linetype = 'solid',
                                                  colour = "white"), 
                  panel.grid.minor = element_line(size = 0.25, linetype = 'solid',
                                                  colour = "white")) +
            scale_x_date(date_labels=("%d-%b"), date_breaks  ="1 day") +
            scale_fill_manual(values=c('#84CFE2','gray', '#FEFAC4'))
        
        d_plot <- ggplotly(s_plot, tooltip = c("text"))
        d_plot
        
    })
    
    
    # plot median retweet and fav per frequent word
    output$retweet_words <- renderCachedPlot({ 
        
        
        p1 <- ggplot(retweets_per_word(), aes(reorder(word, retweets), retweets)) +
            geom_col(fill="#F4B5EC") +
            coord_flip() +
            labs(y = "Retweets", 
                 title = "") +
            geom_label(aes(label = word), vjust = "center", hjust="inward") +
            theme(axis.line=element_blank(),
                  axis.text.y=element_blank(),
                  axis.ticks.y=element_blank(),
                  axis.title.y=element_blank(),
                  panel.background = element_rect(colour = "gray93",
                                                  size = 0.5, linetype = "solid"),
                  panel.grid.major = element_line(size = 0.5, linetype = 'solid',
                                                  colour = "white"), 
                  panel.grid.minor = element_line(size = 0.25, linetype = 'solid',
                                                  colour = "white"))
        
        p2 <- ggplot(fav_per_word(), aes(reorder(word, favorites), favorites)) +
            geom_col(fill="#C2EFBD") +
            coord_flip() +
            labs(y = "Favorites", 
                 title = "") +
            geom_label(aes(label = word), vjust = "center", hjust="inward") +
            theme(axis.line=element_blank(),
                  axis.text.y=element_blank(),
                  axis.ticks.y=element_blank(),
                  axis.title.y=element_blank(),
                  panel.background = element_rect(colour = "gray93",
                                                  size = 0.5, linetype = "solid"),
                  panel.grid.major = element_line(size = 0.5, linetype = 'solid',
                                                  colour = "white"), 
                  panel.grid.minor = element_line(size = 0.25, linetype = 'solid',
                                                  colour = "white"))
        # show to plots on two rows
        grid.arrange(p1, p2, nrow = 2)
        
    }, cacheKeyExpr = { list(retweets_per_word()) })
    
    
    ########
    # column 2
    #########
        
        
    # select the data for selected keyword only
    keyword_filter <- reactive({

            full_sc_tweets_clean() %>%
            filter(word == input$keyword | tag1 == input$keyword | tag2 == input$keyword |
                       tag3 == input$keyword | tag3 == input$keyword)
        
    })
        
    
    # output volume for selected topic
    output$key_vol <- renderText({ 
        
        total <- nrow(keyword_filter())
        paste(total)
        
    })
    
    
    # output pos sentiment perc for selected topic
    output$key_sent_perc <- renderText({ 
        
        total <- nrow(keyword_filter())
        tot_pos <- nrow(keyword_filter()[keyword_filter()$sentiment == 'positive', ])
        perc_pos <- round(tot_pos / total * 100, 2)
        paste(perc_pos, "%")
        
    })
    
    
    
    # output  number of retweets per word
    output$key_med_retweets <- renderText({ 
        
        med_retweets <- keyword_filter() %>% 
            filter(retweet_count !=0) %>%
            dplyr::summarise(retweets = sum(retweet_count)) 
        
        paste(med_retweets[1,1])
        
    })
    
    # output  number of favorites per word
    output$key_med_favorites <- renderText({ 
        
        med_fav <- keyword_filter() %>% 
            filter(favorite_count !=0) %>%
            dplyr::summarise(favorites = sum(favorite_count)) 
        paste(med_fav[1,1])
        
    })
    
    
    # plot daily use of a word
    output$key_daily_word_use <- renderPlotly({ 
        
        data <- keyword_filter() %>%
            group_by (created_at) %>%
            dplyr::summarise(retweets = sum(retweet_count), tweets =n())
        
            s_plot <- ggplot(data, aes( x = as.Date(created_at), y = tweets, 
                                  text=paste(retweets,' retweets'))) +
            geom_point(aes(size=retweets), color="darkorange") +
            scale_size_continuous(range = c(1, 4)) +
                xlab(NULL) +
                labs(y = "Tweets", x = "", title = "") +
                theme(legend.position='none', 
                      panel.background = element_rect(colour = "gray93",
                                                      size = 0.5, linetype = "solid"),
                      panel.grid.major = element_line(size = 0.5, linetype = 'dashed',
                                                      colour = "white"), 
                      panel.grid.minor = element_line(size = 0.25, linetype = 'dashed',
                                                      colour = "white")) +
                scale_x_date(date_labels=("%d-%b"), date_breaks  ="1 day")
            
            d_plot <- ggplotly(s_plot, tooltip = c("text"))
            d_plot
        
    })
    
    # output keyword tweets based on selection
    output$key_tweets <- DT::renderDataTable(DT::datatable({
        data <- keyword_filter()
        if (input$tweet_date != "All") {
            data <- data[data$created_at == input$tweet_date,]
        }
        if (input$tweet_sentiment != "All") {
            data <- data[data$sentiment == input$tweet_sentiment,]
        }
        data <- data %>%
            select(created_at, text, sentiment, retweet_count)
        data
    }, rownames = FALSE, colnames = c('Date', 'Tweet', 'Sentiment', 'RT'))
    )

    

    
}

# Run the application 
shinyApp(ui = ui, server = server)
