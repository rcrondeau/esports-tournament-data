#Scrape Events

#Get Results
i=1
evd.dt <- data.table()

for (i in 1:nrow(ev.dt)){
  url <- ev.dt$url[i]
  name <- ev.dt$Name[i]
  evd.url <- paste(c("https://www.esportsearnings.com", url), collapse = "")
  evd.html <- read_html(evd.url)
  evd.htmlinfo <- html_nodes(evd.html, '.detail_list_box')
  evd.info <- html_nodes(evd.htmlinfo, '.detail_list_box')
  evd.info1 <- 
  
  
  
  
}
evd.url
