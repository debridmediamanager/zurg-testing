# zurg-testing

A self-hosted Real-Debrid webdav server written from scratch, alternative to rclone_rd

## How to run zurg in 5 steps

1. Clone this repo `git clone https://github.com/debridmediamanager/zurg-testing.git`
2. Add your token in `config.yml`
3. `sudo mkdir -p /mnt/zurg`
4. Run `docker compose up -d`
5. `time ls -1R /mnt/zurg` You're done!

The server is also exposed to your localhost via port 9999. You can point [Infuse](https://firecore.com/infuse) or any webdav clients to it.

> Note: I have only tested this in Mac and Linux

## Why zurg? Why not rclone_rd? Why not Real-Debrid's own webdav?

- Better performance than anything out there; changes in your library appear instantly (assuming Plex picks it up fast enough)
- You should be able to access every file even if the torrent names are the same so if you have a lot of these, you might notice that zurg will have more files compared to others (e.g. 2 torrents named "Simpsons" but have different seasons, zurg merges all contents in that directory)
- You can configure a flexible directory structure in `config.yml`; you can select individual torrents that should appear on a directory by the ID you see in [DMM](https://debridmediamanager.com/)
- If you've ever experienced Plex scanner being stuck on a file and thereby freezing Plex completely, it should not happen anymore because zurg does a comprehensive check if a torrent is dead or not

## config.yml

You need a `config.yml` created before you can use zurg

```yaml
# Zurg configuration version
zurg: v1

token: YOUR_TOKEN_HERE
port: 9999
concurrent_workers: 10 # the higher the number the faster zurg runs through your library but too high and you will get rate limited
check_for_changes_every_secs: 15 # zurg polls real-debrid for changes in your library
info_cache_time_hours: 12 # how long do we want to check if a torrent is still alive or dead? 12 to 24 hours is good enough

# List of directory definitions and their filtering rules
directories:
  # Configuration for TV shows
  shows:
    group: media # directories on different groups have duplicates of the same torrent
    filters:
      - regex: /season[\s\.]?\d/i          # Capture torrent names with the term 'season' in any case
      - regex: /saison[\s\.]?\d/i          # For non-English namings
      - regex: /stagione[\s\.]?\d/i        # if there's french, there should be italian too
      - regex: /s\d\d/i           # Capture common season notations like S01, S02, etc.
      - regex: /\btv/i            # anything that has TV in it is a TV show, right?
      - contains: complete
      - contains: seasons

  # Configuration for movies
  movies:
    group: media # because movies and shows are in the same group, and shows come first before movies, all torrents that doesn't fall into shows will fall into movies
    filters:
      - regex: /.*/ # you cannot leave a directory without filters because it will not have any torrents in it

  "ALL MY STUFFS":
    group: all           # notice the group now is "all", which means it will have all the torrents of shows+movies combined because this directory is alone in this group
    filters:
      - regex: /.*/

  "Kids":
    group: kids
    filters:
      - not_contains: xxx       # Ensures adult content is excluded
      - id: XFPQ5UCMUVAEG       # Specific inclusion by torrent ID
      - id: VDRPYNRPQHEXC
      - id: YELNX3XR5XJQM

```
