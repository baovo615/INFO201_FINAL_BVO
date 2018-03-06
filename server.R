# Luxi Zheng

library("shiny")

library("rlang")
library("httr")
# install.packages("")
library("dplyr")
library("tidyr")
library("ggplot2")
library("stringr")
library("jsonlite")
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
# the most recent finished season id f7b4e7b4-8f70-431d-b604-d13cffff1114

base.uri <- "https://www.haloapi.com/stats/h5/player-leaderboards/csr/"

# resource {seasonId}/{playlistId}
resource.uri <- paste0(latest.finished.season.id, "/c98949ae-60a8-43dc-85d7-0feb0b92e719")
uri <- paste0(base.uri, resource.uri)
response <- GET(uri, add_headers('Ocp-Apim-Subscription-Key' = api.key))
response <- fromJSON(content(response, "text"))
leaders <- response$Results %>% 
  flatten()

# service information of top players
base.uri.stats <- "https://www.haloapi.com/stats/" 
player.ids <- leaders$Player.Gamertag
player.ids <- player.ids[1:32]
nospace.ids <- paste0(player.ids, collapse = ",") 
nospace.ids <- gsub(" ", "+", nospace.ids)
resource.stats <- paste0("h5/servicerecords/arena?players=", nospace.ids,"&seasonId=", latest.finished.season.id)
uri.stats <- paste0(base.uri.stats, resource.stats)
halo.stats <- GET(uri.stats, add_headers("Ocp-Apim-Subscription-Key" = api.key)) %>% 
  content("text") %>% 
  fromJSON()

halo.frame <- data.frame(halo.stats$Results)
rnames <- c(1:32)
halo.frame1 <- halo.frame$Result$ArenaStats$ArenaPlaylistStats
team.arena.stats <- data.frame(halo.frame1[[1]]) %>% 
  flatten()
team.arena.stats <- filter(team.arena.stats, PlaylistId == "c98949ae-60a8-43dc-85d7-0feb0b92e719")

for(i in 2:32) {
  x <- data.frame(halo.frame1[[i]]) %>% 
    flatten()
  x <- filter(x, PlaylistId == "c98949ae-60a8-43dc-85d7-0feb0b92e719")
  team.arena.stats <- rbind(team.arena.stats, x)
}
arena.columns <- c("TotalKills", "TotalDeaths", "TotalShotsFired", 
                   "TotalShotsLanded", "TotalMeleeKills", "TotalGrenadeKills", 
                   "TotalTimePlayed","TotalGamesCompleted", "TotalGamesWon", 
                   "TotalGamesLost","TotalGamesTied")
team.arena.stats1 <- select(team.arena.stats, arena.columns)
leaders.counted <- leaders[1:32,]
team.arena.stats1 <- cbind(player.ids, rank = leaders.counted$Rank, team.arena.stats1, xp = halo.frame$Result$Xp)

#######################################################################################################
#######################################################################################################

player.ids2 <- leaders$Player.Gamertag
player.ids2 <- player.ids2[33:64]
nospace.ids2 <- paste0(player.ids2, collapse = ",") 
nospace.ids2 <- gsub(" ", "+", nospace.ids2)
resource.stats2 <- paste0("h5/servicerecords/arena?players=", nospace.ids2,"&seasonId=", latest.finished.season.id)
uri.stats2 <- paste0(base.uri.stats, resource.stats2)
halo.stats2 <- GET(uri.stats2, add_headers("Ocp-Apim-Subscription-Key" = api.key)) %>% 
  content("text") %>% 
  fromJSON()

halo.frame2 <- data.frame(halo.stats2$Results)
rnames2 <- c(1:32)
halo.frame3 <- halo.frame2$Result$ArenaStats$ArenaPlaylistStats
team.arena.stats2 <- data.frame(halo.frame3[[1]]) %>% 
  flatten()
team.arena.stats2 <- filter(team.arena.stats2, PlaylistId == "c98949ae-60a8-43dc-85d7-0feb0b92e719")

for(i in 2:32) {
  x <- data.frame(halo.frame3[[i]]) %>% 
    flatten()
  x <- filter(x, PlaylistId == "c98949ae-60a8-43dc-85d7-0feb0b92e719")
  team.arena.stats2 <- rbind(team.arena.stats2, x)
}

team.arena.stats3 <- select(team.arena.stats2, arena.columns)
leaders.counted2 <- leaders[33:64,]
team.arena.stats3 <- cbind(player.ids2, rank = leaders.counted2$Rank, team.arena.stats3, xp = halo.frame2$Result$Xp)
colnames(team.arena.stats3)[1] <- "player.ids"
total.arena.stats <- rbind(team.arena.stats1, team.arena.stats3)



###################################################
########## Defining the server ####################
###################################################
my.server <- function(input, output) {

}

shinyServer(my.server)
