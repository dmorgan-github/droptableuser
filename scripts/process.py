import os
import sys
import random
import subprocess
import shlex
import sox
import glob


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


def get_dest(src, commit_id):
	dirpath, filename = os.path.split(src)
	if (dirpath == ""):
		dirpath = "."
	filename, ext = os.path.splitext(filename)
	filename = "{}-{}-6db{}".format(filename, commit_id, ext)
	dest = "{}/{}".format(dirpath, filename)
	return dest


def process_sox(src, dest):

	tfm = sox.Transformer()
	# trim silence
	tfm.silence(1, 0.1)
	# normalize
	tfm.norm(-6)
	# add fade in and fade out
	tfm.fade(fade_in_len=8, fade_out_len=8)
	# output
	tfm.build_file(src, dest)


def add_to_music(dest):

	cmd = 'open -a Music "{}"'.format(dest)
	args = shlex.split(cmd)
	subprocess.run(args)


def remove_file(path):
	os.remove(path)


if __name__ == '__main__':

	src = sys.argv[1]

	commit_id = get_commit_id()
	dest = get_dest(src, commit_id)
	process_sox(src, dest)
	add_to_music(dest)
	remove_file(src)


