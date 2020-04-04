/*
https://cdn.korg.com/us/support/download/files/beeb177b34c36fe56e585763c40da579.pdf?response-content-disposition=inline%3Bfilename%2A%3DUTF-8%27%27volcafm_Parameter_List_v1.pdf&response-content-type=application%2Fpdf%3B

* 1: 0 0 0 0 0 0   slow attack, bit of release
* 2: 0 0 0 0 0 0   the same as 1, f*2, detuned
* 3: 0 0 0 1 0 0   bit of longer attack, rel the same, f*7
  4: 0 0 0 0 0 0
* 5: 0 0 0 0 0 1   f*20
  6: 0 0 0 0 0 f
*/

(
Ndef(\fm1)[0] = {

	var freq = ['c1', 'g1', 'eb2'].namecps * [1, 2];

	var mod = {arg freq, ratio=2, fb=0, index=1, ivel=1, idur=1;
		var idx = freq * ratio * Env.circle([index, index, index * ivel, index], [0, idur * 0.5, idur * 0.5], -4).kr;
		var modfreq = freq * ratio;
		var sig = SinOscFB.ar(modfreq, fb) * idx;
		sig;
	};

	var car = {arg freq, mod=0;
		var sig = SinOsc.ar(freq + mod);
		sig;
	};

	var sig = [
		car.( freq ),
		car.( freq * 1.5 ) * SinOsc.kr(1/51).range(0.1, 1),
		car.( freq * 2, mod.( freq, ratio:1, fb:0, index:1, ivel:10, idur:31) ) * (SinOsc.kr(1/31).range(0.1, 0.8)),
		car.( freq * 4, mod.( freq, ratio:2, fb:0.8, index:1, ivel:0.5, idur:19) ) * SinOsc.kr(1/8).range(0.1, 0.8)
	].sum;

	sig = LeakDC.ar(sig);

	sig = BLowShelf.ar(sig, 50, 1, -30);

	sig = Splay.ar(sig) * 0.1;
};
)

Ndef(\fm1).play(vol:0.4, fadeTime:4);
Ndef(\fm1).stop(fadeTime:8);

Ndef(\fm1).filter(90, {arg in; PitchShift.ar(in, 2, 2, 0.01, 0.1)}).set(\wet90, 0.4);
Ndef(\fm1).filter(100, {arg in; JPverb.ar(in, 10, 0, 10, modDepth:0.5)}).set(\wet100, 0.6);
Ndef(\fm1).filter(110, {arg in; LPF.ar(in, 880)});




/////////////////////////////////////////
// record
App.saveWorkspace("wip3", rec:true);
s.stopRecording;



