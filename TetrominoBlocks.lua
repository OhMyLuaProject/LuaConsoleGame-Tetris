TetrominoDefine = TetrominoDefine or {
    O = {
        {1,1},
        {1,1}
    },
    L = {
        {1},
        {1},
        {1,1}
    },
    Z = {
        {1,1},
        {0,1,1}
    },
    S = {
        {0,1,1},
        {1,1,}
    },
    I ={
        {1},
        {1},
        {1},
        {1}
    },
    T = {
        {1,1,1},
        {0,1,},
        {0,1,},
    }
}

local function trimAndFillTetrominoBlocks(blocks)
    local fill = function ()
        for i=1,4 do
            for x=1,4 do
                blocks[i] = blocks[i] or {}
                blocks[i][x] = blocks[i][x] or 0
            end
        end
    end

    fill()

    local loop = true

    while loop do
        loop = false
        if (function() -- 判断这一行是否全空可以删除
            for w=1,4 do
                if blocks[1] and blocks[1][w] ~= 0 then
                    return false
                end
            end
            return true
        end)() then
            loop = true
            for y=1,4 do
                blocks[y] = blocks[y+1]
            end
        end
    end

    --试着按列删了

    loop = true
    while loop do
        loop = false
        if (function() -- 判断这一行是否全空可以删除
            for w=1,4 do
                if blocks[w] and blocks[w][1] ~= 0 then
                    return false
                end
            end
            return true
        end)() then
        loop = true
            for t=1,4 do
                for l=1,4 do
                    local row = blocks[t]
                    if row then
                        row[l] = row[l+1]
                    end
                end
            end
        end
    end

    fill(blocks)
end

--fill 0 into 4x4 area for tetrimino blocks define.
for k,v in pairs(TetrominoDefine) do
    trimAndFillTetrominoBlocks(v)
end

local function clone(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local newObject = {}
        lookup_table[object] = newObject
        for key, value in pairs(object) do
            newObject[_copy(key)] = _copy(value)
        end
        return setmetatable(newObject, getmetatable(object))
    end
    return _copy(object)
end

function createTetromino(shape)
    local def = TetrominoDefine[shape:upper()]
    local newShape = clone(def)

    function newShape:enumBlocksPosition()
        local r=self
        return coroutine.wrap(function ()
            for i=1,4 do
                for p=1,4 do
                    if r[i][p] == 1 then
                        coroutine.yield(p,i)
                    end
                end
            end
        end)
    end

    function newShape:printTetromino()
        print("-----------")
        for x=1,4 do
            print((table.concat(self[x], " "):gsub("0"," ")))
        end
        print("-----------")
    end

    function newShape:rotateBlocks()
        local function get(i) return i + 1 end

        local newBlocks = clone(self)

        local N = 4
        for i=0,(N/2) do
            for j=i,(N-2-i) do
                 local temp = newBlocks[get(i)][get(j)]
                 newBlocks[get(i)][get(j)] = newBlocks[get(N - 1 - j)][get(i)]
                 newBlocks[get(N - 1 - j)][get(i)] = newBlocks[get(N - 1 - i)][get(N - 1 - j)]
                 newBlocks[get(N - 1 - i)][get(N - 1 - j)] = newBlocks[get(j)][get(N - 1 - i)]
                 newBlocks[get(j)][get(N - 1 - i)] = temp
            end
        end

        trimAndFillTetrominoBlocks(newBlocks)
        return newBlocks
    end

    return newShape
end


local tBlock = createTetromino("S")
tBlock:printTetromino()
local newBlock = tBlock:rotateBlocks()
newBlock:printTetromino()