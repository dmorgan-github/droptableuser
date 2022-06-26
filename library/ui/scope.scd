(
func: {|node|

    var view = View().layout_(VLayout().margins_(0).spacing_(0));
    var scope = Stethoscope.new(s, view:view).style_(2)
    .index_(node.bus.index)
    .numChannels_(2).yZoom_(10).xZoom_(5);
    4.do({
        view.children[0].children[0].remove
    });
    view.children[0].children[0].waveColors_([Color.rand, Color.rand]);
    view.children[0].children[2].remove;
    view.children[0].children[1].remove;
    view.children[0].children[0].background = Color.black;//Color.new255(77, 77, 77);
    view.onClose = { scope.free };
    view;
}
)