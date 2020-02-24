library(shiny)
library(DT)

io_table <- as.data.frame(read.csv(file="InterventionOutcomesR.csv", header=TRUE, na.strings = "NaN"))

categorical <- c("StudyName", "Include", "Design", "IndependentVariable", "IndependentType",
                 "DependentVariable", "DependentType", "DependentSubType", "LinkType",
                 "ExperimentalGroup", "ExperimentalGroup2", "ExperimentalGroup3",
                 "ControlGroup", "AgeGroup", "CognitiveStatus")

numerical <- c("TotalSampleSize", "InterventionDuration", "ExperimentalGroupN",
               "ExperimentalGroup2N", "ExperimentalGroup3N", "ControlGroupN", "MeanAge",
               "PercFemale")

# Fix slider increments
io_table$TotalSampleSize <- as.integer(io_table$TotalSampleSize)
io_table$InterventionDuration <- as.integer(io_table$InterventionDuration)
io_table$ExperimentalGroupN <- as.integer(io_table$ExperimentalGroupN)
io_table$ExperimentalGroup2N <- as.integer(io_table$ExperimentalGroup2N)
io_table$ExperimentalGroup3N <- as.integer(io_table$ExperimentalGroup3N)
io_table$ControlGroupN <- as.integer(io_table$ControlGroupN)

ui <- fluidPage(
  
  h2("Intervention Outcomes Data"),
  
  sidebarLayout(
    
    sidebarPanel(
      
      selectInput("plotType", "Plot type", 
                  c("bar", "histogram", "box", "scatter")
      ),
      conditionalPanel(
        condition = "input.plotType == 'bar'",
        selectInput("barCol", "Categorical Value", categorical),
        checkboxInput("proportion", "Proportions", value = FALSE)
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
                                                           sDom  = '<"top">lrt<"bottom">ip'
                                                           )
                  )
  })

  output$mainPlot <- renderPlot({
    
    if (input$plotType == "bar"){
      interestCol <- input$barCol
      val <- io_table[input$mytable_rows_all, interestCol]
      tbl <- as.data.frame(table(val))
      if (input$proportion == TRUE){
        tbl$Freq <- round(tbl$Freq/(sum(tbl$Freq)), 2)
      }
      plt <- barplot(tbl$Freq, ylab = "Frequency", main = paste("Bar Plot of", interestCol), ylim = c(0, 1.1*max(tbl$Freq)))
      text(x = plt, y = tbl$Freq, label = tbl$Freq, pos = 3, cex = 0.8, offset = .5)
      axis(1, at=plt, labels = tbl$val)
    }
    
    if (input$plotType == "histogram"){
      interestCol <- input$histCol
      val <- io_table[input$mytable_rows_all, interestCol]
      numVal <- as.numeric(val)
      par(mai=c(0.37,0.82,0.82,0.42))
      hist(numVal, main = paste("Histogram of", interestCol, sep = " "), labels = TRUE)
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