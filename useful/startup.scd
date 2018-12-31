// set up reusable modules
	{
		this.executeFile("/Users/david/projects/droptableuser/apps/modules/v1/fundamental.scd");
		this.executeFile("/Users/david/projects/droptableuser/apps/modules/v1/env.scd");
		this.executeFile("/Users/david/projects/droptableuser/apps/modules/v1/fx.scd");
		this.executeFile("/Users/david/projects/droptableuser/apps/modules/v1/filter.scd");
		this.executeFile("/Users/david/projects/droptableuser/apps/modules/v1/reverb.scd");
		this.executeFile("/Users/david/projects/droptableuser/apps/modules/v1/delay.scd");
		this.executeFile("/Users/david/projects/droptableuser/apps/modules/v1/distortion.scd");
		this.executeFile("/Users/david/projects/droptableuser/apps/modules/v1/synth.scd");
		this.executeFile("/Users/david/projects/droptableuser/apps/modules/v1/fm7.scd");
		this.executeFile("/Users/david/projects/droptableuser/apps/modules/v1/helper.scd");
		this.executeFile("/Users/david/projects/droptableuser/apps/modules/v1/generator.scd");
		this.executeFile("/Users/david/projects/droptableuser/apps/modules/v1/logic.scd");
		// free buses - s.newBusAllocators
	};

	// setup reaper integration
	{
		~reaper = ();
		~reaper.addr = NetAddr("10.0.1.52", 8000);
		~reaper.record = {arg self; self.addr.sendMsg("/record");};
		~reaper.doStop = {arg self; self.addr.sendMsg("/stop");};
	}.value;

	// set up useful buffers
	{
		var blackman = {arg size = 1024;

			var sig, alpha, a0, a1, a2;
			alpha = 0.16;
			sig = Signal.newClear(size);

			a0 = 0.5*(1-alpha);
			a1 = 0.5;
			a2 = alpha*0.5;

			sig.waveFill( { arg x, i; a0 - (a1*cos( (2*pi*x)/(size-1) ) ) + (a2*cos( (4*pi*x)/(size-1) ) )}, 0, size );
			sig;
		};

		var windowSize = 1024;

		~bufs = ();
		~bufs[\read] = {arg self, key, path;
			self[key.asSymbol] = Buffer.read(s, path.standardizePath);
		};
		~bufs[\alloc] = {arg self, key, seconds = 1, numChannels = 1;
			self[key.asSymbol] = Buffer.alloc(s, s.sampleRate * seconds, numChannels);
		};
		~bufs[\hanning] = Buffer.sendCollection(s, Signal.hanningWindow(windowSize), 1);
		~bufs[\hamming] = Buffer.sendCollection(s, Signal.hammingWindow(windowSize), 1);
		~bufs[\welch] = Buffer.sendCollection(s, Signal.welchWindow(windowSize), 1);
		~bufs[\rectangle] = Buffer.sendCollection(s, Signal.rectWindow(windowSize), 1);
		~bufs[\perc] = Buffer.sendCollection(s, Env.perc.asSignal(windowSize), 1);
		~bufs[\triangle] = Buffer.sendCollection(s, Env.triangle.asSignal(windowSize), 1);
		~bufs[\blackman] = Buffer.sendCollection(s, blackman.(windowSize), 1);

	}.value;