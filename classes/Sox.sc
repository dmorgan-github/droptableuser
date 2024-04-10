// note: good reference: https://github.com/rabitt/pysox/blob/master/sox/transform.py
// also: https://gist.github.com/ideoforms/d64143e2bad16b18de6e97b91de494fd
Sox {

    var <list;

    classvar <>path;

    *new {
        ^super.new.prInit;
    }

    *stats {|src|
        var str;
        var srcpn = PathName(src);
        if (srcpn.parentPath == "") {
            var dir = PathName(thisProcess.nowExecutingPath).pathOnly;
            src = "%/%".format(dir, src);
        };

        str = "%sox \"%\" -n stats 2>&1".format(path, src.standardizePath);
        str.postln.unixCmdGetStdOut.postln;
        ^nil;
    }

    speed {|val|
        list.addAll(["speed", val])
    }

    remix {|left=1, right=2|
        var val = List();
        val.add("remix");
        if (left.notNil) {
            val.add(left)
        };
        if (right.notNil) {
            val.add(right);
        };
        list.addAll(val.asArray)
    }

    norm {|level=(-6)|
        list.addAll(["norm", level])
    }

    silence {|thresh=0.1|
        list.addAll(["silence", "1", thresh, "-50d"]);
        list.add("reverse");
        list.addAll(["silence", "1", thresh, "-50d"]);
        list.add("reverse")
    }

    fade {|fadeInDur=8, fadeOutDur=8|
        list.addAll(["fade", "q", fadeInDur]);
        if (fadeOutDur > 0) {
          list.add("reverse");
          list.addAll(["fade", "q", fadeOutDur]);
          list.add("reverse");
        }
    }

    mono {
        list.addAll(["remix -"])
    }

    trim {|start, len|
        // len 00:04 = 4 seconds
        list.addAll(["trim", start, len]);
    }

    reverse {
        list.add("reverse")
    }

    help {
        "%sox --help".format(path).unixCmdGetStdOut.postln
    }

    transform {|src, dest, replace=false|

        var str;
        var srcpn = PathName(src);
        var destpn = PathName(dest);

        if (srcpn.parentPath == "") {
            var dir = PathName(thisProcess.nowExecutingPath).pathOnly;
            src = "%/%".format(dir, src);
        };
        if (destpn.parentPath == "") {
            var dir = PathName(thisProcess.nowExecutingPath).pathOnly;
            dest = "%/%".format(dir, dest);
        };

        str = "%sox \"%\" \"%\" ".format(path, src.standardizePath, dest.standardizePath) ++ list.join(" ");
        str = str ++ " 2>&1";
        if (replace) {
            str = str ++ "; rm %".format(src);
        };
        str.postln.unixCmdGetStdOut.postln;
        ^"transform done"
    }

    reset {
        list.clear
    }

    prInit {
        list = List();
    }

    *initClass {
        path = "/usr/local/bin/";
    }
}
