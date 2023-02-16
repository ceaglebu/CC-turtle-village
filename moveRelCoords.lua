require("hTest")

tArgs = {...}

if #tArgs < 4 then
   print("Usage: moveTo <x y z dir>") 
end

pos = {
    x = tonumber(tArgs[1]),
    y = tonumber(tArgs[2]),
    z = tonumber(tArgs[3]),
    dir = directions[tArgs[4]]
}

MoveRelCoords(pos)