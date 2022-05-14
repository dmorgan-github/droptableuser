(
func: {|node|

    var key = 'hits';
    var width = 19;
    var color = Color.cyan;
    var hits = node.get(key);
    var view = View(bounds:Rect(width: 300, height: 25))
    .layout_(
        HLayout(

            *hits.collect({|hit, i|
                Button()
                .states_([ [nil, nil, nil], [nil, nil, color] ])
                .fixedWidth_(width)
                .value_(hit)
                .action_({|ctrl|
                    hits[i] = ctrl.value;
                    node.set(key, hits);
                })
            })

        ).spacing_(0).margins_(0)
    );

    view.name_("% %".format(node.key, key)).front
}
)