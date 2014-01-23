# CHANGELOG

## 1.0.15 (2014-01-22)

* Make orderedhash dependency optional for non-Ruby 1.8.7 versions. [#12](https://github.com/BrightcoveOS/Ruby-MAPI-Wrapper/issues/12)

## 1.0.14 (2014-01-22)

* Handle IO streams provided by open-uri in post_io_streaming. [#11](https://github.com/BrightcoveOS/Ruby-MAPI-Wrapper/pull/11). Thanks @robdiciuccio.

## 1.0.13 (2013-04-24)

* Allow an UploadIO object to be passed in to post_io_streaming Thanks @icebreaker

## 1.0.12 (2012-06-12)

* Allow post streaming when you have an file handle instead of a filename. Thanks @keysolutions

## 1.0.11 (2011-09-13)

 * Only set `timeout` and `open_timeout` in `post_file(...)` and `post_file_streaming(...)` if they are set
 * Support output format in Media RSS for passing `:output => 'mrss'` in the options for the `get` method
 * Remove explicit version dependencies from supporting libraries

## 1.0.10 (2011-06-22)

 * Updated `post_file_streaming` method to support Ruby 1.8.7

## 1.0.9 (2011-06-22)

 * Added `post_file_streaming` method

## 1.0.7 (2011-03-21)

 * Allow for hash to be ordered when using the create_video call under Ruby 1.8.7

## 1.0.6 (2011-02-16)

 * `set_timeout` can be used to set an HTTP timeout in seconds.
