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

function createTetromino(shape)
    local newShape = {}

    function newShape:enumBlocksPosition()
        return coroutine.wrap(function ()
            for i=1,4 do
                for p=1,4 do
                    if newShape[i][p] == 1 then
                        coroutine.yield(i,p)
                    end
                end
            end
        end)
    end

    for k,v in pairs(TetrominoDefine[shape:upper()]) do
        newShape[k] = v;
    end

    for i=1,4 do
        for p=1,4 do
            newShape[i] = newShape[i] or {}
            newShape[i][p] = newShape[i][p] or 0
        end
    end

    return newShape
end

function printTetromino(tetromino)
    print("-----------")
    for x=1,4 do
        print((table.concat(tetromino[x], " "):gsub("0"," ")))
    end
    print("-----------")
end