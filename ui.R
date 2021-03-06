library("shiny")
library("rlang")
library("httr")
library("dplyr")
library("tidyr")
library("ggplot2")
library("rsconnect")
source("server.R")

halo.data <- read.csv("data/halo.data.csv", stringsAsFactors = FALSE)
halo.data1 <- read.csv("data/halo.data1.csv", stringsAsFactors = FALSE)
total.halo.data <- rbind(halo.data, halo.data1)
test <- group_by(total.halo.data, Season)


# Define UI for application that draws a histogram
my.ui <- fluidPage( 
  # Application title
  titlePanel("HALO 5"),
  h4("Due to a limitation on the calls we can get from the API, please wait 
     roughly 20 seconds for this page to get the most updated Halo data."),
  tabsetPanel(
    tabPanel("Introduction", fluid = TRUE,
             h4("THE PROJECT"),
             p("This project is created for INFO 201.The project's purpose is to  
               demonstrate the skills that we've learned in class and teamwork."),
             br(),
             h4("DATASET"),
             p("The dataset that we will be working with is the", 
               a("HALO 5 API", href="https://developer.haloapi.com"), 
               ". The documentation for this API was created by 343 Industries, 
               the studio that has been making the Halo Games since Halo 4. The 
               dataset that we're looking at is related to player and match 
               information in matches. Some of the information that is included 
               in the dataset are the results of a match, history of matches per 
               player, match leaderboards, and player service records. It is
               recommended to have some prior knowledge, such as knowledge of
               first person shooter games, how online multiplayer FPS games 
               function, the different game modes in the game, etc before 
               viewing this dataset."),
             br(),
             h4("AUDIENCE"),
             p("Our target audience is mainly Halo players."),
             br(),
             h4("QUESTIONS"),
             tags$li("What matches do players tend to do best in?"),
             tags$li("How do different service records relate to each other? 
                     (ex: experience points vs. total kills)"), 
             tags$li("How are the number of hours played on different playlists 
                     distributed for top ranked players?"),
             br(),
             h4("CREATED BY"),
             p("Bao Vo, Luxi Zheng, Muhammad Hussain, Zixin Wang")
    ),
    tabPanel("Distribution", fluid = TRUE,
             sidebarLayout(
               sidebarPanel(
                 checkboxGroupInput('playlists',
                                    'Playlists:',
                                    playlists.with.duration$name,
                                    selected = playlists.with.duration$name),
                 width = 3
               ),
               mainPanel(
                 p("The following histogram shows the distribution of the amount
                   of time players spend on different playlists. As you can see,
                   the most popular playlist is the Halo WC (World Champion) 
                   2018 playlist. Since top ranked players are mainly using this
                   playlist when they are playing, other players who want to do 
                   more training to get a higher rank could also try to play 
                   more Halo WC playlist. The producer of Halo could also use 
                   these data to determine which playlists are popular and 
                   create new playlists that will be similar to what players 
                   already like or delete playlists that are barely played by 
                   players."),
                 plotOutput("plot"),
                 br(),
                 tableOutput("stats"),
                 br(),
                 p("This following is a table with descriptions for each 
                   playlist."),
                 tableOutput("description")
               )
             )
    ),
    tabPanel("bao", fluid = TRUE,
             mainPanel(
               p("This page displays in-depth statistics from the top 128
                 ranked players. This is a tool to be able to see the
                 different correlations of certain statistics compared to 
                 others. For example, if your accuracy (percentage of total
                 shots hit) is higher then generally you will more games. 
                 Overall its meant to give other lower ranked players an idea
                 of what benchmarks they should strive for in their own
                 gameplay"),
               fluidRow(
                 selectInput(inputId = 'xaxis',
                             label =  'X-axis',
                             choices = colnames(halo.data[, 3:18]),
                             selected = "HoursPlayed"
                 ),
                 
                 selectInput(inputId = 'yaxis',
                             label =  'Y-axis',
                             choices = colnames(halo.data[, 3:18]),
                             selected = "TotalGamesCompleted"
                 )
               ),
               fluidRow(
                 column(width = 12,
                        plotOutput("plot1", height = 350,
                                   click = "plot1_click"
                                   
                        )
                 )
               ),
               fluidRow(
                 column(width = 12,
                        h4("Points near click"),
                        verbatimTextOutput("click_info"),
                        verbatimTextOutput("click_location")
                 )
                 
               )
               )
  ),
  tabPanel("muhammad", fluid = TRUE,
           sidebarLayout(
             sidebarPanel(
               checkboxGroupInput('player', 'Select a Player:', 
                                  choices = c(kd.df$GamerTag)
             )
           ),
             mainPanel(
               p("The information above displays a table of the top players in
                 Halo who play the game mode called Arena. The information shows
                 the Gamertag of the player which is a unique identifier per 
                 character. The next two columns have the total number of kills
                 and deaths the player has in the match. Lastly, the last column
                 is the Kill Death Ratio of the player in that match. The Kill 
                 Death Ratio per player in a match is important because having 
                 a high Kill Death Ratio will allow the character to receive 
                 certain rewards in the game. In this game mode, the average 
                 Kill Death Ratio is", strong(average.kd),"."),
               
               br(),
               
               tableOutput("table")
               
               )
             )
             
          )
  )

)
shinyUI(my.ui)