/////////////////////////////////////////
// proxy space
~p = ~p ? ProxySpace.new(s, \p);

/////////////////////////////////////////
// sand
~p[\sand].clear;
~p[\sand].mold;
(~p[\sand][0] = {

    var trig = \trig.kr;
	var freq = Vibrato.kr(\freq.kr(432).lag(\lag.kr(0)), \vrate.kr(6), \vdepth.kr(0.001)) * [1, 1.01];

	var osc1 = {
		var sig = Saw.ar( (freq.cpsmidi - 3).midicps );
		sig = BPF.ar(sig, Env([1200,1200,440],[0,0.5],0).kr(gate:trig), \osc1_res.kr(0.2));
		sig = sig * Env.adsr(\osc1_atk.kr(0.5)).kr(gate:trig);
		sig;
	};

	var osc2 = {
		var sig = Pulse.ar((freq.cpsmidi + 14).midicps , width:SinOsc.kr(1/8).range(0.3,0.7));
		sig = BPF.ar(sig, Env([2200,2200,1200],[0,0.7],-4).kr(gate:trig), \osc2_res.kr(0.2));
		sig = sig * Env.adsr(\osc2_atk.kr(0.5)).kr(gate:trig);
		sig;
	};

	var osc3 = {
		var sig = VarSaw.ar( (freq.cpsmidi - 12).midicps, width:SinOsc.kr(1/6).range(0.3,0.7));
		sig = BBandPass.ar(sig, Env([880,880,220],[0,0.3],24).kr(gate:trig), 0.1);
		sig = sig * Env.adsr(\osc3_atk.kr(0.5)).kr(gate:trig);
		sig;
	};

	var osc4 = {
		// ??
	};

	//var env = Env(
	//	[0,\peakLevel.kr(1),\susLevel.kr(0.5),0],
	//	[\atk.kr(0.01), \decay.kr(0.3), \sus.kr(1), \rel.kr(1)],
	//	curve:\curve.kr(-4)
	//).kr(gate:trig);

	var env = Env.adsr(\atk.kr(0.5)).kr(gate:trig);

	var sig = [
		osc1.() * \osc1.kr(1),
		osc2.() * \osc2.kr(1),
		osc3.() * \osc3.kr(1)/*,
		osc4.()*/
	].sum;


	sig = sig * env * AmpCompA.kr(freq) * \amp.kr(-12.dbamp);

	sig = SVF.ar(sig, \cutoff.kr(2200), \res.kr(0.5));
	sig = XFade2.ar(sig, JPverb.ar(sig, 2, 0, 2), 0);

	sig = Splay.ar(sig);
	sig;
};
~p[\sand].addSpec(\osc1_cutoff, \freq.asSpec);
~p[\sand].addSpec(\osc2_cutoff, \freq.asSpec);
~p[\sand].addSpec(\osc3_cutoff, \freq.asSpec);
~p[\sand].addSpec(\cutoff, \freq.asSpec);
~p[\sand].addSpec(\osc1_res, [0.001,1, \lin, 0, 0.2]);
~p[\sand].addSpec(\osc2_res, [0.001,1, \lin, 0, 0.2]);
~p[\sand].addSpec(\osc3_res, [0.001,1, \lin, 0, 0.2]);
~p[\sand].addSpec(\res, [0.001,1, \lin, 0, 0.2]);
~p[\sand].addSpec(\osc1_atk, [0, 1, \lin, 0.01]);
~p[\sand].addSpec(\osc2_atk, [0, 1, \lin, 0.01]);
~p[\sand].addSpec(\osc3_atk, [0, 1, \lin, 0.01]);
~p[\sand].addSpec(\atk, [0, 1, \lin, 0.01]);
);
~p[\sand].play;
~p[\sand].stop;
~sand_win = App.guiHelper(~p[\sand], "sand");
~sand_win.front;

~p[\sand].set(\trig, 0, \freq, 840);


440 - 12.midiratio

(
Fdef(\noteOn, {arg note;
	note.debug("noteOn");
	~p[\sand].set(\trig, 1, \freq, note.midicps);
});
Fdef(\noteOff, {arg note;
	note.debug("noteOff");
	~p[\sand].set(\trig, 0);
});
)

~kb = ~keyboard.();
~kb.front;