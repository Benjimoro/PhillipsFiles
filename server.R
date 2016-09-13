#Clemson Watts Center light plot app Server
#
#Author: Ben B. Warner
#Last mod: 2/24/2016

library(shiny)

shinyServer(
  function(input, output, session) {
    output$power<-renderUI({
      luminPow<<-dbGetQuery(wficConn, statement = sprintf("SELECT AVG([power_max])
          FROM [ClemsonWFICv1_trend].[dbo].[luminaire_dimension] WHERE hierarchy_id = %s",
          roomList$id[roomList$name==input$roomPick]))
      helpText(strong("Avg. Max Power per light [W]:"),luminPow)
    })
    output$burn<-renderUI({
      luminBurn<<-dbGetQuery(wficConn, statement = sprintf("SELECT AVG([burn_hour])
          FROM [ClemsonWFICv1_trend].[dbo].[luminaire_dimension] WHERE hierarchy_id = %s",
          roomList$id[roomList$name==input$roomPick]))
      helpText(strong("Avg. Burn hours per light [h]:"), luminBurn)
    })
    output$Occu<-renderUI({
      currentHourYesterday<-as.POSIXct(format(Sys.time(), "%Y-%m-%d %H:00:00.0"),format="%Y-%m-%d %H:%M:%S")-(24*3600)
      powerSum<-powerData()
      powerLast<-powerSum$powerDate[powerSum$the_date==currentHourYesterday]
      isOccup="Yes"
      if(powerLast < 0.04){
        isOccup = "No"
      }
      helpText(strong("Occupied:"), isOccup)
    })
##### Reactive data sets
    weatherData<-reactive({
      input$roomPick
      weatherStats<-dbGetQuery(wficConn, statement = "SELECT [date]
        ,[date_time],[description],[icon_url],[temperature_max_c]
        ,[temperature_min_c],[temperature_max_f],[temperature_min_f]
        ,[source],[weather_code] FROM [ClemsonWFICv1_trend].[dbo].[weather_status];")
      return(weatherStats)
    })
    weatherAvgF<-reactive({
      input$roomPick
      weatherAvgF<-dbGetQuery(wficConn, statement = "SELECT
         [date],SUM([temperature_max_f]+[temperature_min_f])/2 as [avg_temp]
         FROM [ClemsonWFICv1_trend].[dbo].[weather_status] group by date;")
      return(weatherAvgF)
    })
    powerSumDay<-reactive({
      input$roomPick
      powerSumD<<-dbGetQuery(wficConn, statement = sprintf("SELECT [date]
                ,SUM([power_last]) as [powerDate]
                FROM [ClemsonWFICv1_trend].[dbo].[v_power_fact_date] 
                where hierarchy_id=%s group by date order by date",
                roomList$id[roomList$name==input$roomPick]))
      return(powerSumD)
    })
    powerData<-reactive({
      input$roomPick
        powerStats<<-dbGetQuery(wficConn, statement = sprintf("SELECT [the_date]
          ,[luminaire_id],[hierarchy_id],[day_type_id],[power_total]
          ,[power_last],[acc_energy_last],[acc_minute_last]
          FROM [ClemsonWFICv1_trend].[dbo].[v_power_fact_date] WHERE hierarchy_id = %s",
          roomList$id[roomList$name==input$roomPick]))
      
     ###sum by luminaire_id
        powerSum<<-dbGetQuery(wficConn, statement = sprintf("SELECT [the_date]
            ,SUM([power_last]) as [powerDate]
            FROM [ClemsonWFICv1_trend].[dbo].[v_power_fact_date] where hierarchy_id=%s group by the_date",
            roomList$id[roomList$name==input$roomPick]))
        return(powerSum)
    })
#### Dynamic plots
    output$powerPlot<- renderDygraph({
      powerData<-powerData()
      dygraph(as.data.frame(powerData$powerDate,powerData$the_date),group=1)%>%
        dySeries("powerData$powerDate", label="Power [kW]")
    })
    output$weatherPlot<- renderDygraph({
      weatherData<-weatherData()
      dygraph(as.data.frame(cbind(weatherData$temperature_max_f,weatherData$temperature_min_f),weatherData$date),group=1)%>%
        dySeries("V1", label="Max Temp [F]")%>%dySeries("V2", label="Min Temp [F]")%>%
        dyRangeSelector
    })
    output$comparePlot<-renderPlot({
      power<-powerSumDay()
      weather<-weatherAvgF()
      
      y <<- power$powerDate[15:103]
      x <<- weather$avg_temp[21:109]
      yout <- y<.5
      plot(x,y,xlab='temperature [F]',ylab='power [kW]')
      lines(lowess(x,y), col="blue")
      lines(lowess(x[!yout],y[!yout]), col="red")
    })
    
  })