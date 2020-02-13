library(shiny)
library(DT)

io_table <- as.data.frame(read.csv(file="InterventionOutcomesR.csv", header=TRUE, na.strings = ""))

categorical <- c("StudyName", "Include", "Design", "IndependentVariable", "IndependentType",
                 "DependentVariable", "DependentType", "DependentSubType", "LinkType",
                 "ExperimentalGroup", "ExperimentalGroup2", "ExperimentalGroup3",
                 "ControlGroup", "AgeGroup", "CognitiveStatus")

numerical <- c("TotalSampleSize", "InterventionDuration", "ExperimentalGroupN",
               "ExperimentalGroup2N", "ExperimentalGroup3N", "ControlGroupN", "MeanAge",
               "PercFemale")


ui <- fluidPage(
  
  h2("Intervention Outcomes Data"),
  
  sidebarLayout(
    
    sidebarPanel(
      selectInput("plotType", "Plot type", 
                  c("bar", "histogram", "box", "scatter")
      ),
      conditionalPanel(
        condition = "input.plotType == 'bar'",
        selectInput("barCol", "Categorical Value", categorical)
      ),
      conditionalPanel(
        condition = "input.plotType == 'histogram'",
        selectInput("histCol", "Numerical Value", numerical)
      ),
      conditionalPanel(
        condition = "input.plotType == 'box'",
        selectInput("boxCol1", "Categorical Value", categorical),
        selectInput("boxCol2", "Numerical Value", numerical)
      ),
      conditionalPanel(
        condition = "input.plotType == 'scatter'",
        selectInput("scatterCol1", "Numerical Value 1", numerical),
        selectInput("scatterCol2", "Numerical Value 2", numerical)
      )
    ),
    
    mainPanel(
      plotOutput("mainPlot"),
    )
  ),
  DT::dataTableOutput("mytable")
)

server <- function(input, output) {
  
  output$mytable <- DT::renderDT({
    DT::datatable(io_table, filter = "top", options = list(pageLength = 10,
                                                           sDom  = '<"top">lrt<"bottom">ip',
                                                           scrollX=TRUE,
                                                           autoWidth = TRUE,
                                                           columnDefs = list(list(width = '150px', targets = c(1: 23)))
                                                           )
                  )
  })

  output$mainPlot <- renderPlot({
    
    if (input$plotType == "bar"){
      interestCol <- input$barCol
      val <- io_table[input$mytable_rows_all, interestCol]
      tbl <- as.data.frame(table(val))
      plt <- barplot(tbl$Freq, ylab = "Frequency", xlab = interestCol)
      axis(1, at=plt, labels = tbl$val)
    }
    
    if (input$plotType == "histogram"){
      interestCol <- input$histCol
      val <- io_table[input$mytable_rows_all, interestCol]
      numVal <- as.numeric(val)
      hist(numVal, main = "Histogram", xlab = interestCol)
    }
    
    if (input$plotType == "box"){
      catCol <- input$boxCol1
      numCol <- input$boxCol2
      cat <- io_table[input$mytable_rows_all, catCol]
      num <- as.numeric(io_table[input$mytable_rows_all, numCol])
      df <- data.frame(cat, num)
      names(df) <- c("categorical", "numerical")
      boxplot(numerical ~ categorical, data = df)
    }
    
    if (input$plotType == "scatter"){
      numCol1 <- input$scatterCol1
      numCol2 <- input$scatterCol2
      num1 <- as.numeric(io_table[input$mytable_rows_all, numCol1])
      num2 <- as.numeric(io_table[input$mytable_rows_all, numCol2])
      plot(num1, num2, ylab = numCol2, xlab = numCol1)
    }
  })
}

shinyApp(ui, server)