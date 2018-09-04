/////////////////////////////////
// define player object
(
~grid_player = {

	var obj = (
		events: [],
		dur: 1,
		matrix: [],
		process: {arg self, count, time;

			Plazy({

				var rows = self.matrix;
				var evts = rows.collect({arg item, row;

					var val;
					var event;
					var x = (count % item.size).asInt;
					val = item.wrapAt(count).value;

					event = Event.silent;
					if (val > 0) {
						var myEvent = self.events.wrapAt(row);
						if (myEvent.isKindOf(Event)) {
							event = myEvent;
						};
						if (myEvent.isKindOf(Array)) {
							event = myEvent.collect({arg evt;
								Pn(evt, 1)
							});
							event = Ppar(event);
						}
					};

					Pn(event, 1);
				});

				Ppar(evts);
			});
		},
		player: {arg self;

			var player = Pspawner({arg sp;

				inf.do({arg i;

					var time = self.dur.next;
					var evt = self.process(i.asInt, time);
					sp.par(evt);
					sp.wait(time);
				});
			});
			player;
		}
	);

	obj;
};
)

TempoClock.default.tempo_(90/60);

/////////////////////////////////
// midi set up
MIDIClient.init;
m = MIDIOut(0);

//////////////////////////////////////////////

~midi_kit = ~grid_player.();
~p1 = ~midi_kit.player.play;
~p1.stop

(type:\midi, midicmd:\noteOn, midiout:m, midinote:'C1'.namemidi, chan: 0).play


(
~midi_kit.matrix = [

	[1,0,0,0, 0,0,1,0, 0,1,0,0, 1,0,0,0],
	[0,0,0,0, 0,0,0,0, 0,1,1,0, 0,1,1,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0],
	[0,0,0,0, 0,0,1,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,
		0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0
	],
	[0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,1,0, 0,0,0,0, 0,0,0,0],
	[0,0,0,0, 0,0,0,0, 0,0,1,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0]
];
)


Tdef(\midi_kit).stop
(
Tdef(\midi_kit, {

	var cols = 16;

	~midi_kit.dur = Pseq([0.25], inf).asStream;

	~midi_kit.events = [
		(type:\midi, midicmd:\noteOn, midiout:m, midinote:'C1'.namemidi, chan: 0, amp:1),
		(type:\midi, midicmd:\noteOn, midiout:m, midinote:'C#1'.namemidi, chan: 0, amp:1),
		(type:\midi, midicmd:\noteOn, midiout:m, midinote:'D1'.namemidi, chan: 0, amp:1),
		(type:\midi, midicmd:\noteOn, midiout:m, midinote:'D#1'.namemidi, chan: 0, amp:1),
		(type:\midi, midicmd:\noteOn, midiout:m, midinote:'E1'.namemidi, chan: 0, amp:1),
	];

	~midi_kit.matrix = (0..~midi_kit.events.size-1).collect({arg i;
		(0..cols-1).collect({arg j; 0})
	});

	~midi_kit.matrix[0] = [ 1, 0, 0, 0,  1, 0, 0, 0,  1, 0, 0, 0,  1, 0, 0, 0 ];

	loop({

		(1..~midi_kit.events.size-1).do({arg i;

			(0..cols-1).do({arg j;

				var has_hit = false;
				i.do({arg k;
					if (~midi_kit.matrix[k][j] == 1) {
						has_hit = true
					} {
						if (j > 0) {
							// if previous cell has a hit
							if (~midi_kit.matrix[k][j-1] == 1) {
								if (0.8.coin) {
									has_hit = true;
								}
							}
						}
					}
				});

				if (has_hit) {
					~midi_kit.matrix[i][j] = 0;
				} {
					if (0.4.coin) {
						~midi_kit.matrix[i][j] = 1;
					} {
						~midi_kit.matrix[i][j] = 0;
					}
				}
			});

		});

		"............".postln;
		~midi_kit.matrix.asString.replace("],", "],\n").postln;
		32.wait;
	});

});

Tdef(\midi_kit).play;
)


//////////////////////////////////////////////
//
~s1_midi = ~grid_player.();
~p2 = ~s1_midi.player.play;

(
Tdef(\s1, {

	var cols = 16;

	~s1_midi.dur = Prand([0.5], inf).asStream;

	~s1_midi.events = [
		(type:\midi, midicmd:\noteOn, midiout:m, midinote:{['C3', 'C4'].choose.namemidi}, chan: 1),
		(type:\midi, midicmd:\noteOn, midiout:m, midinote:{['D3', 'Eb4'].choose.namemidi}, chan: 1),
		(type:\midi, midicmd:\noteOn, midiout:m, midinote:{['F4', 'Bb3'].choose.namemidi}, chan: 1),
		(type:\midi, midicmd:\noteOn, midiout:m, midinote:{['G3', 'G#4'].choose.namemidi}, chan: 1),
		(type:\midi, midicmd:\noteOn, midiout:m, midinote:{['B4'].choose.namemidi}, chan: 1),
	];

	~s1_midi.matrix = (0..~s1_midi.events.size-1).collect({arg i;
		(0..cols-1).collect({arg j; 0})
	});

	~s1_midi.matrix[0] = [ 1, 0, 0, 0,  1, 0, 0, 0,  1, 0, 0, 0,  1, 0, 0, 0 ];

	loop({

		(1..~s1_midi.events.size-1).do({arg i;

			(0..cols-1).do({arg j;

				var has_hit = false;
				i.do({arg k;
					if (~s1_midi.matrix[k][j] == 1) {
						has_hit = true
					} {
						if (j > 0) {
							// if previous cell has a hit
							if (~s1_midi.matrix[k][j-1] == 1) {
								if (0.8.coin) {
									has_hit = true;
								}
							}
						}
					}
				});

				if (has_hit) {
					~s1_midi.matrix[i][j] = 0;
				} {
					if (0.4.coin) {
						~s1_midi.matrix[i][j] = 1;
					} {
						~s1_midi.matrix[i][j] = 0;
					}
				}
			});

		});

		"............".postln;
		~s1_midi.matrix.asString.replace("],", "],\n").postln;
		32.wait;
	});

});

Tdef(\s1).play;
)

