Bitwig {

	classvar <server;

	*record {
		server.sendMsg("/record");
	}

	*play {
		server.sendMsg("/play");
	}

	*stop {
		server.sendMsg("/stop");
	}

	*tempo {arg bps=1;
		server.sendMsg("/tempo/raw", 60 * bps);
	}

	*time {arg time=0;
		server.sendMsg("/time", time);
	}

	*initClass {
		server = NetAddr("127.0.0.1", 8000); // loopback
	}
}