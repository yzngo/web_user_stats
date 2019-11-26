
local buf = ReadData( mg );
local data = json.decode( buf );

local conn = pgsql.connectdb(conninfo);
if conn:status()  ~= pgsql.CONNECTION_OK then
  log:write( "levelstats 6:\n"..conn:errorMessage().."\n" );
end

-- insert data
for i = 1, #data do

  local res = conn:execParams([[
    insert into "playfab"."levelstats"
    (
        "TitleId","EntityId","Timestamp","version","mode","level","player","param"
    ) 
    values 
    (
      $1::varchar,
      $2::varchar,
      $3::timestamp,
      $4::varchar,
      $5::varchar,
      $6::varchar,
      $7::varchar,
      $8::varchar
    )
    ]], 
    data[i].TitleId,
    data[i].EntityId,
    string.sub(data[i].Timestamp, 1, 19),
    data[i].version,
    data[i].mode,
    data[i].level,
    data[i].player,
    data[i].param
  );
  if res:status() ~= pgsql.PGRES_COMMAND_OK then
    log:write( "levelstats 40:\n"..res:errorMessage().."\n");
  end

  res = conn:execParams([[
    insert into "playfab"."userdata"
    (
      "TitleId","EntityId","name","Timestamp","value","svalue","version"
    ) values (
        $1::varchar,$2::varchar,$3::varchar,$4::timestamp,$5::float8,$6::varchar,$7::varchar
    ) on conflict (
        "TitleId","EntityId","name"
    )
    do update set
        "Timestamp" = $4::timestamp,
        "value" = $5::float8,
        "svalue" = $6::varchar,
        "version" = $7::varchar
    ]],
    data[i].TitleId,
    data[i].EntityId,
    "last_use_car",
    string.sub(data[i].Timestamp, 1, 19),
    data[i].value,
    data[i].player,
    data[i].version
  );
  if res:status() ~= pgsql.PGRES_COMMAND_OK then
    log:write( "levelstats 67:\n"..res:errorMessage().."\n");
  end
end

PrintHttpRes();
conn:finish();
return
