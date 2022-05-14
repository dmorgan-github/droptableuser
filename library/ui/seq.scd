(
func: {|node, key, spec|

    var width = 20;
    var color = Color.cyan;
    var vals = node.get(key);
    var view = View(bounds:Rect(width: 300, height: 100)).layout_(VLayout().spacing_(1).margins_(1));

    vals = spec.unmap(vals);
    view.layout.add(
        MultiSliderView()
        .valueThumbSize_(0.5)
        .strokeColor_(color)
        .fillColor_(color)
        .isFilled_(true)
        .elasticMode_(1)
        .indexThumbSize_(width)
        .value_(vals)
        .action_({|ctrl|
            var vals = spec.map(ctrl.value);
            node.set(key, vals);
        })
    );
    view.name_("% %".format(node.key, key)).front
}
)