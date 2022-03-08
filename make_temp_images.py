## make_temp_images.py
"""
Just making some filler images for the test version
"""
import os
import matplotlib.pyplot as plt

HOME            = "/Users/redx/Documents/Desktop/NFTs/RareRhinos/"
IMAGE_DIR       = HOME + "images"
HIDDEN_IMGS_DIR = HOME + "hidden_images"

os.system("mkdir -p " + IMAGE_DIR)
os.system("mkdir -p " + HIDDEN_IMGS_DIR)

os.chdir(HIDDEN_IMGS_DIR)
plt.annotate("?", (0.4,0.4), fontsize=96)
plt.axis("off")
plt.savefig("hidden.png")
plt.close()
os.chdir(IMAGE_DIR)
for ii in xrange(2222):
  plt.annotate("RR" + str(ii+1).zfill(4), (0.01,0.4), fontsize=96)
  plt.axis("off")
  plt.savefig(str(ii+1) + ".png")
  plt.close()
# end for ii
## make_temp_images.py
