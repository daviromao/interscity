FILE_DIR=`dirname $0`
BASE_DIR=`readlink -f $FILE_DIR/../`

PROJECT_NAME="actuator-controller"
NETWORK="platform"
NET_ALIAS=$PROJECT_NAME
IMAGE_NAME="smart-cities/$PROJECT_NAME"
EXPOSED_PORT=3001

CYAN='\033[0;36m'
NC='\033[0m'

verify () {
  if [ $? != 0 ]; then
    echo $1
    exit 2
  fi
}

if [ "$1" = "start" ]; then
  echo "Starting service $PROJECT_NAME"
  sudo docker run  -d -v $BASE_DIR:/$PROJECT_NAME/ --net=$NETWORK \
    --net-alias=$NET_ALIAS --name $PROJECT_NAME -p $EXPOSED_PORT:3000 \
    $IMAGE_NAME
  if [ ! -f "$BASE_DIR/db/$PROJECT_NAME.sqlite3" ]; then
    sudo docker exec $PROJECT_NAME bundle exec rake db:create 2> /dev/null
  fi
  sudo docker exec $PROJECT_NAME bundle exec rake db:migrate

  echo "${CYAN}"
  echo "############################################################"
  echo "     To execute commands in container you must run"
  echo "     $ sudo docker exec $PROJECT_NAME <command>"
  echo "############################################################"
  echo "${NC}"
fi

if [ "$1" = "stop" ]; then
  echo "Stoping service $PROJECT_NAME"
  sudo rm -rf tmp/pids/*
  sudo docker kill $PROJECT_NAME 1> /dev/null
  sudo docker rm $PROJECT_NAME 1> /dev/null
fi
