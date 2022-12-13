# Checkpoint syslog integration replacement

The Checkpoint Fleet integration as of this date (2022-12-13) is broken when used against Checkpoint version R81.x (the integration only claims to support R77.3 or R80.x). It expects to use Syslog RFC5424, and that doesn't allow for messages longer than 4K, which Checkpoint doesn't care to prevent. As a result, you get broken messages.

The fix is to configure the Checkpoint server to ship logs using the Splunk format to a TCP Custom Logs ingtegration.

You still need to set up the "broken" integration once to get the mappings and perhaps the original pipeline, of which this is
an adaptation.

The data set needs to also be configured to named the same, so that the indices and mappings match.
