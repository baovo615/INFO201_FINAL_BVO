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
<<<<<<< HEAD
library("rsconnect")
=======
library("stringr")
library("jsonlite")
#install.packages("R.utils")
library("R.utils")
# install.packages("lubridate")
library("lubridate")
source("apikey.R")

###################################################
########## Process the data #######################
# the first part of processing the data is commented out becuase 
# I have to get each player's match history and at a limit of 10 calls per 10 second,
# I had to save the data into a csv file and then use that csv file for the shiny app
# otherwise, the app would take 3 min to run to display the data
###################################################

# to get a list of playlists that are ranked and active so we know
# which ones to display to the reader
base.uri <- "https://www.haloapi.com/metadata/h5/metadata/playlists"
response <- GET(base.uri, add_headers('Ocp-Apim-Subscription-Key' = api.key))
playlists <- fromJSON(content(response, "text"))
allplaylists <- playlists %>% select(name, description, isRanked, isActive, gameMode, id)
ranked.active.playlists <- playlists %>%
  filter(isRanked == TRUE & isActive == TRUE) %>%
  select(name, description, gameMode, id)
# team arena's id c98949ae-60a8-43dc-85d7-0feb0b92e719
# 
# # to get the most recent finished season
# base.uri <- "https://www.haloapi.com/metadata/h5/metadata/seasons"
# response <- GET(base.uri, add_headers('Ocp-Apim-Subscription-Key' = api.key))
# seasons <- fromJSON(content(response, "text"))
# latest.finished.season.id <- seasons %>%
#   filter(isActive == FALSE) %>% filter(row_number()==n()) %>% select(id)
# latest.finished.season.id <- latest.finished.season.id[1, 1]
# # the most recent finished season id f7b4e7b4-8f70-431d-b604-d13cffff1114
# 
# base.uri <- "https://www.haloapi.com/stats/h5/player-leaderboards/csr/"
# # resource {seasonId}/{playlistId}
# resource.uri <- paste0(latest.finished.season.id, "/c98949ae-60a8-43dc-85d7-0feb0b92e719?count=250")
# uri <- paste0(base.uri, resource.uri)
# response <- GET(uri, add_headers('Ocp-Apim-Subscription-Key' = api.key))
# response <- fromJSON(content(response, "text"))
# leaders <- response$Results
# leaders <- flatten(leaders) 
# 
# rows.to.used <- seq(10, 169, 10)
# rows.to.used <- c(1, rows.to.used) 
# condense.leaders <- leaders[rows.to.used, ] 
# 
# allgametags <- leaders[['Player.Gamertag']]
# allnospacetags <- gsub(" ", "+", allgametags)
# 
# GetMatches <- function(tag) {
#   Sys.sleep(1)
#   uri <- paste0("https://www.haloapi.com/stats/h5/players/", tag, "/matches?modes=Arena")
#   response <- GET(uri, add_headers('Ocp-Apim-Subscription-Key' = api.key))
#   results <- fromJSON(content(response, "text"))
#   results <- results$Results
#   results <- as.data.frame(results)
#   results <- flatten(results)
#   return(data.frame(PlaylistId = results$HopperId, MatchDuration = results$MatchDuration, stringsAsFactors = FALSE))
# }

# all <- lapply(allnospacetags, GetMatches)

# all.df <- all[[1]]
# for (i in 2:169) {
#   y <- all[[i]]
#   all.df <- rbind(all.df, y)
# } 
# all.df <- all.df %>% mutate(durations = as.duration(MatchDuration))
# 
# write.csv(all.df, "data/matches.csv")

data <- read.csv("data/matches.csv")

total.by.playlist <- data %>% group_by(PlaylistId) %>% 
  summarize(totalDuration = sum(as.numeric(durations)) /60 /60)

playlists.with.duration <- left_join(allplaylists, total.by.playlist, by= c("id" = "PlaylistId")) %>% filter(!is.na(totalDuration)) 

>>>>>>> distribution
###################################################
########## Defining the server ####################
###################################################
my.server <- function(input, output) {
  
<<<<<<< HEAD
  # generates plot of data
  output$plot1 <- renderPlot({
    x <- input$xaxis
    y <- input$yaxis

    # plot axis derived from user inputs 
    ggplot(test, aes_string(x, y, color = "Season")) + 
      geom_point() +
      geom_smooth(method = "lm") +
      scale_color_discrete(name  ="Season",
                            labels=c("2017-09-05 to 2017-11-01",
                                     "2017-11-01 to 2018-03-01")) +
      labs(title = paste0(x, " vs ", y)) 

  })
  
  # display additional information on user clicks
  output$click_info <- renderPrint({
    nearPoints(test, input$plot1_click, addDist = TRUE) %>% 
      select(rank, player.ids, Season)
  })
  # display additional information on user clicks
  output$click_location <- renderText({
    paste0("x= ", input$plot1_click$x, "\ny= ", input$plot1_click$y)
  })

=======
  output$plot <- renderPlot({ 
    info.to.use <- playlists.with.duration %>% filter(name %in% input$playlists)
    par(mar=c(11, 5, 0.5, 0.5)) 
    hist <- barplot(info.to.use$totalDuration, names.arg=info.to.use$name, las=2, ylab = "Total Number of Hours Played") 
    return(hist)
  })
  
  # create a table with playlist information for those who don't know much about the game
  output$description <- renderTable({
    result <- playlists.with.duration %>% select(name, description, isRanked, isActive, gameMode)
    return(result)
  })
  
  output$stats <- renderTable({
    result <- playlists.with.duration %>% filter(name %in% input$playlists)
    totalhours <- sum(as.numeric(result$totalDuration))
    result <- result %>% mutate(percentage = round(totalDuration / totalhours * 100))
    result <- result %>% select(name, description, isRanked, isActive, gameMode, totalDuration, percentage)
    return(result)
  })
>>>>>>> distribution
}

shinyServer(my.server)
