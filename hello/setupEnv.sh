# SPecify the folder structure you want

FOLDER_1="srcs"
FOLDER_2="requirements"

# setup the env
export INCEPTION_PATH=$(pwd)
touch $FOLDER_1/.env
echo "DOMAIN_NAME=$USER.42.fr" > $FOLDER_1/.env
echo "CERT_=/etc/ssl/certs/$USER.42.fr.crt" >> $FOLDER_1/.env
echo "KEY_=/etc/ssl/private/$USER.42.fr.key" >> $FOLDER_1/.env
echo "MYSQL_PROBLEM=problemdb"  >> $FOLDER_1/.env
echo "MYSQL_ROOT_PROBLEM_PASSWORD=noproblem"  >> $FOLDER_1/.env
echo "MYSQL_USER_PROBLEM=problemuser"  >> $FOLDER_1/.env
echo "MYSQL_USER_PASSWORD_PROBLEM=noproblem"  >> $FOLDER_1/.env
echo "WP_PROBLEM_ADMIN=wpproblem"  >> $FOLDER_1/.env
echo "WP_PROBLEM_ADMIN_PASSWORD=justproblem"  >> $FOLDER_1/.env
echo "WP_PROBLEM_EMAIL=just@problem.com"  >> $FOLDER_1/.env
echo "WP_NORMAL_PROBLEM=userproblem" >> $FOLDER_1/.env
echo "WP_NORMAL_PROBLEM_PASS=okeypass" >> $FOLDER_1/.env
echo "WP_NORMAL_PROBLEM_EMAIL=not@problem.com"  >> $FOLDER_1/.env
echo "INCEPTION_PATH=$INCEPTION_PATH" >> $FOLDER_1/.env
mkdir -p /home/kvebers/problem_files
mkdir -p /home/kvebers/problem_db

