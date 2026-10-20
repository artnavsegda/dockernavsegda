print("Content-Type: text/plain\r\n\r\n");
print("hello from ucode cgi\n");
print("method: ", getenv("REQUEST_METHOD"), "\n");
print("query:  ", getenv("QUERY_STRING"), "\n");
let t = localtime();
print(sprintf("time:   %04d-%02d-%02d %02d:%02d:%02d\n", t.year, t.mon, t.mday, t.hour, t.min, t.sec));