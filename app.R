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

splitCategories <- c("Include", "Design", "LinkType", "AgeGroup")

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
        selectInput("histCol", "Numerical Value", numerical),
        checkboxInput("proportion_hist", "Proportions", value = FALSE)
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
      ),
      checkboxInput("split", "Split Current Values", value = FALSE),
      conditionalPanel(
        condition = "input.split == 1",
        selectInput("splitCol", "Split Category", splitCategories)
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
    
    if (input$split == 1){
      
      tbl <- io_table[input$mytable_rows_all,]
      attach(tbl)
      
      if (input$plotType == "bar"){
        if (input$splitCol == "Include"){
          
          par(mfrow=c(2,1))
          val_N <- tbl[tbl[,"Include"] == "N", input$barCol]
          val_Y <- tbl[tbl[,"Include"] == "Y", input$barCol]
          tbl_N <- as.data.frame(table(val_N))
          tbl_Y <- as.data.frame(table(val_Y))
          
          if (input$proportion == TRUE){
            tbl_N$Freq <- round(tbl_N$Freq/(sum(tbl_N$Freq)), 2)
            tbl_Y$Freq <- round(tbl_Y$Freq/(sum(tbl_Y$Freq)), 2)
          }
          
          plt <- barplot(tbl_N$Freq, ylab = "Frequency", main = paste("Include = N"), ylim = c(0, 1.3*max(tbl_N$Freq)))
          text(x = plt, y = tbl_N$Freq, label = tbl_N$Freq, pos = 3, cex = 0.8, offset = .5)
          axis(1, at=plt, labels = tbl_N$val)
          plt2 <- barplot(tbl_Y$Freq, ylab = "Frequency", main = paste("Include = Y"), ylim = c(0, 1.3*max(tbl_Y$Freq)))
          text(x = plt, y = tbl_Y$Freq, label = tbl_Y$Freq, pos = 3, cex = 0.8, offset = .5)
          axis(1, at=plt, labels = tbl_Y$val)
        }
        if (input$splitCol == "Design"){
          
          par(mfrow=c(3,1))
          val_Acute <- tbl[tbl[,"Design"] == "Acute", input$barCol]
          val_Intervention <- tbl[tbl[,"Design"] == "Intervention", input$barCol]
          val_NA <- tbl[tbl[,"Design"] == "NA", input$barCol]
          tbl_Acute <- as.data.frame(table(val_Acute))
          tbl_Intervention <- as.data.frame(table(val_Intervention))
          tbl_NA <- as.data.frame(table(val_NA))
          
          if (input$proportion == TRUE){
            tbl_Acute$Freq <- round(tbl_Acute$Freq/(sum(tbl_Acute$Freq)), 2)
            tbl_Intervention$Freq <- round(tbl_Intervention$Freq/(sum(tbl_Intervention$Freq)), 2)
            tbl_NA$Freq <- round(tbl_NA$Freq/(sum(tbl_NA$Freq)), 2)
          }
          
          plt <- barplot(tbl_Acute$Freq, ylab = "Frequency", main = paste("Design = Acute"), ylim = c(0, 1.3*max(tbl_Acute$Freq)))
          text(x = plt, y = tbl_Acute$Freq, label = tbl_Acute$Freq, pos = 3, cex = 0.8, offset = .5)
          axis(1, at=plt, labels = tbl_Acute$val)
          plt2 <- barplot(tbl_Intervention$Freq, ylab = "Frequency", main = paste("Design = Intervention"), ylim = c(0, 1.3*max(tbl_Intervention$Freq)))
          text(x = plt, y = tbl_Intervention$Freq, label = tbl_Intervention$Freq, pos = 3, cex = 0.8, offset = .5)
          axis(1, at=plt, labels = tbl_Intervention$val)
          plt3 <- barplot(tbl_NA$Freq, ylab = "Frequency", main = paste("Design = NA"), ylim = c(0, 1.3*max(tbl_NA$Freq)))
          text(x = plt, y = tbl_NA$Freq, label = tbl_NA$Freq, pos = 3, cex = 0.8, offset = .5)
          axis(1, at=plt, labels = tbl_NA$val)
        }
        if (input$splitCol == "LinkType"){
          
          par(mfrow=c(3,1))
          val_Positive <- tbl[tbl[,"LinkType"] == "Positive", input$barCol]
          val_Null <- tbl[tbl[,"LinkType"] == "NULL", input$barCol]
          val_NA <- tbl[tbl[,"LinkType"] == "NA", input$barCol]
          tbl_Positive <- as.data.frame(table(val_Positive))
          tbl_Null <- as.data.frame(table(val_Null))
          tbl_NA <- as.data.frame(table(val_NA))
          
          if (input$proportion == TRUE){
            tbl_Positive$Freq <- round(tbl_Positive$Freq/(sum(tbl_Positive$Freq)), 2)
            tbl_Null$Freq <- round(tbl_Null$Freq/(sum(tbl_Null$Freq)), 2)
            tbl_NA$Freq <- round(tbl_NA$Freq/(sum(tbl_NA$Freq)), 2)
          }
          
          plt <- barplot(tbl_Positive$Freq, ylab = "Frequency", main = paste("LinkType = Positive"), ylim = c(0, 1.3*max(tbl_Positive$Freq)))
          text(x = plt, y = tbl_Positive$Freq, label = tbl_Positive$Freq, pos = 3, cex = 1, offset = .5)
          axis(1, at=plt, labels = tbl_Positive$val)
          plt2 <- barplot(tbl_Null$Freq, ylab = "Frequency", main = paste("LinkType = NULL"), ylim = c(0, 1.3*max(tbl_Null$Freq)))
          text(x = plt, y = tbl_Null$Freq, label = tbl_Null$Freq, pos = 3, cex = 1, offset = .5)
          axis(1, at=plt, labels = tbl_Null$val)
          plt3 <- barplot(tbl_NA$Freq, ylab = "Frequency", main = paste("LinkType = NA"), ylim = c(0, 1.3*max(tbl_NA$Freq)))
          text(x = plt, y = tbl_NA$Freq, label = tbl_NA$Freq, pos = 3, cex = 1, offset = .5)
          axis(1, at=plt, labels = tbl_NA$val)
        }
        if (input$splitCol == "AgeGroup"){
          
          par(mfrow=c(3,1))
          val_Middle <- tbl[tbl[,"AgeGroup"] == "Middle", input$barCol]
          val_Older <- tbl[tbl[,"AgeGroup"] == "Older", input$barCol]
          val_NA <- tbl[tbl[,"AgeGroup"] == "NA", input$barCol]
          tbl_Middle <- as.data.frame(table(val_Middle))
          tbl_Older <- as.data.frame(table(val_Older))
          tbl_NA <- as.data.frame(table(val_NA))
          
          if (input$proportion == TRUE){
            tbl_Middle$Freq <- round(tbl_Middle$Freq/(sum(tbl_Middle$Freq)), 2)
            tbl_Older$Freq <- round(tbl_Older$Freq/(sum(tbl_Older$Freq)), 2)
            tbl_NA$Freq <- round(tbl_NA$Freq/(sum(tbl_NA$Freq)), 2)
          }
          
          plt <- barplot(tbl_Middle$Freq, ylab = "Frequency", main = paste("AgeGroup = Middle"), ylim = c(0, 1.3*max(tbl_Middle$Freq)))
          text(x = plt, y = tbl_Middle$Freq, label = tbl_Middle$Freq, pos = 3, cex = 1, offset = .5)
          axis(1, at=plt, labels = tbl_Middle$val)
          plt2 <- barplot(tbl_Older$Freq, ylab = "Frequency", main = paste("AgeGroup = Older"), ylim = c(0, 1.3*max(tbl_Older$Freq)))
          text(x = plt, y = tbl_Older$Freq, label = tbl_Older$Freq, pos = 3, cex = 1, offset = .5)
          axis(1, at=plt, labels = tbl_Older$val)
          plt3 <- barplot(tbl_NA$Freq, ylab = "Frequency", main = paste("AgeGroup = NA"), ylim = c(0, 1.3*max(tbl_NA$Freq)))
          text(x = plt, y = tbl_NA$Freq, label = tbl_NA$Freq, pos = 3, cex = 1, offset = .5)
          axis(1, at=plt, labels = tbl_NA$val)
        }
      }
      if (input$plotType == "hist"){
        
      }
    } else{
    
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
        par(mai=c(0.5,0.82,0.82,0.42))
        plt <- hist(numVal, main = paste("Histogram of", interestCol, sep = " "), labels = FALSE)
        if (input$proportion_hist == TRUE){
          new_label = round(plt$counts/sum(plt$counts), 2)
          text(x = plt$mids, y = plt$counts, label = new_label, pos = 3, cex = 0.8, offset = 0.1)
        } else {
          text(x = plt$mids, y = plt$counts, label = plt$counts, pos = 3, cex = 0.8, offset = 0.1)
        }
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
    }
  }, width = 1500, height = 425)

  
}

shinyApp(ui, server)