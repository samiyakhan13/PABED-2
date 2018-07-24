library(shiny)
library(shinydashboard)
library(bigrquery)

header <- dashboardHeader(title = "PABED")

textareaInput <- function(inputId, label, value="", placeholder="", rows=2){
    tagList(
    div(strong(label), style="margin-top: 5px;"),
    tags$style(type="text/css", "textarea {width:100%; margin-top: 5px;}"),
    tags$textarea(id = inputId, placeholder = placeholder, rows = rows, value))
}

sidebar <- dashboardSidebar(
disable = TRUE
)

body <- dashboardBody(
fluidRow(
tabBox(width = 12,
tabPanel(tagList(shiny::icon("info-circle"), "UG Enrollments"),
fluidRow(
box(title="Inputs", status = "info", width=12, solidHeader = T,
textInput("pid", "Please Enter BigQuery Project ID*"),
textInput("dbname", "Please Enter Database Name*"),
textInput("ay1", "Please Enter Academic Year - 1"),
textInput("ay2", "Please Enter Academic Year - 2"),
actionButton("button", "Submit"),
##textInput("bq_sql", "Please Enter BigQuery SQL Here"),
##textareaInput("bq_sql", "Enter BigQuery SQL Here", rows=4),
helpText("*Please enter all the values")
)
),
fluidRow(
box(title = "Result & Analysis",
status = "success", width = 12, solidHeader = T,
plotOutput("linePlot", height = "600px"),
br()
)
)
## conditionalPanel
),## tabPanel
br()
)
),
br(),
helpText("PABED is an open-source project. The code is available at GitHub.")
)

dashboardPage(header, sidebar, body, skin = "black")
