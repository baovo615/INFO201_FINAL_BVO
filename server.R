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
resource.uri <- paste0(latest.finished.season.id, "/c98949ae-60a8-43dc-85d7-0feb0b92e719")
uri <- paste0(base.uri, resource.uri)
response <- GET(uri, add_headers('Ocp-Apim-Subscription-Key' = api.key))
response <- fromJSON(content(response, "text"))
leaders <- response$Results



###################################################
########## Defining the server ####################
###################################################
my.server <- function(input, output) { 
 
}

shinyServer(my.server)