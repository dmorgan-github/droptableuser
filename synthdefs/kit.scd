/////////////////////////////////////////
// bd
// https://www.thonk.co.uk/wp-content/uploads/2018/12/BD-Schematic-1024x487.jpg

/*
envelopes matter the most! Bending and clipping them slightly for the pitch envelope can make a huge difference.
// not sure where this came from, sorry if i plagiarized.
b = Buffer.alloc(s, 512, 1, { |buf| buf.chebyMsg([0,0.6,2])});
(SynthDef(\kick, {arg freq = 50, amp=0.5;

    var amp_env, phase_env, phase, dur, out;
    dur = 0.25;
    amp_env = EnvGen.ar(Env.perc(1e-6,dur), doneAction:2);
    phase_env = EnvGen.ar(Env.perc(1e-6,0.125));

    phase = SinOsc.ar(20,0,pi) * phase_env;
    out = (Impulse.ar(0) + SinOsc.ar(freq,phase)) * amp_env * amp;
    out = LeakDC.ar(Shaper.ar(b, out));
    out = LPF.ar(out, 2500);
    out = HPF.ar(out, 30);
    Out.ar(0, out!2);
}).add)
};
*/

/*
~kick = S(\kick);
~kick.dur = 0.5;
~kick.freq = 50;
~kick.play;
~kick.stop;


/////////////////////////////////////////
// clap
// https://www.thonk.co.uk/shop/prok-handclap-panel-pcb/
(
SynthDef(\clap, {

	var osc1 = {
		var sig = WhiteNoise.ar;
		sig = BPF.ar(sig, 440);
		sig;
	};

	var osc2 = {
		var sig = Crackle.ar();
		sig = BPF.ar(sig, 2000);
		sig;
	};

	var osc3 = {
		var sig = PinkNoise.ar;
		sig = BPF.ar(sig, 1000);
		sig;
	};

	var sig = [
		osc1.(),
		osc2.(),
		osc3.()
	].sum;

	var lpf = LPF.ar(sig, 220) * Env.perc(0.1, 0.1).ar();

	var bpf = BPF.ar(sig, 1000) * Env.perc(0.01, 0.2).ar();

	sig = [
		lpf,
		bpf
	].sum;

	sig = Splay.ar(sig) * \amp.kr(0.3) * \vel.kr(1);
	DetectSilence.ar(sig, doneAction:Done.freeSelf);
	Out.ar(\out.kr(0), sig);

}).add;
)

~clap = S(\clap);
~clap.dur = 2;
~clap.play;
~clap.stop;

/////////////////////////////////////////
// sd
//https://www.thonk.co.uk/shop/prok-drums-snare-kit/
(
SynthDef(\sd, {

	var osc1 = {
		var freq = 160;
		var freqmul = XLine.ar(2, 1, 0.01);
		SinOsc.ar(freq * freqmul, 1) * Env.perc(0.001, 0.1).ar();
	};
	var osc2 = {
		var freq = 180;
		var freqmul = XLine.ar(2, 1, 0.07);
		SinOsc.ar(freq * freqmul, 1) * Env.perc(0.001, 0.1).ar();
	};

	var osc3 = {
		var sig = Crackle.ar();
		sig = BPF.ar(sig, 2000) * 2;
		sig;
	};

	var sig = [
		osc1.(),
		osc2.()
	].sum;

	var noise = osc3.();

	noise = [
		noise * Env.perc(0.001, 0.1).ar(),
		BPF.ar(noise) * Env.perc(0.001, 0.1).ar()
	].sum;

	sig = [
		sig,
		noise
	].sum;

	sig = Splay.ar(sig) * \amp.kr(0.3) * \vel.kr(1);
	DetectSilence.ar(sig, doneAction:Done.freeSelf);
	Out.ar(\out.kr(0), sig);

}).add;
)

~sd = S(\sd);
~sd.play;
~sd.stop;

/////////////////////////////////////////
// hh
(
SynthDef(\hh, {

	var osc1 = Pulse.ar([100, 422, 733] * 2).sum;
	var osc2 = Pulse.ar([1101, 2230, 1420] * 4).sum;
	var osc3 = WhiteNoise.ar();

	var sig = [
		osc1,
		osc2,
		osc3
	].sum;

	var lo = BPF.ar(sig, 240) * 1 * Env.perc(0.001, 0.01, 1, -14).ar();
	var mid = BPF.ar(sig, 1000) * 1 * Env.perc(0.001, 0.01, 1, -14).ar();
	var hi = BPF.ar(sig, 11800) * 1 * Env.perc(0.001, 0.01, 1, -14).ar();

	lo = LPF.ar(lo, 180);
	mid = HPF.ar(mid, 1100);
	hi = HPF.ar(hi, 8000);

	osc3 = osc3 * Env.perc(0.001, 0.2, 1, -2).ar();
	osc3 = BPF.ar(osc3, 10400);

	sig = [
		lo,
		mid * 0.8,
		hi * 0.5,
		osc3
	].sum;

	sig = Splay.ar(sig) * \amp.kr(0.3) * \vel.kr(1);
	DetectSilence.ar(sig, doneAction:Done.freeSelf);
	Out.ar(\out.kr(0), sig);

}).add;
)

~hh = S(\hh);
~hh.play;
~hh.stop;
~hh.dur = 0.125;




(
q = ();
q.numChans = 2;

ProxyChain.add(
    \dust, \mix -> { |dens=20, dustdec=0.02, dustfreq= 600|
        Ringz.ar(Dust.ar(dens).lag(0.0001), dustfreq, dustdec)
    }
);

ProxyChain.add(
    \ringmod, \filter -> { |in, randrate=5|
        in.asArray[0]     // force mono inputs
        * SinOsc.ar(LFNoise0.kr([randrate, randrate]).exprange(300, 3000)).sum
    },
    \dist, \filter -> { |in, drive=10, amp=0.2| (in.asArray[0] * drive).clip2(0.5) * amp }
);
    // add specs for the controls used (for NodeProxyEditor).
Spec.add(\dens, [0.1, 1000, \exp]);
Spec.add(\dustamp, [0, 1, \amp]);
Spec.add(\dustdec, [0.0001, 0.1, \exp]);
Spec.add(\dustfreq, \freq);

c = ProxyChain(\test, [\dust, \ringmod, \dist, \riseComb5 ]);

s.boot;
)



g = ProxyChainGui.new(c, 12);
c.key.postcs;
c.proxy.key;

    // define buttons more specifically
(
g = c.gui(20,
[
    [ \generators, \label ],      // a label only
    [ \dust, \slotCtl, 0.25 ],         // a control for a slot, and initial volume

    [ 'mono FX', \label ],
    [ \ringmod, \slotCtl, 0.5 ],     // initial mix level
    [ \dist, \slotCtl ],

    [ 'multichan', \label ],
    [ \riseComb5, \slotCtl ],         // off (0) by default.
    [],
        // extras:
        // e.g. open an extra NdefGui with more space for controls
    [\phatEdit, \extra, { c.gui(40) } ],

        // or maybe bigger buttons for play and end
    [\play, \extra, { c.playN } ],
    [\end, \extra, { c.end } ],

]
)
)

*/
