# SwiftypeMonitoring

SwiftypeMonitoring is a collection of helpers for monitoring services used at Swiftype.
It can be used to build application-level monitoring using Nagios or your tool of choice.
The type of monitoring checks you could write with it include "is this Resque queue too large?",
"Are records in table X too told?", and "is my Elasticsearch cluster healthy?"

This library was extracted from the internal Swiftype monitoring framework,
however the code is presented as-is.

## Usage

To use, define a subclass of SwiftypeMonitoring::Check and override
the `run` method:

```
class FoobarCheck < SwiftypeMonitoring::Check
  # Check thresholds
  warning_option('Warning threshold for Foobar', 3600)
  critical_option('Critical threshold for Foobar', 7200)

  def run
    foobar = get_some_metric

    if foobar > config[:critical]
      critical("Foobar is too large (#{foobar}). " +
               "Limit is #{config[:critical]}")
    end

    if foobar > config[:warning]
      warning("Foobar is too large (#{foobar}). " +
              "Limit is #{config[:critical]}")
    end

    ok("Foobar (#{foobar}) is within acceptable limits")
  end
end
```
