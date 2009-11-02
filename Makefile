#  __  ____   __
# |  \/  \ \ / /
# | |\/| |\ V /
# |_|  |_| |_|
#   ___ ___  ___  ___
#  / __/ _ \|   \| __|
# | (_| (_) | |) | _|
#  \___\___/|___/|___|
#  ___ ___  __      ___   ___ __  __
# |_ _/ __| \ \    / /_\ | _ \  \/  |
#  | |\__ \  \ \/\/ / _ \|   / |\/| |
# |___|___/   \_/\_/_/ \_\_|_\_|  |_|

PROJECT_PATH=http://path/to/svnrepo
PROJECT_NAME="test"

CONFIG_FILE=myconfig.config
CONFIG_FILE_PATH=config/$(CONFIG_FILE)

ACTIVITY_LOG = activity.log
ACTIVITY_XML = my_activity.xml

SVN=$(shell which svn)
ANT=$(shell which ant)
PYTHON=$(shell which python)
FFMPEG=$(shell which ffmpeg)
SH=$(shell which sh)

CODESWARM_URL="http://codeswarm.googlecode.com/svn/trunk/"
CODESWARM=/home/nagi/sources/codeswarm
FRAMES=$(CODESWARM)/frames
DATA=$(CODESWARM)/data

CONVERT_CMD=$(CODESWARM)/convert_logs/convert_logs.py
VIDEO_CMD=$(FFMPEG) -f image2 -r 24 -i ./frames/code_swarm-%05d.png /tmp/$(PROJECT_NAME).mpg

all: framesfolder checkout create-log convert-log create-frames create-video
	@echo "";
	@echo "----------------------------------------";
	@echo "DONE. Saved /tmp/$(PROJECT_NAME).mpg file!";
	@echo "----------------------------------------";

framesfolder:
	test -d $(FRAMES) || mkdir $(FRAMES)

checkout:
	$(SVN) co $(PROJECT_PATH) $(PROJECT_NAME)

create-log:
	cd $(PROJECT_NAME); $(SVN) log -v > ../$(ACTIVITY_LOG)

convert-log:
	$(PYTHON) $(CONVERT_CMD) -s $(ACTIVITY_LOG) -o $(ACTIVITY_XML)

create-frames:
	cp $(ACTIVITY_XML) $(DATA);
	cp $(CONFIG_FILE_PATH) $(DATA);
	cd $(CODESWARM); $(SH) run.sh data/$(CONFIG_FILE)

create-video:
	cd $(CODESWARM); $(VIDEO_CMD)

download-codeswarm:
	$(SVN) co $(CODESWARM_URL) $(CODESWARM)

install-codeswarm: download-codeswarm
	cd $(CODESWARM); $(ANT)

usage:
	@echo ""
	@echo "Create a video from subversion repository using codeswarm."
	@echo ""
	@echo "Usage:"
	@echo ""
	@echo "  make all PROJECT_PATH=/project/svn/repo PROJECT_NAME=project_name"
	@echo ""

clean:
	@rm -f $(FRAMES)/*.png;
	@rm -rf $(PROJECT_NAME);
	@rm -f $(ACTIVITY_LOG);
	@rm -f $(ACTIVITY_XML);
