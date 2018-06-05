(
view: {arg objName, envir, util;

	var view = View().layout_(HLayout().spacing_(1).margins_(1));
	var nodes = List.new;

	(0..15).select({arg i; i.even}).do({arg val, i;

		var node = NodeProxy.audio(s, 2).play(out:val);
		var myView = View().layout_(VLayout().spacing_(0).margins_(0));
		var specs = (
			vol: [0,4,\lin,0,1]
		);

		var playView = util[\playView].(val + 1, node, view);
		var multiInputsView = util[\multiInputsView].(node, view);s

		myView.layout.add(playView.maxWidth_(150));
		myView.layout.add(multiInputsView.maxWidth_(150));

		view.layout.add(myView);
		nodes.add(node);
	});

	view.onClose_({
		"destroy".debug("multichanout");
		nodes.do({arg node;
			node.clear;
			node.free;
			node = nil;
		});
	})
}
)


