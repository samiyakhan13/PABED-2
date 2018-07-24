library("shiny")
library(bigrquery)
library(devtools)
devtools::install_github("hadley/httr")
devtools::install_github("hadley/bigrquery")
devtools::install_github("s-u/PKI") #for SHA256
library(httr)

endpoint <- oauth_endpoints("google")
secrets <- jsonlite::fromJSON("bigrquery-token.json") #change if necessary
scope <- c("https://www.googleapis.com/auth/bigquery", "https://www.googleapis.com/auth/drive")

#Convert secrets$private_key from whatever it comes as from Google to RSA
#openssl must be installed
#I'm sure there is a more elegant way to do this
fileConn<-file("temp")
writeLines(secrets$private_key, fileConn)
close(fileConn)
system("openssl rsa -in temp -out temp2")
secrets$private_key <- scan("temp2",what="character",sep="\n")
system("rm temp")
system("rm temp2")

token <- httr::oauth_service_token(endpoint, secrets, scope)
bigrquery::set_access_cred(token)
##path <- "~/.bigrquery-token.json"
##has_auth <- file.exists(path)

##skip_if_no_auth <- function() {
##  if (!has_auth) {
##      skip("Authentication not available")
##  }
##}

##if (has_auth)
##set_service_token(path)

shinyServer <- function(input, output, session){

        output$linePlot <- renderPlot({

        if (input$button == 0)
        return()
        
        isolate({
            #Set Project parameters
            projectid <- input$pid
            databasename <- input$dbname
            #Set names to academic years 1 and 2
            academicyear1 <- input$ay1
            academicyear2 <- input$ay2
            #Set field names
            undergradenrol <- "UGDS"
            project <- projectid
            sql <- paste("SELECT SUM(CAST(", undergradenrol, " AS INTEGER)) AS Var1 FROM [", projectid, ":", databasename, ".", academicyear1, "] WHERE ", undergradenrol, " IS NOT NULL", sep="")
            
            x <- query_exec(sql, project = project)
            
            sql1 <- paste("SELECT SUM(CAST(", undergradenrol, " AS INTEGER)) AS Var2 FROM [", projectid, ":", databasename, ".", academicyear2, "] WHERE ", undergradenrol, " IS NOT NULL", sep="")
            
            y <- query_exec(sql1, project = project)
            
            UGDS <- c(x$Var, y$Var)
            
            maxval = max(x$Var, y$Var)
            minval = min(x$Var, y$Var)
            
            g_range <- range(minval, maxval)
            plot(UGDS, type="o", col="blue", ylim=g_range,
            axes=FALSE, ann=FALSE)
            
            # Make x axis
            axis(1, at=1:2, lab=c(academicyear1, academicyear2))

            # Create box around plot
            box()
            
            # Create a title with a red, bold/italic font
            title(main="Comparison of Undergraduate Enrollments", col.main="red", font.main=4)
            
            # Label the x and y axes with dark green text
            title(xlab="Year", col.lab=rgb(0,0.5,0))
            title(ylab="UG Enrollments", col.lab=rgb(0,0.5,0))
            
            disptext <- paste(x$Var, ", ", y$Var)

            legend("topright", c(disptext), cex=0.5, col=c("blue"), text.col=c("black"), lty=1,lwd=2,pch=4,bty="o", inset=0.01)

        })
    })
    
}