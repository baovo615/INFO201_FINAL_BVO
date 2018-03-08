halo.data <- read.csv("data/halo.data.csv", stringsAsFactors = FALSE)
halo.data1 <- read.csv("data/halo.data1.csv", stringsAsFactors = FALSE)
total.halo.data <- rbind(halo.data, halo.data1)
test <- group_by(total.halo.data, Season)
library("shiny")
library("rlang")
library("httr")
library("dplyr")
library("tidyr")
library("ggplot2")
library("rsconnect")

# Define UI for application that draws a histogram
my.ui <- fluidPage(
  
  # Application title
  titlePanel("HALO 5"),
  h4("By: Luxi Zheng \n03/04/2018"), 
  h4("Due to a limitation on the calls we can get from the API, please wait 
     roughly 20 seconds for this page to get the most updated Halo data."),
  tabsetPanel(
    tabPanel("Introduction", fluid = TRUE,
             h4("THE PROJECT"),
             p("This project is created for INFO 201. "),
             h4("DATASET"),
             p("The dataset that we will be working with is the", 
               a("HALO 5 API", href="https://developer.haloapi.com"), 
               ". The documentation for this API was created by 343 Industries, 
               the studio that has been making the Halo Games since Halo 4. 
               The dataset that we're looking at is related to player and match 
               information in matches. Some of the information that is included 
               in the dataset are the results of a match, history of matches per
               player, match leaderboards, and player service records. 
               It is recommended to have some prior knowledge, 
               such as knowledge of first person shooter games, 
               knowledge of how online multiplayer FPS games function, 
               the different game modes in the game, 
               etc before viewing this dataset."),
             h4("AUDIENCE"),
             p(),
             h4("QUESTIONS"),
             tags$li("What matches do players tend to do best in?"),
             tags$li("How does service time correlate with skill level?"),
             tags$li("Which game mode do players have the longest lifetime?"),
             tags$li("How are the number of hours played distributed for top 
                     ranked players?"),
             h4("CREATED BY"),
             p("Bao Vo, Luxi Zheng, Muhammad Hussain, Zixin Wang")
    ),
    tabPanel("Distribution", fluid = TRUE

    ),
    tabPanel("bao", fluid = TRUE,
             mainPanel(
               p("This page displays in-depth statistics from the top 128 
                 ranked players "),
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
             mainPanel(
               p("This page will...")
             )
    ),
    tabPanel("zixin", fluid = TRUE,
             mainPanel(
               p("This page will...")
             )
    )
  )
)
shinyUI(my.ui)