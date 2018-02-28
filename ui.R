library(shiny)

# Define UI for application that draws a histogram
my.ui <- fluidPage(

  # Application title
  titlePanel("HALO 5"),
  h4("By: Luxi Zheng \n02/23/2018"),

  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      checkboxGroupInput('playlists',
                         'Playlists:',
                         1998:2014, selected = c(2000, 2010)),
      sliderInput("range",
                  "Range of ranked players: ",
                  min = 0,
                  max = 250,
                  value = c(0, 100)),
      width = 3
    ),

    # create the different tabs plus text to go along with each tab
    mainPanel()
  )
)
shinyUI(my.ui)
