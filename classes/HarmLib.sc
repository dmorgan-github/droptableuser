SmpLib {

	classvar <>bufs;

	*at {arg ... args;
		var buf = this.ensureBuf(*args);
		^buf;
	}

	*ensureBuf {arg ... args;

		var key = (\smpls ++ args.join).asSymbol;
		var path = Archive.global.at(\smpls, *args);
		var buf = bufs[key];
		if (buf.isNil, {
			buf = Buffer.read(Server.default, path);
			bufs.put(key, buf);
		});
		^buf;
	}

	*put {arg ... args;
		Archive.global.put(\smpls, *args);
	}

	*initClass {
		bufs = IdentityDictionary.new;
	}
}


HarmLib {

	// Archive.postTree

	classvar <>bufs;

	*at {arg ... args;

		var buf = this.ensureBuf(*args);
		var amps = this.ensureAmps(*args);
		^buf;
	}

	*ensureAmps {arg ... args;

		var amps = Archive.global.at(\harms, *args);
		if (amps.isNil, {
			// default
			amps = (0..19).collect({arg num; (num+1).reciprocal});
			Archive.global.put(\harms, *(args.asList.add(amps)));
		});
		^amps;
	}

	*ensureBuf {arg ... args;

		var amps = this.ensureAmps(*args);
		var key = (\harms ++ args.join).asSymbol;
		var buf = bufs[key];
		if (buf.isNil, {

			buf = Buffer.alloc(Server.default, 512, 1);
			buf.cheby(amps);
			bufs.put(key, buf);
		});
		^buf;
	}

	*put {arg ... args;
		Archive.global.put(\harms, *args);
	}

	*save {
		Archive.write;
	}

	*edit {arg ... args;

		var amps = this.ensureAmps(*args);
		var buf = this.ensureBuf(*args);
		var name = args.join("/");

		this.editHarms({arg harms;
			buf.cheby(harms);
			Archive.global.put(\harms, *(args.asList.add(harms)) )
		}, amps, name);
	}

	*showEditor {arg parent, vals, width, height, cb;

		var thumbWidth = width/21.3;
		MultiSliderView(parent, width@height)
		.size_(20)
		.value_(vals)
		.drawLines_(false)
		.isFilled_(true)
		.thumbSize_(thumbWidth)
		.action_({arg ctrl;
			cb.value(ctrl.value);
		});
	}

	*editHarms {arg cb, vals, name;

		var paddingX = 5;
		var paddingY = 5;
		var height = 300;
		var width = 500;
		var top = Window.screenBounds.height - height;
		var left = Window.screenBounds.width - width;

		var win = Window("Harm Editor: " ++ name, Rect(left, top, width + (paddingX * 3), height + (paddingY * 2)));
		var view = win.view;

		view.decorator_(FlowLayout(view.bounds, paddingX@paddingY));
		win.background_(Color.black);
		win.alpha = 0.8;
		win.front;
		win.alwaysOnTop_(true);
		this.showEditor(win, vals, width, 200, {arg harms;
			cb.value(harms);
		});
	}

	*initClass {
		bufs = IdentityDictionary.new;
	}
}