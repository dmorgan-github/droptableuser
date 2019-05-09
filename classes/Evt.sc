Evt {

	*on {arg event, obj, func;
		NotificationCenter.register(this, event, obj, func);
	}

	*off {arg event, obj;
		NotificationCenter.unregister(this, event, obj);
	}

	*trigger {arg event, data = Dictionary.new;
		var me = this;
		NotificationCenter.notify(me, event, data);
	}

	*clear {
		NotificationCenter.clear;
	}
}