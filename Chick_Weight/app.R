#Developing Data Products
#app.r
#by Lawrence Tomaziefski
#2019-02-20
#============================================================================
library(shiny)

# Define UI that asks the user which experimental diets they want to explore.
ui <- fluidPage(
        pageWithSidebar(
                headerPanel(h3('Select Experimental Diets to Compare')),
                sidebarPanel(
                        selectInput('chick_1', 'Select an Experimental Diet', unique(ChickWeight$Diet)),
                        selectInput('chick_2', 'Select an Experimental Diet', unique(ChickWeight$Diet))
                        
                ),
                mainPanel(
                        plotOutput('plot1')
                )
        )
)


# Define server logic plot comparison
server <- function(input, output) {
        library(dplyr)
        library(ggplot2)
        
        selected_chicks = reactive({
                subset(ChickWeight,Diet == input$chick_1 | Diet == input$chick_2, select = c(weight, Time, Chick, Diet))
        })
        output$plot1 = renderPlot({
                ggplot(selected_chicks(), aes(x=Time, y=weight, shape=Diet, color = Diet)) +
                        theme(panel.background = element_rect(fill = NA),
                              panel.grid.minor = element_line(color = NA),
                              panel.grid.major.x = element_line(color = NA),
                              panel.grid.major.y = element_line(color = "grey95"),
                              panel.border = element_rect(color = "black", fill = NA, size = 1),
                              plot.title = element_text(hjust = 0.5),
                              text = element_text(size = 10, color = "black", face = "bold"),
                              plot.caption = element_text(hjust = 0.5)) + 
                        geom_point(size=2) +
                        scale_shape_manual(values = c(1,16))+
                        labs(y = "Chick Weight (gm)",
                             x = "Day",
                             title = "Comparison of Chick Weights by Experimenatial Diet")
                
        })
}

# Run the application 
shinyApp(ui = ui, server = server)

