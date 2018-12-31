Evt {

	*on {arg event, obj, func;
		NotificationCenter.register(this, event, obj, func);
	}

	*off {arg event, obj;
		NotificationCenter.unregister(this, event, obj);
	}

	*trigger {arg event, data = Dictionary.new;
		var me = this;
		//{
			//event.debug("trigger");
			NotificationCenter.notify(me, event, data);
		//}.fork(quant:0.0);
	}

	*clear {
		NotificationCenter.clear;
	}
}