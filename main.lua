require "TetrominoBlocks"

local tetrominoLayout = {}
local setCurrentTetrominoPosition = nil

local width = 10
local height = 20

--init layout
for i=1,height do
    tetrominoLayout[i] = {}
    for x=1,width do
        tetrominoLayout[i][x] = 0
    end
end

local inputKey = " "

local currentTetromino --[[ = {
    shape = nil,
    displayChar = "O",
    x = 0,
    y = 0
}
--]]

local function createRamdomTetromino()
    local function enumKeys(hashtable)
        local keys = {}
        for k, v in pairs(hashtable) do
            keys[#keys + 1] = k
        end
        return keys
    end

    local keys = enumKeys(TetrominoDefine)

    --为啥random第一次就重复一个？
    math.randomseed(os.time())
    local idx
    for i=1,1000 do
        idx = math.random(#keys)
    end

    local shapeName = keys[idx]

    local shape = createTetromino(shapeName)
    for i=1,math.random(5) do
        shape = shape:rotateBlocks()
    end

    local newTetromino = { 
        shape = shape,
        displayChar = shapeName , 
        x = width / 2,
        y = 0
    }

    print("create "..shapeName.." tetromino")

    return newTetromino
end

--[[
    @desc: 检查物件是否还在游戏区域范围内
    author:{author}
    time:2020-04-24 17:53:28
    @return: true表示物件完全在范围内
]]
local function checkCurrentTetrominoInBounds(x,y)
    local function checkMovable(x,y)
         local dunny = {}
         local able = ((tetrominoLayout[y] or dunny)[x] or dunny) == 0
        if not able then
            print(string.format("(%d,%d) isnt avaliable",x,y))
        end
         return able
    end
 
    local shape = currentTetromino.shape

    x = x or currentTetromino.x
    y = y or currentTetromino.y

    local function checkBound(x,y)
        for rx,ry in shape:enumBlocksPosition() do
            local realX = x + rx
            local realY = y + ry
    
            if not checkMovable(realX,realY) then
                return false
            end
        end
    
        return true
    end

    return checkBound(x ,y)
end

--[[
    @desc: 判断当前的下落方块是否还能继续下落
    author:{author}
    time:2020-04-24 17:45:33
    @return: true为可以下落(没到底或没碰到其他方块)
]]
local function checkCurrentTetrominoDownable()
    local x = currentTetromino.x
    local y = currentTetromino.y + 1 --提前向下一格看看有没有冲突，没有就是可以下的
    
    return checkCurrentTetrominoInBounds(x,y)
end
 
 local function makeTetrominoDownOnce()
    setCurrentTetrominoPosition(nil,currentTetromino.y + 1) 
 end
 

local function tryMoveXTetromino(offsetX)
    local x = currentTetromino.x + offsetX
    local y = currentTetromino.y
   
    if checkCurrentTetrominoInBounds(x,y) then 
        setCurrentTetrominoPosition(x,nil) 
    end
end

function setCurrentTetrominoPosition(x,y)
    x = x or currentTetromino.x
    y = y or currentTetromino.y

    currentTetromino.x = x
    currentTetromino.y = y
end

local function tryMoveDownTetromino(min,max)
    --二分
    min = min or currentTetromino.y
    max = max or height

    local mid = ((max - min)/2 + min)

    if (min - mid) == 0 then
        return
    end

    local y = mid

    if checkCurrentTetrominoInBounds(currentTetromino.x,y) then
        setCurrentTetrominoPosition(nil,y) 
        min = y
    else
        --既然这里动不了，那在下面也一样
        max = y
    end

    tryMoveDownTetromino(min,max)
end

local function tryRotateTetromino()
    local function rotate(tiems)
        for i=1,(times or 1) do
            local rotatedBlocks = currentTetromino.shape:rotateBlocks()
            currentTetromino.shape = rotatedBlocks
        end
    end

    rotate()
    if not checkCurrentTetrominoInBounds(currentTetromino.x,currentTetromino.y) then
        --滚回去
        print("rotate back")
        rotate(4)
    end
end

local requestMove = false

local function processPlayerInput()
    print("please input one key of {q,a,s,d,r}")
    key = io.read()
    requestMove = true

    if key == "q" then
        Exit = true
        requestMove = false
    elseif key == "a" then
        tryMoveXTetromino(-1) 
    elseif key == "d" then
        tryMoveXTetromino(1) 
    elseif key == "s" then
        requestMove = false
        tryMoveDownTetromino()
    elseif key == "r" then
        tryRotateTetromino()
        requestMove = false
    end
end

function printCurrentTetromino(x,y,ch)
    for rx,ry in currentTetromino.shape:enumBlocksPosition() do
        local row = tetrominoLayout[(ry+y)]
        if row then
            row[(rx+x)] = ch
        end
    end
end

local function printLayout()
    printCurrentTetromino(currentTetromino.x,currentTetromino.y,currentTetromino.displayChar)

    --print layout
    print("---------------------")
    for y=1,height do
        local row = tetrominoLayout[y]
        print("|" .. (table.concat(row, " "):gsub("0"," ")) .. "|")
    end
    print("---------------------")
    
    printCurrentTetromino(currentTetromino.x,currentTetromino.y,0)
end

local function checkAndCleanBottomRow()
    local function cleanLine(y)
        for i=y,1,-1 do
            tetrominoLayout[i]=tetrominoLayout[i-1] or (function ()
                local o = {}
                for x=1,width do
                    o[x] = 0
                end
                return o
            end)()
        end
    end

    for y=1,height do
        if (function()
            for x=1,width do
                if tetrominoLayout[y][x] == 0 then
                    return false
                end
            end
            return true
        end)() then
            print("clean line"..y)
            cleanLine(y)
        end
    end
end

local function pinCurrentTetromino()
    printCurrentTetromino(currentTetromino.x,currentTetromino.y,currentTetromino.displayChar)
end

while not Exit do
    currentTetromino = currentTetromino or createRamdomTetromino()

    local skip = false
    --check condition to failed or create new one to fall
    if not checkCurrentTetrominoDownable() then
        if currentTetromino.y == 0 then
            print("BOOM!")
            break
        else
            pinCurrentTetromino()
            currentTetromino = nil
        end
        skip = true
    end

    if not skip then
        checkAndCleanBottomRow()

        processPlayerInput()
        
        if requestMove then
            makeTetrominoDownOnce()
        end

        os.execute("cls")
        printLayout()
    end
end

print("886")