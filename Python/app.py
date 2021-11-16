from Module import Module 
import json
import checksumdir
from os import listdir
from os.path import isfile, join
import glob
import os

class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

path = "/Users/tompeterson/Documents/modules"
count = path.split("/")
# print(len(count))
# print(os.walk("/Users/tompeterson/Documents/modules"))

with open("./modules.json") as f:
  data = json.load(f)

def getModules():
    module_dirs = []
    for root,dirs,files in os.walk(path):
        if len(root.split("/")) == len(count) + 2:
            module_dirs.append(root)
    return module_dirs

for d in getModules():
    print(d)
    mds = d.split("/")
    print("Working on module: " + mds[-1])
    if mds[-2] in data:
        if mds[-1] in data[mds[-2]]:
            print("found module configuration for: " + mds[-2] + "/" + mds[-1])
            print("Checking Hash")
            print("current hash: " + checksumdir.dirhash(d))
            existing = data[mds[-2]][mds[-1]]
            print("existing hash: " + existing["hash"] )
            if checksumdir.dirhash(d) == existing["hash"]:
                print("hashes match, no changes detected")
            else:
                print(f"{bcolors.OKGREEN}{mds[-2]}/{mds[-1]} -> Changes detected! \n 1. update major version \n 2. update minor version \n 3. update patch version \n q. Quit{bcolors.ENDC}")
                answer = input("> ")
                if answer == "1":
                    print(f"{bcolors.OKCYAN}Updated the major version from: {str(existing['major'])} to: {str(int(existing['major'])+1)} {bcolors.ENDC}")
                    existing['major'] = int(existing['major'])+1
                    existing['hash'] = checksumdir.dirhash(d)
                elif answer == "2":
                    print(f"{bcolors.OKCYAN}Updated the minor version from: {str(existing['minor'])} to: {str(int(existing['minor'])+1)} {bcolors.ENDC}")
                    existing['minor'] = int(existing['minor'])+1
                    existing['hash'] = checksumdir.dirhash(d)
                elif answer == "3":
                    print(f"{bcolors.OKCYAN}Updated the patch version from: {str(existing['patch'])} to: {str(int(existing['patch'])+1)} {bcolors.ENDC}")
                    existing['patch'] = int(existing['patch'])+1
                    existing['hash'] = checksumdir.dirhash(d)
                elif answer == "q":
                    print(f"{bcolors.OKBLUE} Skipping this update!{bcolors.ENDC}")
                else:
                    print(f"{bcolors.OKBLUE} WARNING: Could not read input, please provide either 1, 2, 3, or q{bcolors.ENDC}")
        else: 
            print("Could not find the module in the existing registry. \n Do you want to add it?")
            answer = input("> ")
            if answer == "y" or answer == "yes":
                data[mds[-2]][mds[-1]] = {
                    'hash': checksumdir.dirhash(d),
                    'major':  0,
                    'minor': 0,
                    'patch': 1,
                }
            elif answer == "n" or answer == "no":
                print(f"{bcolors.OKBLUE} Skipping this update!{bcolors.ENDC}")
            else:
                print(f"{bcolors.WARNING}Could not read input, please provide either y, yes, n, no.{bcolors.ENDC}")
    else:
        print("Could not find the module in the existing registry. \n Do you want to add it?")
        answer = input(">")
        if answer == "y" or answer == "yes":
            data[mds[-2]] = {} # need to create root folder syntax as well.
            data[mds[-2]][mds[-1]] = {
                    'hash': checksumdir.dirhash(d),
                    'major':  0,
                    'minor': 0,
                    'patch': 1,
            }
        elif answer == "n" or answer == "no":
                print(f"{bcolors.OKBLUE} Skipping this update!{bcolors.ENDC}")
        else:
            print(f"{bcolors.WARNING}Could not read input, please provide either y, yes, n, no.{bcolors.ENDC}")   

moduleFile = open("new.json", "w")
moduleFile.write(json.dumps(data))