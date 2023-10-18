https://scsynth.org/t/rearrange-visual-elements-by-drag-drop/8132/10?u=droptableuser
(
var win = Window("", Rect(500, 500, 300, 150));

var myCustomFunction = {
	"Views order modified.".postln;
	"".postln;
};

var myButtonFunction = { |index, buttonState|
	order[index].post;
	if(buttonState == 0)
	{ " is OFF".postln; }
	{ " is ON".postln; };
	"".postln;
};

var selectedView = -1;
var previousView = -1;
var margin = 5;
var mouseOffset = 0;
var mousePos = 0;

var dragView = UserView(
).background_(Color.grey);

var order = [\In, \Delay, \Ring, \Reverb, \Out];
var views;

var reArrangeViews = {
	var caseWidth = (dragView.bounds.width -
		(margin * (views.size + 1))) / views.size;

	views.do({ |view, index|

		if(selectedView != index) {
			view.moveTo(
				margin + ((caseWidth + margin) * index),
				margin);

			view.fixedSize_(
				Point(
					caseWidth,
					dragView.bounds.height - (margin * 2)));
		} {
			view.moveTo(
				mousePos - mouseOffset,
				margin);

			view.fixedSize_(
				Point(
					caseWidth,
					dragView.bounds.height - (margin * 2)));
		};
	});
};

dragView.onResize_({ reArrangeViews.value; });

dragView.mouseDownAction_({ |view, x|
	var caseWidth = (view.bounds.width -
		(margin * (views.size + 1)) / views.size);

	selectedView = x.linlin(
		0, view.bounds.width,
		0, views.size).asInteger;
	previousView = selectedView;

	mouseOffset = x%(caseWidth + margin);
	mouseOffset = mouseOffset - margin;
	mousePos = x;
});

dragView.mouseMoveAction_({ |view, x|
	if(selectedView != -1) {
		var hoveredView = x.linlin(
			0, view.bounds.width,
			0, views.size).asInteger;

		if(hoveredView == views.size)
		{ hoveredView = hoveredView - 1 };

		if(hoveredView != selectedView) {
			var viewToMove = views[hoveredView];
			views[hoveredView] = views[selectedView];
			views[selectedView] = viewToMove;
			selectedView = hoveredView;
			view.refresh;
		};

		mousePos = x;

		reArrangeViews.value;
	};
});

dragView.mouseUpAction_({ |view, x|
	if(previousView != selectedView) {
		myCustomFunction.value;
	};
	selectedView = -1;
	reArrangeViews.value;
});

views = Array.fill(5,
	{ |index|
		var button = Button();

		var view = UserView(dragView)
		.layout_(
			VLayout(

				StaticText()
				.string_(order[index])
				.stringColor_(Color.white)
				.align_(\center),

				button
				.states_([[\OFF], [\ON, \, Color.green]])
				.action_({ myButtonFunction.value(index, button.value) })

			).spacing_(5).margins_(5)
		).background_(Color.rand)
		.mouseDownAction_(false)
		.mouseUpAction_(false)
		.mouseMoveAction_(false);

		view
});

win.layout_(
	VLayout(
		dragView
	).margins_(0);
);

win.front;

CmdPeriod.doOnce({ win.close });
)


https://scsynth.org/t/rearrange-visual-elements-by-drag-drop/8132/11?u=droptableuser
(
~size = 100;
~spacing = 10;
~order = [\In, \Delay, \Ring, \Reverb, \Out];
~createView = {|n|
	var e = (
		name: StaticText().string_(n).stringColor_(Color.white).align_(\center),
		but: Button().states_([[\OFF], [\ON, \, Color.green]]).mouseMoveAction_{ true } // prevents propagation to parrent view
		.fixedHeight_(20).value_(2.rand)
	);
	View()
	.layout_(VLayout(e[\name], e[\but])
	.spacing_(5).margins_(5)).background_(Color.rand).fixedSize_((~size - ~spacing)@(~size - ~spacing))
	// for real life usage you would output the event 'e' from the function and have access to both 
	// the parrent view and the subviews: e[\view], e[\name], e[\but]
};
v = ();
~order.do{|n|v.add(n -> ~createView.(n))};
~layout = HLayout(*~order.collect{|n|v[n] }).spacing_(~spacing).margins_(~spacing);
w = View().layout_(~layout).front.alwaysOnTop_(true);

~mouseDrag = {|order, v, size = 100, spacing = 10|
	var leftInit, offset, curKey, oldI, newI;
	order.do{|n|
		v[n].mouseDownAction_{|view, x, y|
			leftInit = v[n].bounds.left;
			offset = x;
			curKey = n;
		};

		v[n].mouseUpAction_{
			v[curKey].moveTo(order.indexOfEqual(curKey) * size + spacing, spacing)
		};

		v[n].mouseMoveAction_{|view, x, y|
			var pos = v[n].bounds.left - leftInit;
			var relativePos = pos%size;

			{ v[n].moveTo((v[n].bounds.left + x - offset).max(0).min(order.size - 1 * size + (2 * spacing)), spacing) }.defer;
			v[n].front;

			newI = (v[n].bounds.left / size).round.asInteger;
			oldI = order.indexOfEqual(n);
			order.move(oldI, newI);
			order.debug(\order);
			order.do {|name, i|
				if (i != newI)
				{ { v[name].moveTo(spacing + (i * size), spacing ) }.defer }
				// you could add logic to only call .moveTo if the calculated new bounds are different fromt the current bounds
			};
		}
	}
};
~mouseDrag.(~order, v, ~size, ~spacing);
)