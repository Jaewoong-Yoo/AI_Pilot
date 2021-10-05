-- C:\Users\Jaewoong\Saved Games\DCS\Scripts\Export.lua
-- local net               = require('net')

local log_file = nil

-- function string:split(delimiter)
-- 	local result = { }
-- 	local from = 1
-- 	local delim_from, delim_to = string.find( self, delimiter, from )
-- 	while delim_from do
-- 	  table.insert( result, string.sub( self, from , delim_from-1 ) )
-- 	  from = delim_to + 1
-- 	  delim_from, delim_to = string.find( self, delimiter, from )
-- 	end
-- 	table.insert( result, string.sub( self, from ) )
-- 	return result
-- end  
-- delimiter = string.split(stringtodelimite,pattern) 

function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

-- function uri_actions.restartMission()
-- 	-- local mission_id = params["mission_id"] + 1
-- 	-- result = net.missionlist_run(mission_id)
-- 	result = net.missionlist_run(0)
-- 	return result
-- end

function LuaExportStart()
	-- need to check
	log_file = io.open("C:/Users/Jaewoong/Desktop/Data.txt", "w")

	package.path  = package.path..";"..lfs.currentdir().."/LuaSocket/?.lua"
	package.cpath = package.cpath..";"..lfs.currentdir().."/LuaSocket/?.dll"

	socket = require("socket")
	IPAddress = "localhost"
	Port = 8082
	-- Port = 8087

	MySocket = socket.try(socket.connect(IPAddress, Port))
	MySocket:setoption("tcp-nodelay",true) 
	-- repeat
	-- 	sum = b + sum 
	-- socket.try(MySocket:send(string.format("IAS: %.4f \n",IAS)))
end

function LuaExportBeforeNextFrame()
	-- SEND COMMAND
	local msg, err, part = MySocket:receive()
	local cmd = split(msg, " ")
	log_file:write(string.format("CMD1: %.2f \n", cmd[1]))
	log_file:write(string.format("CMD2: %.2f \n", cmd[2]))
	log_file:write(string.format("CMD3: %.2f \n", cmd[3]))
	-- log_file:write(string.format("CMD4: %.2f \n", cmd[4]))
	-- log_file:write(string.format("CMD5: %.2f \n", cmd[5]))
	
	----------------------- Output ------------------------
	-- command = 2001 - joystick pitch 	(=elevator)
	-- command = 2002 - joystick roll	(=aileron)
	-- command = 2003 - joystick rudder
	-- command = 2004 - joystick thrust (both engines)
	-- command = 2005 - joystick left engine thrust
	-- command = 2006 - joystick right engine thrust
	------------------------------------------------------
	-- LoSetCommand(2001, tonumber(cmd[1]))
	-- LoSetCommand(2002, tonumber(cmd[2]))
	-- LoSetCommand(2003, tonumber(cmd[3]))
	-- LoSetCommand(2004, tonumber(cmd[4]))
	-- -- LoSetCommand(2005, tonumber(cmd[4]))
	-- -- LoSetCommand(2006, tonumber(cmd[5]))

	LoSetCommand(2002, tonumber(cmd[1]))
	LoSetCommand(2001, tonumber(cmd[2]))
	LoSetCommand(2004, tonumber(cmd[3]))
	-- LoSetCommand(113) -- 84(Fire on), 85(Fire off), 113(Cannon), 350(Release weapon), 351(Stop release weapon)
	-- LoSetCommand(84)
	
	-- elseif cmd[3] ~= 0 then
	-- 	LoSetCommand(2003, tonumber(cmd[3]))
	-- elseif cmd[4] ~= 0 then
	-- 	LoSetCommand(2004, tonumber(cmd[4]))
	-- elseif cmd[4] == 4 then
	-- 	LoSetCommand(51,0)
	-- end
	-- command = 51 -- Mission quit 							
end

