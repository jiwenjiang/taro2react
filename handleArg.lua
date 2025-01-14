#!/opt/homebrew/bin/lua

local function contains(str, pattern)
    return string.find(str, pattern)
end

local handleArg = function(arg)
    if contains(arg, '-') or contains(arg, '-\\-') then
        local outPutDesktop = false
        if arg == '--help' or arg == '-h' then
            print('--desktop / -d', 'transform files genarate to desktop')
            print([[taro2react xx.tsx xx.scss
defalut genarate file in same dir with input file
        ]])
        end
        if arg == '--desktop' or arg == '-d' then
            outPutDesktop = true
        end
        return { isOpt = true, outPutDesktop = outPutDesktop }
    end
    return { isOpt = false, outPutDesktop = false }
end

return handleArg
