# Luxi Zheng

library("shiny")

library("rlang")
library("httr")
# install.packages("tidyr")
library("dplyr")
library("tidyr")
library("ggplot2")
library("stringr")
library("jsonlite")
#install.packages("R.utils")
library("R.utils")
# install.packages("lubridate")
library("lubridate")
source("apikey.R")

###################################################
########## Process the data #######################
###################################################
# to get a list of playlists that are ranked and active so we know
# which ones to display to the reader
base.uri <- "https://www.haloapi.com/metadata/h5/metadata/playlists"
response <- GET(base.uri, add_headers('Ocp-Apim-Subscription-Key' = api.key))
playlists <- fromJSON(content(response, "text"))
allplaylists <- playlists %>% select(name, description, gameMode, id)
playlists <- playlists %>%
  filter(isRanked == TRUE & isActive == TRUE) %>%
  select(name, description, gameMode, id)
# team arena's id c98949ae-60a8-43dc-85d7-0feb0b92e719

# to get the most recent finished season
base.uri <- "https://www.haloapi.com/metadata/h5/metadata/seasons"
response <- GET(base.uri, add_headers('Ocp-Apim-Subscription-Key' = api.key))
seasons <- fromJSON(content(response, "text"))
latest.finished.season.id <- seasons %>%
  filter(isActive == FALSE) %>% filter(row_number()==n()) %>% select(id)
latest.finished.season.id <- latest.finished.season.id[1, 1]
# the most recent finished season id f7b4e7b4-8f70-431d-b604-d13cffff1114

base.uri <- "https://www.haloapi.com/stats/h5/player-leaderboards/csr/"
# resource {seasonId}/{playlistId}
resource.uri <- paste0(latest.finished.season.id, "/c98949ae-60a8-43dc-85d7-0feb0b92e719?count=250")
uri <- paste0(base.uri, resource.uri)
response <- GET(uri, add_headers('Ocp-Apim-Subscription-Key' = api.key))
response <- fromJSON(content(response, "text"))
leaders <- response$Results
leaders <- flatten(leaders) 

rows.to.used <- seq(10, 169, 10)
rows.to.used <- c(1, rows.to.used) 
condense.leaders <- leaders[rows.to.used, ] 
gametags <- condense.leaders[['Player.Gamertag']]
nospacetags <- gsub(" ", "+", gametags)

GetMatches <- function(tag) {
  Sys.sleep(1)
  uri <- paste0("https://www.haloapi.com/stats/h5/players/", tag, "/matches?modes=Arena")
  response <- GET(uri, add_headers('Ocp-Apim-Subscription-Key' = api.key))
  results <- fromJSON(content(response, "text"))
  results <- results$Results
  results <- flatten(results)
  return(data.frame(PlaylistId = results$HopperId, MatchDuration = results$MatchDuration, stringsAsFactors = FALSE))
}

all <- lapply(nospacetags, GetMatches)

all.df <- all[[1]]
for (i in 2:17) {
  y <- all[[i]]
  all.df <- rbind(all.df, y)
}  
all.df <- all.df %>% mutate(durations = as.duration(MatchDuration))

total <- sum(all.df$durations)

total.by.playlist <- all.df %>% group_by(PlaylistId) %>% summarize(totalDuration = sum(durations))

playlists.with.duration <- left_join(allplaylists, total.by.playlist, by= c("id" = "PlaylistId")) %>% 
  filter(!is.na(totalDuration)) 

###################################################
########## Defining the server ####################
###################################################
my.server <- function(input, output) {
  
  output$plot <- renderPlot({ 
    hist <- barplot(playlists.with.duration$totalDuration, names.arg=playlists.with.duration$name, las=2, xlab = "Playlists", ylab = "Total Duration (s)")
    return(hist)
  })
  
  output$description <- renderTable({
    result <- playlists.with.duration %>% select(name, description)
    return(result)
  })
}

shinyServer(my.server)
