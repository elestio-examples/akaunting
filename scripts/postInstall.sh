# #set env vars
set -o allexport; source .env; set +o allexport;

#wait until the server is ready
echo "Waiting for software to be ready ..."
sleep 120s;


docker-compose down;

sed -i "s~AKAUNTING_SETUP=true~AKAUNTING_SETUP=false~g" ./docker-compose.yml

docker-compose up -d;

sleep 30s;