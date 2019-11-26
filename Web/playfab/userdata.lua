
local buf = ReadData( mg );
local data = json.decode( buf );
local conn = pgsql.connectdb(conninfo);
if conn:status()  ~= pgsql.CONNECTION_OK then
    log:write( "userdata 6:\n"..conn:errorMessage().."\n" );
end

-- insert or update data
local res;
for i = 1, #data do
  
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
        data[i].name,
        string.sub(data[i].Timestamp, 1, 19),
        data[i].value,
        data[i].svalue,
        data[i].version
    );

    if res:status() ~= pgsql.PGRES_COMMAND_OK then
        log:write( "userdata 38:\n"..res:errorMessage().."\n");
    end
end

PrintHttpRes();
conn:finish()
return

