(

SynthDef.new(\piano, {arg freq = 440, amp = 0.5;
	var osc = MdaPiano.ar(freq);
	var env = EnvGen.kr(Env.linen, doneAction:2);
	Out.ar(0, osc * env * amp);
}).add;

~harms = {arg parent, vals, width, height, cb;

	var thumbWidth = width/21.3;
	vals = vals ? (0..19).collect({arg num; (num+1).reciprocal});

	"Here".postln;

	MultiSliderView(parent, width@height)
	.size_(20)
	.value_(vals)
	.drawLines_(false)
	.isFilled_(true)
	.thumbSize_(thumbWidth)
	.action_({arg ctrl;
		cb.value(ctrl.value);
	});
};

~env = {arg parent, width, height, env, min, max, cb;

	var ctrlWidth = 28;
	var envCtrl;
	var cv = CompositeView(parent, (ctrlWidth)@height);
	cv.decorator_(FlowLayout(cv.bounds));

	StaticText(cv, (ctrlWidth-4)@15)
	.stringColor_(Color.white)
	.string_(max);

	cv.decorator.nextLine;
	NumberBox(cv, (ctrlWidth-4)@ctrlWidth)
	.action_({arg ctrl;

		var level = ctrl.value;
		var numPoints = envCtrl.value[0].size;
		var levels = level.linlin(min, max, 0, 1)!numPoints;
		var result = [
			(0..numPoints - 1 ).normalize,
			levels
		];
		envCtrl.valueAction_(result);
	});
	cv.decorator.nextLine;

	StaticText(cv, (ctrlWidth-4)@15)
	.stringColor_(Color.white)
	.string_(min);

	ctrlWidth = width - ctrlWidth;
	envCtrl = EnvelopeView(parent, ctrlWidth@height)
	.drawLines_(true)
	.step_(0.05)
	.setEnv(env)
	.gridOn_(true)
	.action_({arg ctrl;
		var times = ctrl.value[0].differentiate.drop(1);
		var levels = ctrl.value[1].linlin(0, 1, min, max);
		env.times = times;
		env.levels = levels;
		if (cb.notNil, {
			cb.value(env);
		});
	});
};

~keyboard = {arg parent, rootNote, width, height, cb;

	var cv;
	var letterWidth;
	var defaultScaleRatios = [1, 1.1892071150009, 1.3348398541699, 1.4142135623731, 1.4983070768767, 1.781797436280 ];
	var scaleRatios = defaultScaleRatios;
	var fontFamily = "Courier New";
	var fontSize = 12;
	var freqText;

	var cache = Dictionary.new;
	var keyMap = List.new();

	keyMap.add("r" -> 0);
	keyMap.add("e" -> 1);
	keyMap.add("w" -> 2);
	keyMap.add("q" -> 3);
	keyMap.add("a" -> 4);
	keyMap.add("s" -> 5);

	keyMap.add("d" -> 10);
	keyMap.add("f" -> 11);
	keyMap.add("g" -> 12);
	keyMap.add("h" -> 13);
	keyMap.add("j" -> 14);
	keyMap.add("k" -> 15);

	keyMap.add("l" -> 20);
	keyMap.add(";" -> 21);
	keyMap.add("'" -> 22);
	keyMap.add("]" -> 23);
	keyMap.add("[" -> 24);
	keyMap.add("p" -> 25);

	keyMap.add("o" -> 30);

	cv = CompositeView(parent, width@height);
	cv.decorator_(FlowLayout(cv.bounds));

	letterWidth = cv.bounds.width / 23;
	keyMap.do({arg item;
		var st = StaticText.new(cv, letterWidth@30 )
		.string_(item.key)
		.stringColor_(Color.white)
		.font_(Font(fontFamily, fontSize));
		cache.add(item.key -> st );
	});

	parent.view.mouseUpAction = {arg self, obj;
		parent.view.focus;
	};

	parent.view.keyDownAction = {arg self, obj;

		var freq = 0;
		var val = nil;
		var num = 0;
		keyMap.do({arg item, i;
			if (item.key == obj.asString, {
				val = item.value;
				cache.at(item.key).stringColor_(Color.green);
				num = i;
			});
		});

		if (val.isNil.not, {
			var index = val % 10;
			var octave = (val/10).floor;
			var ratio = scaleRatios[index];
			if (ratio.isNil.not, {
				freq = (rootNote * ratio) * (2 ** octave);
			});
		});
		if (freq > 0, {
			cb.value(freq, num);
			freq.postln;
		});
	};

	parent.view.keyUpAction = {arg self, obj;
		var freq = 0;
		var val = nil;
		keyMap.do({arg item;
			if (item.key == obj.asString, {
				val = item.value;
				cache.at(item.key).stringColor_(Color.white);
			});
		});

	};
};

~slider = {arg parent, val, width, height, cb;

	var ctrlWidth = 35;
	var numBoxCtrl;

	var sliderCtrl = Slider.new(parent, (width - ctrlWidth)@height)
	.value_(val)
	.step_(0.01)
	.action_({arg ctrl;
		cb.value(ctrl.value);
		numBoxCtrl.value_(ctrl.value);
	});

	numBoxCtrl = NumberBox(parent, ctrlWidth@height)
	.value_(val)
	.action_({arg ctrl;
		sliderCtrl.valueAction_(ctrl.value);
	});
};

/*
~drum = {arg parent, width, height, cb;

	var cv;
	var letterWidth;
	var fontFamily = "Courier New";
	var fontSize = 12;

	var cache = Dictionary.new;
	var keyMap = List.new();

	keyMap.add("w" -> 0);
	keyMap.add("e" -> 1);
	keyMap.add("r" -> 2);
	keyMap.add("t" -> 3);
	keyMap.add("y" -> 4);
	keyMap.add("u" -> 5);
	keyMap.add("i" -> 6);
	keyMap.add("o" -> 7);
	keyMap.add("s" -> 8);
	keyMap.add("d" -> 9);
	keyMap.add("f" -> 10);
	keyMap.add("g" -> 11);
	keyMap.add("h" -> 12);
	keyMap.add("j" -> 13);
	keyMap.add("k" -> 14);
	keyMap.add("l" -> 15);

	cv = CompositeView(parent, width@height);
	cv.decorator_(FlowLayout(cv.bounds));

	letterWidth = cv.bounds.width / 23;
	keyMap.do({arg item, i;
		var st;
		st = StaticText.new(cv, letterWidth@30 )
		.string_(item.key)
		.stringColor_(Color.white)
		.font_(Font(fontFamily, fontSize));
		cache.add(item.key -> st );
	});

	parent.view.mouseUpAction = {arg self, obj;
		parent.view.focus;
	};

	parent.view.keyDownAction = {arg self, obj;

		var val = nil;
		keyMap.do({arg item;
			if (item.key == obj.asString, {
				val = item.value;
				cache.at(item.key).stringColor_(Color.green);
			});
		});

		if (val.isNil.not, {
			cb.value(val);
		});
	};

	parent.view.keyUpAction = {arg self, obj;
		var freq = 0;
		var val = nil;
		keyMap.do({arg item;
			if (item.key == obj.asString, {
				val = item.value;
				cache.at(item.key).stringColor_(Color.white);
			});
		});
	};

};
*/


)