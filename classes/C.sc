C {

    *henon {|a = 1.4, b = 0.3, x0 = 0, x1 = 1, size = 64|
        ^size.collect({ var aux = 1 - (a * (x1 ** 2)) + (b * x0); x0 = x1; x1 = aux; aux });
    }

    *quad {|a = 1, b = -1, c = -0.75, xi = 0, size = 64|
        ^size.collect({ xi = (a * (xi ** 2)) + (b * xi) + c; xi })
    }

    *cusp {|a = 1.0, b = 1.9, xi = 0, size = 64|
        ^size.collect({ xi = a - (b * sqrt(abs(xi))) })
    }

    *gbman {|xi = 1.2, yi = 2.1, size = 64|
        ^size.collect({ var x; xi = 1 - yi + abs(x = xi); yi = x; xi })
    }

    *latoocarfian {|a = 1, b = 3, c = 0.5, d = 0.5, xi = 0.5, yi = 0.5, size = 64|
        ^size.collect({ var x = xi;
            xi = sin(b * yi) + (c * sin(b * xi));
            yi = sin(a * x) + (d * sin(a * yi));
            xi
        })
    }

    *lincong {|a = 1.1, c = 0.13, m = 1, xi = 0, size = 64|
        ^size.collect({ xi = (a * xi + c) % m })
    }

    *standard {|k = 1, xi = 0.5, yi = 0, size = 64|
        ^size.collect({ yi = yi + (k * sin(xi)) % 2pi; xi = (xi + yi) % 2pi; xi - pi * 0.3183098861837907 })
    }

    *fbsine {|im = 1, fb = 0.1, a = 1.1, c = 0.5, xi = 0.1, yi = 0.1, size = 64|
        ^size.collect({ xi = sin((im * yi) + (fb * xi)); yi = (a * yi + c) % 2pi; xi })
    }
}
