local rex = require "rex_pcre"

local function checkFileExtensionAndContinue(filename)
    local extension = filename:match("%.([^%.]+)$") -- 获取文件名的后缀
    if extension ~= "tsx" and extension ~= "less" and extension ~= "scss" then
        print("\27[31m仅支持tsx,less,scss格式文件转换\27[0m")
        return false                                -- 返回 false 表示不继续处理
    end
    OpenFile(filename, extension)
    return true -- 返回 true 表示继续处理
end

function OpenFile(path, ext)
    local file = io.open(path, "r")
    if not file then
        error("Unable to open file: " .. path)
    end

    -- 读取文件所有内容
    local content = file:read("*a")
    file:close()
    if ext ~= "tsx" then
        content = rex.gsub(content, "(\\d+px)", function(m)
            local num = m:match("%d+")
            return math.ceil(num / 2) .. "px"
        end)
    else
        content = rex.gsub(content, "(<View|<ScrollView)(?!\\w)", "<div")
        content = rex.gsub(content, '</View>|</ScrollView>', '</div>')
        content = rex.gsub(content, "<Image(?!\\w)", "<img")
        content = content:gsub("</Image>", "</img>")
    end

    local outputPath = "react_" .. path

    file, err = io.open(outputPath, "w")
    if not file then
        error("Unable to open file for writing: " .. err)
    end

    -- 写入替换后的内容
    file:write(content)
    file:close()
    -- print('fileContent:', content)
end

for i, v in ipairs(arg) do
    if not checkFileExtensionAndContinue(v) then
        print(v .. " - Skipping...")
        break -- 不再处理其他文件
    end
    print(string.format("\27[32m成功转换文件: %s\27[0m", v))
end
