(
Require(App.librarydir ++ "ui/common.scd");
Fdef(\fx, {|node, nodeviewfunc|

	var view;
	var key = node.key;
	var playview = Fdef(\playview);
	var nodeview = nodeviewfunc.(node);

	var baseview;
	var baseViewFunc = Fdef(\baseview);

	playview = playview.(node);//..addDependant(viewListener);

	view = View().layout_(VLayout(
		playview,
		nodeview
	).spacing_(0).margins_(0));

	baseview = baseViewFunc.(view, key);
	baseview;
})
)