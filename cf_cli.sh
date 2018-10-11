#/bin/bash

# Global Variables
space_guid=""
space_name=""
name=""
memory=""
disk=""
state=""
health_check_timeout=""

# Param Variables
param_space=""
param_app=""

# Global loop counter
counter=0

# Global array size
size=0

PARAMS=""
while (( "$#" )); do
  case "$1" in
    -s|--space)
      param_space=$2
      space_name=$2
      shift 2
      ;;
    -a|--app)
      param_name=$2
      shift 2
      ;;
    --) # end argument parsing
      shift
      break
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      echo $PARAMS
      shift
      ;;
  esac
done
# set positional arguments in their proper place
eval set -- "$PARAMS"

func_get_apps() {
  `cf curl /v2/apps > sample.json`
}

func_get_spaces() {
  `cf curl /v2/spaces > sample.json`
}

func_get_array_size() {
  size=`jq -r '.resources | length' sample.json`
}

func_get_space_guid() {
  space_guid=`jq -r ".resources[$counter].metadata.guid" sample.json`
}

func_get_space_name() {
  space_name=`cf curl /v2/spaces/$space_guid | jq -r ".entity.name"`
}

func_get_space_url() {
  space_url=`jq -r ".resources[$counter].entity.space_url" sample.json`
}

func_get_name() {
  name=`jq -r ".resources[$counter].entity.name" sample.json`
}

func_get_memory() {
  memory=`jq -r ".resources[$counter].entity.memory" sample.json`
}

func_get_disk() {
  disk=`jq -r ".resources[$counter].entity.disk_quota" sample.json`
}

func_get_state() {
  state=`jq -r ".resources[$counter].entity.state" sample.json`
}

func_get_health_check_timeout() {
  health_check_timeout=`jq -r ".resources[$counter].entity.health_check_timeout" sample.json`
}

func_get_command() {
  `cf curl $endpoint > temp.json`
}

func_init_app_details() {
  func_get_name
  func_get_memory
  func_get_disk
  func_get_state
  func_get_health_check_timeout
}

func_get_apps_for_space() {
  `cf curl /v2/spaces/$space_guid/apps > sample.json`
}

func_get_space_guid_for_name() {
  func_get_spaces
  func_get_array_size
  counter=0
  while [[ $counter -le $size ]]
  do
    func_get_name
    if [[ $name == $param_space ]]; then
      func_get_space_guid
      return
    fi
    ((counter++))
  done
  echo "Space name not found!"
  exit 0
}

if [ ! -z ${param_space} ]; then  
  func_get_space_guid_for_name
  func_get_apps_for_space
else 
  func_get_apps
fi

counter=0
size=`jq -r '.resources | length' sample.json`

while [[ $counter -le $size ]]
do
 func_init_app_details
 if [[ $name != "null" ]]; then
  echo '/ ****************************** /' 
  echo 'Name: ' $name
  echo 'Memory: ' $memory
  echo 'Disk Quota: ' $disk
  echo 'State: ' $state
  echo 'Health-Check-Timeout: ' $health_check_timeout
  echo 'Space: ' $space_name
  echo '/ ****************************** /'

 fi 
  ((counter++))
done


