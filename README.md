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

#######################MAIN API########################

cd /home/ec2-user
curl -H 'Cache-Control: no-cache' -O https://raw.githubusercontent.com/okhmat-anton/babber-sh/refs/heads/main/base-babber-api.sh
chmod +x base-babber-api.sh
./base-babber-api.sh
rm base-babber-api.sh

########################TRACKER##########################

cd /home/ec2-user
curl -H 'Cache-Control: no-cache' -O https://raw.githubusercontent.com/okhmat-anton/babber-sh/refs/heads/main/akm-tracker.sh
chmod +x akm-tracker.sh
./akm-tracker.sh
rm akm-tracker.sh


####################### UPLOADER ########################

cd /home/ec2-user
curl -H 'Cache-Control: no-cache' -O https://raw.githubusercontent.com/okhmat-anton/babber-sh/refs/heads/main/base-uploader.sh
chmod +x base-uploader.sh
./base-uploader.sh
rm base-uploader9o.sh

#########################################################