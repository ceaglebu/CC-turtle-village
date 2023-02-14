fs.makeDir("temp")
 
directions = {
    north = 0, east = 1, south = 2, west = 3
}
 
moves = {
    forward = 1, backward = -1,
    up = 2, down = -2
}
 
function UpdatePos(pos)
    local file = fs.open("temp/state", "w")
    file.writeLine(string.format("%d %d %d %d", pos.x, pos.y, pos.z, pos.dir))
    file.close()
    return true
end
 
function GetPos()
    local file = fs.open("temp/state", "r")
    local line = file.readLine()
    local pos = {}
    pos.x, pos.y, pos.z, pos.dir = line:match("(%S+) (%S+) (%S+) (%S+)")
    for k,v in pairs(pos) do
        pos[k] = tonumber(v)
    end 
    return pos
end
 
function MovePos(move)
    local newPos = GetPos()
 
    if move == moves.forward or move == moves.backward then  
        local dir = newPos.dir
        local update = (move == moves.forward and 1 or -1)
        if dir == directions.north then newPos.z = newPos.z - update
        elseif dir == directions.east then newPos.x = newPos.x + update
        elseif dir == directions.south then newPos.z = newPos.z + update
        elseif dir == directions.west then newPos.x = newPos.x - update 
        end
    elseif move == moves.up then
        newPos.y = newPos.y + 1
    elseif move == moves.down then
        newPos.y = newPos.y - 1
    else
        return false
    end
    return UpdatePos(newPos)
end

function SetPosDir(dir)
    pos = GetPos()
    pos.dir = dir
    UpdatePos(pos)
end

function PrintPos()
    pos = GetPos()
    print("X: ",pos.x)
    print("Y: ",pos.y)
    print("Z: ", pos.z)
    print("Dir: ",pos.dir)
    return true
end
 
function Forward()
    if turtle.forward() then
        return MovePos(moves.forward)
    else
        return false
    end
end
 
function Back()
    if turtle.back() then
        return MovePos(moves.backward)
    else
        return false
    end
end
 
function Up()
    if turtle.up() then
        return MovePos(moves.up)
    else
        return false
    end
end
 
function Down()
    if turtle.down() then
        return MovePos(moves.down)
    else
        return false
    end
end

function TurnTo(dir)
    currDir = GetPos().dir
    if currDir == dir then
        return true
    elseif currDir < 4 then
        local i = 0
        while (currDir + i) % 4 ~= dir do
            i = i + 1
        end
        if i > 2 then
            turtle.turnLeft()
            currDir = (currDir - 1) % 4
        else
            while currDir ~= dir do
                turtle.turnRight()
                currDir = (currDir + 1) % 4
            end
        end
        SetPosDir(currDir)
        return true
    end
end

function Left()
    TurnTo((GetPos().dir - 1) % 4)
end
 
function Right()
    turtle.turnRight()
end