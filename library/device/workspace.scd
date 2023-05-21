(
func: {
    var view, grid;
    var env = topEnvironment;

    view = View().layout_(VLayout());
    grid = GridLayout();

    env.getPairs.pairsDo({|k, v, i|
        if (v.isKindOf(InstrProxy)) {
            var row = 0;
            grid.add( StaticText().string_(k), row, i);
            v.objects.do({|obj, j|
                if (obj.respondsTo(\key) and: { obj.key == \pat} ) {
                    var state = v.streamstate[j] ?? 0;
                    grid.add(
                        Button()
                        .states_([ ["", nil, Color.cyan], [ "", nil, Color.white] ])
                        .action_({|ctrl|
                            if (ctrl.value == 1) {
                                v.par(j)
                            }{
                                v.suspend(j)
                            }
                        })
                        .value_(state),
                        (row = row+1),
                        i
                    );
                }
            })
        };
    });
    view.layout.add(grid);
    view.front
}
)