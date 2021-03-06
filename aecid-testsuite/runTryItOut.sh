#!/bin/bash

BRANCH=main

if [ $# -gt 0 ]
then
BRANCH=$1
fi


sudo chown -R aminer:aminer /var/lib/aminer 2> /dev/null

# extract the file from the development branch of the wiki project.
# the second ```python script is searched for.
git clone https://github.com/ait-aecid/logdata-anomaly-miner.wiki.git 2> /dev/null
cd logdata-anomaly-miner.wiki 2> /dev/null
git checkout $BRANCH > /dev/null 2>&1
cd ..
awk '/^```python$/ && ++n == 2, /^```$/' < logdata-anomaly-miner.wiki/AMiner-TryItOut.md | sed '/^```/ d' | sed '/^```python/ d' > /tmp/tryItOut-config.yml
sudo rm -r logdata-anomaly-miner.wiki

sudo aminer --config /tmp/tryItOut-config.yml > /dev/null &
sleep 5 & wait $!
sudo pkill -x aminer
exit_code=$?
rm /tmp/tryItOut-config.yml
exit $exit_code
