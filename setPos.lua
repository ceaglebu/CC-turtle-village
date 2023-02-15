require("hTest")

local tArgs = {...}

if #tArgs < 4 then
    print("Usage: setPos <x y z dir>")
    return
end

pos = {
    x = tonumber(tArgs[1]),
    y = tonumber(tArgs[2]),
    z = tonumber(tArgs[3]),
    dir = directions[tArgs[4]]
}

UpdatePos(pos)