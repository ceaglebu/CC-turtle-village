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

function Forward()
    while not turtle.forward() do
        if not turtle.attack() then
            if not turtle.dig() then
                return false
            end
        end
    end

    return MovePos(moves.forward)
end
 
function Back()
    if turtle.back() then
        return MovePos(moves.backward)
    else
        TurnAround()
        if Forward() then TurnAround() else
            TurnAround()
            return false
        end
    end
end
 
function Up()
    while not turtle.up() do
        if not turtle.digUp() then
            return false
        end
    end
    return MovePos(moves.up)
end
 
function Down()
    while not turtle.down() do
        if not turtle.digDown() then
            return false
        end
    end
    return MovePos(moves.down)
end

function MoveTo(pos)
    local currPos = GetPos()

    if currPos.x ~= pos.x then
        if currPos.x < pos.x then
            TurnTo(directions.east)
        elseif currPos.x > pos.x then
            TurnTo(directions.west)
        end
        while GetPos().x ~= pos.x do
            Forward()
        end
    end

    if currPos.z ~= pos.z then
        if currPos.z < pos.z then
            TurnTo(directions.south)
        elseif currPos.z > pos.z then
            TurnTo(directions.north)
        end
        while GetPos().z ~= pos.z do
            Forward()
        end
    end

    if currPos.y ~= pos.y then
        while GetPos().y < pos.y do
            Up()
        end
        while GetPos().y > pos.y do
            Down()
        end
    end

    TurnTo(pos.dir)
    return true
end

function MoveRel(pos)
    for k,v in pairs(pos) do
        pos[k] = pos[k] + GetPos()[k]
    end
    
    pos.dir = pos.dir % 4
    return MoveTo(pos)
end