(
view: {arg objName, envir, util;

	var blackman = {arg size = 2048;

		var sig, alpha, a0, a1, a2;
		alpha = 0.16;
		sig = Signal.newClear(size);

		a0 = 0.5*(1-alpha);
		a1 = 0.5;
		a2 = alpha*0.5;

		sig.waveFill( { arg x, i; a0 - (a1*cos( (2*pi*x)/(size-1) ) ) + (a2*cos( (4*pi*x)/(size-1) ) )}, 0, size );
		sig;
	};

	var windowSize = 1024;
	var envbuf = Buffer.sendCollection(s, Signal.hanningWindow(windowSize), 1);

	var envbufs = {
		var bufs = ();
		bufs[\hann] = envbuf;
		bufs[\hamming] = envbuf.setn(0, Signal.hammingWindow(windowSize));
		bufs[\welch] = envbuf.setn(0, Signal.welchWindow(windowSize));
		bufs[\rectangle] = envbuf.setn(0, Signal.rectWindow(windowSize));
		bufs[\perc] = envbuf.setn(0, Env.perc(windowSize));
		bufs[\triangle] = envbuf.setn(0, Env.triangle(windowSize));
		bufs[\blackman] = envbuf.setn(0, blackman.(windowSize));
		bufs;
	}.value;

	var node = NodeProxy.audio(s, 2).source_({arg in;

		var buf = \buf.kr(0);

		var trig = \trig.tr;
		var pos = \pos.kr(0);
		var graindur = \graindur.kr(0.5);
		var rate = \rate.kr(1);
		var envbuf = \envbuf.kr(-1).lag(0.01);
		var pan = \pan.kr(0);
		var grainamp = \grainamp.kr(1);
		var loop = \loop.kr(0);

		var amp = Dwhite(grainamp.clip(0,1), 1, inf);
		var panValue = Dwhite(pan.neg, pan, inf);
		var reverse = \reverse.kr(0);
		var rev = Dwrand([-1,1], [reverse,1-reverse], inf);

		var sig = GrainBufJ.ar(2,
			trig,
			dur: graindur,
			sndbuf: buf,
			rate: rate * rev,
			pos: pos,
			loop: loop,
			interp: 4,
			grainAmp: amp,
			pan: panValue,
			envbufnum: envbuf
		);

		Splay.ar(sig);
	}).set(\envbuf, envbufs[\hann].bufnum);

	var specs = (
		buf: \set,
		trig: \set,
		pos: [0,1,\lin,0,0],
		graindur: [0,2,\lin,0,0.5],
		rate: [0,4,\lin,0,1],
		pan: [-1,1,\lin,0,0],
		grainamp: [0,1,\lin,0,1],
		loop: [0,1,\lin,1,0],
		reverse: [0,1,\lin,0,0],
		stereo:[-1,1,\lin,0,0]
	);

	var envkeys = envbufs.keys.asArray;
	var view = View().layout_(VLayout().margins_(2).spacing_(2));
	var playView = util[\playView].(objName, node, view);
	var specsView = util[\specsView].(objName, specs, node, envir, view);
	var buttonsView = View().layout_(HLayout(
		Button().states_([["o"], ["||"]]).action_({arg ctrl;
			if (ctrl.value == 1) {
				node.set(\rec_trig, 1, \rec, 1, \plevel, 0);
			} {
				node.set(\rec_trig, 0, \rec, 0, \plevel, 0);
			}
		}),
		Button().states_([["^"], ["||"]]).action_({arg ctrl;
			if (ctrl.value == 1) {
				node.set(\rec_trig, 1, \rec, 1, \plevel, 1);
			} {
				node.set(\rec_trig, 0, \rec, 0);
			}
		}),
	).margins_(2).spacing_(2));

	view.layout.add(PopUpMenu().items_(envkeys).action_({arg ctrl;
		node.set(\envbuf, envbufs[ctrl.item.asSymbol].bufnum)
	}).value_(envkeys.indexOf(\hann)));
	view.layout.add(playView);
	view.layout.add(specsView);

	envir[objName] = node;

	view.onClose_({
		envir[objName].clear(envir[objName].fadeTime);
		{
			"destroy: ".debug(objName);
			envbufs.do({arg k,v;
				v.free;
			});
			envir[objName] = nil;
		}.defer(envir[objName].fadeTime + 1);
	});

	view;
};
)
