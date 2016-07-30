Evt {

	*on {arg event, obj, func;
		NotificationCenter.register(this, event, obj, func);
	}

	*off {arg event, obj;
		NotificationCenter.unregister(this, event, obj);
	}

	*trigger {arg event, data = Dictionary.new, defer = nil;
		if (defer.isNil, {
			NotificationCenter.notify(this, event, data);
		}, {
			{NotificationCenter.notify(this, event, data);}.defer(defer);
		});
	}

	*clear {
		NotificationCenter.clear;
	}
}