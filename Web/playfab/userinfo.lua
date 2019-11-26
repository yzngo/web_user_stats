

local buf = ReadData( mg );
local data = json.decode( buf );

local conn = pgsql.connectdb(conninfo);
if conn:status()  ~= pgsql.CONNECTION_OK then
    log:write( "userinfo 8:\n"..conn:errorMessage().."\n" );
end

-- insert or update data
local res;
for i = 1, #data do

  res = conn:execParams([[
        insert into "playfab"."userinfo"
        (
          "TitleId",
          "EntityId",
          "Latitude",
          "Longitude",
          "City",
          "CountryCode",
          "ContinentCode",
          "Platform",
          "Timestamp",
          "IPV4Address",
          "PlatformUserId"
        ) values (
            $1::varchar,
            $2::varchar,
            $3::float4,
            $4::float4,
            $5::varchar,
            $6::varchar,
            $7::varchar,
            $8::varchar,
            $9::timestamp,
            $10::inet,
            $11::varchar
        ) on conflict (
            "TitleId",
            "EntityId"
        )
        do update set
            "Latitude" = $3::float4,
            "Longitude" = $4::float4,
            "City" = $5::varchar,
            "CountryCode" = $6::varchar,
            "ContinentCode" = $7::varchar,
            "Platform" = $8::varchar,
            "Timestamp" = $9::timestamp,
            "IPV4Address" = $10::inet,
            "PlatformUserId" = $11::varchar
        ]],
        data[i].TitleId,
        data[i].EntityId,
        data[i].Location.Latitude,
        data[i].Location.Longitude,
        data[i].Location.City,
        data[i].Location.CountryCode,
        data[i].Location.ContinentCode,
        data[i].Platform,
        string.sub(data[i].Timestamp, 1, 19),
        data[i].IPV4Address,
        data[i].PlatformUserId
    );
    if res:status() ~= pgsql.PGRES_COMMAND_OK then
        log:write( "eventlist 69:\n"..res:errorMessage().."\n");
    end
end

PrintHttpRes();
conn:finish();
return
