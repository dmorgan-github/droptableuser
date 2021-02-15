from pydub import AudioSegment, effects
import os
import sys

if __name__ == "__main__":

	args = sys.argv
	path = args[1]


	full_path = os.path.abspath(path)

	song = AudioSegment.from_wav(full_path)
	# should result in wav with peak of -6db
	normalizedsound = effects.normalize(song, 4)

	directory = os.path.dirname(full_path)
	name, ext = os.path.splitext(full_path)
	name = name + '-6db' + ext
	full_path = directory + '/' + name

	normalizedsound.export(name, 'wav')
