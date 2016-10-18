#Clemson Watts Center light app Global
#
#Author: Ben B. Warner
#Last mod: 2/24/2016

library(shiny)
Sys.setenv(JAVA_HOME='C:\\Program Files\\Java\\jdk1.8.0_74\\jre')
#Sys.setenv(JAVA_HOME='\\usr\\lib\\jvm\\java-7-openjdk-amd64\\jre')
library(rJava)
library(RJDBC)
library(dygraphs)

drv <- JDBC("com.microsoft.sqlserver.jdbc.SQLServerDriver", "www/sqljdbc4.jar")
wficConn <- dbConnect(drv, "jdbc:sqlserver://wfic-envis-sql", "******", "********")

roomList<-dbGetQuery(wficConn, statement = "SELECT 
      [id],[name],[type],[reference],[is_root],[tenancy_id],[parent_id]
      FROM [ClemsonWFICv1_trend].[dbo].[hierarchy_dimension]")
roomList<-roomList[-c(1,2,3),]
