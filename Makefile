DR := npx dotenvx run --

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

DEV_DC := docker compose
PROD_DC := docker compose -f docker-compose.yaml -f docker-compose.production.yaml

exec:
	$(REQUIRED_P)
	@${DR} ${PROD_DC} exec $(P) sh

up-b-dev:
	$(OPTIONAL_P)
	@${DEV_DC} up -d --build $(P)

up-b-prod:
	$(OPTIONAL_P)
	@${DR} ${PROD_DC} up -d --build $(P)

stop:
	$(OPTIONAL_P)
	@${DR} ${PROD_DC} stop $(P)

restart:
	$(OPTIONAL_P)
	@${DR} ${PROD_DC} restart $(P)

logs:
	$(OPTIONAL_P)
	@${DR} ${PROD_DC} logs -f $(P)

ps:
	$(OPTIONAL_P)
	@${DR} ${PROD_DC} ps -a $(P)

# Dotenvx

encrypt:
	@npx dotenvx encrypt

decrypt:
	@npx dotenvx decrypt

# Nginx

renew:
	@sudo certbot renew --deploy-hook 'npx dotenvx run -- docker compose -f docker-compose.yaml -f docker-compose.production.yaml exec -T nginx nginx -s reload'

.PHONY: exec up-b-dev up-b-prod stop restart logs ps encrypt decrypt renew
