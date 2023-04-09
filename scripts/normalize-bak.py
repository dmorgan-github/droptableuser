#alias normalize="/Users/david/opt/anaconda3/envs/audio/bin/python /Users/david/projects/droptableuser/scripts/normalize.py"

from pydub import AudioSegment, effects
import os
import sys
from shutil import copy
import subprocess

if __name__ == "__main__":

	args = sys.argv
	path = args[1]
	copy_to_music = 0
	if (len(args) > 2):
		copy_to_music = args[2]

	full_path = os.path.abspath(path)
	song = AudioSegment.from_wav(full_path)
	# should result in wav with peak of -6db
	normalizedsound = effects.normalize(song, 4)
	directory = os.path.dirname(full_path)
	name, ext = os.path.splitext(full_path)
	name = name + '-6db' + ext
	full_path = name
	normalizedsound.export(full_path, 'wav')

	#open -a Music full_path
	subprocess.run(['open', '-a', 'Music', full_path])

	if (copy_to_music != 0):
		print('copying to Music')
		copy(full_path, '/Users/david/Music/Music/Media.localized/Automatically Add to Music.localized/')



