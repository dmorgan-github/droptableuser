// from: https://github.com/scztt/Deferred.quark/blob/master/Deferred.sc
/*
(
var d;

d = Deferred();
d.then({
	|value|
	"[%] %".format(thisThread.identityHash, value).postln;
	1.wait;
	value + 10
}).then({
	|value|
	"[%] %".format(thisThread.identityHash, value).postln;
	1.wait;
	value * 10;
}).then({
	|value|
	"[%] %".format(thisThread.identityHash, value).postln;
	1.wait;
	value - 0.01;
}).then({
	|value|
	"[%] final value: %".format(thisThread.identityHash, value).postln;
});

"[%] %".format(thisThread.identityHash, "about to start").postln;
d.value = 0;
)
*/
Deferred {
	var value, error, resolved=\unresolved, waitingThreads;

	*new {
		^super.new.init
	}

	*using {
		|func, clock|
		var d = Deferred();
		^d.using(func, clock)
	}

	*newResolved {
		|value|
		^this.new.value_(value)
	}

	init {
		waitingThreads = Array(1);
	}

	asDeferred {
		^this
	}

	wait {
		|timeout|
		this.prWait(timeout);

		if (resolved == \error) {
			error.throw;
		};

		^value
	}

	hasValue {
		^(resolved == \value)
	}

	hasError {
		^(resolved == \error)
	}

	isResolved {
		^(resolved != \unresolved);
	}

	value {
		switch(resolved,
			\value, 		{ ^value },
			\error, 		{ error.throw },
			\unresolved,	{ AccessingDeferredValueError().throw }
		);
	}

	value_{
		|inValue|
		if (resolved == \unresolved) {
			resolved = \value;
			value = inValue;
			this.prResume();
		} {
			ResettingDeferredValueError(value, error).throw;
		}
	}

	error {
		// @TODO - do we want to error here if no error was provided?
		^error
	}

	error_{
		|inError|
		if (resolved == \unresolved) {
			resolved = \error;
			error = inError;
			this.prResume();
		} {
			ResettingDeferredValueError(value, error).throw;
		}
	}

	valueCallback {
		^{
			|value|
			this.value = value;
		}
	}

	errorCallback {
		^{
			|error|
			this.error = error;
		}
	}

	using {
		|function, clock|
		// We want to catch errors that happen when function is called, but AVOID catching errors
		// that may occur during the this.value set operation.
		{
			var funcResult = \noValue;

			try {
				funcResult = function.value(this);

				if (funcResult.isKindOf(Deferred)) {
					funcResult = funcResult.wait();
				};

				// gotcha: returning an Exception from a function wrapped in a try effectively throws.
				nil;
			} {
				|error|
				this.error = error;
			};

			if (funcResult != \noValue) {
				this.value = funcResult;
			}
		}.forkIfNeeded(clock ?? thisThread.clock);
	}

	then {
		|valueFunc, errorFunc, clock|
		var newDeferred, result, errResult, handleFunc;
		// If not specified, just default to returning / rethrowing whatevers passed in
		valueFunc = valueFunc ? { |v| v };
		errorFunc = errorFunc ? { |v| v.throw; };

		newDeferred = Deferred();

		handleFunc = {
			if (this.hasValue) {
				newDeferred.using({
					valueFunc.value(this.value);
				})
			} {
				// SUBTLE: If we throw in value-handling code, it's turned into an error.
				// If we throw during ERROR-handling code, we immediately fail and don't
				// continue the chain. Otherwise, Error return values are passed along
				// as errors, everything else as value.
				errResult = errorFunc.value(this.error);

				newDeferred.using({
					if (errResult.isKindOf(Exception)) {
						errResult.throw;
					} {
						errResult;
					}
				})
			}
		};

		if (this.isResolved) {
			handleFunc.()
		} {
			{
				this.prWait;
				handleFunc.();
			}.fork(clock ?? thisThread.clock);
		};

		^newDeferred
	}

	onValue {
		|function, clock|
		this.then(function, nil, clock);
	}

	onError {
		|function, clock|
		this.then(nil, function, clock);
	}

	prWait {
		|timeout|
		if (resolved == \unresolved) {
			waitingThreads = waitingThreads.add(thisThread.threadPlayer);

			if (timeout.notNil) {
				thisThread.clock.sched(timeout, {
					if (resolved == \unresolved) {
						this.error = DeferredTimeoutError(value, error).timeout_(timeout);
					}
				})
			};

			while { resolved == \unresolved } {
				\hang.yield;
			};

			waitingThreads = waitingThreads.remove(thisThread.threadPlayer);
		}
	}

	prResume {
		waitingThreads.do {
			|thread|
			thread.clock.sched(0, thread);
		};
	}

	printOn {
		|stream|
		stream << "Deferred(%)".format(this.identityHash);
	}
}

ResettingDeferredValueError : Error {
	var <>value, <>error;

	*new {
		|value, error|
		^super.new(
			"Setting a Deferred value after the value has already been set. (value:%, error:%)".format(value, error)
		).value_(value).error_(error);
	}
}

AccessingDeferredValueError : Error  {
	errorString {
		^"Accessing Deferred value before the value has been set.";
	}
}

DeferredTimeoutError : Error  {
	var <>timeout;

	*new {
		|timeout|
		^super.newCopyArgs(timeout);
	}

	errorString {
		^"Timed out waiting for Deferred after % seconds.".format(timeout)
	}
}