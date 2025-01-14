#!/opt/homebrew/bin/lua

local checkFileExtensionAndContinue = function(filename)
    local extension = filename:match("%.([^%.]+)$") -- 获取文件名的后缀
    if extension ~= "tsx" and extension ~= "less" and extension ~= "scss" then
        print("\27[31m仅支持tsx,less,scss格式文件转换\27[0m")
        return false -- 返回 false 表示不继续处理
    end
    -- OpenFile(filename, extension)
    return extension 
end


return checkFileExtensionAndContinue
