# babber-sh
sh scripts

for git get token from here https://github.com/settings/personal-access-tokens
https://<token>@github.com/user/repo.git

######################PG###########################

cd /home/ec2-user
curl -H 'Cache-Control: no-cache' -O https://raw.githubusercontent.com/okhmat-anton/babber-sh/refs/heads/main/base-postgre.sh
chmod +x base-postgre.sh
./base-postgre.sh
rm base-postgre.sh

######################MONGO###########################

cd /home/ec2-user
curl -H 'Cache-Control: no-cache' -O https://raw.githubusercontent.com/okhmat-anton/babber-sh/refs/heads/main/base-mongo.sh?skdhjbc
chmod +x base-mongo.sh
./base-mongo.sh
rm base-mongo.sh

#######################SOCKET########################

cd /home/ec2-user
curl -H 'Cache-Control: no-cache' -O https://raw.githubusercontent.com/okhmat-anton/babber-sh/refs/heads/main/base-socket.sh
chmod +x base-socket.sh
./base-socket.sh
rm base-socket.sh

########################TRACKER##########################

cd /home/ec2-user
curl -H 'Cache-Control: no-cache' -O https://raw.githubusercontent.com/okhmat-anton/babber-sh/refs/heads/main/akm-tracker.sh
chmod +x akm-tracker.sh
./akm-tracker.sh
rm akm-tracker.sh

#########################################################
