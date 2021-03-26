#!/bin/bash
if [ ! -n "$4" ] ;then
    echo "you should run as: grant-cognos-access.sh <cluster> <cpd user> <password> <csv file>  such as grant-cognos-access.sh "https://cpd-url" admin password cognos-users.csv"
    exit
fi
cpd_cluster_host=$1
cpd_user=$2
cpd_password=$3
users_csv=$4
response=$(curl -k -X POST -H "cache-control: no-cache" -H "content-type: application/json" -d "{\"username\":\"${cpd_user}\",\"password\":\"${cpd_password}\"}" "${cpd_cluster_host}/icp4d-api/v1/authorize")
token=$(echo ${response} | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["token"]')
fetch_all_instances=$(curl -k -X GET -H "Authorization: Bearer ${token}" -H "cache-control: no-cache" -H "content-type: application/json" "${cpd_cluster_host}/zen-data/v3/service_instances?fetch_all_instances=false&limit=9223372036854775807&offset=0")
#echo ${fetch_all_instances}
instance_id=$(echo ${fetch_all_instances} | python parse_cognos_instance_id.py)
echo ${instance_id}
while IFS=, read -r user_name
do
    echo ${user_name}
    user=$(curl -k -X GET -H "Authorization: Bearer ${token}" -H "cache-control: no-cache" -H "content-type: application/json" "${cpd_cluster_host}/api/v1/usermgmt/v1/user/${user_name}")
    echo ${user}
    uid=$(echo ${user} | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["uid"]')
    echo ${uid}
    lower_name=$(echo ${user_name} | tr A-Z a-z)
    curl -k -X POST -H "Authorization: Bearer ${token}" -H "cache-control: no-cache" -H "content-type: application/json" -d "{\"users\":[{\"uid\":\"${uid}\",\"username\":\"${lower_name}\",\"display_name\":\"${user_name}\",\"role\":\"Analytics Users\",\"id\":\"${uid}\"}],\"serviceInstanceID\":\"${instance_id}\"}" "${cpd_cluster_host}/zen-data/v2/serviceInstance/users"
done < "${users_csv}"