##
# Makefile for deploy-tool
# Part of project Metadata Storage (ANDS Funded)
# Author: Neil Fan <neil.fan@deakin.edu.au>
#
##

FACETS = \
	opt/researchdata/data/tmp/.placeholder \
	opt/researchdata/data/sql/activity_extract.sql \
	opt/researchdata/data/sql/party_extract.sql \
	etc/rc.d/init.d/redbox \
	etc/rc.d/rc0.d/K10redbox \
	etc/rc.d/rc1.d/K10redbox \
	etc/rc.d/rc2.d/S90redbox \
	etc/rc.d/rc3.d/S90redbox \
	etc/rc.d/rc4.d/S90redbox \
	etc/rc.d/rc5.d/S90redbox \
	etc/rc.d/rc6.d/K10redbox \
	etc/rc.d/init.d/mint \
	etc/rc.d/rc0.d/K10mint \
	etc/rc.d/rc1.d/K10mint \
	etc/rc.d/rc2.d/S90mint \
	etc/rc.d/rc3.d/S90mint \
	etc/rc.d/rc4.d/S90mint \
	etc/rc.d/rc5.d/S90mint \
	etc/rc.d/rc6.d/K10mint \
	etc/httpd/conf.d/researchdata_proxy.conf \
	etc/cron.daily/mint-data-import.cron \
	etc/cron.daily/mint.extract.activity.cron \
	etc/cron.daily/mint.extract.party.cron \
	etc/cron.weekly/mint.import.geonames.cron \
	var/www/html/index.htm \
	var/www/html/redbox/.placeholder \
	var/www/html/mint/.placeholder \




##
# Environment 
# 	  Get current host name The hostname will determine what
# 	  environment we are building for
##
OS      	:= $(shell uname -s)
HOST    	:= $(shell hostname -s)

##
# Commands
##
MKDIR   	:= $(shell which mkdir) -p
RM      	:= $(shell which rm) -rf
CP      	:= $(shell which cp) -Prvf


SCRIPTDIR	:= $(shell pwd)/scripts
FACETDIR	:= $(shell pwd)/facets/$(HOST)
ROOTDIR		:= /

default: build

.PHONY: new-section determine-host

# Need this PHONY task for loop of facets
new-section: 

$(FACETS): new-section
	@echo Copying Facet $@
	@$(MKDIR) $(ROOTDIR)$(dir $@)
	$(CP) $(FACETDIR)/$@ $(ROOTDIR)$@

determine-host:
	@echo Determining Host Environment
	@echo HOST= $(HOST)

facets : $(FACETS)
	@echo Finishing Facets ...

clean:
	@$(RM) /root/.m2
	@$(RM) /opt/researchdata/mint/home
	@$(RM) /opt/researchdata/mint/portal
	@$(RM) /opt/researchdata/mint/server
	@$(RM) /opt/researchdata/redbox/home
	@$(RM) /opt/researchdata/redbox/portal
	@$(RM) /opt/researchdata/redbox/server

reset-rebuild-script:
	@chmod a+rx $(SCRIPTDIR)/rebuild.redbox
	@chmod a+rx $(SCRIPTDIR)/rebuild.mint

restart-httpd:
	@echo Restart HTTPD Server .....
	@service httpd restart

restart-mint:
	@echo Restart MINT Server .....
	@service mint restart

restart-redbox:
	@echo Restart REDBOX Server .....
	@service redbox restart

restart: restart-mint restart-redbox restart-httpd
	@echo Server Restarted .....

# Test environment
install-researchdata-dev:
	$(SCRIPTDIR)/rebuild.mint test
	$(SCRIPTDIR)/rebuild.redbox test


install-researchdata:
	$(SCRIPTDIR)/rebuild.mint production
	$(SCRIPTDIR)/rebuild.redbox production


install: new-section determine-host reset-rebuild-script install-$(HOST) facets restart
	@echo Install completed for host $(HOST)

import:
	$(FACETDIR)/etc/cron.daily/mint.extract.activity.cron
	$(FACETDIR)/etc/cron.daily/mint.extract.party.cron
	$(FACETDIR)/etc/cron.weekly/mint.import.geonames.cron
	$(FACETDIR)/etc/cron.daily/mint-data-import.cron
	@service mint restart
