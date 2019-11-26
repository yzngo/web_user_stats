mg.write("HTTP/1.1 200 OK\r\n")
mg.write("Connection: close\r\n")
mg.write("Content-Type: text/json\r\n")
mg.write("Cache-Control: no-cache\r\n")
mg.write("\r\n")

local param = json.decode( ReadData( mg ) );
local event = param.event;
local country = param.country;
local platform = param.platform;
local version = param.version;
local date = param.date;
local param0 = param.param0;
local param1 = param.param1;

local conn = pgsql.connectdb(conninfo);
if conn:status()  ~= pgsql.CONNECTION_OK then
  log:write( "getdata 18:\n"..conn:errorMessage().."\n" );
end

local xAxis = {};
local yAxis = {};
if date == "ALL" then
    date = 30;
end

--[[
res:ntuples() - Returns the number of rows (tuples) in the query result.
--]]
local sqlstr = "";
if event == "ui_stats" then
    sqlstr = sqlstr..GetSQLBasisString( "action", "uistats", version, country, platform );
    sqlstr = sqlstr..[[  and "page"=$5::varchar ]];
elseif event == "level_stats" then
    sqlstr = sqlstr..GetSQLBasisString( param1, "levelstats", version, country, platform );
    sqlstr = sqlstr..[[  and "mode"=$5::varchar ]];
elseif event == "level_car_stats" then
    sqlstr = sqlstr..GetSQLBasisString( param1, "levelstats", version, country, platform );
elseif event == "user_stats" then
    version = "ALL"
    sqlstr = sqlstr..GetSQLBasisString( param0, "userinfo", version, country, platform );
elseif event == "user_data_enum" then
    sqlstr = sqlstr..GetSQLBasisString( "value", "userdata", version, country, platform );
    sqlstr = sqlstr..[[ and "name"=$5::varchar ]];
elseif event == "user_data_enums" then
    sqlstr = sqlstr..GetSQLBasisString( "svalue", "userdata", version, country, platform );
    sqlstr = sqlstr..[[ and "name"=$5::varchar ]];
elseif event == "user_data_coin" then
    sqlstr = sqlstr..GetSQLCoinString();
end

if event ~= "user_data_coin" then
    sqlstr = sqlstr..[[ group by x ]];
    sqlstr = sqlstr..[[ order by x ]];
end

local res = conn:execParams(sqlstr, version, country, date, platform, param0, param1 );
if res:status() ~= pgsql.PGRES_TUPLES_OK then
    log:write( res:status());
 log:write( "getdata 59:\n"..res:errorMessage().."\n" );
end


if event ~= "user_data_coin" then
    for i = 1, res:ntuples() do
        xAxis[i] = res[i].x;
        yAxis[i] = res[i].y;
    end
else
    for i = 1, res:nfields() do
        xAxis[i] = res:fname( i );
        yAxis[i] = res[1][i];
    end
end


--set chats -----------------------------
local chats = {};
chats.title = {};
chats.title.text = param.text;
chats.title.subtext = "[国家:"..country.."]  ["..date.." 天] [版本: "..version.."] [平台: "..platform.."]";
chats.title.x = "center";
chats.title.textStyle = {};
chats.title.textStyle.fontSize = 25;
chats.title.textStyle.fontWeight = "bolder";
chats.title.subtextStyle = {};
chats.title.subtextStyle.fontSize = 15;

chats.tooltip = {};
chats.tooltip[1] = {};

chats.legend = {};
chats.legend.orient= "vertical";
chats.legend.x = "left";
chats.legend.y = "top";
chats.legend.itemWidth = 24;
chats.legend.itemHeight = 18;
chats.legend.itemGap = 30;
chats.legend.icon = "circle";
chats.legend.data = xAxis;
for i = 1,#xAxis do 
    chats.legend.data[i] = xAxis[i];
end
chats.xAxis = {};
chats.xAxis.data = xAxis;

chats.yAxis = {};
chats.yAxis[1] = {};

chats.series = {};
chats.series[1] = {};
chats.series[1].name = "Amount";
chats.series[1].type = param.type;
chats.series[1].data = {};
for i = 1,#xAxis do
    chats.series[1].data[i] = {};
    chats.series[1].data[i].value = yAxis[i];
    chats.series[1].data[i].name = xAxis[i];
end

chats.series[1].labelLine = {};
chats.series[1].labelLine.normal = {};
chats.series[1].labelLine.normal.show = false;
chats.series[1].label = {};
chats.series[1].label.normal = {};
chats.series[1].label.normal.position = "inner";
chats.series[1].label.normal.formatter = "{c}";

local jsonStr = tostring(json:encode( chats ));

mg.write( jsonStr )
conn:finish();
return;