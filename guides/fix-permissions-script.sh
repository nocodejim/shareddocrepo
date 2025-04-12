#!/bin/bash
# Fix permissions on mounted volumes
sudo chown -R developer:developer /home/developer/project
sudo chmod -R 775 /home/developer/project
# Ensure target directory has full write permissions
sudo mkdir -p /home/developer/project/target/classes
sudo chmod -R 777 /home/developer/project/target
# Execute the command
exec "$@"