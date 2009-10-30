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

CONFIG_FILE=config/myconfig.config

ACTIVITY_LOG = activity.log
ACTIVITY_XML = my_activity.xml

SVN=$(shell which svn)
ANT=$(shell which ant)
PYTHON=$(shell which python)
FFMPEG=$(shell which ffpmeg)

CODESWARM_URL="http://codeswarm.googlecode.com/svn/trunk/"
CODESWARM=/home/nagi/sources/codeswarm
FRAMES=$(CODESWARM)/frames
DATA=$(CODESWARM)/data

CONVERT_CMD=$(CODESWARM)/convert_logs/convert_logs.py
VIDEO_CMD=$(FFMPEG) -f image2 -r 24 -i ./frames/code_swarm-%05d.png /tmp/$(PROJECT_NAME).mpg

all: framesfolder checkout create-log convert-log create-frames create-video
	echo "";
	echo "----------------------------------------";
	echo "DONE. Saved /tmp/$(PROJECT_NAME).mpg file!";
	echo "----------------------------------------";

framesfolder:
	test -d $(FRAMES) || mkdir $(FRAMES)

checkout:
	$(SVN) co $(PROJECT_PATH) $(PROJECT_NAME)

create-log:
	cd $(PROJECT_NAME); $(SVN) log -v > ../$(ACTIVITY_LOG)

convert-log:
	$(PYTHON) $(CONVERT_CMD) -s $(ACTIVITY_LOG) -o $(ACTIVITY_XML)

create-frames:
	cp $(ACTIVITY_XML) $(DATA) && \
	cp $(CONFIG_FILE) $(DATA)/ && \
	cd $(CODESWARM); sh run.sh data/$(CONFIG_FILE)

create-video:
	cd $(CODESWARM); $(VIDEO_CMD)

download-codeswarm:
	$(SVN) co $(CODESWARM_URL) $(CODESWARM)

install-codeswarm: download-codeswarm
	cd $(CODESWARM); $(ANT)

clean:
	rm $(FRAMES)/*.png;
	rm -rf $(PROJECT_NAME);
	rm $(ACTIVITY_LOG);
	rm $(ACTIVITY_XML);
