from Module import Module 
import json
import checksumdir
from os import listdir
from os.path import isfile, join
import glob
import os

print(os.walk("/Users/tompeterson/Documents/modules"))


directories = os.walk("/Users/tompeterson/Documents/modules")
for d in directories:
    dir = d[0].split("/")
    if len(dir) == 6:
        print ("getting the modules in this folder: " + '/'.join(dir))
        module_directories = os.walk('/'.join(dir))
        for md  in module_directories:
            print(md)
    else:
        print("not a root module folder: "+ '/'.join(dir))
    


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