#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(jpeg)
library(here)
library(stringr)
library(reticulate)
library(RSocrata)
library(httr)
library(jsonlite)
occasion <- list("Formal", "Semi-Formal", "Business Casual", "Casual", "Athleisure", "Lounge")

color <- list("Color" = list("Neutral", "Color"))

places <- list("Fayetteville, Arkansas")

data <- readxl::read_excel(here::here("MakeMyOutfit/data", "hack.xlsx"))

### best working code chunk
my_auth_token <- "c07715f450534a45826144758221211"
call_api <- function(hosts){
  base_url <- "http://api.weatherapi.com/v1"
  # only change q='zipcode' for different areas
  call_url <- paste0("http://api.weatherapi.com/v1/forecast.json?key=c07715f450534a45826144758221211&q=72701&days=1&aqi=no&alerts=no") 
  message("Calling ", call_url)
  req <- GET(call_url)
  
  if(req$status_code != 200){
    stop("Problem with calling the API - response: ", content(req))
  }
  response_content <- rawToChar(content(req, 'raw'))
  json_response <- fromJSON(response_content)
  json_response
}
daily_temp <- call_api(forecast$forecastday$day$avgtemp_f)
weather <- daily_temp$forecast$forecastday$day$avgtemp_f

# Define UI for application
ui <- fluidPage(
    tags$script(HTML(
      "document.body.style.backgroundColor = 'pink';"
    )),
    # Application title
    titlePanel("Pick Your Outfit"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            selectInput("weather", "Current Location: Fayettevile, AR", choices = weather), 
            sliderInput("freq", "Comfortability:", min = 0, max = 5, value = 0),
            selectInput("occasion", "Choose an occasion:", 
                        choices = data$occasion, selected = "none")
        ),

        # 
           mainPanel(
             imageOutput("outfit")
           )
        )
    )

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  # Send a pre-rendered image, and don't delete the image after sending it
  # NOTE: For this example to work, it would require files in a subdirectory
  # named images/
    
  output$outfit <- renderImage({
      list(
        filename <- normalizePath(file.path(here::here("MakeMyOutfit/clothes-photos"),
                                            paste(input$occasion, '.jpg', sep=''))))
        
        # Return a list containing the filename
        list(src = filename, height = 700)
      
    }, deleteFile = FALSE)
  
}


  
shinyApp(ui = ui, server = server)

