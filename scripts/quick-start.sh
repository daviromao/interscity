FILE_DIR=`dirname $0`
BASE_DIR=`readlink -f $FILE_DIR/../`
PROJECT_NAME='resource-discoverer'
IMAGE_NAME=smart-cities/$PROJECT_NAME
NETWORK='platform'
verify () {
  if [ $? != 0 ]; then
    echo $1
    exit 2
  fi
}

sudo docker -v > /dev/null
verify "Error: You need to install docker first!"

echo "Installing and updating base image."
sudo docker pull debian:unstable
verify "Error: downloading debian:unstable image."

echo "Building docker image."
sudo docker build -t $IMAGE_NAME .
verify "Error: building docker image."

echo "Creating shared network."
sudo docker network create $PLATFORM 2> /dev/null

echo "To start the service run :"
echo "   $ sh scripts/development.sh start"
