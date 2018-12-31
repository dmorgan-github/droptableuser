~noise_buf  = Buffer.read(s, "/Users/david/projects/droptableuser/workspaces/ws1/cdosys.dll.wav");
~buf = Buffer.read(s, "/Users/david/projects/droptableuser/workspaces/ws1/55208__noisecollector__kidstory.wav");

~p[\noise].ident

~p[\noise].mold;
~p[\noise].clear;
~p[\noise].play(vol:1);
~p[\noise].stop;
~p[\noise].fadeTime = 0;
(
~p[\noise][0] = {

	var gate = \gate.kr(0);
	var trig_in = \trig.tr;
	var seq = ~p[\seq].kr;//Impulse.kr(1);
	var ptrn = \ptrn.kr(Array.fill(16, 0));
	var pattern = Demand.kr(seq, 0, Dseq(ptrn, inf));
	var changed = seq * (pattern > 0);
	var pos = Latch.kr(pattern, changed);
	var pos_in = \startPos.kr(0).lag(0.001);

	var buf = \buf.kr(0);
	var trig = SelectX.kr(gate, [seq * (pattern > 0), trig_in]);
	var startPos = SelectX.kr(gate, [pos, pos_in]);
	var rate = SelectX.kr(gate, [1, \rate.kr(1)]);
	var sig = PlayBuf.ar(1, buf, rate:rate, trigger:trig, startPos: startPos, loop: 1);
	var id = \replyid.kr(0);

	SendTrig.kr(trig, id, startPos);
	sig = sig * \amp.kr(-6.dbamp);
	Splay.ar(sig);
};
)
~p[\noise].set(\buf, ~buf);


(~p[\seq][0] = {
	var trig = \trig.tr;
	trig;
})
(~p[\seq][2] = \set -> Pbind(
	\trig, 1,
	\dur, 0.25
))

(
Pdef(\test, {
	var node = topEnvironment[\p][\noise];
	var id = node.nodeID;
	Pseq([
		Pbind(
			\type, \set,
			\id, Pfunc({id}),
			\args, #[\startPos, \gate, \trig],
			\gate, 1,
			\trig, 1,
			\startPos, Pseg([1499400, 1578316],[10],-4),
			\dur, 1/96),
		Pbind(
			\type, \set,
			\id, Pfunc({id}),
			\args, #[\gate],
			\gate, Pn(0, 1)
		)
	])
})
)

(
Pdef(\test2, {
	var node = topEnvironment[\p][\noise];
	var id = node.nodeID;
	Pseq([
		Pbind(
			\type, \set,
			\id, Pfunc({id}),
			\args, #[\startPos, \gate, \trig],
			\gate, 1,
			\trig, 1,
			\startPos, Pseq(topEnvironment[\pos].asArray, 1),
			\dur, Pseq(topEnvironment[\durs].asArray, 1)
		),
		Pbind(
			\type, \set,
			\id, Pfunc({id}),
			\args, #[\gate],
			\gate, Pn(0, 1)
		)
	])
})
)

Pdef(\test2).play





