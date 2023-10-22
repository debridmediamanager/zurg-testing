# Experiment: Benchmarking zurg and rclone_rd

On a freshly created directory, ensure that you have your zurg's `config.yml` as well as your `rclone.conf`.

And then, create this `docker-compose.yml` file.

```yaml
version: '3.8'

services:
  zurg:
    image: debridmediamanager/zurg:latest
    restart: unless-stopped
    ports:
      - 9999
    volumes:
      - ./config.yml:/app/config.yml
      - zurgdata:/app/data

  rclone:
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

  rclonerd:
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
    command: "mount rd: /data --umask=002 --allow-other --uid=1000 --gid=1000 --dir-cache-time 10s --read-only"

volumes:
  zurgdata:
```

after this we benchmark `rclone` (zurg) and `rclonerd` (rclone_rd)

```
# benchmark: zurg
time (for i in {1..10}; do (docker compose exec rclone ls -1R /data | wc -l); done)

# benchmark: rclone_rd
time (for i in {1..10}; do (docker compose exec rclonerd ls -1R /data | wc -l); done)
```

And report the results to:

https://discord.com/channels/1021692389368283158/1164654697337061417
