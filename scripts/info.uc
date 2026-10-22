#!/usr/bin/ucode
// quick smoke test: talk to ubus and uci like a real router script would
'use strict';

import * as ubus from 'ubus';
import { cursor } from 'uci';

let conn = ubus.connect();
if (!conn)
	die(`ubus connect failed: ${ubus.error()}\n`);

printf("objects: %J\n\n", conn.list());
printf("system board: %.J\n\n", conn.call('system', 'board'));
printf("system info: %.J\n\n", conn.call('system', 'info'));
printf("lan status: %.J\n\n", conn.call('network.interface.lan', 'status'));

let uci = cursor();
printf("uci network.lan: %.J\n", uci.get_all('network', 'lan'));
