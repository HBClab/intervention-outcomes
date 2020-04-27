library(shiny)
library(DT)
library(ggplot2)
library(markdown)

ref <- as.data.frame(read.csv(file="pano_intervention_references.csv", header = TRUE))
io_table <- as.data.frame(read.csv(file="InterventionOutcomesRFull.csv", header=TRUE, na.strings = "NaN"))

categorical <- c("StudyName", "Include", "Design", "IndependentVariable", "IndependentType",
                 "DependentVariable", "DependentType", "DependentSubType", "LinkType",
                 "ExperimentalGroup", "ExperimentalGroup2", "ExperimentalGroup3",
                 "ControlGroup", "AgeGroup", "CognitiveStatus", "TestType", "TestTypeSub",
                 "FitnessMeasure", "InterventionIntensity", "ConversionToNorton2010",
                 "IntensityAdherence", "TrueInterventionToincreaseFtiness.")

numerical <- c("TotalSampleSize", "InterventionDuration", "ExperimentalGroupN",
               "ExperimentalGroup2N", "ExperimentalGroup3N", "ControlGroupN", "MeanAge",
               "PercFemale", "BMIBaseline", "SessionAdherence", "ChangeinFM",
               "ChangeinFMStandardized", "SessionsPerWeek", "DurationInMinutes", "WeeklyMinutes")

hidden_col_indices <- c(10,12,13,14,15,16,17,18,19,20,21,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40)

splitCategories <- c("Include", "Design", "LinkType", "AgeGroup")

# Fix slider increments
io_table$TotalSampleSize <- as.integer(io_table$TotalSampleSize)
io_table$InterventionDuration <- as.integer(io_table$InterventionDuration)
io_table$ExperimentalGroupN <- as.integer(io_table$ExperimentalGroupN)
io_table$ExperimentalGroup2N <- as.integer(io_table$ExperimentalGroup2N)
io_table$ExperimentalGroup3N <- as.integer(io_table$ExperimentalGroup3N)
io_table$ControlGroupN <- as.integer(io_table$ControlGroupN)

ui <- navbarPage("PANO",
  
  tabPanel("Plot",
  
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
  ),
  
  tabPanel("References",
           DT::dataTableOutput("reference_table")),
  
  tabPanel("About",
           includeMarkdown("about.md"))
)

server <- function(input, output) {
  
  output$mytable <- DT::renderDT({
    DT::datatable(io_table, filter = "top", options = list(pageLength = 10,
                                                           sDom  = '<"top">lrt<"bottom">ip',
                                                           columnDefs = list(list(visible=FALSE, targets=hidden_col_indices))
                                                           )
                  )
  })
  
  output$reference_table <- DT::renderDT({
    tbl <- io_table[input$mytable_rows_all, "refID"]
    DT::datatable(ref[ref$refID %in% tbl,], options = list(pageLength = 10)
    )
  })

  output$mainPlot <- renderPlot({
    
    if (input$split == 1){
      
      interestCol <- input$barCol
      tbl <- data.frame(io_table[input$mytable_rows_all, ])
      
      if (input$plotType == "bar"){
        plt <- ggplot(tbl, aes(x=tbl[,interestCol])) + geom_bar() +
          theme(axis.text.x = element_text(angle = 90, hjust=1)) + xlab("") +
          ylab("Frequency") +
          facet_wrap(~ tbl[,input$splitCol])
        
        if (input$proportion ==TRUE){
          print(plt + geom_text(stat='count', aes(label=round(..count../sum(..count..), 2)), vjust=-1)
          )
        } else{
          print(plt + geom_text(stat='count', aes(label=..count..), vjust=-1)
          )
        }
        
      }
      if (input$plotType == "histogram"){
        plt <- ggplot(tbl, aes(x=as.numeric(tbl[,interestCol]))) +
          geom_histogram() +
          facet_wrap(~ tbl[,input$splitCol])
        
        if (input$proportion_hist ==TRUE){
          print(plt + stat_bin(geom="text", aes(label=round(..count../sum(..count..), 2)), vjust = -1)
          )
        } else{
          print(plt + stat_bin(geom="text", aes(label=round(..count..,2)), vjust = -1)
          )
        }
        
      }
    } else{
    
      if (input$plotType == "bar"){
        interestCol <- input$barCol
        tbl <- data.frame(io_table[input$mytable_rows_all,])
        
        plt <- ggplot(tbl, aes(x= tbl[,interestCol])) +
                geom_bar() +
                theme(axis.text.x = element_text(angle = 90, hjust=1)) +
                xlab("") + ylab("Frequency") +
                ggtitle(paste("Bar Plot of", interestCol))
        
        
        if (input$proportion ==TRUE){
          print(plt + geom_text(stat='count', aes(label=round(..count../sum(..count..), 2)), vjust=-1)
          )
        } else{
          print(plt + geom_text(stat='count', aes(label=..count..), vjust=-1)
          )
        }
      }
      
      if (input$plotType == "histogram"){
        interestCol <- input$histCol
        tbl <- data.frame(io_table[input$mytable_rows_all,])

        plt <- ggplot(tbl, aes(x=tbl[,interestCol])) + geom_histogram() +
          xlab("") + ylab("Frequency")
        
        if (input$proportion_hist ==TRUE){
          print(plt + stat_bin(geom="text", aes(label=round(..count../sum(..count..), 2)), vjust = -1)
            )
        } else{
          print(plt + stat_bin(geom="text", aes(label=round(..count..,2)), vjust = -1)
            )
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
  }, width = 1200, height = 425)

  
}

shinyApp(ui, server)