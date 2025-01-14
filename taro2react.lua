#!/opt/homebrew/bin/lua

local rex = require "rex_pcre"
local scriptPath = debug.getinfo(1, "S").source:sub(2)
local scriptDir = scriptPath:match("(.*/)")
package.path = scriptDir .. "?.lua;" .. package.path
local isDesktop = false
local checkFileExtensionAndContinue = require("checkFileExtensionAndContinue")
local handleArg = require("handleArg")

function OsDesktopPath()
    -- 获取操作系统类型
    local osType = package.config:sub(1, 1)

    -- 根据操作系统类型拼接桌面路径
    local desktopPath
    if osType == "\\" then
        -- Windows系统
        desktopPath = os.getenv("USERPROFILE") .. "\\Desktop"
    else
        -- macOS或Linux系统
        desktopPath = os.getenv("HOME") .. "/Desktop"
    end
    return desktopPath
end

function convert_filename(filename)
    -- 检查文件名是否包含 /dir/ 前缀，不管前面有多少层目录
    if filename:match("^.*/") then
        -- 如果有 /dir/，将 /dir/ 后的文件名加上 react_ 前缀
        return filename:gsub("(.*/)(.+)", "%1react_%2")
    else
        -- 如果没有 /dir/，直接在文件名前加上 react_
        return "react_" .. filename
    end
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
        content = content:gsub("Notify%.open%({[^}]-color:%s*[^}]-message:%s*\"(.-)\"%}",
            "Notify.show({ type: \"warning\", message: \"%1\" })")
    end

    local newPath = rex.gsub(path, ".scss", ".less")
    -- local path, filename, extension = newPath:match("(.*/)(.-)%.([^%.]+)$")
    local filename, extension = newPath:match("([^/]+)%.([^/]+)")
    local outputPath = convert_filename(newPath)
    if isDesktop then
        outputPath = OsDesktopPath() .. "/react_" .. filename .. "." .. extension
    end

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
    local res = handleArg(v)
    if res.outPutDesktop then
        isDesktop = true
    end
end
for i, v in ipairs(arg) do
    local res = handleArg(v)
    if res.isOpt then
        break
    end
    local ext = checkFileExtensionAndContinue(v)
    if not ext then
        print(v .. " - Skipping...")
        break -- 不再处理其他文件
    end
    OpenFile(v, ext)

    print(string.format("\27[32m成功转换文件: %s\27[0m", v))
end
