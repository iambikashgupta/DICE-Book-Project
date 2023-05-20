# run the following libraries; if these libraries are not installed in
# your local machine, you will have to install them first

library(shiny)
library(dplyr)
library(ggplot2)
library(stringr)
library(htmltools)
library(shinythemes)
library(treemapify)
library(plotly)
library(shinydashboard)
library(DT)


# read the CSV file here
dice_library <- read.csv("dice_library.csv")

# Define UI
ui <- dashboardPage(
  
  dashboardHeader(
    title = "DICE Book Library"
  ),
  
#  
  dashboardSidebar(
    sidebarMenu(
      id = "sidebar",
      menuItem(
        "Search",
        tabName = "search",
        icon = icon("search"),
        startExpanded = TRUE,
        selected = TRUE,
        collapsible = TRUE,
        fluidRow(
          column(
            12,
            textInput("search_box", "Search by words"),
            selectInput("genre_box", "Select genre", choices = c("", sort(unique(dice_library$Genre)))),
            selectInput("author_box", "Select author", choices = c("", sort(unique(dice_library$Author))))
          )
        )
      )
    )
    ),
  
  dashboardBody(
    
    tabsetPanel(
      tabPanel('About',
        fluidRow(
          box(
            title = "Book Giveaway",
            status = "primary",
            solidHeader = TRUE,
            collapsible = TRUE,
            width = 12,
            p(
              "The Office of Diversity, Inclusion, Climate, and Equity (DICE) at Heinz proudly 
              recognizes and celebrates the rich history, diverse cultures, and invaluable 
              contributions made by numerous communities at our institution. 
              As part of our commitment, we meticulously curate a collection of books that 
              we enthusiastically offer to individuals who express interest. 
              In the spirit of commemoration, we have previously donated books during 
              significant occasions such as Women's History Month, Black History Month, 
              and Indigenous People's Day. Stay tuned for our informative emails, where we 
              provide a convenient Google form for avid readers to register their preferences 
              and receive these captivating books. Additionally, we are continuously enhancing 
              this dashboard to keep you updated on upcoming literary events and future giveaways.",
            br(),
          ),
            p(tags$b("How to use this Dashboard?"), br(),"Browse through our book database by leveraging the 
             search boxes on the sidebar to find (filter!) books we have or are anticipating to have at our library."),
          br(),
          tags$img(src = "dicelogo.png", height = "150px", width = "200px")
          )
        )
      ),
      
      tabPanel('Database', DT::dataTableOutput("book_table")),
      tabPanel('Current Genre Distribution', plotlyOutput("genre_plot"))
      )
 )
 
)
  

# Define server
server <- function(input, output) {
  
  # Filter data based on search term
  search_results <- reactive({
    if (input$search_box == "") {
      dice_library
    } else {
      dice_library %>%
        filter(str_detect(tolower(Title), tolower(input$search_box)) |
                 str_detect(tolower(Genre), tolower(input$search_box)) |
                 str_detect(tolower(Author), tolower(input$search_box)) |
                 str_detect(tolower(Notes), tolower(input$search_box)) |
                 str_detect(tolower(URL), tolower(input$search_box)))
    }
  })
  
  # Filter data based on selected genre
  genre_results <- reactive({
    if (input$genre_box == "") {
      dice_library
    } else {
      dice_library %>%
        filter(Genre == input$genre_box)
    }
  })
  
  # Filter data based on selected author
  author_results <- reactive({
    if (input$author_box == "") {
      dice_library
    } else {
      dice_library %>%
        filter(Author == input$author_box)
    }
  })
  
  # Filter data based on search by words
  words_results <- reactive({
    if (input$search_box == "") {
      dice_library
    } else {
      dice_library %>%
        filter(str_detect(tolower(Title), tolower(input$search_box)) |
                 str_detect(tolower(Genre), tolower(input$search_box)) |
                 str_detect(tolower(Author), tolower(input$search_box)) |
                 str_detect(tolower(Notes), tolower(input$search_box)) |
                 str_detect(tolower(URL), tolower(input$search_box)))
    }
  })
  
  
  # Generate plot of book genres as an interactive treemap
  output$genre_plot <- renderPlotly({
    genre_data <- dice_library %>% count(Genre)
    
    plot_ly(genre_data, labels = ~Genre, parents = "", values = ~n, type = 'treemap') %>%
      layout(title = "Current Book Genre Distribution",
             xaxis = list(showgrid = FALSE, zeroline = FALSE),
             yaxis = list(showgrid = FALSE, zeroline = FALSE))
  })
  
  
  output$book_table <- DT::renderDataTable({
    if (!is.null(input$search_box) && input$search_box != "") {
      words_results()
    } else if (!is.null(input$genre_box) && input$genre_box != "") {
      genre_results() 
    } else if (!is.null(input$author_box) && input$author_box != "") {
      author_results() 
    } else {
      dice_library 
    }
  })
  
}

# Run app
shinyApp(ui, server)

