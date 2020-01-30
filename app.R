library(shiny)
library(DT)

io_table <- as.data.frame(read.csv(file="InterventionOutcomesR.csv", header=TRUE, na.strings=c(""," ","NA")))

ui <- basicPage(
  h2("Intervention Outcomes data"),
  DT::dataTableOutput("mytable")
)

server <- function(input, output) {
  output$mytable = DT::renderDataTable({
    DT::datatable(io_table, filter = "top", options = list(pageLength = 140))
  })
}

shinyApp(ui, server)