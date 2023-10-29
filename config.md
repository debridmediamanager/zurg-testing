# Zurg Configuration Documentation

Welcome to the Zurg Configuration guide. This document will help you set up and understand the `config.yaml` file for configuring your media library directory structure.

## Table of Contents

1. [Basic Configuration](#basic-configuration)
2. [Directory Definitions and Filters](#directory-definitions-and-filters)
3. [Advanced Filtering](#advanced-filtering)
4. [Regex](#regex)
5. [Library Update Trigger](#library-update-trigger)

## Basic Configuration

Here are the primary configurations:

- `zurg`: Configuration version. E.g., `v1`.
- `token`: Your RD API token. [Get it here](https://real-debrid.com/apitoken).
- `port`: Port number (default is `9999`).
- `concurrent_workers`: Number of concurrent workers (default is `10`).
- `check_for_changes_every_secs`: Time interval for checking changes (default is `15` seconds).
- `info_cache_time_hours`: Cache time for info (default is `12` hours).
- `enable_repair`: Set to `true` if you want Zurg to repair your torrents. Important: Only ONE instance of Zurg should have this enabled.
- `network_buffer_size`: You can play around this value and see if there's any performance gain when streaming files. Common values are `16384` for 16KB, `32768` for 32KB (default), so on...

```yaml
zurg: v1
token: YOUR_RD_API_TOKEN
port: 9999
concurrent_workers: 10
check_for_changes_every_secs: 15
info_cache_time_hours: 12
enable_repair: true
network_buffer_size: 32768
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

### Important Considerations

1. **Unexpected Results with `any_file_inside_*` Filters:** Such filters can occasionally lead to unexpected outcomes. For instance, imagine two torrents named `The Simpsons`. One might contain files labeled `*s17*` episodes, while the other has `*s19*`. If one torrent aligns with the criteria of an `any_file_inside_*` filter and the other does not, the directory will display the torrent and incorporate files from both torrents - `*s17*` and `*s19*`.

2. **Interactions of `not_contains` or `not_contains_strict` in `or` Context:** When `not_contains` or `not_contains_strict` are used within an `or` context in combination with `regex`, `contains`, or `contains_strict`, it can lead to unanticipated results. For example:

 ```yaml
 filters:
   - or:
     - not_contains: keyword1
     - regex: /pattern/i
     - contains: keyword2
     - contains_strict: Keyword3
 ```

In this scenario, a torrent might match if it doesn't contain `keyword1` or if it matches the regex pattern, or if it contains `keyword2`, or if it strictly contains `Keyword3`. This can lead to torrents being included that you might not have anticipated.

It's essential to test your filters thoroughly to ensure they behave as intended and make necessary adjustments.

## Regex

In Zurg, you can use regular expressions (often referred to as "regex") to define patterns for filtering. A regex pattern is wrapped between slashes `/`. For example, `/season[\s\.]?\d/i` is a regex pattern. The main part of this pattern is `season[\s\.]?\d`, which matches strings like "season 1", "season.2", or "season 3". The trailing `i` after the last slash is a flag that makes the pattern case-insensitive. This means "SEASON 1", "SeAsOn 2", and "season 3" would all match this pattern.

You can append flags after the pattern to change how the pattern behaves:

- `i`: Case-Insensitive. It allows the pattern to match strings regardless of their case. For example, `/abc/i` matches "abc", "ABC", "aBc", etc.
  
- `m`: Multiline mode. It allows `^` and `$` to match the start/end of each line in a string and not just the start/end of the entire string.
  
- `s`: Dot matches newline. It allows `.` to match newlines. Without this flag, `.` matches any character except a newline.
  
- `x`: Extended mode. It allows you to add whitespace and comments within your regex for better readability.

For example, the pattern `/abc/im` would match the string "ABC" (because of the `i` flag) and would allow for matching at the start/end of each line in a multiline string (because of the `m` flag).

## Library Update Trigger

Using the `on_library_update` directive, you can configure a trigger to refresh your Plex library whenever changes are detected:

```yaml
on_library_update: |
  token="Your X-Plex-Token Here"
  plex_url="http://plex.box"

  # Get the list of library sections from Plex
  sections_xml=$(curl -s "$plex_url/library/sections" -H "X-Plex-Token: $token")

  # Extract section IDs using grep and awk
  section_ids=$(echo "$sections_xml" | grep -o 'key="[0-9]*"' | awk -F'"' '{print $2}')

  # Loop through each section ID and refresh the section
  for id in $section_ids; do
      curl -s -X POST "$plex_url/library/sections/$id/refresh" -H "X-Plex-Token: $token"
  done

  echo "All sections refreshed."
```

Ensure you replace the placeholders (`Your X-Plex-Token Here` and `http

://plex.box`) with the appropriate values for your setup.

## Happy organizing!
