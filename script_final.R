
library("shiny")
library("rlang")
library("httr")
library("dplyr")
library("tidyr")
library("ggplot2")
library("stringr")
library("jsonlite")
library("lubridate")
source("api_key.R")

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
season.id2 <- "f7b4e7b4-8f70-431d-b604-d13cffff1114"

base.uri <- "https://www.haloapi.com/stats/h5/player-leaderboards/csr/"

# resource {seasonId}/{playlistId}
GetLeaders <- function(seasonid) {
  resource.uri <- paste0(seasonid, 
                         "/5c9808b0-03a3-4577-b966-7217f9dda52d")
  uri <- paste0(base.uri, resource.uri)
  response <- GET(uri, add_headers('Ocp-Apim-Subscription-Key' = api.key))
  response <- fromJSON(content(response, "text"))
  leaders <- response$Results %>% 
    flatten()
}
# service information of top players
base.uri.stats <- "https://www.haloapi.com/stats/" 

# preparing names of desired columns to select
arena.columns <- c("TotalKills", "TotalDeaths", "TotalShotsFired", 
                   "TotalShotsLanded", "TotalMeleeKills", "TotalGrenadeKills", 
                   "TotalTimePlayed","TotalGamesCompleted", "TotalGamesWon", 
                   "TotalGamesLost","TotalGamesTied")

# function that creats a data from of up to 32 top players
# takes 2 arguements which are the range of a higher ranked player to a lower 
# rank (the highest being rank 1)
GetStats <- function(rank1, rank2, seasonid, leader) {
  
  # preparing string of players to request from api
  player.ids <- leader$Player.Gamertag
  player.ids <- player.ids[rank1:rank2]
  nospace.ids <- paste0(player.ids, collapse = ",") 
  nospace.ids <- gsub(" ", "+", nospace.ids)
  
  # Requesting from halo api and generating a dataframe
  resource.stats <- paste0("h5/servicerecords/arena?players=", nospace.ids,
                           "&seasonId=", seasonid)
  uri.stats <- paste0(base.uri.stats, resource.stats)
  halo.stats <- GET(uri.stats, add_headers("Ocp-Apim-Subscription-Key" = 
                                             api.key)) %>% 
    content("text") %>% 
    fromJSON()
  
  halo.frame <- data.frame(halo.stats$Results)
  halo.frame1 <- halo.frame$Result$ArenaStats$ArenaPlaylistStats
  team.arena.stats <- data.frame(halo.frame1[[1]]) %>% 
    flatten()
  team.arena.stats <- filter(team.arena.stats, PlaylistId == 
                               "5c9808b0-03a3-4577-b966-7217f9dda52d")
  
  # for loop to get data from nested list into a data frame
  for(i in 2:(rank2 - rank1 +1)) {
    x <- data.frame(halo.frame1[[i]]) %>% 
      flatten()
    x <- filter(x, PlaylistId == "5c9808b0-03a3-4577-b966-7217f9dda52d")
    team.arena.stats <- rbind(team.arena.stats, x)
  }
  
  # add additional columns to dataframe
  team.arena.stats1 <- select(team.arena.stats, arena.columns)
  leaders.counted <- leader[rank1:rank2,]
  team.arena.stats1 <- cbind(player.ids, rank = leaders.counted$Rank, 
                             team.arena.stats1, xp = halo.frame$Result$Xp)
  
}

# gathering data frames to combind into a singular data frame
halo.stats1 <- GetStats(1,32, latest.finished.season.id,
                        GetLeaders(latest.finished.season.id))
halo.stats2 <- GetStats(33,64, latest.finished.season.id, 
                        GetLeaders(latest.finished.season.id))
halo.stats3 <- GetStats(65,96, latest.finished.season.id,
                        GetLeaders(latest.finished.season.id))
halo.stats4 <- GetStats(97, 128, latest.finished.season.id,
                        GetLeaders(latest.finished.season.id))
total.halo.stats <- rbind(halo.stats1, halo.stats2, halo.stats3, halo.stats4)

halo.stats5 <- GetStats(1,32, season.id2, GetLeaders(season.id2))
halo.stats6 <- GetStats(33,64, season.id2, GetLeaders(season.id2))
halo.stats7 <- GetStats(65,96, season.id2, GetLeaders(season.id2))
halo.stats8 <- GetStats(97, 128, season.id2, GetLeaders(season.id2))
total.halo.stats1 <- rbind(halo.stats5, halo.stats6, halo.stats7, halo.stats8)

# translating totaltime into something readable
total.halo.stats <- mutate(total.halo.stats, 
                           HoursPlayed = 
                             round(as.double(as.duration(TotalTimePlayed)) / 
                                     3600)) %>% 
  mutate(WinPercent = round(TotalGamesWon / TotalGamesCompleted * 100)) %>% 
  mutate(Accuracy = round(TotalShotsLanded / TotalShotsFired * 100)) %>% 
  mutate(Season = latest.finished.season.id)

total.halo.stats1 <- mutate(total.halo.stats1, 
                           HoursPlayed = 
                             round(as.double(as.duration(TotalTimePlayed)) / 
                                     3600)) %>% 
  mutate(WinPercent = round(TotalGamesWon / TotalGamesCompleted * 100)) %>% 
  mutate(Accuracy = round(TotalShotsLanded / TotalShotsFired * 100)) %>% 
  mutate(Season = season.id2)

# writing to a csv to access data without additional api request
write.csv(total.halo.stats, file = "data/halo.data.csv")
write.csv(total.halo.stats1, file = "data/halo.data1.csv")
