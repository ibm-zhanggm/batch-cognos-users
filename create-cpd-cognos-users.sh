#!/bin/bash
if [ ! -n "$4" ] ;then
    echo "you should run as: create-cpd-cognos-users.sh <cluster> <cpd user> <password> <csv file> <user temp password>  such as create-cpd-cognos-users.sh "https://cpd-url" admin password cognos-users.csv temp4now
    exit
fi
cpd_cluster_host=$1
cpd_user=$2
cpd_password=$3
users_csv=$4
response=$(curl -k -X POST -H "cache-control: no-cache" -H "content-type: application/json" -d "{\"username\":\"${cpd_user}\",\"password\":\"${cpd_password}\"}" "${cpd_cluster_host}/icp4d-api/v1/authorize")
token=$(echo ${response} | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["token"]')
while IFS=, read -r user_name
do
    echo ${user_name}
    echo $(curl -k -X POST -H "Authorization: Bearer ${token}" -H "cache-control: no-cache" -H "content-type: application/json" -d "{\"user_name\":\"${user_name}\",\"password\":\"${temp-password}\",\"displayName\":\"${user_name}\",\"user_roles\":[\"User\"],\"email\":\"${user_name}\"}" "${cpd_cluster_host}/icp4d-api/v1/users")
done < "${users_csv}"