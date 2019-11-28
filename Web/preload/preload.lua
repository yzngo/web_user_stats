
log = io.open('..\\Log\\log.log', 'a');

SQL_OPTION =                {"CountryCode",  "version",  "Platform" };
SQL_OPTION_FROM_TABLE  =    {"userinfo",     "userdata", "userinfo" };

conninfo = [[
            dbname=postgres
            user=yang
            password=yang
            connect_timeout=3
                ]];

function ReadData( mg )
    local tbl = {};
    repeat
        local tmp = mg.read();
        if (tmp) then
            table.insert( tbl, tmp );
        end
    until (not tmp);
    local buf = table.concat( tbl );
    return buf;
end


function PrintHttpRes()
    mg.write("HTTP/1.0 201 Created\r\n")
    mg.write("Connection: close\r\n")
    mg.write("Date: " .. os.date("%a, %d %b %Y %H:%M:%S GMT") .. "\r\n")
    mg.write("\r\n")
end

-- Debug helper function to print a table
function TableToStr(t)
    if t == nil then return "" end
    local retstr= "{"

    local i = 1
    for key,value in pairs(t) do
        local signal = ","
        if i==1 then
          signal = ""
        end

        if key == i then
            retstr = retstr..signal..ToStringEx(value)
        else
            if type(key)=='number' or type(key) == 'string' then
                retstr = retstr..signal..'['..ToStringEx(key).."]="..ToStringEx(value)
            else
                if type(key)=='userdata' then
                    retstr = retstr..signal.."*s"..TableToStr(getmetatable(key)).."*e".."="..ToStringEx(value)
                else
                    retstr = retstr..signal..key.."="..ToStringEx(value)
                end
            end
        end

        i = i+1
    end
     retstr = retstr.."}"
     return retstr
end

function ToStringEx(value)
    if type(value)=='table' then
       return TableToStr(value)
    elseif type(value)=='string' then
        return "\'"..value.."\'"
    else
       return tostring(value)
    end
end


-- first link this option, then link others
function GetSQLBasisString( column, table, version, country, platform, ex_option )
    local sqlstr = "";
    sqlstr = sqlstr.."select distinct \""..column.."\" as x, count(\""..column.."\") as y from \"playfab\".\""..table.."\" where  ";
    sqlstr = sqlstr..GetSQLOptionString( version, country, platform );
    sqlstr = sqlstr..ex_option;
    sqlstr = sqlstr..[[ group by x ]];
    sqlstr = sqlstr..[[ order by x ]];
    return sqlstr;
end

function GetSQLCoinString( param0, param1, version, country, platform )
    local sqlstr = [[
        select
        count(case when T.value <= 50000 then 1 end) as "5万以下",
        count(case when T.value between 50000 and 100000 then 1 end) as "5-10万",
        count(case when T.value between 100000 and 150000 then 1 end) as "10-15万",
        count(case when T.value between 150000 and 200000 then 1 end) as "15-20万",
        count(case when T.value between 200000 and 250000 then 1 end) as "20-25万",
        count(case when T.value between 250000 and 300000 then 1 end) as "25-30万",
        count(case when T.value between 300000 and 1000000 then 1 end) as "30-100万",
        count(case when T.value >=1000000 then 1 end) as "100万以上"

        from ( 
            select value from "playfab"."userdata" where ]];
    sqlstr = sqlstr..GetSQLOptionString( version, country, platform );
    sqlstr = sqlstr..[[ and name=$5::varchar ) as T ]];
    return sqlstr;
end

function GetSQLOptionString( version, country, platform )
    local sqlstr = "";
    local num = 0;
    if version ~= "ALL" then
        num = num + 1;
        sqlstr = sqlstr..[[  "version"=$1::varchar  ]];
    end

    if country ~= "ALL" then
        if num ~= 0 then
            sqlstr = sqlstr.." and  ";
        end
        num = num + 1;
        sqlstr = sqlstr..[[ "EntityId" in ( select "EntityId" from "playfab"."userinfo" where "CountryCode"=$2::varchar ) ]];
    end

    if platform ~= "ALL" then
        if num ~= 0 then
            sqlstr = sqlstr.." and ";
        end
        num = num + 1;
        sqlstr = sqlstr..[[ "EntityId" in ( select "EntityId" from "playfab"."userinfo" where "Platform"=$4::varchar ) ]];
    end
 
    if num ~= 0 then
        sqlstr = sqlstr.."and ";
    end
    sqlstr = sqlstr..[[ "Timestamp" >= date_trunc('day', now()-interval '$3 day')  ]];
    return sqlstr;
end