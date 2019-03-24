-- ** Configuration **
local subliminalPath = "/usr/bin/subliminal"
local subDownloadDirPath = "/tmp/mpv-auto-sub/"
local subLanguage = "tr"
local autoLoadDownloadedSub = true
-- ** Configuration **

local utils = require 'mp.utils'

local vidName
local vidPath
local subPath

function prepare()
    vidName = mp.get_property('filename')
    vidPath = mp.get_property('path')
    subPath = subDownloadDirPath .. string.gsub(vidName, "%.%w+$", ".srt")
    
    if not exists(subDownloadDirPath) then
        os.execute("mkdir " .. subDownloadDirPath)
    else
        if (autoLoadDownloadedSub and exists(subPath)) then
            load_subtitle(subPath)
	end
    end
end

function run()
    mp.osd_message("Fetching subtitle")
    local p = utils.subprocess({ args = {subliminalPath, "download", "-s", "-f", "-l", subLanguage, "-d", subDownloadDirPath, vidPath}})
    if p.error == nil then
        if load_subtitle(subPath) then
            mp.osd_message("Subtitle successfully loaded")
        else
            mp.osd_message("Subtitle couldn't load")
        end
        load_subtitle(subPath)
    else
        mp.osd_message("Subtitle couldn't fetch")
    end
end

function load_subtitle(path)
    return mp.commandv("sub_add", path)
end

function exists(file)
    local ok, err, code = os.rename(file, file)
    if not ok then
        if code == 13 then
            return true
        end
    end
    return ok, err
end

mp.register_event("file-loaded", prepare)
mp.add_key_binding('b', 'run_auto_sub', run)