(
view: {
	var node = ~p[\noise];
	var pauseCursor = false;
	var oscFunc;
	var buf = ~buf;
	var win = View().layout_(VLayout()).minHeight_(300).minWidth_(800);
	var sfv;
	//var slider = Slider().action_({arg ctrl;
	//	var pos = ctrl.value.linlin(0,1,0,buf.numFrames);
	//	sfv.timeCursorPosition = pos.postln;
	//	node.set(\startPos, pos, \trig, 1);
	//}).orientation_(\horizontal);
	var buttons = List.new;
	var positions = Array.fill(16, 0);
	var buttonView = View().layout_(HLayout(
		*(0..15).collect({arg i;
			var button = Button()
			.states_([[i, Color.white, Color.gray], [i, Color.black, Color.white]])
			.maxWidth_(30)
			.action_({arg ctrl;
				buttons.do({arg button, j;
					if (j != i) {
						button.value_(0)
					};
				});
				if (positions[i].isNil.not) {
					sfv.timeCursorPosition = positions[i];
				};
			})
			.mouseUpAction_({arg ctrl, x, y, modifiers;
				if (modifiers.bitAnd(524288) == 524288) {
					positions[i] = sfv.timeCursorPosition;
				};
				node.set(\ptrn, positions.asArray.postln);
			});
			buttons.add(button);
			button;
		});
	));

	var controlsView = {

		var myView = View().layout_(HLayout().margins_(2).spacing_(2));
		var dragSink, button;

		button = Button()
		.fixedSize_(8)
		.states_([ ["x"] ])
		.font_(Font().size_(9))
		.action_({
			dragSink.string = "";
			button.enabled = false;
		})
		.enabled_(false);

		dragSink = DragSink()
		.string_("<-  ")
		.background_(Color.clear)
		.canReceiveDragHandler_({
			var obj = View.currentDrag;
			var bufnum = obj[\bufnum];
			(bufnum.isNil.not);
		})
		.receiveDragHandler_({arg v;

			var obj = View.currentDrag.value;
			var bufnum = obj[\bufnum];
			var name = obj[\name];

			if (bufnum.isNil.not) {

				var buf = s.cachedBufferAt(bufnum);
				buf.loadToFloatArray(action:{arg a;
					{
						sfv.setData(a, channels: buf.numChannels);
						sfv.setSelection (0, [0, buf.numFrames]);
						node.set(\buf, buf.bufnum);
						sfv.mouseUpAction.value(sfv);
					}.defer
				});

				v.string = name;
				button.enabled = true;
			} {
				var msg = "bufnum % doesn't exist in environment".format(bufnum);
				NotificationCenter.notify(view, \status, msg);
				button.enabled = false;
			}
		})
		.maxHeight_(35)
		.minWidth_(35);

		myView.layout.add(dragSink, button);
		myView;
	};

	sfv = SoundFileView()
	.background_(Color.gray(0.3))
	.timeCursorOn_(true)
	.gridOn_(true)
	.resize_(5)
	.gridResolution_(0.0)
	.mouseUpAction = ({arg view;
		node.set(\gate, 0);
	});

	sfv.mouseMoveAction = {arg ctrl, x, y;
		var width = ctrl.bounds.width;
		var height = ctrl.bounds.height;
		var pos = x.linlin(0, width, 0, buf.numFrames);
		var rate = y.linlin(0, height, 24, -24).midiratio;
		sfv.timeCursorPosition = pos;
		node.set(\startPos, pos, \gate, 1, \trig, 1, \rate, rate);
	};
	sfv.setSelectionColor(0, Color.blue(alpha:0.5));
	buf.loadToFloatArray(action:{arg a;
		{
			sfv.setData(a, channels: buf.numChannels);
			sfv.setSelection (0, [0, buf.numFrames]);
			sfv.mouseUpAction.value(sfv);
		}.defer
	});

	oscFunc = OSCFunc({arg msg, time;
		var pos = msg[3];
		{
			if (pauseCursor.not) {
				sfv.timeCursorPosition = pos;
				positions.do({arg val, i;
					if (val == pos) {
						buttons[i].value_(1);
					} {
						buttons[i].value_(0);
					}
				});
			}
		}.defer
	},'/tr', s.addr);

	win.layout.add(buttonView);
	win.layout.add(sfv);
	win.keyDownAction_({arg ctrl, char, modifiers, unicode, keycode, key;
		if (key == 16777248) {
			pauseCursor = true;
		}
	});
	win.keyUpAction_({arg ctrl, char, modifiers, unicode, keycode, key;
		if (key == 16777248) {
			pauseCursor = false;
		}
	});
	win.onClose_({
		oscFunc.free;
	});
}
)



(
~durs = List.new;
~bobo.do({arg val, i;
	if (~bobo[i+1].isNil.not) {
		~durs.add(~bobo[i+1].sec - ~bobo[i].sec)
	}
});
~pos = ~bobo.collect({arg val;
	val.pos
});
)
