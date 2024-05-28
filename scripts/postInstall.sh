# #set env vars
set -o allexport; source .env; set +o allexport;

#wait until the server is ready
echo "Waiting for software to be ready ..."
sleep 120s;


if [ -e "./initialized" ]; then
    echo "Already initialized, skipping..."
else
    cat /opt/elestio/startPostfix.sh > post.txt
    filename="./post.txt"

    SMTP_LOGIN=""
    SMTP_PASSWORD=""

    # Read the file line by line
    while IFS= read -r line; do
    # Extract the values after the flags (-e)
    values=$(echo "$line" | grep -o '\-e [^ ]*' | sed 's/-e //')

    # Loop through each value and store in respective variables
    while IFS= read -r value; do
        if [[ $value == RELAYHOST_USERNAME=* ]]; then
        SMTP_LOGIN=${value#*=}
        elif [[ $value == RELAYHOST_PASSWORD=* ]]; then
        SMTP_PASSWORD=${value#*=}
        fi
    done <<< "$values"

    done < "$filename"

    rm post.txt

    docker-compose exec -T akaunting-db bash -c "mariadb -u root -p'${DB_ROOT_PASSWORD}' -e \"USE akaunting; INSERT INTO asd_settings (company_id, \\\`key\\\`, \\\`value\\\`) VALUES (1, 'email.protocol', 'smtp'), (1, 'email.smtp_host', 'tuesday.mxrouting.net'), (1, 'email.smtp_port', '465'), (1, 'email.smtp_username', '${SMTP_LOGIN}'), (1, 'email.smtp_password', '${SMTP_PASSWORD}'), (1, 'email.smtp_encryption', 'ssl');\""


    docker-compose down;

    sed -i "s~AKAUNTING_SETUP=true~AKAUNTING_SETUP=false~g" ./docker-compose.yml

    docker-compose up -d;

    sleep 30s;
    touch "./initialized"
fi

