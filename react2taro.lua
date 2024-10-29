local rex = require "rex_pcre"
local checkFileExtensionAndContinue = require("checkFileExtensionAndContinue")

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
            return math.ceil(num * 2) .. "px"
        end)
    else
        content = rex.gsub(content, "<div(?!\\w)", "<View")
        content = rex.gsub(content, '</div>', '</View>')
        content = rex.gsub(content, "<span(?!\\w)", "<Text")
        content = content:gsub("</span>", "</Text>")
        content = rex.gsub(content, "<img(?!\\w)", "<Image")
        content = content:gsub("</img>", "</Image>")
    end

    local outputPath = "taro_" .. path

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
    local ext = checkFileExtensionAndContinue(v)
    if not ext then
        print(v .. " - Skipping...")
        break -- 不再处理其他文件
    end
    OpenFile(v, ext)

    print(string.format("\27[32m成功转换文件: %s\27[0m", v))
end
