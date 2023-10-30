# Start Plex Mount
start-plex-mount-example:
	@docker-compose -f docker-compose.yml up -d
	@echo "Plex Mount started: WebDAV and HTTP running at localhost:9999"

# Stop Plex Mount
stop-plex-mount-example:
	@docker-compose -f docker-compose.yml down

# Start Infuse SFTP
start-infuse-sftp-example:
	@docker-compose -f docker-compose.infuse.yml up -d
	@echo "Infuse SFTP started: WebDAV and HTTP running at localhost:9997, SFTP at localhost:9998"

# Stop Infuse SFTP
stop-infuse-sftp-example:
	@docker-compose -f docker-compose.infuse.yml down

.PHONY: start-plex-mount-example stop-plex-mount-example start-infuse-sftp-example stop-infuse-sftp-example
