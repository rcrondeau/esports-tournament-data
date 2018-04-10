#Scrape ESport Earnings

ev.dt <- data.table()

#Get Events
for(season in c(1998, 1999, 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018)){
url = paste(c("https://www.esportsearnings.com/history/", season, "/list_events"), collapse = "")
ev.html <- read_html(url)
ev.content <- html_nodes(ev.html, '.content_main')
ev.htmltable <- html_nodes(ev.content, '.detail_list_table')
ev.url <- html_attr(html_nodes(ev.htmltable, "a"), "href")
ev.table <- html_table(ev.htmltable[[1]])
ev.table <- ev.table[-1, ]
names(ev.table) <- c("Date", "Name", "Total Prize")
ev.table$year <- season
ev.table$url <- ev.url
ev.dt <- rbind(ev.dt, ev.table)
print(season)
}

tourn.dt <- filter(ev.dt, !grepl("events",url))
events.dt <- filter(ev.dt, grepl("events",url))

events.dt.temp <- events.dt
tourn.dt.temp <- tourn.dt

tourn.temp <- data.table()

for(i in 1:nrow(events.dt.temp)) {
  tryCatch({
    url <- events.dt.temp$url[i]
    date <- events.dt.temp$Date[i]
    year <- events.dt.temp$year[i]
    event.url <- paste(c("https://www.esportsearnings.com", url), collapse = "")
    event.html <- read_html(event.url)
    event.htmlinfo <- html_nodes(event.html, '.content_main')
    event.info <- html_nodes(event.htmlinfo, '.detail_list_table')
    event.url <- html_attr(html_nodes(event.info, "a"), "href")
    event.url.dt <- data.table(event.url)
    names(event.url.dt) <- c("url")
    event.url.dt <- filter(event.url.dt, grepl("tournaments",url))
    event.table <- html_table(event.info[[1]])
    if (ncol(event.table) > 4) {
      event.table <- event.table[, c(2,4,5)] 
    } else {
      event.table <- event.table[, c(1,3,4)]
    }
    event.table$url <- flatten(event.url.dt)
    names(event.table) <- c("Name", "Total Prize","Game", "url")
    event.table$Date <- date
    event.table$year <- year
    tourn.temp <- rbind(tourn.temp, event.table)
    print(i) 
  }, error=function(e){}
  )
}


#Get Game for tourn.dt
for(i in 1:nrow(tourn.dt.temp)) {
  url <- tourn.dt.temp$url[i]
  date <- tourn.dt.temp$Date[i]
  year <- tourn.dt.temp$year[i]
  event.url <- paste(c("https://www.esportsearnings.com", url), collapse = "")
  event.html <- read_html(event.url)
  event.htmlinfo <- html_nodes(event.html, '.info_box')
  event.info <- html_node(event.htmlinfo, '.info_box_inner')
  event.info <- html_node(event.info, '.format_table')
  event.info <- html_nodes(event.info, '.format_row')
  event.info <- html_nodes(event.info, '.format_cell.info_text_value')
  game <- html_text(event.info[[3]])
  tourn.dt.temp$Game[i] <- game
  print(i)
}

#Fix Issues
#tourn.temp <- data.table()
#names(tourn.final) <- c("Date", "Name", "Total Prize", "year", "url", "Game")

tourn.final <- rbind(tourn.temp, tourn.dt.temp)

fwrite(tourn.final, "/data/esports_tournament_data_TEMP2.csv")
