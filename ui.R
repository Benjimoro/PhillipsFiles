#Clemson Watts Center light plots app UI
#
#Author: Ben B. Warner
#Last mod: 4/14/2016

library(shiny)
library(dygraphs)

shinyUI(
  fluidPage(
          fluidRow(
            column(1),
            column(3,
              selectInput("roomPick", strong("Select WFIC Room:"),
                roomList$name,
                selected = roomList$name[6])),
            column(3,
              selectInput("interv",label = strong("Time interval:"),
                c("hour","day","week","month","year"),selected = "year"))),
          fluidRow(
            column(1),
            column(3,uiOutput('power')),column(3,uiOutput('burn')),column(3,uiOutput('Occu'))),
          fluidRow(
            column(1),
            column(9,
              strong("Daily Power Consumption per room:"),
              dygraphOutput("powerPlot",height="220px"),br(),
              strong("Exterior Max. and Min. Temperature:"),
              dygraphOutput("weatherPlot",height="250px"),br(),
              strong("Power Consumption as a function of Average Exterior Temp."),
              plotOutput("comparePlot",height="300px")))
    ))