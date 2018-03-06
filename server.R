# Muhammad Hussain

library("shiny")

library("rlang")
library("httr")
 #install.packages("tidyr")
library("dplyr")
library("tidyr")
library("ggplot2")
library("stringr")
library("jsonlite")

source("apikey.R")



###################################################
########## Process the data #######################
###################################################
# to get a list of playlists that are ranked and active so we know
# which ones to display to the reader
base.uri <- "https://www.haloapi.com/metadata/h5/metadata/playlists"
response <- GET(base.uri, add_headers('Ocp-Apim-Subscription-Key' = api.key))
playlists <- fromJSON(content(response, "text"))
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
leaders <- response$Results %>% flatten()

rows.to.used <- seq(10, 169, 10)
rows.to.used <- c(1, rows.to.used)

condense.leaders <- leaders[rows.to.used, ]
gametags <- condense.leaders[["Player.Gamertag" ]]

#This will add a '+' instead of a space in the URL for the 
#GetMatchID function
gametags <- gsub('([[:punct:]])|\\s+','+',gametags)


GetMatchID <- function(tag) {
  Sys.sleep(1)
  base.uri <- paste0("https://www.haloapi.com/stats/h5/players/", tag, "/matches?modes=Arena")
  response <- GET(base.uri, add_headers("Ocp-Apim-Subscription-Key" = api.key))
  results <- fromJSON(content(response, "text", encoding = "ISO-8859-1"))
  results <- results$Results
  results <- as.data.frame(results)
  results <- flatten(results)
  return(results$Id.MatchId)
}


lapply(gametags,GetMatchID)
#For Loop to create a dataframe of gamertags by matchID
all <- lapply(gametags, GetMatchID)
all.df <- all[[1]]
for (i in 2:17) {
  y <- all[[i]]
  all.df <- rbind(all.df, y)
}

#putting the matchID per gamertag in a vector
match.id.gametags <- c(all.df[1:17])

#This function will get me the information for the number of kills and deaths
#per player.
GetMatchResults <- function(id) {
  Sys.sleep(1)
  base.uri <- paste0("https://www.haloapi.com/stats/h5/arena/matches/", id)
  response <- GET(base.uri, add_headers("Ocp-Apim-Subscription-Key" = api.key))
  results <- fromJSON(content(response, "text", encoding = "ISO-8859-1"))
  results <- results$PlayerStats
  results <- as.data.frame(results)
  results <- flatten(results)
  return(data.frame(GamerTag = results$Player.Gamertag,  
                    TotalKills = results$TotalKills, 
                    TotalDeaths = results$TotalDeaths,
                    stringsAsFactors = FALSE))
}

#using lapply to get the match results based off of the ID from the top players
lapply(match.id.gametags, GetMatchResults)

#taking the results froma above and looping through to create a dataframe of the
#information
kd <- lapply(match.id.gametags, GetMatchResults)
kd.df <- kd[[1]]
for (i in 2:17) {
  y <- kd[[i]]
  kd.df <- rbind(kd.df, y)
}

#creating a column that has the kill death ratio per player
kd.df$`Kill Death Ratio` <- (kd.df$TotalKills / kd.df$TotalDeaths)

###################################################
########## Defining the server ####################
###################################################
my.server <- function(input, output) {
  output$table <- renderTable({
    player.selector <- subset(kd.df, 
                               kd.df$GamerTag %in% input$player)
  })
}

shinyServer(my.server)
