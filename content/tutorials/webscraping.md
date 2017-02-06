---
title:      "Turning Internet into waylay sensors using web scraping"
date:       2015-10-01 10:19:06
author:     Veselin Pizurica
---

Belgians love holiday! So we decided to create a sensor that tells you weather there is a holiday in Belgium. For that we used one web [site] [web] that has a html table of the holidays in Belgium. In order to turn this into a sensor, we used some little help from _cheerio_ library. So, let's see how does it work?

```
var url = "http://www.wettelijke-feestdagen.be/";
var currentDate = new Date();
var isHoliday = false;

  request({
            "uri": url
        }, function(err, resp, body){
        var $ = cheerio.load(body);
          var dates = [];
          $('td:contains(Nieuwjaar)').parents('table').find('tr').each(function(index,item){
           if(index>0)
           {
              var tds = $(item).find('td');
              var data = tds.eq(1).text().trim().replace("Mei", "May");
              var dateFeest = {
                   title: $(tds.eq(0)).find('a').text().trim(),
                   data: data,
                   date : new Date(data)
              };
              dates.push(dateFeest);
              var tmpFlag = currentDate.getDate()  === dateFeest.date.getDate() &&
              currentDate.getMonth() === dateFeest.date.getMonth();
              isHoliday = isHoliday || tmpFlag;
           }
           });
           console.log(JSON.stringify(dates));
            var value = {
            observedState: isHoliday? "TRUE" : "FALSE",
            rawData :{
              dates: dates
            }
           };
           //console.log(JSON.stringify(value));
           send(null, value);
});
```

Link to the [repo] [repo]

[web]: http://www.wettelijke-feestdagen.be/
[repo]: https://raw.githubusercontent.com/waylayio/Sensors/master/isHolidayBelgium
