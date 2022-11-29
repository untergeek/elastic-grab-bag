# Log redate script

This script has been used in the past for workshops and demos to create 300K lines of Apache-style web logs for testing and demoing. 
Running it _requires_ a local Logstash instance. It will set the dates for these logs from their original time in 2014 to end at the
prompted date, effectively giving a month of logs at 1K lines per day.

**Both files must be placed in the root directory of a working Logstash instance.** 

Most recently tested with Logstash version: 8.4.3

## Run example

```
./redate-logs.sh
Enter the workshop date format YYYY-MM-DD [2022-12-06]:2022-12-01
Enter your UTC offset format +/-HH, examples +00 -08 +01 [+09]:
You set 2022-12-01T15:00:00.000+09:00 as the workshop date.
Ok to proceed [Y]/n?
Generating logs-OUTPUT...
Using bundled JDK: /Users/buh/logstash-8.4.3/jdk.app/Contents/Home
Sending Logstash logs to /Users/buh/logstash-8.4.3/logs which is now configured via log4j2.properties
[2022-11-29T11:29:47,715][INFO ][logstash.runner          ] Log4j configuration path used is: /Users/buh/logstash-8.4.3/config/log4j2.properties
[2022-11-29T11:29:47,727][INFO ][logstash.runner          ] Starting Logstash {"logstash.version"=>"8.4.3", "jruby.version"=>"jruby 9.3.8.0 (2.6.8) 2022-09-13 98d69c9461 OpenJDK 64-Bit Server VM 17.0.4+8 on 17.0.4+8 +indy +jit [x86_64-darwin]"}
...
[2022-11-29T11:29:50,343][INFO ][logstash.outputs.file    ][main][bd2b5db1a3a8caa96ff7e21c61b2e52988d72d25fe15a9bb392844773e03ace5] Opening file {:path=>"/Users/buh/logstash-8.4.3/logs-OUTPUT"}
[2022-11-29T11:29:57,367][INFO ][logstash.javapipeline    ][main] Pipeline terminated {"pipeline.id"=>"main"}
```

You may or may not need to hit control-C at the end to kill Logstash after that.
