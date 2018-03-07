halo.stats <- read.csv("data/halo.stats.csv", stringsAsFactors = FALSE)
  
###################################################
########## Defining the server ####################
###################################################
my.server <- function(input, output) {
  output$plot1 <- renderPlot({
    x <- sym(input$xaxis)
    y <- sym(input$yaxis)
    ggplot(halo.stats, aes_string(x, y)) + 
      geom_point() +
      labs(title = paste0(x, " vs ", y))
  })
  
  output$click_info <- renderPrint({
    nearPoints(halo.stats, input$plot1_click, addDist = TRUE) %>% 
      select(rank, player.ids)
  })

}

shinyServer(my.server)
