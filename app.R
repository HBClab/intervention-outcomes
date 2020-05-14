library(shiny)
library(DT)
library(ggplot2)
library(markdown)
library(dplyr)

ref <- as.data.frame(read.csv(file="pano_intervention_references.csv", header = TRUE))
io_table <- as.data.frame(read.csv(file="InterventionOutcomesRFull.csv", header=TRUE,
                                   na.strings = "NaN"))

categorical <- c("StudyName", "Include", "Design", "IndependentVariable", "IndependentType",
                 "DependentVariable", "DependentType", "DependentSubType", "LinkType",
                 "ExperimentalGroup", "ExperimentalGroup2", "ExperimentalGroup3",
                 "ControlGroup", "AgeGroup", "CognitiveStatus", "TestType", "ChangeinFM",
                 "TestTypeSub", "FitnessMeasure", "InterventionIntensity", "ConversionToNorton2010",
                 "IntensityAdherence", "TrueInterventionToincreaseFitness.")

numerical <- c("TotalSampleSize", "InterventionDuration", "ExperimentalGroupN",
               "ExperimentalGroup2N", "ExperimentalGroup3N", "ControlGroupN", "MeanAge",
               "PercFemale", "BMIBaseline", "SessionAdherence",
               "ChangeinFMStandardized", "SessionsPerWeek", "DurationInMinutes", "WeeklyMinutes")

hidden_col_indices <- c(10,12,13,14,15,16,17,18,19,20,21,24,25,26,27,28,29,30,31,32,33,
                        34,35,36,37,38,39,40,41,42,43,44,45,46)

splitCategories <- c("Design","IndependentVariable", "IndependentType", "DependentVariable",
                     "DependentType", "DependentSubType", "LinkType", "ExperimentalGroup",
                     "ControlGroup", "AgeGroup", "CognitiveStatus", "TestType", "TestTypeSub",
                     "FitnessMeasure", "ConversionToNorton2010", "ConversionToGarber2011",
                     "IntensityAdherence", "TrueInterventionToincreaseFitness.")

numToCat <- c("InterventionDurationCategorical", "PercFemaleCategorical", "BMIBaselineCategorical",
              "SessionAdherenceCategorical", "ChangeinFMStandardizedCategorical",
              "WeeklyMinutesCategorical")

# Fix slider incrementsA
io_table$InterventionDuration <- as.integer(io_table$InterventionDuration)

# Create numerical -> categorical cols
io_table$InterventionDurationCategorical <- cut(io_table$InterventionDuration, c(0, 11.99,
                                                                                 23.99, 1000))
levels(io_table$InterventionDurationCategorical) <- c("short (<12 weeks)", "medium (12-24 weeks)",
                                                     "long (>24 weeks)")
io_table$PercFemaleCategorical <- cut(io_table$PercFemale, c(-1, 49, 51, 101))
levels(io_table$PercFemaleCategorical) <- c("majority men", "equal men/women N",
                                                      "majority women")
io_table$BMIBaselineCategorical <- cut(io_table$BMIBaseline, c(0, 18.5, 24.9, 29.9, 50))
levels(io_table$BMIBaselineCategorical) <- c("underweight", "normal weight",
                                            "overweight", "obese")
io_table$SessionAdherenceCategorical <- cut(io_table$SessionAdherence, c(0, 60, 74, 89, 101))
levels(io_table$SessionAdherenceCategorical) <- c("poor", "fair",
                                             "moderate", "excellent")
io_table$ChangeinFMStandardizedCategorical <- cut(io_table$ChangeinFMStandardized, c(-10, -.001,
                                                                                     .001, 10))
levels(io_table$ChangeinFMStandardizedCategorical) <- c("decrease", "no change", "increase")
io_table$WeeklyMinutesCategorical <- cut(io_table$WeeklyMinutes, c(0, 150, 1000))
levels(io_table$WeeklyMinutesCategorical) <- c("below 150 minutes/week",
                                                        "at or above 150 minutes/week")




