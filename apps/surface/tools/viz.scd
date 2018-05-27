(
view: {arg objName, envir, util;

	//--variables
	var len = 256;
	var theta = 0;
	var fps = 60;
	var arr = Array.fill(len, 0);
	var cnt = 0;

	//--interface
	var trails = 1;
	var speed = 0;
	var amp = 0.5;
	var version = 0;

	//--window setup
	var view = View().layout_(VLayout());
	var width= len, height= len;
	var win = Window("waveform", Rect(99, 99, width, height), false);
	var uv = UserView(win, Rect(0, 0, width, height));
	var w2= width*0.5;
	var h2= height*0.5;

	var buf = Buffer.alloc(s, len, 1);

	var multiInputsView;

	var node = NodeProxy.audio(s, 2).filter(100, {arg in;
		var buffer = \buf.kr(0);
		RecordBuf.ar(Mix.ar(in), buffer);
		Silence.ar;
	}).set(\buf, buf);

	//--buffer
	//s.sync;

	//--main loop
	uv.drawFunc = {

		//uncomment framerate display in the two lines below to gain some speed
		Pen.color= Color.white;
		Pen.stringAtPoint("" ++ uv.frameRate, Point(10, 10));


		//--
		buf.getn(0, buf.numFrames-1, {|data| arr= data});

		if(cnt==0, {
			Pen.fillColor= Color.black;	//erase first time
			Pen.fillRect(Rect(0, 0, width, height));
		});

		Pen.fillColor= Color.grey(0, trails);
		Pen.fillRect(uv.bounds);	//manually clear
		Pen.strokeColor= Color.green;

		switch(version,
			0, {	//line
				Pen.rotate(theta, w2, h2);
				Pen.translate(0, h2);
				arr.do{|y, x|
					var p= Point(x, y*(height*amp));
					if(x==0, {Pen.moveTo(p)}, {Pen.lineTo(p)});
				};
				Pen.stroke;
			},
			1, {	//warp
				Pen.rotate(theta, w2, h2);
				Pen.translate(w2, h2);
				arr.do{|y, x|
					var p = Point(x*amp, y*amp).rotate(y*2pi);
					if(x == 0, {Pen.moveTo(p)}, {Pen.lineTo(p)});
				};
				Pen.stroke;
			},
			2, {	//flower
				Pen.translate(w2, h2);
				Pen.moveTo(Point(arr[0], 0)*arr[0]);
				arr.do{|y, x|
					var p = Point(y, x)*y;
					var a = x%width/width*2pi+theta;
					Pen.lineTo(p.rotate(a));
				};
				Pen.stroke;
			}
		);
		theta = theta+speed;
		cnt = cnt+1;
	};

        //--window management
	uv.clearOnRefresh = false;	//do not erase - just draw on top of
	win.onClose= {
		node.clear;
		node = nil;
		buf.free;
	};

	//win.asView.front;
	//CmdPeriod.doOnce({if(w.isClosed.not, {w.close})});
	uv.animate= true;

	multiInputsView = util[\multiInputsView].(node, view);

	view.layout.add(multiInputsView);

	view.layout.add(win.asView);

	view.layout.add(HLayout(
		StaticText().string_("trails"),
		Slider().orientation_(\horizontal)
		.maxWidth_(200)
		.action_({arg ctrl;
			trails = ctrl.value.linlin(0.0,1.0,0.0,1.0);
		})
	));

	view.layout.add(HLayout(
		StaticText().string_("speed"),
		Slider().orientation_(\horizontal)
		.maxWidth_(200)
		.action_({arg ctrl;
			speed = ctrl.value.linlin(0,1,0,2pi);
		})
	));

	view.layout.add(HLayout(
		StaticText().string_("amp"),
		Slider().orientation_(\horizontal)
		.maxWidth_(200)
		.action_({arg ctrl;
			amp = ctrl.value.linlin(0.0,1.0,0.0,10.0);
		})
	));

	view.layout.add(HLayout(
		StaticText().string_("version"),
		PopUpMenu().items_([0,1,2]).action_({arg ctrl;
			version = ctrl.value.asInt;
		})
	));

	envir[objName] = node;

	view.onClose_({
		envir[objName].clear(envir[objName].fadeTime);
		{
			"destroy: ".debug(objName);
			envir[objName] = nil;
		}.defer(envir[objName].fadeTime + 1);
	});
}
)
