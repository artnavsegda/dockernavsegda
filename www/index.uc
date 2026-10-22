'use strict';

import * as ubus from 'ubus';

let conn = ubus.connect();
let board = conn.call('system', 'board');

print("Content-Type: application/json\r\n\r\n");
printf("%.J\n", {
	method: getenv('REQUEST_METHOD'),
	query: getenv('QUERY_STRING'),
	board
});
