// "https://scsynth.org/t/animation-and-envelopeview-solved/294/2"

(
var def = 8;
var nodes = ["this", "is", "so much", "fun"];
Window.closeAll;
a = Window("text-boxes", Rect(200 , 450, 450, 450))
.onClose_{e.stop;};
l = "du gros test en poudre".split($ );
b = EnvelopeView(a, Rect(0, 0, 440, 440))
    .thumbWidth_(60.0)
    .thumbHeight_(15.0)
    .drawLines_(true)
    .drawRects_(true)
    .value_([[0.1, 0.4, 0.5, 0.3], [0.1, 0.2, 0.9, 0.7]])
    .selectionColor_(Color.red)
.grid_(1.asPoint / def)
.step_(1 / def)
.gridOn_(true)
.mouseDownAction_{ arg s, x, y, mod, nb, count;
	if (count == 2){
		ListView(s.parent, Rect(x, y, 100, 130))
		.focus
		.items_(l)
		.keyDownAction_{ arg ss, k, mod, code;
			if (code == 13){
				s.setString(s.index, l[ss.value.postln]);
				ss.close;
			}
		}
	}
}
.mouseUpAction_{ arg s, x, y, mod, nb, count;
	k[s.index] = f.(s.index);
};
nodes.size.do({arg i;
	    b.setString(i, ["this", "is", "so much", "fun"].at(i));
	    b.setFillColor(i,[Color.yellow, Color.white, Color.green].choose);
});
a.front;
z = [[2,1],
	[2,0],
	[0,1,3],
	[2,0,1]];
z.do{ arg val, index;
	b.connect(index.postln, val.postln);
};
d = UserView(a, a.bounds.extent).acceptsMouse_(false);
f = { arg i;
	var e, g;
	b.index = i;
	e = ((b.x * 0.86) * b.bounds.extent.x) + (b.bounds.extent.x * 0.06818);
	g = (((1 - b.y) * 0.96) * b.bounds.extent.y) + (b.bounds.extent.y * 0.01818);
	b.index = -1;
	e@g
};
k = nodes.size.collect{ arg i;
	f.(i);
};
d.clearDrawing
.drawFunc_{
	4.do{ arg i;
		Pen.addRect(Rect.aboutPoint(k[i], 35, 15));
	};
	Pen.stroke;
};
d.drawFunc = d.drawFunc.addFunc(r{
	var i = 0;
	loop{
		var j = 0;
		var next_i = z[i].choose;
		var pt1 = k[i];
		var pt2 = k[next_i];
		var distX = pt2.x - pt1.x;
		var distY = pt2.y - pt1.y;
		var slope = min(distX, distY) / max(distX, distY);
		var start = pt1;
		var distance = sqrt(distX ** 2 + (distY ** 2));
		while {j < 100}{
			Pen.color_(Color.red);
			Pen.fillOval(Rect.aboutPoint(start + ((distX@distY) * (j / 100)), 10, 10));
			0.yield;
			j = j + 1;
		};
		i = next_i;
	}
});
Button(a, 30@30)
.states_([
	["go"], ["stop"]
])
.action_{ arg self;
	switch(self.value,
		1, {
			e = Pfset({
				AppClock.sched(0, {
					d.animate = true;
				})
			},
			Pbind(\type, \rest,
				// \dur, 0.01,
				\finish, Pfunc { arg i;
				}
			)
			).play
		},
		0, {
			d.animate = false;
			e.stop;
		}
	);
}
)