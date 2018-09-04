~p = ~p ? ProxySpace.new(s, \p);
~p.quant = 1.0;

(
SynthDef(\wn, {

	var sig = WhiteNoise.ar;
	var dur = \d.kr(0.055);
	var env = EnvGen.ar(Env.perc(1e-6, dur), doneAction:2);
	sig = RLPF.ar(sig, Line.kr(\f.kr(1880), 60, dur), \rq.kr(0.2));

	sig = sig * env * \amp.kr(1);
	sig = [sig, DelayC.ar(sig, 0.01, 0.01)];
	Out.ar(\out.kr(0), sig);

}).add;
)

(~p[\wn][0] = Pbind(
	\instrument, \wn,
	\dur, 0.125,
	\f, Pseg(Pwhite(220, 1800), Pwhite(0.1, 1), -4),
	\d, Pwhite(0.055, 0.15),
	\rq, Pseg(Pwhite(0.01, 1), Pwhite(0.1, 1), 4),
	\amp, Pbjorklund(5, 8, inf).collect({arg val; if (val == 0) {0.3}{0.7} }) * 0.5;
))

(~p[\dec][0] = {
	var in = \in.ar([0,0]);
	var fx = Decimator.ar(in, 44100/[7,2], [8, 32]);
	fx;
})

~p[\dec] <<> ~p[\wn];
~p[\dec].play;
~p[\dec].stop(fadeTime:10);

~p[\wn].play;
~p[\wn].stop(fadeTime:10);


/////////////////////////////////////////////
(~p[\dust_swipe] = {

	var n = 20;
	var b = 256;
	var f = s.sampleRate/b;

	var sig = Mix.arFill(50, {arg i;
		i = i+1;
		FSinOsc.ar(f*i, 0, 1/i)
		* LFTri.kr(0.1, i/n*2).exprange(0.05, 3)
		* Env.perc.kr(0, Dust.kr(1+(i/n)));
	});

	(sig!2).tanh * 1;
});

~p[\dust_swipe].play;
~p[\dust_swipe].stop(fadeTime:10);


/////////////////////////////////////////////
(~p[\cicli][0] = {arg speed=0.5;

	var size = 16;
	var nC = Dust.kr(0.05!size);
	var dC = Dust.kr(0.1!size);

	var localIn = LocalIn.kr(nC.size*2);
	var freq,sin;

	nC = nC + CoinGate.kr(TRand.kr(0.1,1,Dust.kr(0.1)),localIn[(0..nC.size-1)]).scramble;
	dC = dC + CoinGate.kr(TRand.kr(0.1,1,Dust.kr(0.1)),localIn[(nC.size..nC.size*2-1)]).scramble;

	freq = Demand.kr(nC,80,Drand(80*((Scale.major.ratios*.1(2**(0..4))).flat),inf));
	sin = SinOsc.ar(freq)*EnvGen.kr(Env.perc(0.1,2),Impulse.kr(TRand.kr(0.2,1.2,dC)*speed));
	LocalOut.kr(nC++dC);
	Mix(Pan2.ar(sin/sin.size*AmpCompA.kr(freq),[-1,1]))*4

});
~p[\cicli].play(fadeTime:4);
~p[\cicli].stop;

/////////////////////////////////////////////
~p[\syn].mold
(~p[\syn][0] = {

	var trig = Dust.kr([0.2, 1]);
	var freq = StandardN.ar(1).range(0,7).round;

	var scale = Scale.locrian.degrees;
	var note = ([72, 84] + Select.kr(freq, scale)).midicps;

	var sig = SinOsc.ar(note);
	var env = Env.perc(releaseTime:SinOsc.kr(0.1).range(0.1,0.5)).kr(gate:trig);
	sig * env * AmpCompA.kr(note) * 0.7;

});
~p[\syn].play(fadeTime:0);
~p[\syn].stop(fadeTime:10);

