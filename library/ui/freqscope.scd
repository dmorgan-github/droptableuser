(
func: {|node|

    var view = View(bounds:Rect(0, 0, 511/2, 300/2)).layout_(VLayout().margins_(0).spacing_(0));
    var scope = FreqScopeView(view, view.bounds);
    node = if (node.respondsTo(\node)) {node.node}{node};

    scope.inBus = node.bus.index;
    scope.freqMode = 1;
    scope.active = true;
    scope.fill = true;
    scope.waveColors_([Color.rand.alpha_(1)]);
    view.onClose_({ scope.kill }); // YOU MUST HAVE THIS
    view;
}
)

