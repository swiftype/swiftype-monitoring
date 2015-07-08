# SwiftypeMonitoring

SwiftypeMonitoring is a collection of helpers for monitoring services used at Swiftype.
It can be used to build application-level monitoring using Nagios or your tool of choice.
The type of monitoring checks you could write with it include "is this Resque queue too large?",
"Are records in table X too told?", and "is my Elasticsearch cluster healthy?"

This library was extracted from the internal Swiftype monitoring framework,
however the code is presented as-is.
