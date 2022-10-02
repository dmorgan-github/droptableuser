(
func: {arg node;

	var frdb = [[100,0,1], [250,0,1], [1000,0,1], [3500,0,1], [6000,0,1]];

	var toControl = {
		frdb.collect({ |item, i|
			[item[0].cpsmidi - 1000.cpsmidi, item[1], item[2].log10]
		}).flat;
	};

	var fromControl = {arg controls;
		if (controls.sum == 0) {
			frdb;
		}{
			controls.clump(3).collect({arg item;
				[(item[0] + 1000.cpsmidi).midicps, item[1], 10**item[2]]
			});
		}
	};

	var sendCurrent = {
		var val = toControl.();
		node.setn(\eq_controls, val);
	};

	//var baseview;
	//var baseViewFunc = Fdef(\baseview);
    var window;

    var uvw, font;
    var bypassButton;
    var selected;
    var tvw, tvwViews;
    var stopOnClose = false;

    var mouseDownAction = { |vw, x, y, mod|
        var bounds;
        var pt;
        var min = 20, max = 22050, range = 24;

        bounds = vw.bounds.moveTo(0, 0);
        pt = (x@y);

        selected =  frdb.detectIndex({ |array|
            ((array[0].explin(min, max, 0, bounds.width))@(array[1].linlin(range.neg, range, bounds.height, 0, \none)))
                .dist(pt) <= 5;
        }) ? -1;

        if (selected != -1) { tvw.focus(selected) };
        vw.refresh;
    };

    var mouseMoveAction = { |vw, x, y, mod|

        var bounds;
        var pt;
        var min = 20, max = 22050, range = 24;

        bounds = vw.bounds.moveTo(0,0);
        pt = (x@y);

        if (selected != -1) {
            case
			{ ModKey(mod).alt } {
                if ( ModKey(mod).shift) {
					frdb[selected] = frdb[selected][[0,1]]
					++ [
						y.linexp(bounds.height, 0, 0.1, 10, \none)
						.nearestInList(
							if ([0,4].includes(selected)){
								[0.6,1,2.5,5,10]
							}{
								[0.1,0.25,0.5,1,2.5,5,10]
							}
                        )
					];
				} {
					frdb[selected] = frdb[selected][[0,1]]
                    ++ [
						y.linexp(bounds.height, 0, 0.1, 10, \none)
						.clip(
							if ([0,4].includes(selected)) {
								0.6
							} {
								0.1
							}, 10)
						.round(0.01)];
				};
                tvwViews[selected][2].value = frdb[selected][2];
			}
			{ ModKey(mod).shift } {
				frdb[selected] = [
					pt.x.linexp(0, bounds.width, min, max)
                    .nearestInList([25,50,75,100,250,500,750,1000,2500,5000,7500,10000]),
					pt.y.linlin(0, bounds.height, range, range.neg, \none)
					.clip2(range).round(6),
					frdb[selected][2]
                ];
				tvwViews[selected][0].value = frdb[selected][0];
				tvwViews[selected][1].value = frdb[selected][1];
			}
			{ true } {
				frdb[selected] = [
					pt.x.linexp(0, bounds.width, min, max).clip(20,20000).round(1),
					pt.y.linlin(0, bounds.height, range, range.neg, \none).clip2(range)
					.round(0.25),
					frdb[selected][2]
                ];
				tvwViews[selected][0].value = frdb[selected][0];
				tvwViews[selected][1].value = frdb[selected][1];
			};
			sendCurrent.();
			vw.refresh;
        };
    };

    var drawFunc = { |vw|

        var freqs, svals, values, bounds, zeroline;
        var freq = 1200, rq = 0.5, db = 12;
        var min = 20, max = 22050, range = 24;
        var vlines = [100,1000,10000];
        var dimvlines = [25,50,75, 250,500,750, 2500,5000,7500];
        var hlines = [-18,-12,-6,6,12,18];
        var pt, strOffset = 11;
        var sr = Server.default.sampleRate;

        bounds = vw.bounds.moveTo(0,0);
        #freq,db,rq = frdb[0] ? [freq, db, rq];

        freqs = ({|i| i } ! (bounds.width+1));
        freqs = freqs.linexp(0, bounds.width, min, max);

        values = [
            BLowShelf.magResponse(freqs, sr, frdb[0][0], frdb[0][2], frdb[0][1]),
            BPeakEQ.magResponse(freqs, sr, frdb[1][0], frdb[1][2], frdb[1][1]),
            BPeakEQ.magResponse(freqs, sr, frdb[2][0], frdb[2][2], frdb[2][1]),
            BPeakEQ.magResponse(freqs, sr, frdb[3][0], frdb[3][2], frdb[3][1]),
            BHiShelf.magResponse(freqs, sr, frdb[4][0], frdb[4][2], frdb[4][1])
        ].ampdb.max(-200).min(200);

        zeroline = 0.linlin(range.neg,range, bounds.height, 0, \none);
        svals = values.sum.linlin(range.neg,range, bounds.height, 0, \none);
        values = values.linlin(range.neg,range, bounds.height, 0, \none);

        vlines = vlines.explin(min, max, 0, bounds.width);
        dimvlines = dimvlines.explin(min, max, 0, bounds.width);

        pt = frdb.collect { |array|
            (array[0].explin(min, max, 0, bounds.width))
            @
            (array[1].linlin(range.neg,range,bounds.height,0,\none));
        };

        Pen.color_(Color.white.alpha_(0.25));
        Pen.roundedRect(bounds, [6,6,0,0]).fill;

        Pen.color = Color.gray(0.2).alpha_(0.5);
        Pen.roundedRect(bounds.insetBy(0,0), [6,6,0,0]).clip;

        Pen.color = Color.gray(0.2).alpha_(0.125);

        hlines.do({ |hline,i|
            hline = hline.linlin(range.neg,range, bounds.height, 0, \none);
            Pen.line(0@hline, bounds.width@hline)
            });
        dimvlines.do({ |vline,i|
            Pen.line(vline@0, vline@bounds.height);
            });
        Pen.stroke;

        Pen.color = Color.gray(0.2).alpha_(0.5);
        vlines.do({ |vline,i|
            Pen.line(vline@0, vline@bounds.height);
		});
        Pen.line(0@zeroline, bounds.width@zeroline).stroke;
        Pen.font = font;

        Pen.color = Color.gray(0.2).alpha_(0.5);
        hlines.do({ |hline|
            Pen.stringAtPoint(hline.asString ++ "dB",
                3@(hline.linlin(range.neg,range, bounds.height, 0, \none)
                    - strOffset));
            });
        vlines.do({ |vline,i|
            Pen.stringAtPoint(["100Hz", "1KHz", "10KHz"][i],
                (vline+2)@(bounds.height - (strOffset + 1)));
            });

        values.do({ |svals,i|
            var color;
            color = Color.hsv(
                i.linlin(0,values.size, 0, 1),
                0.75, 0.7).alpha_(if (selected == i) { 0.75 } { 0.25 }
			);

            Pen.color = color;
            Pen.moveTo(0@(svals[0]));
            svals[1..].do({ |val, i|
                Pen.lineTo((i+1)@val);
			});
            Pen.lineTo(bounds.width@(bounds.height/2));
            Pen.lineTo(0@(bounds.height/2));
            Pen.lineTo(0@(svals[0]));
            Pen.fill;

            Pen.addArc(pt[i], 5, 0, 2pi);
            Pen.color = color.alpha_(1);
            Pen.stroke;
		});

        Pen.color = Color.blue(0.5);
        Pen.moveTo(0@(svals[0]));

        svals[1..].do({ |val, i|
            Pen.lineTo((i + 1)@val);
		});
        Pen.stroke;

        Pen.extrudedRect(bounds, [6,6,0,0], 1, inverse: true);
    };

    var init = {

		frdb = fromControl.(node.get(\eq_controls));

		window = Window.new("eq", Rect(299/1.5, 130/1.5, 505/1.5, 320/1.5), true);
        window.view.decorator = FlowLayout(window.view.bounds, 10@10, 4@0);

        uvw = UserView(window,
            window
			.view.bounds.insetBy(10,10)
			.height_(window.view.bounds.height - 80)
		).resize_(5);

        font = Font(Font.defaultSansFace, 10);
        uvw.focusColor = Color.clear;
        selected = -1;

        tvw = TabbedView(window,
            window.view.bounds.insetBy(10,10).height_(35).top_(200),
            ["low shelf", "peak 1", "peak 2", "peak 3", "high shelf"],
            { |i|
				Color.hsv(i.linlin(0,5,0,1), 0.75, 0.5).alpha_(0.35);
			}!5
		)
		.font_(font)
		.resize_(8)
		.tabPosition_(\bottom);

        tvw.focusActions = { |i| { selected = i; uvw.refresh;  }; }!5;
        tvwViews = [];
        window.view.decorator.shift(0,8);

        tvw.views.do({ |view, i|

            var vw_array = [];
            view.decorator = FlowLayout(view.bounds.moveTo(0,0));
            StaticText(view, 35@14).font_(font).align_(\right).string_("freq:");
            vw_array = vw_array.add(
                RoundNumberBox(view, 40@14).font_(font).value_(frdb[i][0])
				.clipLo_(20).clipHi_(22000)
				.action_({ |vw|
					frdb[i][0] = vw.value;
					sendCurrent.();
					uvw.refresh;
				})
			);

            StaticText(view, 25@14).font_(font).align_(\right).string_("db:");
            vw_array = vw_array.add(
                RoundNumberBox(view, 40@14).font_(font).value_(frdb[i][1])
				.clipLo_(-36).clipHi_(36)
				.action_({ |vw|
					frdb[i][1] = vw.value;
					sendCurrent.();
					uvw.refresh;
				})
			);

            StaticText(view, 25@14)
			.font_(font)
			.align_(\right)
			.string_((0: "rs:", 4:"rs:")[i] ? "rq" );

            vw_array = vw_array.add(
                RoundNumberBox(view, 40@14)
				.font_(font)
				.value_(frdb[i][2])
				.step_(0.1).clipLo_(if ([0,4].includes(i)) { 0.6 } {0.01}).clipHi_(10)
				.action_({ |vw|
					frdb[i][2] = vw.value;
					sendCurrent.();
					uvw.refresh;
				})
			);

            tvwViews = tvwViews.add(vw_array);
        });

        uvw.mouseDownAction_ { |vw, x, y, mod| mouseDownAction.(vw, x, y, mod); };
        uvw.mouseMoveAction_ { |vw, x, y, mod| mouseMoveAction.(vw, x, y, mod); };
        uvw.drawFunc = { |vw| drawFunc.(vw); };

		/*
        bypassButton = RoundButton.new(window, 17@17)
		.extrude_(true).border_(1)
		.states_([
			['power', Color.gray(0.2), Color.white(0.75).alpha_(0.25)],
			['power', Color.red(0.8), Color.white(0.75).alpha_(0.25)]])
		.value_(0)
		.action_({ |bt|
			switch(bt.value,
				1, { \bypasson.postln; },
				0, { \bypassoff.postln }
			);
		})
		.resize_(7);
		*/

        window.refresh;
        window = window.asView.fixedSize_(Size(337, 185)).background_(Color.clear);
        window;
    };

	init.();
}
)