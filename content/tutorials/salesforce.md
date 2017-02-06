---
title:      "Salesforce integration using jsforce package"
date:       2015-10-15 10:19:06
---

This actuator you can later find in this [repo] [repo]. In this example we use _jsforce_ package that is available in the sandboxed VM. We will create an incident _Event_ in the saleforce database. Interestingly, it took me longer to figure out how to get tokens than to implement this actuator, which probably is not that suprising for people who are into ERP business. So, here is the link [salesforce] [salesforce] that describes how to generate the access token (note that the final token is actually a password + token together?). That you will need to put in the global settings (see the code below). Code should be easy to read:


```
var user = options.globalSettings.salesForceUser;
var token = options.globalSettings.salesForceToken;
var subject = waylayUtil.evaluateData(options, options.requiredProperties.subject); //subject must be there
var lc = waylayUtil.evaluateData(options, options.requiredProperties.location) || '';
var minutes = waylayUtil.evaluateData(options, options.requiredProperties.duration) || 1;


if(user === undefined || token === undefined || subject === undefined) {
    send(new Error("token or user not defined"));
}
else {
    try{
        var conn = new jsforce.Connection();
        conn.login(user, token, function(err, res){
            if (err) { 
              console.error(err); 
              send(new Error(err));
            } else{
                 conn.sobject("Event").create({ 
                      Subject : subject,
                      Location: lc,
                      ActivityDateTime: moment().toISOString(),
                      DurationInMinutes : minutes
                  }, function(err, ret) {
                    if (err) { 
                       console.error(err); 
                       send(new Error(err));
                    } else {
                        send(null, { message: JSON.stringify(ret)});
                        send(null)
                    }
                  });
            }
        });
    }
    catch(err){
        console.error(err); 
        send(new Error(err));
    }
}
```

[repo]: https://raw.githubusercontent.com/waylayio/Actuators/master/createEventForSalesForce
[salesforce]: https://help.salesforce.com/apex/HTViewHelpDoc?id=user_security_token.htm&language=en
