## make_temp_metadata.py
"""
This will create a json file for each image and also a _metadata.json
file that stitches them together. 
"""
IPFS_URL = ""
IPFS_URL = "QmUrtxTLjJDcEMxKbSSPxJh1k4m55JwXM15ogT5RUcnyZV"
import os
import glob
import time
import numpy as np
from hashlib import sha1
HOME = "/Users/redx/Documents/Desktop/NFTs/RareRhinos/"

META_DIR  = HOME + "metadata/"
IMAGE_DIR = HOME + "images/"

os.system("mkdir -p " + META_DIR)

os.chdir(IMAGE_DIR)
images = np.sort(glob.glob("*.png"))

NUM = len(images)

changes = {
           "name" : ["RR#" + str(ii+1) for ii in range(NUM)],

           "description" : NUM*["Some pithy description of Rare Rhinos ;)"],

           "image" : ["ipfs://" + IPFS_URL + "/" + str(ii+1) + ".png" for ii in range(NUM)],

           "dna" : ["" + sha1(str(ii+1).encode('utf-8')).hexdigest() for ii in range(NUM)],
           "edition" : [ii for ii in range(NUM)],

           "date" : [int(time.time()*10000)+ii for ii in range(NUM)],

           "compiler" : NUM*["Rare Rhinos Engine"],

           "attributes" : [[
            {
             'trait_type': 'RR Trait #1',
             'value': "fill in the blank here"
            },
            {
             'trait_type': 'RR Trait #2',
             'value': "fill in the blank here"
            },
            {
             'trait_type': 'RR Trait #3',
             'value': "fill in the blank here"
            },
            {
             'trait_type': 'RR Trait #4',
             'value': "fill in the blank here"
            }
            ] for ii in range(NUM)]
          }
# end changes dictionary

os.chdir(META_DIR)
with open("_metadata.json", "w") as fid_write_global:
  fid_write_global.write("[\n")

  cnt = 0
  for ii,image in enumerate(images):
    cnt += 1
    print("image: ", image)
    with open(META_DIR + "template.json", "r") as fid_read:
      with open(str(cnt) + ".json", "w") as fid_write_local:
        for line in fid_read:
          for key in changes.keys():
            if key in line:
              line = line.split(":")[0]
              if type(changes[key][ii]) == type("str"):
                line += ': "' + str(changes[key][ii]) + '",\n'
              else:
                line += ': ' + str(changes[key][ii]) + ',\n'
              # end if/else

              if "attributes" in line:
                new_line = ""
                for char in line:
                  if char == "'":
                    char = '"'
                  # end if
                  new_line += char
                line = new_line
              # end if

              if key == "compiler":
                line = line[:-2] + "\n"
              # end if
            # end if
          # end for
          fid_write_local.write(line)
          if ii < NUM-1 and line.split()[0] == "}":
            line = line[:-1] + ",\n"
          # end if
          fid_write_global.write(4*" " + line)
        # end for
      # end with
    # end with
    name_old = IMAGE_DIR + image
    name_new = IMAGE_DIR + str(cnt) + ".png"

    print("name_old: ", name_old)
    print("name_new: ", name_new)
    #os.system("mv " + name_old + " " + name_new)
  # end for
  fid_write_global.write("]")
# end with
## end make_temp_metadata.py
