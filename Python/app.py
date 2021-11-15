from Module import Module 
import json
import checksumdir
from os import listdir
from os.path import isfile, join
import glob
import os

path = "/Users/tompeterson/Documents/modules"
count = path.split("/")
# print(len(count))
# print(os.walk("/Users/tompeterson/Documents/modules"))

with open("./modules.json") as f:
  data = json.load(f)

# d2 = data['Resource_group']["resource_group2"]
# if "Resource_group" in data:
#     print("found it!")
# else:
#     print("nope!")

def root():
    root_dirs = []
    for root,dirs,files in os.walk(path):
        if len(root.split("/")) == len(count) + 1:
            root_dirs.append(root)
    return root_dirs
def getModules():
    module_dirs = []
    for root,dirs,files in os.walk(path):
        if len(root.split("/")) == len(count) + 2:
            module_dirs.append(root)
    return module_dirs

print(getModules())

# Get all directories in folder
# directories = os.walk("/Users/tompeterson/Documents/modules")
for d in getModules():
    print(d)
    mds = d.split("/")
    print("Working on module: " + mds[-1])
    if mds[-2] in data:
        if mds[-1] in data[mds[-2]]:
            print("found module configuration for: " + mds[-2] + "/" + mds[-1])
            print("Checking Hash")
            print("current hash: " + checksumdir.dirhash(d))
            existing = data[mds[-2]][mds[-1]]["hash"]
            print("existing hash: " + existing )
            if checksumdir.dirhash(d) == existing:
                print("hashes match, no changes detected")
            # print(d)
            # print("Found: " + mds[-3] + "/" + mds[-2])
            # print(d)
            # print(checksumdir.dirhash(d))

            # list_of_files = glob.glob("".join((md[0], "/*")))
            # if len(list_of_files) == 0:
            #     print("--- did not find any version info!")
            #     new =  input("--- Is this a new module? yes/no ")
            #     if new == 'yes':
            #         print("new version")

            #     break
            # else:
            #     # print(list_of_files)
            #     latest_file = max(list_of_files, key=os.path.getctime)
            #     print("found: " + latest_file)
    # else: 
    #     print("Skipping: " + md[0])
    


# [x[0] for x in os.walk("/Users/tompeterson/Documents/modules")]:
#     print (x)



# List all files in the dir
# onlyfiles = [f for f in listdir("./.version") if isfile(join("./.version", f))]
# print(onlyfiles)


# list_of_files = glob.glob('../.version/*') # * means all if need specific format then *.csv
# latest_file = max(list_of_files, key=os.path.getctime)
# print("found: " + latest_file)

# with open(latest_file) as f:
#   data = json.load(f)


# if checksumdir.dirhash("../Python") == data['hash']:
#     print("no changes!")
# else:
#     print("changes???")
#     print(checksumdir.dirhash("../Python"))

# moduleFile = open("module.json", "w")

# tfmodule = Module(0,0,1,checksumdir.dirhash("../Python"),"vnet")

# moduleFile.write(json.dumps(tfmodule.__dict__))


# print(tfmodule.hash)