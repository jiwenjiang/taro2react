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
        content = rex.gsub(content, "(\\d+(px|rpx))", function(m)
            local num = m:match("%d+")
            return math.ceil(num / 2) .. "px"
        end)
        content = rex.gsub(content, "(\\d+(PX))", function(m)
            local num = m:match("%d+")
            return math.ceil(num) .. "px"
        end)
    else
        if string.find(content, 'useRouter') then
            content = rex.gsub(content, "const router = useRouter", "const navigate = useNavigate")
            content = 'import { useNavigate } from "react-router-dom";' .. "\n" .. content
            content = content:gsub("navigateTo%({[^}]-%s*url: [`\"]([^`\"]-)[`\"][^}]-%}%)", "navigate(`%1`)")
            content = content:gsub("router.params.", "")
        end
        content = rex.gsub(content, "(<View|<ScrollView)(?!\\w)", "<div")
        content = rex.gsub(content, '</View>|</ScrollView>', '</div>')
        content = rex.gsub(content, "<Text(?!\\w)", "<span")
        content = content:gsub("</Text>", "</span>")
        content = rex.gsub(content, "<Image(?!\\w)", "<img")
        content = content:gsub("</Image>", "</img>")
        content = content:gsub(".scss", ".less")
        content = content:gsub("Notify%.open%({[^}]-color:%s*\"warning\"[^}]-message:%s*\"(.-)\"%}",
            "Notify.show({ type: \"warning\", message: \"%1\" })")
    end

    local newPath = rex.gsub(path, ".scss", ".less")
    local outputPath = "react_" .. newPath

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
