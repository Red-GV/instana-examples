DOWNLOAD_DIR = /tmp
PACKAGE_DIR = $(shell pwd)/package

HOTEL_RESERVATION_VERSION = 0.2.2
HOTEL_RESERVATION_PACKAGE = hotel-reservation-v$(HOTEL_RESERVATION_VERSION)
HOTEL_RESERVATION_PATH = $(PACKAGE_DIR)/DeathStarBench-hotelReservation-$(HOTEL_RESERVATION_VERSION)/hotelReservation

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-24s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: deploy
deploy: ## Deploys the hotel reservation application
	sh deploy.sh $(HOTEL_RESERVATION_PATH)

.PHONY: undeploy
undeploy: ## Undeploys the hotel reservation application
	sh undeploy.sh $(HOTEL_RESERVATION_PATH)

.PHONY: package 
package: ## Creates package directory
	mkdir -p $(PACKAGE_DIR)

.PHONY: hotel-reservation
hotel-reservation: package ## Downloads hotel reservation application
	curl -LSs https://github.com/delimitrou/DeathStarBench/archive/refs/tags/hotelReservation-$(HOTEL_RESERVATION_VERSION).tar.gz -o $(DOWNLOAD_DIR)/$(HOTEL_RESERVATION_PACKAGE).tar.gz
	cd $(PACKAGE_DIR) && tar -zxf $(DOWNLOAD_DIR)/$(HOTEL_RESERVATION_PACKAGE).tar.gz