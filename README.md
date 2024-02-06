# zurg

A self-hosted Real-Debrid webdav server written from scratch. Together with [rclone](https://rclone.org/) it can mount your Real-Debrid torrent library into your file system like Dropbox. It's meant to be used with Infuse (webdav server) and Plex (mount zurg webdav with rclone).

[Are you looking for the source code?](https://github.com/debridmediamanager/zurg-testing/issues/53)

## Download

### Latest version: v0.9.3-hotfix.8

[Download the binary](https://github.com/debridmediamanager/zurg-testing/releases) or use docker

```sh
docker pull ghcr.io/debridmediamanager/zurg-testing:latest
# or
docker pull ghcr.io/debridmediamanager/zurg-testing:v0.9.3-hotfix.8
```

## How to run zurg in 5 steps for Plex with Docker

1. Clone this repo `git clone https://github.com/debridmediamanager/zurg-testing.git`
2. Add your token in `config.yml`
3. `sudo mkdir -p /mnt/zurg`
4. Run `docker compose up -d`
5. `time ls -1R /mnt/zurg` You're done! If you do edits on your config.yml just do `docker compose restart zurg`.

A webdav server is also exposed to your localhost via port `9999`.

### Note: when using zurg in a server outside of your home network, ensure that "Use my Remote Traffic automatically when needed" is unchecked on your [Account page](https://real-debrid.com/account)

## Command-line utility

```
Usage:
  zurg [flags]
  zurg [command]

Available Commands:
  clear-downloads Clear all downloads (unrestricted links) in your account
  clear-torrents  Clear all torrents in your account
  completion      Generate the autocompletion script for the specified shell
  help            Help about any command
  network-test    Run a network test
  version         Prints zurg's current version

Flags:
  -c, --config string   config file path (default "./config.yml")
  -h, --help            help for zurg

Use "zurg [command] --help" for more information about a command.
```

## Why zurg? Why not X?

- Better performance than anything out there; changes in your library appear instantly ([assuming Plex picks it up fast enough](./plex_update.sh))
- You can configure a flexible directory structure in `config.yml`; you can select individual torrents that should appear on a directory by the ID you see in [DMM](https://debridmediamanager.com/). [Need help?](https://github.com/debridmediamanager/zurg-testing/wiki/Config)
- If you've ever experienced Plex scanner being stuck on a file and thereby freezing Plex completely, it should not happen anymore because zurg does a comprehensive check if a torrent is dead or not. You can run `ps aux --sort=-time | grep "Plex Media Scanner"` to check for stuck scanner processes.
- zurg guarantees that your library is **always available** because of its repair abilities!

## Guides

- [@I-am-PUID-0](https://github.com/I-am-PUID-0) - [pd_zurg](https://github.com/I-am-PUID-0/pd_zurg)
- [@Pukabyte](https://github.com/Pukabyte) - [Guide: Zurg + RDT + Prowlarr + Arrs + Petio + Autoscan + Plex + Scannarr](https://puksthepirate.notion.site/Guide-Zurg-RDT-Prowlarr-Arrs-Petio-Autoscan-Plex-Scannarr-eebe27d130fa400c8a0536cab9d46eb3)
- [u/pg988](https://www.reddit.com/user/pg988/) - [Windows + zurg + Plex guide](https://www.reddit.com/r/RealDebrid/comments/18so926/windows_zurg_plex_guide/)
- [@ignamiranda](https://github.com/ignamiranda) - [Plex Debrid Zurg Windows Guide](https://github.com/ignamiranda/plex_debrid_zurg_scripts/)
- [@funkypenguin](https://github.com/funkypenguin) - ["Infinite streaming" from Real Debrid with Plex](https://elfhosted.com/guides/media/stream-from-real-debrid-with-plex/) (ElfHosted)
- [u/TimeyWimeyInsaan](https://www.reddit.com/user/TimeyWimeyInsaan/) - [A Newbie guide for Plex+Real-Debrid using Zurg & Rclone](https://docs.google.com/document/d/114URAz5h5jarpo1xz4GyFUzRzoBnOKVQPxH0-2R5KC8/view)

## Service Providers

- [ElfHosted](https://elfhosted.com) - Easy, [open source](https://elfhosted.com/open/), Kubernetes / GitOps driven hosting of popular self-hosted apps - tested, tightly integrated, and secured. Apps start at $0.05/day, and new accounts get $10 credit, no commitment.
- [zurg.club](http://zurg.club/) - optimized Plex+zurg server setup for $50/month

## Please read our [wiki](https://github.com/debridmediamanager/zurg-testing/wiki) for more information!

## [zurg's version history](https://github.com/debridmediamanager/zurg-testing/wiki/History)