/////////////////////////////////////////////
(~p[\syn2][0] = {

	var trig = Dust.kr([0.5, 1.5]);
	var freq = LFNoise2.ar(0.5).range(0,7).round;
	var scale = Scale.locrian.degrees;

	var note = ([72, 60] + Select.kr(freq, scale)).midicps;

	var f = Env([2220,2220,1220],[0, 0.1],-4).kr(gate:trig);

	var sig = RLPF.ar(Saw.ar(note), f, 0.15);

	var env = Env.perc(releaseTime:0.2).kr(gate:trig);

	sig * env * AmpCompA.kr(note) * 0.2;

});
~p[\syn2].play(fadeTime:0);
~p[\syn2].stop(fadeTime:10);


/////////////////////////////////////////////
~p[\mix][0] = \mix -> {~p[\syn]};
~p[\mix][1] = \mix -> {~p[\dust_swipe]};
~p[\mix][2] = \mix -> {~p[\syn2]};
~p[\mix].set(\mix0, 1, \mix1, 1, \mix2, 1);
~p[\mix].gui;

/////////////////////////////////////////////
(~p[\send_del][0] = {
	var in = \in.ar([0,0]);
	var fx = DelayC.ar(in, 10, \delay.kr(0.2).lag(0.1));
	fx;
});

~p[\send_del] <<> ~p[\mix];//~p[\mix];
~p[\send_del].play;
~p[\send_del].stop(fadeTime:10);

/////////////////////////////////////////////
(~p[\snd_fb][0] = {
	var in = \in.ar([0,0]);
	var fx = FbC({arg fb; fb * 0.6 + in}, [0.2, 0.4, 0.6, 1.2]);
	Splay.ar(fx)
});
~p[\snd_fb] <<> ~p[\send_del];
~p[\snd_fb].vol = 1;
~p[\snd_fb].play
~p[\snd_fb].stop(fadeTime:10);


~p[\fx].clear;
(~p[\fx] = {
	var in = \in.ar([0,0]);
	var fx = FreqShift.ar(in, 220);
	fx
});

~p[\fx] <<> ~p[\snd_fb];
~p[\fx].play

(~p[\grey] = {
	var in = \in.ar([0,0]);
	var fx = Greyhole.ar(in);
	fx
});

~p[\grey] <<> ~p[\fx];
~p[\grey].vol = 0.5;
~p[\grey].play;

(~p[\g] = {
	var in = \in.ar([0,0]);
	var rate = SinOsc.kr(0.2);
	var fx = GrainIn.ar(2, Impulse.kr(rate), rate * 5, in);
	fx = LPF.ar(fx, SinOsc.kr(0.1).range(880, 2200) );
	fx
});

~p[\g] <<> ~p[\grey];
~p[\g].play;


(~p[\verb] = {
	var in = \in.ar([0, 0]);
	var fx = JPverb.ar(in);
	fx
})

~p[\verb] <<> ~p[\g];
~p[\verb].play

/////////////////////////////////////////////
// ui
(
Slider2D()
.action_({arg ctrl;
	var x = ctrl.x.linlin(0,1,0.001, 10);
	~p[\send_del].set(\delay, x);
})
.alwaysOnTop_(true)
.front
)


App.recordWorkspace("ws14");
s.stopRecording



/////////////////////////////////////////////

~p[\burst].mold;
(~p[\burst][0] = {

	var trig = \trig.tr(0);
	var sig = WhiteNoise.ar * Decay2.kr(trig, 0.001);
	sig!2;
});
~p[\burst].stop;
~p[\burst].set(\trig, 1);

(~p[\burst_fb][0] = {

	var in = \in.ar([0,0]);
	var fx = FbC({arg fb; fb * \fb.kr(0.3) + in}, 10, \delay.kr(1));
	fx
});

~p[\burst_fb] <<> ~p[\burst];
~p[\burst_fb].play;

