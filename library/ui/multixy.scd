(
func: {|instr, onload, onaction, title|

    var envview, view;
    view = View().layout_(VLayout().spacing_(0).margins_(0));
    envview = EnvelopeView()
    .thumbWidth_(60.0)
    .thumbHeight_(15.0)
    .drawLines_(false)
    .drawRects_(true)
    .gridOn_(true)
    .grid_(Point(0.5, 0))
    //.grid_(0)
    .gridColor_(Color.cyan.alpha_(0.5))
    .selectionColor_(Color.cyan)
    .background_(Color.clear)
    //.value_( [[0.1, 0.4, 0.5, 0.3], [0.1, 0.2, 0.9, 0.7]])
    .action_({|ctrl|
        var val = ctrl.value;
        var index = ctrl.index;
        var xvals = val[0];
        var yvals = val[1];
        var x = xvals[index];
        var y = yvals[index];
        onaction.(ctrl, index, x, y);
    });

    onload.(envview);

    instr.do({|node, i|
        envview.setFillColor(i, if (node.isMonitoring and: {node.isPlaying} ) { node.color.alpha_(0.3) } { Color.grey.alpha_(0.5) } );
        envview.setString(i, node.key);
    });

    view.layout.add(envview);
    view
    .name_(title)
    .minHeight_(200)
    .minWidth_(300)
    .front
},
doc: "
~mod = Module('ui/multixy')
~nodes = [~g, ~h, ~i, ~j]
~mod.(
    ~nodes, 
    {|ctrl|
        // set initial values
    }, 
    {|ctrl, index, x, y|
        x = x.linlin(0, 1, -1, 1);
        y = y.linlin(0, 1, 0, 0.2);
        ~nodes[index].set(\\center, x, \\amp, y);
    }, 
    \"amp/pan\"
)
"
)