function LuaExportAfterNextFrame()
	
	----------------------- input ------------------------
	-- height, distance, Angle Error, AOA, SS, Vel, Angle
	------------------------------------------------------
	-- LoGetObjectById() -- (args - 1 (number), results - 1 (table))
	-- Returned object table structure:
	-- { 
	-- 	Name = 
	-- 	Type =  {level1,level2,level3,level4},  ( see Scripts/database/wsTypes.lua) Subtype is absent  now
	-- 	Country   =   number ( see Scripts/database/db_countries.lua
	-- 	Coalition = 
	-- 	CoalitionID = number ( 1 or 2 )
	-- 	LatLongAlt = { Lat = , Long = , Alt = }
	-- 	Heading =   radians
	-- 	Pitch      =   radians
	-- 	Bank      =  radians
	-- 	Position = {x,y,z} -- in internal DCS coordinate system ( see convertion routnes below)
	-- 	-- only for units ( Planes,Hellicopters,Tanks etc)
	-- 	UnitName    = unit name from mission (UTF8)  
	-- 	GroupName = unit name from mission (UTF8)
	-- 		Flags = {
	-- 		RadarActive = true if the unit has its radar on
	-- 		Human = true if the unit is human-controlled
	-- 		Jamming = true if the unit uses EMI jamming
	-- 		IRJamming = -- same for IR jamming
	-- 		Born = true if the unit is born (activated)
	-- 		AI_ON = true if the unit's AI is active
	-- 		Invisible = true if the unit is invisible
	-- 		Static - true if the unit is a static object
	-- 		}
	-- }
	------------------------------------------------------

	local t = LoGetModelTime()

	-- local IAS = LoGetIndicatedAirSpeed()
	-- local MSS = LoGetMissionStartTime()
	-- socket.try(MySocket:send(string.format("IAS: %.4f \n",IAS)))
	-- socket.try(MySocket:send(string.format("MSS: %.4f \n",MSS)))

	-------------------- ID setting --------------------
	-- Ownship_id = 16777728 -- Dogfight_close_test.miz
	-- Target_id = 16777472  -- Dogfight_close_test.miz

	-- Ownship_id = 16779264 -- Dogfight_random_close.miz

	local Ownship_id = 16778496 -- Dogfight_random_4actions.miz
	local Target_id = 0
	-- for k,v in pairs(LoGetWorldObjects()) do
	-- 	if k == Ownship_id then Ownship_id else Target_id = k -- Dogfight_random_close.miz
	-- end

	local Ownship_info = LoGetObjectById(Ownship_id)
	-- local Target_info = LoGetObjectById(Target_id) -- Target_id 있는 경우에만 아래 info 불러오기
	local aoa = LoGetAngleOfAttack() -- OK
	local alt = LoGetAltitudeAboveSeaLevel() -- OK
	local ss = LoGetSlipBallPosition() -- OK
	local vel = LoGetVectorVelocity() -- OK
	local ang_vel = LoGetAngularVelocity() -- OK
	local engine = LoGetEngineInfo() -- OK
	-- local ver_vel = LoGetVerticalVelocity() -- check_freefall에서 speed-down-fps 역할 가능?

	Lat = Ownship_info.LatLongAlt.Lat
	Lon = Ownship_info.LatLongAlt.Long
	Alt = Ownship_info.LatLongAlt.Alt
	b = Ownship_info.Bank
	p = Ownship_info.Pitch
	h = Ownship_info.Heading
	-- x = Ownship_info.Position.x
	-- y = Ownship_info.Position.y
	-- z = Ownship_info.Position.z
	-- alt = Ownship_info.LatLongAlt.Alt

	for k,v in pairs(LoGetWorldObjects()) do
		if k == Ownship_id then
		elseif LoGetObjectById(k).Bank ~= 0.0 then
			Target_id = k -- Dogfight_random_close.miz
		end
	end
	if Target_id == 0 then
		tLat = 0.0
		tLon = 0.0
		tAlt = 0.0
		tb = 0.0
		tp = 0.0
		th = 0.0
		tx = 0.0
		ty = 0.0
		tz = 0.0
	elseif Target_id ~= 0 then
		local Target_info = LoGetObjectById(Target_id)
		tLat = Target_info.LatLongAlt.Lat
		tLon = Target_info.LatLongAlt.Long
		tAlt = Target_info.LatLongAlt.Alt
		tb = Target_info.Bank
		tp = Target_info.Pitch
		th = Target_info.Heading
		tx = Target_info.Position.x
		ty = Target_info.Position.y
		tz = Target_info.Position.z
	end

	-- xx = LoGeoCoordinatesToLoCoordinates(Lon, Lat).x
	-- zz = LoGeoCoordinatesToLoCoordinates(Lon, Lat).z
	-- Test
	-- socket.try(MySocket:send(LoGetSideDeviation()))
	-- socket.try(MySocket:send(string.format("check")))
	-- log_file:write(string.format("check"))
	
	-- Make Input
	-- socket.try(MySocket:send(string.format("ID = %.1f", getID )))
	-- socket.try(MySocket:send(string.format("Lat = %.8f, Lon = %.8f, Alt = %.8f, b = %.6f, p = %.6f, h = %.6f, x = %.8f, y = %.8f, z = %.8f, velx = %.6f, vely = %.6f, velz = %.6f, tLat = %.8f, tLon = %.8f, tAlt = %.8f, tb = %.6f, tp = %.6f, th = %.6f, b_rate = %.6f, p_rate = %.6f, h_rate = %.6f", Lat, Lon, Alt, b, p, h, x, y, z, vel.x, vel.y, vel.z, tLat, tLon, tAlt, tb, tp, th, ang_vel.x, ang_vel.y, ang_vel.z)))

	-- socket.try(MySocket:send(string.format(
	-- 	"Lat = %.8f, Long = %.8f, Alt = %.8f, b = %.6f, p = %.6f, h = %.6f, x = %.8f, y = %.8f, z = %.8f, tLat = %.8f, tLong = %.8f, tAlt = %.8f, tb = %.6f, tp = %.6f, th = %.6f, tx = %.8f, ty = %.8f, tz = %.8f, velx = %.6f, vely = %.6f, velz = %.6f, b_rate = %.6f, p_rate = %.6f, h_rate = %.6f, aoa = %.4f, ss = %.4f, xx = %.8f, yy = %.8f, zz = %.8f", 
	-- 	Lat, Long, Alt, b, p, h, x, y, z, 
	-- 	tLat, tLong, tAlt, tb, tp, th, tx, ty, tz, 
	-- 	vel.x, vel.y, vel.z, ang_vel.x, ang_vel.y, ang_vel.z, aoa, ss, xx, yy, zz
	-- )))

	socket.try(MySocket:send(string.format(
		"t = %.8f, Lat = %.8f, Lon = %.8f, Alt = %.8f, b = %.6f, p = %.6f, h = %.6f, tLat = %.8f, tLon = %.8f, tAlt = %.8f, tb = %.6f, tp = %.6f, th = %.6f, velx = %.6f, vely = %.6f, velz = %.6f, b_rate = %.6f, p_rate = %.6f, h_rate = %.6f, aoa = %.4f", 
		-- "t = %.2f, Lat = %.8f, Lon = %.8f, Alt = %.8f, b = %.6f, p = %.6f, h = %.6f, tLat = %.8f, tLon = %.8f, tAlt = %.8f, tb = %.6f, tp = %.6f, th = %.6f, velx = %.6f, vely = %.6f, velz = %.6f, b_rate = %.6f, p_rate = %.6f, h_rate = %.6f, aoa = %.4f, ss = %.4f", 
		t, Lat, Lon, Alt, b, p, h, 
		tLat, tLon, tAlt, tb, tp, th, 
		vel.x, vel.y, vel.z, ang_vel.x, ang_vel.y, ang_vel.z, aoa
		-- vel.x, vel.y, vel.z, ang_vel.x, ang_vel.y, ang_vel.z, aoa, ss
	)))
	
	-- socket.try(MySocket:send(string.format("ss = %.2f", ss))) -- NOT working in F/A-18C!!! (but, not problem in Su-25T)

end

function LuaExportStop()

	if MySocket then 
		socket.try(MySocket:send("exit"))
		MySocket:close()
	end

	log_file:write(string.format("exit"))

	if log_file then
		log_file:close()
		log_file = nil
	end

	net.missionlist_run(0)
end

function LuaExportActivityNextEvent(t)
	local tNext = t
	return tNext
end