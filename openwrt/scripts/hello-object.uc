#!/usr/bin/ucode
// publish a ubus object from ucode:  ubus call hello greet '{"name":"world"}'
'use strict';

import * as ubus from 'ubus';
import * as uloop from 'uloop';

uloop.init();

let conn = ubus.connect();
conn.publish('hello', {
	greet: {
		call: (req) => ({ message: `Hello, ${req.args.name ?? 'stranger'}!` }),
		args: { name: '' }
	}
});

uloop.run();
