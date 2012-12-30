#!/bin/bash
#mongo admin --eval 'db.shutdownServer()'
sudo service mongodb          stop
sudo service mysql            stop
sudo service postgresql       stop
sudo sync
sudo sync
sync
sync
sudo shutdown -h now
