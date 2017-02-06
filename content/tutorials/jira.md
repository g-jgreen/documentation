---
title:      JIRA integration using REST with basic authentication
date:       2015-09-25 10:19:06
author:     Veselin Pizurica
---

This example you can find in this [repo] [repo] and it is based on documentation that you can find here [jira] [jira]. In this example we use _request_ package with basic authentication option. It is almost 1to1 translation of the JIRA documentation. Not more than 1 minute job, have a look:

```
var username =  options.globalSettings.JIRA_USER;
var password = options.globalSettings.JIRA_PASSWORD;
var url = options.globalSettings.JIRA_URL;
var subject = options.requiredProperties.subject;
var message = waylayUtil.evaluateData(options, options.requiredProperties.message);
var type = options.requiredProperties.type || 'Bug';
var project = options.requiredProperties.project;


var data = {
    "fields": {
       "project":
       {
          "key": project
       },
       "summary": subject,
       "description":  message,
       "issuetype": {
          "name" : type
       }
   }
};

if(username && password && subject && message && project && url){
  var options = {
        url: url,
        json: data,
        auth: {
            user: username,
            pass: password,
            sendImmediately: true
        }
  };

  var callback = function(error, response, body) {
    if (!error && (response.statusCode == 200 || response.statusCode == 201)) {
      send();
    }else{
      console.log(response);
      send(new Error("Calling JIRA failed: " + response));
    }
  };

  request.post(options, callback);
}else{
  send(new Error("Missing properties"));
}
```

[repo]: https://github.com/waylayio/Actuators/blob/master/jira
[jira]: https://developer.atlassian.com/jiradev/jira-apis/jira-rest-apis/jira-rest-api-tutorials/jira-rest-api-example-create-issue
