import os
import sys
import random
import subprocess
import shlex
import sox
import glob


norm = 3

def get_commit_id():

	cmd = 'git add .'
	args = shlex.split(cmd)
	subprocess.run(args)

	cmd = 'git commit -m "update patches"'
	args = shlex.split(cmd)
	subprocess.run(args)

	cmd = 'git rev-parse --short HEAD'
	args = shlex.split(cmd)
	output = subprocess.run(args, capture_output=True)
	return output.stdout.decode('ascii').replace('\n', '')


def get_dest(src):
	dirpath, filename = os.path.split(src)
	if (dirpath == ""):
		dirpath = "."
	filename, ext = os.path.splitext(filename)
	#filename = "{}-{}-{}db{}".format(filename, commit_id, norm, ext)
	filename = "{}-{}db{}".format(filename, norm, ext)
	dest = "{}/{}".format(dirpath, filename)
	return dest


def process_sox(src, dest, dofade=True):

	tfm = sox.Transformer()
	# trim silence
	tfm.silence(1, 0.1)
	# normalize
	tfm.norm(norm * -1)
	# add fade in and fade out
	if (dofade):
		tfm.fade(fade_in_len=8, fade_out_len=8)
	else: 
		print('process without fade')
	# output
	tfm.build_file(src, dest)


def add_to_music(dest):

	cmd = 'open -a Music "{}"'.format(dest)
	args = shlex.split(cmd)
	subprocess.run(args)


def remove_file(path):
	os.remove(path)


if __name__ == '__main__':

	dofade = True
	src = sys.argv[1]
	if (len(sys.argv) > 2):
		dofade = False

	#commit_id = get_commit_id()
	dest = get_dest(src)
	process_sox(src, dest, dofade)
	#add_to_music(dest)
	remove_file(src)


