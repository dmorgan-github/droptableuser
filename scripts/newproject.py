import random
import string
import os

n = 3
val = ''.join([random.choice(string.ascii_lowercase) for _ in range(n)])
path = "/Users/david/Documents/supercollider/workspaces/{}".format(val)
os.mkdir(path)

with open('{}/{}.scd'.format(path, val), 'w') as fp:
    pass

print(val)