(~p[\burst_verb][0] = {
	var in = \in.ar([0,0]);
	var fx = JPverb.ar(in, 10, size:5);
	fx;
})

~p[\burst_verb] <<> ~p[\burst_fb];
~p[\burst_verb].play;


(~p[\burst_filt][0] = {
	var in = \in.ar([0,0]);
	var fx = RLPF.ar(in, \freq.kr(440), \rq.kr(1));
	fx;
});

~p[\burst_filt] <<> ~p[\burst_verb];
~p[\burst_filt].play;

(
Slider2D()
.action_({arg ctrl;
	var x = ctrl.x.linexp(0,1,60,4000);
	var y = ctrl.y;
	[x,y].postln;
	~p[\burst_filt].set(\freq, x, \rq, y);
})
.alwaysOnTop_(true).front;
)


(
Slider2D()
.action_({arg ctrl;
	var x = ctrl.x;
	var y = ctrl.y.linlin(0,1,0,10);
	[x,y].postln;
	~p[\burst_fb].set(\fb, x, \delay, y);
})
.alwaysOnTop_(true).front
)


App.recordWorkspace("ws14");
s.stopRecording;



/////////////////////////////////////////////
// ui
(
Fdef(\md_0_0, {arg ctrl, x, y, modifiers, buttonNumber, clickCount;

	var node = ~p[\dust_swipe];
	if (clickCount == 2) {
		if (node.isMonitoring) {
			node.stop;
		}{
			node.play;
		}
	};
});

Fdef(\mm_0_0, {arg ctrl, x, y, modifiers;
	var node = ~p[\dust_swipe];
	var bounds = ctrl.bounds;
	var width = bounds.width;
	var height = bounds.height;
	var vol = y.linlin(0,height,1,0);
	node.vol = vol;
});

)




(
var size = 100;
var rows = 3;
var cols = 3;

var defaultView = {
	UserView()
	.fixedSize_(size)
	.drawFunc_({arg view;
		Pen.fillColor = Color.black.alpha_(rrand(0.1, 0.8));
		Pen.fillRect(Rect(0, 0, size, size));
	});
};

var uv = {arg y, x;

	var key = (y.asSymbol ++ '_' ++ x.asSymbol).asSymbol;
	var myView = Fdef(('v_' ++ key).asSymbol).value(size, size);

	if (myView.isNil.not) {
		myView
	} {
		defaultView.()
		.mouseOverAction_({arg ctrl, x, y;
			Fdef(('mo_' ++ key).asSymbol).value(ctrl, x, y);
			false;
		})
		.mouseUpAction_({arg ctrl, x, y, modifiers;
			Fdef(('mu_' ++ key).asSymbol).value(ctrl, x, y, modifiers);
			false;
		})
		.mouseDownAction_({arg ctrl, x, y, modifiers, buttonNumber, clickCount;
			Fdef(('md_' ++ key).asSymbol).value(ctrl, x, y, modifiers, buttonNumber, clickCount);
			false;
		})
		.mouseEnterAction_({arg ctrl, x, y;
			Fdef(('me_' ++ key).asSymbol).value(ctrl, x, y);
			false;
		})
		.mouseMoveAction_({arg ctrl, x, y, modifiers;
			Fdef(('mm_' ++ key).asSymbol).value(ctrl, x, y, modifiers);
			false;
		});
	};
};

var win = View()
.alwaysOnTop_(true)
.palette_(QPalette.dark)
.acceptsMouseOver_(true)
.mouseOverAction_({arg ctrl, x, y;
	var key = \mo_win;
	Fdef(key).value(ctrl, x,y);
})
.layout_(VLayout().spacing_(0.5).margins_(0.5))
.minWidth_(size * cols)
.minHeight_(size * rows);

rows.do({arg i;
	var layout = HLayout();
	cols.do({arg j;
		layout.add(uv.(i, j));
	});
	win.layout.add(layout);
});

win.front;
)


