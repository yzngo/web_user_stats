mg.write("HTTP/1.1 200 OK\r\n")
mg.write("Connection: close\r\n")
mg.write("Content-Type: text/json\r\n")
mg.write("Cache-Control: no-cache\r\n")
mg.write("\r\n")

DEBUG = false;
local country = {};
local version = {};
local platform = {};
local conn = pgsql.connectdb(conninfo);

local res = conn:exec([[
    select distinct "CountryCode" as id  from "playfab"."userinfo" 
    order by "id"
]]);
for i = 1, res:ntuples() do
    country[i] = res[i].id;
end

res = conn:exec([[
    select distinct "version" as id from "playfab"."userdata" 
    order by "id"
]])
for i = 1, res:ntuples() do
    version[i] = res[i].id;
end

res = conn:exec([[
    select distinct "Platform" as id from "playfab"."userinfo" 
    order by "id"
]])
for i = 1, res:ntuples() do
    platform[i] = res[i].id;
end


local data = {};
data.country = country;
data.version = version;
data.platform = platform;
local jsonStr = tostring(json:encode( data ));

if DEBUG then
    if conn:status()  ~= pgsql.CONNECTION_OK then
        mg.write(json.encode( debuginfo ));
    else
        mg.write(json.encode( conn:errorMessage()));
    end
else
    mg.write( jsonStr )
end

conn:finish()
