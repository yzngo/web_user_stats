mg.write("HTTP/1.1 200 OK\r\n")
mg.write("Connection: close\r\n")
mg.write("Content-Type: text/json\r\n")
mg.write("Cache-Control: no-cache\r\n")
mg.write("\r\n")

local conn = pgsql.connectdb(conninfo);
if conn:status()  ~= pgsql.CONNECTION_OK then
    log:write( "getoption 6:\n"..conn:errorMessage().."\n" );
  end

local data = {};

for i = 1, #SQL_OPTION do
    local sqlstr = "select distinct \""..SQL_OPTION[i].."\" as id from \"playfab\".\""..SQL_OPTION_FROM_TABLE[i].."\" order by \"id\"";
    local res = conn:exec(sqlstr);
    if res:status() ~= pgsql.PGRES_TUPLES_OK then
        log:write( "getoption 24:\n"..res:errorMessage().."\n" );
    end
    
    data[SQL_OPTION[i]] = {};
    for j = 1, res:ntuples() do
        data[SQL_OPTION[i]][j] = res[j].id;
    end
end

local jsonStr = tostring(json:encode( data ));
mg.write( jsonStr )
conn:finish()
return
