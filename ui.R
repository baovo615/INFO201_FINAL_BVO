library(shiny)
source("server.R")

# Define UI for application that draws a histogram
my.ui <- fluidPage(
  
  # Application title
  titlePanel("HALO 5"),
  h4("By: Luxi Zheng \n02/23/2018"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      
      checkboxGroupInput('player', 'Select a Player:', choices = c(kd.df$GamerTag)
      ),
      
      br()
      
      # create the different tabs plus text to go along with each tab
      
    ),
    mainPanel(
      tabsetPanel(type = "tabs",
                  tabPanel("muhammad", tableOutput("table"),
                           p("The information above displays a table of the top players in Halo
                 who play the game mode called Arena. The information shows the Gamertag of
                 the player which is a unique identifier per character. The next two columns
                 have the total number of kills and deaths the player has in the match. Lastly,
                 the last column is the Kill Death Ratio of the player in that match. The Kill
                 Death Ratio per player in a match is important because having a high Kill Death
                 Ratio will allow the character to receive certain rewards in the game. In
                 this game mode, the average Kill Death Ratio is", strong(average.kd),".")
                  )
      )
    )
  )
)
shinyUI(my.ui)
