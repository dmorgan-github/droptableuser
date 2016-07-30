/////////////////////////////////////////////////////////////

Pphrase {

	var <isBeat;

	var <isBarStart;

	var <countToBarEnd;

	var <isDownBeat;

	var <isBackBeat;

	var <delta;

	*new {arg isBeat, isBarStart, countToBarEnd, isDownBeat, isBackBeat, delta;

		^super.new.prInit(isBeat, isBarStart, countToBarEnd, isDownBeat, isBackBeat, delta);
	}

	prInit {arg pIsBeat, pIsBarStart, pCountToBarEnd, pIsDownBeat, pIsBackBeat, pDelta;

		isBeat = pIsBeat;
		isBarStart = pIsBarStart;
		countToBarEnd = pCountToBarEnd;
		isDownBeat = pIsDownBeat;
		isBackBeat = pIsBackBeat;
		delta = pDelta;
		^this;
	}
}

PphraseManager {

	*build {arg beats = 8, beatDiv = 2, phraseMaker;

		var delta = 1/beatDiv;

		var rtn = Routine({

			var queue = LinkedList.new;
			var count = 0;

			inf.do({arg i;

				var event, dir, wait;

				var phrase;
				var isBeat = false;
				var isBarStart = false;
				var countToBarEnd = beats;
				var isDownBeat = false;
				var isBackBeat = false;
				var barPos = count % beats;

				if (barPos.equalWithPrecision(0)) {
					isBarStart = true;
				};

				countToBarEnd = beats - barPos;

				if ((barPos % 1) == 0) {

					isBeat = true;
					if (barPos.asInt.even) {
						isDownBeat = true;
					} {
						isBackBeat = true;
					};
				};

				if (queue.isEmpty) {
					phrase = Pphrase(isBeat, isBarStart, countToBarEnd, isDownBeat, isBackBeat, delta);
					count = count + phraseMaker.value(phrase, queue, beats, beatDiv);
				};

				event = queue.popFirst;
				dir = event[\dir] ? 1;
				wait = event[\delta];
				[wait, event[\index], dir].yield;
			});
		});

		^rtn;
	}
}

Pslcr {

	*build {arg buf, beats, beatDiv, phraseMaker, clock = TempoClock.default;

		var rtn = Routine({

			var numFrames = buf.numFrames;
			var sampleRate = buf.sampleRate;

			// length in seconds of sample
			var len = numFrames/sampleRate;

			// beats per second
			var bps = beats/len;

			// number of slices
			var slices = beats * beatDiv;

			// frames per slice
			var fps = numFrames/slices;

			var rtn = PphraseManager.build(beats, beatDiv, phraseMaker);

			inf.do({

				var val = rtn.next();
				var delta = val[0];
				var index = val[1];
				var dir = val[2];
				var rate = clock.tempo / bps * dir;
				var dur = clock.beatDur * delta;

				var startPos = index * fps;
				if (dir < 0) {
					// start at the end of slice in order to play backward
					startPos = ((index + 1) * fps) - 1;
				};

				[delta, buf, rate, startPos].yield;
			});
		});

		^rtn;
	}
}