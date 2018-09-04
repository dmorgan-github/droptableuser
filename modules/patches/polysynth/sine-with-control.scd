(
SynthDef(\sine, {

	var gate = \gate.kr(1);
	var freq = Vibrato.kr(\freq.kr(432), \vrate.kr(6), \vdepth.kr(0.0));
	var sig = SinOsc.ar(freq).tanh;
	var env = Env.adsr(
		\atk.kr(0.01),
		\decay.kr(0.3),
		\susLevel.kr(0.5),
		\rel.kr(1),
		curve:\curve.kr(-4)
	).kr(gate:gate, doneAction:Done.freeSelf);
	sig = sig * env * AmpCompA.kr(freq) * \amp.kr(-20.dbamp);
	sig = Pan2.ar(sig, \pan.kr(0));
	Out.ar(\out.kr(0), sig);

}).add;
)

~p[\sines].group.release;

/////////////////////////////////////////
// touchosc: notes
~notes = ();
(
var scale = Scale.new(#[0,2,5,7,10]);
~p[\sines].play;
~p[\verb].play;
Fdef('/1/buttons1', {arg row, col, val;

	var key = ('/1/buttons1/' ++ row ++ '/' ++ col).asSymbol;
	var offset = (7 * 1).neg;
	var degree = 7 * row + col + offset;
	var freq = ~freq_func.( (degree: degree, scale: scale));

	if (val == 1) {
		//~notes[key].release;
		~notes[key] = Synth(\sine,
			[\freq, freq, \gate, 1, \atk, 1, \rel, 10, \vdepth, 0.005, \amp, -18.dbamp, \out, ~p[\sines].bus.index],
			target:~p[\sines].group
		);
	} {
		~notes[key].release;
	}
});

{
	var size = 5;
	Fdef('/1/encoder1', {arg val;
		if (val == 1) {
			size = (size + 0.1).clip(0, 20);
		} {
			size = (size - 0.1).clip(0, 20);
		};
		~p[\verb].set(\size, size);
	})
}.();

);

/////////////////////////////////////////
// verb
~p[\verb].clear;
(~p[\verb][0] = {
	var in = \in.ar([0,0]);
	var fx = JPverb.ar(in, 5, 0, \size.kr(5));
	fx;
};
//~p[\verb].addSpec(\param, [0.0, 1.0, \lin, 0.0, 0.4]);
);
~p[\verb] <<> ~p[\sines];
~p[\verb].play;
~p[\verb].stop;
~verb_win = App.guiHelper(~p[\verb], "verb");
~verb_win.front;


App.saveWorkspace("ws1");