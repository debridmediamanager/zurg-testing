# zurg-testing

A self-hosted Real-Debrid webdav server written from scratch, alternative to rclone_rd. Together with [rclone](https://rclone.org/) it can mount your Real-Debrid torrent library into your filesystem.

# How to run zurg

## How to run zurg in 5 steps for Plex

1. Clone this repo `git clone https://github.com/debridmediamanager/zurg-testing.git`
2. Add your token in `config.yml`
3. `sudo mkdir -p /mnt/zurg`
4. Run `docker compose up -d`
5. `time ls -1R /mnt/zurg` You're done!

A webdav server is also exposed to your localhost via port `9999`.

## How to run zurg in 4 steps for [Infuse](https://firecore.com/infuse) with SFTP

1. Clone this repo `git clone https://github.com/debridmediamanager/zurg-testing.git`
2. Add your token in `config.yml`
4. Run `docker compose -f docker-compose.infuse.yml up -d` to start the containers; `docker compose -f docker-compose.infuse.yml down` to remove
4. `echo "ls" | sftp -P 9998 localhost` You're done!

The SFTP server is exposed via port `9998`, and a webdav server is also exposed to your localhost via port `9997`. You can point [Infuse](https://firecore.com/infuse) or any webdav clients to it.

> Note: I have only tested this in Mac and Linux

## make commands

This repository provides a `Makefile` for managing the Docker Compose setups for Plex and Infuse SFTP. Below is a description of each available command.

### Start Plex Mount

```bash
make start-plex-mount-example
```

Upon successful start, it will display:

```
Plex Mount started: WebDAV and HTTP running at localhost:9999
```

### Stop Plex Mount

```bash
make stop-plex-mount-example
```

### Start Infuse SFTP

```bash
make start-infuse-sftp-example
```

Upon successful start, it will display:

```
Infuse SFTP started: WebDAV and HTTP running at localhost:9997, SFTP at localhost:9998
```

### Stop Infuse SFTP

```bash
make stop-infuse-sftp-example
```

## Why zurg? Why not X?

- Better performance than anything out there; changes in your library appear instantly (assuming Plex picks it up fast enough)
- You should be able to access every file even if the torrent names are the same so if you have a lot of these, you might notice that zurg will have more files compared to others (e.g. 2 torrents named "Simpsons" but have different seasons, zurg merges all contents in that directory)
- You can configure a flexible directory structure in `config.yml`; you can select individual torrents that should appear on a directory by the ID you see in [DMM](https://debridmediamanager.com/).
- If you've ever experienced Plex scanner being stuck on a file and thereby freezing Plex completely, it should not happen anymore because zurg does a comprehensive check if a torrent is dead or not

## Please read our [configuration doc](./config.md)
