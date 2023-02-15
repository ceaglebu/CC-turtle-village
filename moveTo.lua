require("hTest")

print("x: ")
toX = tonumber(read())
print("y: ")
toY = tonumber(read())
print("z: ")
toZ = tonumber(read())
print("Direction (north, south, east, west): ")
toDir = read()

MoveTo(createPos(toX, toY, toZ, directions.toDir))