ui <- navbarPage("PANO",
  
  tabPanel("Plot",
  
    sidebarLayout(
      
      sidebarPanel(
        
        selectInput("plotType", "Plot type", 
                    c("bar", "histogram", "heatmap", "box", "scatter")
        ),
        conditionalPanel(
          condition = "input.plotType == 'bar'",
          selectInput("barCol", "Categorical Value", c(categorical, numToCat)),
          checkboxInput("proportion", "Proportions", value = FALSE),
          checkboxInput("split", "Split Current Values", value = FALSE),
          conditionalPanel(
            condition = "input.split == '1'",
            selectInput("splitCol", "Split Category", c(splitCategories, numToCat))
          )
        ),
        conditionalPanel(
          condition = "input.plotType == 'histogram'",
          selectInput("histCol", "Numerical Value", numerical),
          checkboxInput("proportion_hist", "Proportions", value = FALSE),
          checkboxInput("split_hist", "Split Current Values", value = FALSE),
          conditionalPanel(
            condition = "input.split_hist == '1'",
            selectInput("splitColHist", "Split Category", c(splitCategories, numToCat))
          )
        ),
        conditionalPanel(
          condition = "input.plotType == 'heatmap'",
          selectInput("heatCol1", "Categorical Value X", c(categorical, numToCat)),
          selectInput("heatCol2", "Categorical Value Y", c(categorical[2:length(categorical)], numToCat)),
          checkboxInput("split_heat", "Split Current Values", value = FALSE),
          conditionalPanel(
            condition = "input.split_heat == '1'",
            selectInput("splitColHeat", "Split Category", c(splitCategories, numToCat))
          )
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
    DT::datatable(io_table, filter = "top",
                  options = list(pageLength = 10,
                                 sDom  = '<"top">lrt<"bottom">ip',
                                 columnDefs = list(list(visible=FALSE,
                                                        targets=hidden_col_indices))
                                                           )
                  )
  })
    
  output$reference_table <- DT::renderDT({
    tbl <- io_table[input$mytable_rows_all, "refID"]
    DT::datatable(ref[ref$refID %in% tbl,], options = list(pageLength = 10)
    )
  })

  output$mainPlot <- renderPlot({
    
    if (input$split == 1 & input$plotType == "bar"){
      
      interestCol <- input$barCol
      tbl <- data.frame(io_table[input$mytable_rows_all, ])
      
      plt <- ggplot(tbl, aes(x=tbl[,interestCol])) + geom_bar() +
        theme(axis.text.x = element_text(angle = 90, hjust=1)) + xlab(interestCol) +
        ylab("Frequency") +
        facet_wrap(~ tbl[,input$splitCol])
      
      if (input$proportion ==TRUE){
        print(plt + geom_text(stat='count', aes(label=round(..count../sum(..count..), 2)), vjust=-1)
        )
      } else{
        print(plt + geom_text(stat='count', aes(label=..count..), vjust=-1)
        )
      }

    } else if(input$split_hist == 1 & input$plotType == "histogram"){
      
      histCol <- input$histCol
      tbl <- data.frame(io_table[input$mytable_rows_all, ])
      
      plt <- ggplot(tbl, aes(x=as.numeric(tbl[,histCol]))) +
        geom_histogram() +
        facet_wrap(~ tbl[,input$splitColHist]) + xlab(histCol)
      
      if (input$proportion_hist ==TRUE){
        print(plt + stat_bin(geom="text", aes(label=round(..count../sum(..count..), 2)), vjust = -1)
        )
      } else{
        print(plt + stat_bin(geom="text", aes(label=round(..count..,2)), vjust = -1)
        )
      }
    } else if(input$split_heat == 1 & input$plotType == "heatmap"){
      
      tbl <- data.frame(io_table[input$mytable_rows_all, ])
      tbl_filt <- as.data.frame(select(tbl, input$heatCol1, input$heatCol2, input$splitColHeat))
      tbl_count <- as.data.frame(tbl_filt %>% count(tbl_filt[, input$heatCol1], 
                                                    tbl_filt[, input$heatCol2],
                                                    tbl_filt[, input$splitColHeat]))
      
      
      plt <- ggplot(data = tbl_count, mapping = aes(x = tbl_count[, 1],
                                                    y = tbl_count[, 2],
                                                    fill = tbl_count[, 4])) + geom_tile() +
        facet_wrap(~ tbl_count[, 3])
      print(plt + xlab(input$heatCol1) + ylab(input$heatCol2) +
              labs(fill = "Counts") + theme(axis.text.x = element_text(angle = 90, hjust=1)))
      
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
          xlab(interestCol) + ylab("Frequency")
        
        if (input$proportion_hist ==TRUE){
          print(plt + stat_bin(geom="text", aes(label=round(..count../sum(..count..), 2)), vjust = -1)
            )
        } else{
          print(plt + stat_bin(geom="text", aes(label=round(..count..,2)), vjust = -1)
            )
        }
      }
      
      if (input$plotType == "heatmap"){
        
        tbl <- data.frame(io_table[input$mytable_rows_all, ])
        tbl_filt <- as.data.frame(select(tbl, input$heatCol1, input$heatCol2))
        tbl_count <- as.data.frame(tbl_filt %>% count(tbl_filt[, input$heatCol1], 
                                                      tbl_filt[, input$heatCol2]))
        
        
        plt <- ggplot(data = tbl_count, mapping = aes(x = tbl_count[, 1],
                                            y = tbl_count[, 2],
                                            fill = tbl_count[, 3]))
        print(plt + geom_tile() + xlab(input$heatCol1) + ylab(input$heatCol2) +
                labs(fill = "Counts") + theme(axis.text.x = element_text(angle = 90, hjust=1)))
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