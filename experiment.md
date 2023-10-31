# Experiment: Benchmarking zurg and rclone_rd

On a freshly created directory, ensure that you have your zurg's `config.yml` 

```yaml
zurg: v1

token: TOKENHERE
port: 9999
concurrent_workers: 20
check_for_changes_every_secs: 15
info_cache_time_hours: 12

directories:
  all:
    group: all
    filters:
      - regex: /.*/
```

as well as your `rclone.conf`

```
[zurg]
type = http
url = http://zurg:9999/http
no_head = false
no_slash = false

[rclone_rd]
type = realdebrid
api_key = YOUR_RD_TOKEN

[rd_webdav]
type = webdav
url = https://dav.real-debrid.com/
vendor = other
user = YOUR_RD_USERNAME
pass = YOUR_RD_WEBDAV_PASSWORD
```

And then, create this `docker-compose.yml` file.

```yaml
version: '3.8'

services:
  zurg:
    image: ghcr.io/debridmediamanager/zurg-testing:latest
    restart: unless-stopped
    ports:
      - 9999:9999
    volumes:
      - ./config.yml:/app/config.yml
      - zurgdata:/app/data

  rclone_zurg:
    image: rclone/rclone:latest
    restart: unless-stopped
    environment:
      TZ: Europe/Berlin
      PUID: 1000
      PGID: 1000
    volumes:
      - ./rclone.conf:/config/rclone/rclone.conf
    cap_add:
      - SYS_ADMIN
    security_opt:
      - apparmor:unconfined
    devices:
      - /dev/fuse
    command: "mount zurg: /data --umask=002 --allow-other --uid=1000 --gid=1000 --dir-cache-time 10s --read-only"

  rclone_rd:
    image: itstoggle/rclone_rd:latest
    restart: unless-stopped
    environment:
      TZ: Europe/Berlin
      PUID: 1000
      PGID: 1000
    volumes:
      - ./rclone.conf:/config/rclone/rclone.conf
    cap_add:
      - SYS_ADMIN
    security_opt:
      - apparmor:unconfined
    devices:
      - /dev/fuse
    command: "mount rclone_rd: /data --umask=002 --allow-other --uid=1000 --gid=1000 --dir-cache-time 10s --read-only"

  rd_webdav:
    image: rclone/rclone:latest
    restart: unless-stopped
    environment:
      TZ: Europe/Berlin
      PUID: 1000
      PGID: 1000
    volumes:
      - ./rclone.conf:/config/rclone/rclone.conf
    cap_add:
      - SYS_ADMIN
    security_opt:
      - apparmor:unconfined
    devices:
      - /dev/fuse
    command: "mount rd_webdav: /data --umask=002 --allow-other --uid=1000 --gid=1000 --dir-cache-time 10s --read-only"

volumes:
  zurgdata:
```

after this we benchmark `rclone_zurg` (zurg) and `rclone_rd` (rclone_rd) and `rd_webdav` (Real-Debrid's webdav)

```
# benchmark: rclone_zurg
(for i in {1..10}; do time (docker compose exec rclone_zurg ls -1R /data | wc -l); done)

# benchmark: rclone_rd
(for i in {1..10}; do time (docker compose exec rclonerd ls -1R /data | wc -l); done)

# benchmark: rd_webdav
(for i in {1..10}; do time (docker compose exec rd_webdav ls -1R /data | wc -l); done)
```

And report the results to:

https://discord.com/channels/1021692389368283158/1164654697337061417
