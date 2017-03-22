(
Evt.on(\keydown, \keys, {arg data;

	var args = data[\args];
	var char = args[1].asSymbol;
	var scale = Scale.melodicMinor;
	var degrees = scale.degrees;
	var degree, octave = 4;

	var keymap = ('z': 0, 'x': 1, 'c': 2, 'v': 3, 'b': 4, 'n': 5, 'm': 6,
		'a': 7, 's': 8, 'd': 9,'f': 10,'g': 11, 'h': 12, 'j': 13, 'k': 14, 'l': 15,
		'q': 16,'w': 17,'e': 18,'r': 19, 't': 20, 'y': 21, 'u': 22, 'i': 23, 'o': 24, 'p': 25);

	var name, freq, root;
	var index = keymap[char];

	root = octave * 12;
	name = (root + index.degreeToKey(scale)).midiname;

	[name, name.namecps].postln;

	if (index.isNil.not) {
		(\instrument: \lead1, \degree: index, \octave: octave, scale: scale, \amp: 0.2, \latency: 0.001, \amp: 0.03).play;
	}
})
)


(

{
	var paddingX = 5;
	var paddingY = 5;
	var height = 100;
	var width = 100;
	var top = Window.screenBounds.height - height;
	var left = Window.screenBounds.width - width;

	var win = Window("keyboard", Rect(left, top, width + (paddingX * 3), height + (paddingY * 2)));
	var view = win.view;
	var st;

	view.decorator_(FlowLayout(view.bounds, paddingX@paddingY));
	win.background_(Color.black);
	win.alpha = 0.8;
	win.front;
	win.alwaysOnTop_(true);

	st = StaticText.new(view, 30@30 )
	.stringColor_(Color.white);

	view.keyDownAction = { arg ...args;

		Evt.trigger(\keydown, (args:args) );
		st.string_(args[1]);
	};

}.value;

)

(
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

~kb = {arg func;

	//Window.closeAll;
	{
		var paddingX = 5;
		var paddingY = 5;
		var height = 300;
		var width = 500;
		var top = Window.screenBounds.height - height;
		var left = Window.screenBounds.width - width;

		var win = Window("Wave Shaper", Rect(left, top, width + (paddingX * 3), height + (paddingY * 2)));
		var view = win.view;

		view.decorator_(FlowLayout(view.bounds, paddingX@paddingY));
		win.background_(Color.black);
		win.alpha = 0.8;
		win.front;
		win.alwaysOnTop_(true);
		~keyboard.(win, 65.40639132515;, width, 200, func);
	}.value;
};


)