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
###################################################
########## Defining the server ####################
###################################################
my.server <- function(input, output) {
  
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
    nearPoints(halo.data, input$plot1_click, addDist = TRUE) %>% 
      select(rank, player.ids)
  })
  # display additional information on user clicks
  output$click_location <- renderText({
    paste0("x= ", input$plot1_click$x, "\ny= ", input$plot1_click$y)
  })

}

shinyServer(my.server)
