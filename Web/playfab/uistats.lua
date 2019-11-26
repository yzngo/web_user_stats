
local buf = ReadData( mg );
local data = json.decode( buf );
local conn = pgsql.connectdb(conninfo);
if conn:status()  ~= pgsql.CONNECTION_OK then
  log:write( "uistats 6:\n"..conn:errorMessage().."\n" );
end

-- insert data
for i = 1, #data do
  local res = conn:execParams([[
    insert into "playfab"."uistats"
    (
        "TitleId",
        "EntityId",
        "Timestamp",
        "version",
        "page",
        "action",
        "param" 
    ) 
    values 
    (
      $1::varchar,
      $2::varchar,
      $3::timestamp,
      $4::varchar,
      $5::varchar,
      $6::varchar,
      $7::varchar
    )
    ]], 
    data[i].TitleId,
    data[i].EntityId,
    string.sub(data[i].Timestamp, 1, 19),
    data[i].version,
    data[i].page,
    data[i].action,
    data[i].param
  );

  if res:status() ~= pgsql.PGRES_COMMAND_OK then
    log:write( "uistats 43:\n"..res:errorMessage().."\n");
  end
end

PrintHttpRes();
conn:finish();
return
