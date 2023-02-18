(
func: {|len=16, key|

    var buf, node;
    node = D.node;

    if (key.notNil) {
        node.key = key;
    } {
        key = node.key;
    };

    buf = B.allocSec(key, len);
    node.set(\buf, buf);
    node.fx(100, 'delay/bufdelay');
    node.set(\rec, 1, \fb, 1);
    node;
},
doc: "
~rec = Module('device/rec').()
~rec[0] = ~harm.node
~rec.set(\\rec, 1, \\fb, 1)
~rec.get(\\buf)
"
)
