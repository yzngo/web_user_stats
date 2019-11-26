
local buf = ReadData( mg );
local data = json.decode( buf );

local conn = pgsql.connectdb(conninfo);
if conn:status()  ~= pgsql.CONNECTION_OK then
  log:write( "eventlist 6:\n"..conn:errorMessage().."\n" );
end

-- insert data
for i = 1, #data do

  local  res = conn:execParams([[
        insert into "playfab"."eventlist"
        (
          "EventName", 
          "Timestamp",
          "EntityId",
          "TitleId",
          "Data"
        ) 
        values 
        (
          $1::varchar,
          $2::timestamp,
          $3::varchar,
          $4::varchar,
          $5::jsonb
        )
        ]], 
        data[i].EventName, 
        string.sub(data[i].Timestamp, 1, 19),
        data[i].EntityId,
        data[i].TitleId,
        tostring(json.encode(data[i]))
  );

  if res:status() ~= pgsql.PGRES_COMMAND_OK then
    log:write( "eventlist 39:\n"..res:errorMessage().."\n");
  end

end

PrintHttpRes();
conn:finish()
return
