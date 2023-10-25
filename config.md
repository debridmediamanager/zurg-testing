# Zurg Configuration Documentation

Welcome to the Zurg Configuration guide. This document will help you set up and understand the `config.yaml` file for configuring your media library directory structure.

## Table of Contents

1. [Basic Configuration](#basic-configuration)
2. [Directory Definitions and Filters](#directory-definitions-and-filters)
3. [Advanced Filtering](#advanced-filtering)
4. [Regex](#regex)

## Basic Configuration

Here are the primary configurations:

- `zurg`: Configuration version. E.g., `v1`.
- `token`: Your RD API token. [Get it here](https://real-debrid.com/apitoken).
- `port`: Port number (default is `9999`).
- `concurrent_workers`: Number of concurrent workers (default is `10`).
- `check_for_changes_every_secs`: Time interval for checking changes (default is `15` seconds).
- `info_cache_time_hours`: Cache time for info (default is `12` hours).
- `enable_repair`: Set to `true` if you want Zurg to repair your torrents. Important: Only ONE instance of Zurg should have this enabled.

```yaml
zurg: v1
token: YOUR_RD_API_TOKEN
port: 9999
concurrent_workers: 10
check_for_changes_every_secs: 15
info_cache_time_hours: 12
enable_repair: true
```

## Directory Definitions and Filters

Define directories and their filtering rules under the `directories` key.

Each directory can have:

- `group`: Directories in the same group might have duplicates of the same torrent. It's a way to categorize your directories.
- `group_order`: Determines the order within the group. Directories with lower numbers get priority. 
- `filters`: List of filtering conditions. 

For example, for TV shows:

```yaml
directories:
  shows:
    group: media
    group_order: 1
    filters:
      - regex: /season[\s\.]?\d/i
      ...
```

### Filter Types

You can use the following filters:

- `regex`: Regular expression matching.
- `contains`: Checks if the string contains the specified substring.
- `contains_strict`: Same as `contains`, but case-sensitive.
- `not_contains`: Opposite of `contains`.
- `not_contains_strict`: Opposite of `contains_strict`.

## Advanced Filtering

For more complex conditions, use the `and` & `or` filters:

- `and`: All conditions inside must be true.
- `or`: At least one condition inside must be true.

Additionally, you can specify conditions for files inside a torrent:

- `any_file_inside_regex`: Matches file names inside the torrent using regex.
- `any_file_inside_contains`: Checks if any file inside the torrent contains the specified substring.
- `any_file_inside_contains_strict`: Same as above, but case-sensitive.

```yaml
filters:
  - regex: /example/i
  - and:
    - contains: keyword1
    - not_contains: keyword2
  - or:
    - contains_strict: Keyword3
    - any_file_inside_regex: /pattern/i
```

## Regex

In Zurg, you can use regular expressions (often referred to as "regex") to define patterns for filtering. A regex pattern is wrapped between slashes `/`. For example, `/season[\s\.]?\d/i` is a regex pattern. The main part of this pattern is `season[\s\.]?\d`, which matches strings like "season 1", "season.2", or "season 3". The trailing `i` after the last slash is a flag that makes the pattern case-insensitive. This means "SEASON 1", "SeAsOn 2", and "season 3" would all match this pattern.

You can append flags after the pattern to change how the pattern behaves:

- `i`: Case-Insensitive. It allows the pattern to match strings regardless of their case. For example, `/abc/i` matches "abc", "ABC", "aBc", etc.
  
- `m`: Multiline mode. It allows `^` and `$` to match the start/end of each line in a string and not just the start/end of the entire string.
  
- `s`: Dot matches newline. It allows `.` to match newlines. Without this flag, `.` matches any character except a newline.
  
- `x`: Extended mode. It allows you to add whitespace and comments within your regex for better readability.

For example, the pattern `/abc/im` would match the string "ABC" (because of the `i` flag) and would allow for matching at the start/end of each line in a multiline string (because of the `m` flag).

## Happy organizing!
