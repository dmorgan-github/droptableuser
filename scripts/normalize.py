#alias normalize="/Users/david/opt/anaconda3/envs/audio/bin/python /Users/david/projects/droptableuser/scripts/normalize.py"

import sys
from pydub import AudioSegment, effects
import os
from shutil import copy
import subprocess

if __name__ == "__main__":

	try:

		#print(os.environ["PATH"])
		args = sys.argv
		path = args[1]
		copy_to_music = 0
		if (len(args) > 2):
			copy_to_music = args[2]

		full_path = os.path.abspath(path)
		print('open ' + full_path)
		song = AudioSegment.from_wav(full_path)
		#song = AudioSegment.from_file(full_path, "wav")
		# should result in wav with peak of -6db

		print('normalizing ')
		normalizedsound = effects.normalize(song, 6)
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

	except Exception as e:
		print(e)

