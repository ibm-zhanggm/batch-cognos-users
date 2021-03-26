import json,sys
obj=json.load(sys.stdin)
for item in obj["service_instances"]:
    if item["addon_type"]=="cognos-analytics-app":
        print item["id"]
        break