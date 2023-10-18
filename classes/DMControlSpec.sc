// adding a sort property to help
// organize guis
DMControlSpec : ControlSpec {

    var <>sort=0;

    *new {|minval = (0.0), maxval = (1.0), warp = ('lin'), step = (0.0), default, units, grid, sort=0|
        var res = super.new(minval, maxval, warp, step, default, units, grid);
        res.sort = sort;
        ^res;
    }
}