
local f = io.open("source.txt", "a")

	repeat
		local buf = mg.read();
		if (buf) then
			f:write(buf)
		end
	until (not buf);
  f:close()
    
  PrintHttpRes();
  return
