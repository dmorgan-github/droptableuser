(
//requires wslib
//60.midiname
//\C3.namemidi

var middle_c = 60;
var notes = middle_c + (Scale.major.degrees ++ 12);
var freq1, freq2, interval, dir;

var intervals = [
	"unision",
	"minor 2nd",
	"major 2nd",
	"minor 3rd",
	"major 3rd",
	"perfect 4th",
	"diminished 5th",
	"perfect 5th",
	"minor 6th",
	"major 6th",
	"minor 7th",
	"major 7th",
	"octave"
];

~set_interval_chromatic = {arg choices;

	var dir = [1,-1].choose;
	var interval = choices.choose;

	if (dir < 0) {
		freq1 = middle_c + 12;
	} {
		freq1 = middle_c;
	};

	freq2 = freq1 + (interval * dir);

	[freq1, freq2].debug;

	nil;
};

~set_interval_scale = {

	var dir = [1,-1].choose;

	if (dir < 0) {
		freq1 = middle_c + 12;
	} {
		freq1 = middle_c;
	};

	freq2 = notes.choose;

	//[freq1, freq2].debug;

	nil;
};

~choose = {arg limit, f1;

	freq1 = notes.choose;
	freq2 = notes.choose;

	if (limit.isNil.not) {
		freq1 = notes[0..limit-1].choose;
		freq2 = notes[0..limit-1].choose;
	};

	if (f1.isNil.not) {
		var midinote = f1.namemidi;
		midinote.debug;
		freq1 = midinote;
	};

	nil;
};

~play_scale = {

	Tdef(\trainer, {
		notes.do({arg freq;
			Synth(\piano, [\freq, freq.midicps]);
			1.wait;
		});
	}).play
};

~play = {

	Tdef(\trainer, {
		Synth(\piano, [\freq, freq1.midicps]);
		//(\instrument: \default, \freq: freq1.midicps).play;

		2.wait;
		Synth(\piano, [\freq, freq2.midicps]);
		//(\instrument: \default, \freq: freq2.midicps).play;
	}).play
};

~check_notes = {arg note1, note2;

	var result = [note1.namemidi, note2.namemidi];
	var interval, dif, dir = "asc";

	if ( (result[0] == freq1) && (result[1] == freq2) ) {
		"correct".postln;
	}  {
		"try again".postln;
	};

	dif = freq2 - freq1;
	if (dif < 0) {
		dir = "desc";
		dif = dif * -1;
	};
	interval = intervals.at(dif)  + dir;
	[result.midiname, [freq1, freq2].midiname, interval ];
};

~choose_play = {arg limit, f1;

	var choices = [
		[1,2], //seconds
		[3,4], //thirds
		[5], //fourths
		[6,7], //fifths
		[8,9], //sixths
		[10,11]
	];

	//~choose.(limit, f1);
	var interval = choices.choose;
	//~set_interval_chromatic.(interval);
	~set_interval_scale.();
	~play.();
};
)

~choose_play.();
~play.();
~play_scale.();

~check_notes.(\C4, 'G3');



