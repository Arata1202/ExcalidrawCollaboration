define REQUIRED_P
	@set -e; \
	if [ -z "$(strip $(P))" ]; then \
		echo ""; \
		echo "ERROR: Missing required P."; \
		echo "Usage: make $(MAKECMDGOALS) P=<TARGET>"; \
		exit 1; \
	fi
endef

define OPTIONAL_P
	@set -e; \
	if [ -z "$(strip $(P))" ]; then \
		echo ""; \
		echo "WARN: P is empty. This will run on ALL services."; \
		echo "Tip: make $(MAKECMDGOALS) P=<TARGET>"; \
		echo ""; \
		printf "Proceed? [y/N] "; \
		read ans; \
		echo ""; \
		case "$$ans" in \
			y|Y|yes|YES) ;; \
			*) echo "Aborted"; exit 1 ;; \
		esac; \
	fi
endef

# Docker

DC := docker compose

exec:
	$(REQUIRED_P)
	@${DC} exec $(P) sh

up:
	$(OPTIONAL_P)
	@${DC} up -d $(P)

up-b:
	$(OPTIONAL_P)
	@${DC} up -d --build $(P)

stop:
	$(OPTIONAL_P)
	@${DC} stop $(P)

restart:
	$(OPTIONAL_P)
	@${DC} restart $(P)

logs:
	$(OPTIONAL_P)
	@${DC} logs -f $(P)

ps:
	$(OPTIONAL_P)
	@${DC} ps -a $(P)

# Nginx

renew:
	@sudo certbot renew --deploy-hook 'docker compose exec -T nginx nginx -s reload'

.PHONY: exec up up-b stop restart logs ps renew
