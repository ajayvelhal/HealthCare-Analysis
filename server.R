library(shiny)

# Define UI for application that draws a histogram
library(shinydashboard)


server <-shinyServer(function(input, output,session) {
  data <- reactive({ 
    req(input$file_da) ## ?req #  require that the input is available
    
    inFile <- input$file_da 
    
    df <- read.csv(inFile$datapath, header = T, sep = ',')
    colnames(df) <- c("Diseases","Month","Year","Admitted_Male","Admitted_Female","Admitted_Male_Child","Admitted_Female_Child","Death_male","Death_Female","Death_Male_Child","Death_Female_Child")
    
    
    output$da <- renderPlot({
      text <- readLines(inFile$datapath)
      docs<- Corpus(VectorSource(text))
      inspect(docs)
      
      toSpace<- content_transformer(function(x,pattern)gsub(pattern,"",x))
      docs<-tm_map(docs,toSpace,"/")
      docs<-tm_map(docs,toSpace,"@")
      docs<-tm_map(docs,content_transformer(tolower))
      docs<-tm_map(docs,removeNumbers)
      docs<-tm_map(docs,removeWords,stopwords("english"))
      docs<-tm_map(docs,removeWords,c("blabla1","blabla2"))
      docs<-tm_map(docs,removePunctuation)
      docs<-tm_map(docs,stripWhitespace)
      docs<-tm_map(docs,stemDocument)
      
      dtm<-TermDocumentMatrix(docs)
      m<-as.matrix(dtm)
      
      v<-sort(rowSums(m),decreasing = TRUE)
      d<-data.frame(word=names(v),freq=v)
      head(d,2)
      set.seed(1234)
      
      wordcloud(words=d$word,freq=d$freq,min.freq=1,max.words=100,
                random.order=FALSE,rot.per=0.30,
                colors=brewer.pal(8,"Dark2"))
      
    })
    
    updateSelectInput(session,inputId = 'month', label='Select Month', choices = df$Month, selected = df$Month)
    updateSelectInput(session,inputId = 'year1', label='Select Year', choices = df$Year, selected = df$Year)
    updateSelectInput(session,inputId = 'year2', label='Select Year', choices = df$Year, selected = df$Year)
    updateSelectInput(session,inputId = 'disease', label='Select Disease', choices = df$Diseases, selected = df$Diseases)
    return(df)
    
    
  })
  
  
  observe({
    res<- data()%>%filter(data()$Month == input$month & data()$Year == input$year1) %>% select(Diseases,Admitted_Male)
    result<-data.frame(list(c(res)))
    #print(result)
    
    plot2<- data()%>%filter(data()$Disease == input$disease & data()$Year == input$year1) %>% select(Month,Admitted_Male,Admitted_Female,Admitted_Male_Child,Admitted_Female_Child)
    plot2dis<- data.frame(list(c(plot2)))
    #plot2dis$month<- factor(plot2dis$month,levels = month.abb)
    #print(input$month)
    print(plot2dis)
    
    #plot_trans<- as.data.frame(t(plot2dis))
    #print(plot_trans)
    
    #group_by(plot2dis,variable_name="condition")
    
    #plot2dis$facet <- row.names(plot2dis)
    
    #plot2dis.long <- melt(plot2dis,"facet")
    #print(plot2dis.long)
    
    output$plot1<- renderPlot({
      ggplot(result,aes(Diseases,Admitted_Male)) + geom_point() + theme_classic()
      
    })
    
    colours <- c("red", "orange", "blue")
    
    #bp <- barplot(as.data.frame.matrix(plot2dis),main = "My Bar Plot",ylab="Numbers",cex.lab=1.5,cex.main=1.4,beside=TRUE,col = colours)
    
    #barplot(t(plot2dis), beside=TRUE, 
     #       legend.text = TRUE, col = c("red", "green"), 
      #      args.legend = list(x = "topleft", bty = "n", inset=c(-0.05, 0)))
    #print(plot2dis)
    
    output$view_male<- renderPlot({
     ggplot(plot2dis,aes(x=Month,y=Admitted_Male)) + geom_bar(stat="identity") 
    })
    
    output$view_female<- renderPlot({
      ggplot(plot2dis,aes(x=Month,y=Admitted_Female)) + geom_bar(stat="identity") 
    })
    output$view_male_child<- renderPlot({
      ggplot(plot2dis,aes(x=Month,y=Admitted_Male_Child)) + geom_bar(stat="identity") 
    })
    output$view_female_child <- renderPlot({
      ggplot(plot2dis,aes(x=Month,y=Admitted_Female_Child)) + geom_bar(stat="identity") 
    })
  })
  
})

# Run the application 
#shinyApp(ui = ui, server = server)
