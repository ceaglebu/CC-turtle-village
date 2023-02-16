--[[
    movement.lua
    2/14/22

    This header file introduces better movement functions that allow
    for a turtle's position and fuel level to be saved in temporary 
    files.
]]

------------
-- Config --
------------

stateFiles = {
    position = ".pos",
    fuel = ".fuel"
}

---------------
-- Constants --
---------------

directions = {
    north = 0, east = 1, south = 2, west = 3
}

moves = {
    forward = 1, backward = -1,
    up = 2, down = -2
}

-----------------
-- I/O Control --
-----------------

-- Writes a position to the position statefile
function UpdatePos(pos)
    local file = fs.open(stateFiles.position, "w")
    file.writeLine(string.format("%d %d %d %d", pos.x, pos.y, pos.z, pos.dir))
    file.close()
    return true
end

-- Retrieves turtle's current position from position statefile.
function GetPos()
    if not fs.exists(stateFiles.position) then
        print("Position file does not exist")
    end
    local file = fs.open(stateFiles.position, "r")
    local line = file.readLine()
    local pos = {}
    pos.x, pos.y, pos.z, pos.dir = line:match("(%S+) (%S+) (%S+) (%S+)")
    for k,v in pairs(pos) do
        pos[k] = tonumber(v)
    end 
    return pos
end

-- Updates the turtle's position based on the direction it moves.
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

function createPos(x, y, z, dir)
    local pos = {x=x, y=y, z=z, dir=dir}
    return pos
end

-- Redundant functions for easier access to individual position elements
function setPosX(x)
    local pos = GetPos()
    pos.x = x
    return UpdatePos(pos)
end

function setPosY(y)
    local pos = GetPos()
    pos.y = y
    return UpdatePos(pos)
end

function setPosZ(z)
    local pos = GetPos()
    pos.z = z
    return UpdatePos(pos)
end

function SetPosDir(dir)
    local pos = GetPos()
    pos.dir = dir
    return UpdatePos(pos)
end

-- Print the position for debugging purposes
function PrintPos()
    local pos = GetPos()
    print("X: ",pos.x)
    print("Y: ",pos.y)
    print("Z: ", pos.z)
    print("Dir: ",pos.dir)
    return true
end

--------------
-- Movement --
--------------

-- Makes the turtle turn to a specific direction and updates position file
function TurnTo(dir)
    local currDir = GetPos().dir
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
    else
        return false
    end
end

-- Turns the turtle left
function Left()
    return TurnTo((GetPos().dir - 1) % 4)
end

-- Turns the turtle right
function Right()
    return TurnTo((GetPos().dir + 1) % 4)
end

-- Turns the turtle around
function TurnAround()
    Left()
    return Left()
end

function Forward(ct)
    ct = ct or 1;
    for i = 1,ct do
        while not turtle.forward() do
            if not turtle.attack() then
                if not turtle.dig() then
                    return false
                end
            end
        end
        if not MovePos(moves.forward) then return false end
    end
    return true
end
 
function Back(ct)
    ct = ct or 1
    for i = 1,ct do
        if turtle.back() then
            if not MovePos(moves.backward) then return false end
        else
            TurnAround()
            if Forward() then TurnAround() else
                TurnAround()
                return false
            end
        end
    end
    return true
end
 
function Up(ct)
    ct = ct or 1
    for i = 1,ct do
        while not turtle.up() do
            if not turtle.digUp() then
                return false
            end
        end
        if not MovePos(moves.up) then return false end
    end
    
    return true
end
 
function Down(ct)
    ct = ct or 1
    for i = 1,ct do
        while not turtle.down() do
            if not turtle.digDown() then
                return false
            end
        end
        if not MovePos(moves.down) then return false end
    end
    return true
end

function MoveTo(pos)
    local currPos = GetPos()

    if currPos.x ~= pos.x then
        if currPos.x < pos.x then
            TurnTo(directions.east)
            Forward(pos.x - currPos.x)
        elseif currPos.x > pos.x then
            TurnTo(directions.west)
            Forward(currPos.x - pos.x)
        end
    end

    if currPos.z ~= pos.z then
        if currPos.z < pos.z then
            TurnTo(directions.south)
            Forward(pos.z - currPos.z)
        elseif currPos.z > pos.z then
            TurnTo(directions.north)
            Forward(currPos.z - pos.z)
        end
    end

    if currPos.y ~= pos.y then
        Up(pos.y - currPos.y)
        Down(currPos.y - pos.y)
    end

    TurnTo(pos.dir)
    return true
end

--[[ 
    Move relative to the turtle's position. Does not consider
     direction turtle is facing, just uses in game coords.
     Direction is not relative.
]]--
function MoveRelCoords(pos)
    pos.x = pos.x + GetPos().x
    pos.y = pos.y + GetPos().y
    pos.z = pos.z + GetPos().z
    return MoveTo(pos)
end

function MoveRelFacing(pos)
    local initDir = GetPos().dir
    
    if pos.x < 0 then
        Back(-pos.x)
    elseif pos.x > 0 then
        Forward(pos.x)
    end
    if pos.y > 0 then
        Up(pos.y)
    else
        Down(-pos.y)
    end
    if pos.z > 0 then
        Right()
        Forward(pos.z)
    elseif pos.z < 0 then
        Left()
        Forward(pos.z)
    end
    
    TurnTo((initDir + pos.dir) % 4)
end