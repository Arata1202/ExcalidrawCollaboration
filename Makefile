DR := npx dotenvx run --

define REQUIRED_E
	@set -e; \
	if [ "$(E)" != "dev" ] && [ "$(E)" != "prod" ]; then \
		echo ""; \
		echo "ERROR: Invalid E."; \
		echo "Usage: make $(MAKECMDGOALS) E=<dev|prod>"; \
		exit 1; \
	fi
endef

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
PROD_DC := ${DR} docker compose -f docker-compose.yaml -f docker-compose.production.yaml
DC = $(if $(filter prod,$(E)),${PROD_DC},${DEV_DC})

exec:
	$(REQUIRED_E)
	$(REQUIRED_P)
	@${DC} exec $(P) sh

up-b:
	$(REQUIRED_E)
	$(OPTIONAL_P)
	@${DC} up -d --build $(P)

stop:
	$(REQUIRED_E)
	$(OPTIONAL_P)
	@${DC} stop $(P)

restart:
	$(REQUIRED_E)
	$(OPTIONAL_P)
	@${DC} restart $(P)

logs:
	$(REQUIRED_E)
	$(OPTIONAL_P)
	@${DC} logs -f $(P)

ps:
	$(REQUIRED_E)
	$(OPTIONAL_P)
	@${DC} ps -a $(P)

# Dotenvx

encrypt:
	@npx dotenvx encrypt

decrypt:
	@npx dotenvx decrypt

# Nginx

renew:
	@sudo certbot renew --deploy-hook 'npx dotenvx run -- docker compose -f docker-compose.yaml -f docker-compose.production.yaml exec -T nginx nginx -s reload'

.PHONY: exec up-b stop restart logs ps encrypt decrypt renew
