-- KOReader plugin to add all ebooks found on device to onw own collection called "All eBooks"
require "defaults"
package.path = "common/?.lua;frontend/?.lua;" .. package.path
package.cpath = "common/?.so;common/?.dll;/usr/lib/lua/?.so;" .. package.cpath

local Dispatcher = require("dispatcher")  -- luacheck:ignore
local InfoMessage = require("ui/widget/infomessage")
local UIManager = require("ui/uimanager")
local WidgetContainer = require("ui/widget/container/widgetcontainer")
local _ = require("gettext")
local LuaSettings = require("luasettings")
local ffiUtil = require("ffi/util")
local lfs = require("libs/libkoreader-lfs")
local logger = require("logger")
local util = require("util")
local DataStorage = require("datastorage")
local ReadCollection = require("readcollection")
local FileManagerCollection = require("apps/filemanager/filemanagercollection")

if G_reader_settings == nil then
    G_reader_settings = require("luasettings"):open(
        DataStorage:getDataDir().."/settings.reader.lua")
end

-- Get the base ebooks folder on the ereader to start the search for ebooks
local ebooks_directory_path = G_reader_settings:readSetting("home_dir")
if ebooks_directory_path == nil then
    ebooks_directory_path = '.'
end

-- Get the Koreader base folder on the ereader where the settings are stored
local koreader_settings_directory_path = DataStorage:getFullDataDir()

-- Get the Koreader file on the ereader where the settings are stored for collections
local collection_file = DataStorage:getSettingsDir() .. "/collection.lua"

local ReadCollection = {
    coll = nil, -- hash table
    coll_settings = nil, -- hash table
    last_read_time = 0,
    default_collection_name = "favorites",
}

-- read, write

local function buildEntry(file, order, attr)
    file = ffiUtil.realpath(file)
    if file then
        attr = attr or lfs.attributes(file)
        if attr and attr.mode == "file" then
            return {
                file  = file,
                text  = file:gsub(".*/", ""),
                order = order,
                attr  = attr,
            }
        end
    end
end

function ReadCollection:_read()
    local collection_file_modification_time = lfs.attributes(collection_file, "modification")
    if collection_file_modification_time then
        if collection_file_modification_time <= self.last_read_time then return end
        self.last_read_time = collection_file_modification_time
    end
    local collections = LuaSettings:open(collection_file)
    if collections:hasNot(self.default_collection_name) then
        collections:saveSetting(self.default_collection_name, {})
    end
    logger.dbg("ReadCollection: reading from collection file")
    self.coll = {}
    self.coll_settings = {}
    for coll_name, collection in pairs(collections.data) do
        local coll = {}
        for _, v in ipairs(collection) do
            local item = buildEntry(v.file, v.order)
            if item then -- exclude deleted files
                coll[item.file] = item
            end
        end
        self.coll[coll_name] = coll
        self.coll_settings[coll_name] = collection.settings or { order = 1 } -- favorites, first run
    end
end

function ReadCollection:write(updated_collections)
    local collections = LuaSettings:open(collection_file)
    for coll_name in pairs(collections.data) do
        if not self.coll[coll_name] then
           collections:delSetting(coll_name)
        end
    end
    for coll_name, coll in pairs(self.coll) do
        if updated_collections == nil or updated_collections[1] or updated_collections[coll_name] then
            local is_manual_collate = not self.coll_settings[coll_name].collate or nil
            local data = { settings = self.coll_settings[coll_name] }
            for _, item in pairs(coll) do
                table.insert(data, { file = item.file, order = is_manual_collate and item.order })
            end
            collections:saveSetting(coll_name, data)
        end
    end
    logger.dbg("ReadCollection: writing to collection file")
    collections:flush()
end

-- info

function ReadCollection:isFileInCollection(file, collection_name)
    file = ffiUtil.realpath(file) or file
    return self.coll[collection_name][file] and true or false
end

function ReadCollection:getCollectionNextOrder(collection_name)
    if self.coll_settings[collection_name].collate then return end
    local max_order = 0
    for _, item in pairs(self.coll[collection_name]) do
        if max_order < item.order then
            max_order = item.order
        end
    end
    return max_order + 1
end

-- manage items

function ReadCollection:addItem(file, collection_name)
    local item = buildEntry(file, self:getCollectionNextOrder(collection_name))
    self.coll[collection_name][item.file] = item
end

-- manage collections

function ReadCollection:addCollection(coll_name)
    local max_order = 0
    for _, settings in pairs(self.coll_settings) do
        if max_order < settings.order then
            max_order = settings.order
        end
    end
    self.coll_settings[coll_name] = { order = max_order + 1 }
    self.coll[coll_name] = {}
end


local AllMyeBooks = WidgetContainer:extend{
    name = "All eBooks",
    is_doc_only = false,
}


function start(ebooks_directory_path)
    local files = scandir(ebooks_directory_path)
    local collection_name = "All eBooks"
    ReadCollection:_read()
    ReadCollection:addCollection(collection_name)
    
    if #files > 0 then
       add_ebooks_to_collection(files, collection_name)
    end
end

function scandir(directory)
    local i, t, popen = 0, {}, io.popen
  --  local pfile = popen('find  "'..directory..'"   -maxdepth 5 -type f  -name "*.epub" -o -name "*.pdf" -not | sort ') --  on windows
    local pfile = popen('find "'..directory..'" -maxdepth 10 -type f  -name "*.epub" -o -name "*.pdf" -o -name "*.azw3" -o -name "*.mobi" -o -name "*.docx"  | sort ') -- on linux
    for filename in pfile:lines() do
        i = i + 1
            t[i] = filename   
    end
    pfile:close()
    return t
end

function add_ebooks_to_collection(files, collection_name) 
    local count
    count = 0
    for _, file in ipairs(files) do
        ReadCollection:addItem(file, collection_name)   
    end
    ReadCollection:write({collection_name})
end


function AllMyeBooks:onDispatcherRegisterActions()
    Dispatcher:registerAction("AllMyeBooks_action", {category="none", event="AllMyeBooks", title=_("Create AllMyeBooks collection"), general=true,})
end

function AllMyeBooks:init()
    self:onDispatcherRegisterActions()
    self.ui.menu:registerToMainMenu(self)
end

function AllMyeBooks:addToMainMenu(menu_items)
    menu_items.AllMyeBooks = {
        text = _("All eBooks Collection"),
        -- following will add the menu as NEW under the folder icon when activated sorting_hint must be commented
        --sub_item_table = {
        --    {         
        --        text = _("Create Collection"),
        --        keep_menu_open = true,   
                
        -- in which menu this should be appended
        sorting_hint = "more_tools",
        -- a callback when tapping
        callback = function()
        
        UIManager:show(InfoMessage:new{
                text = _("Busy to create 'All eBooks' Collection...please wait till ready info appears."),
                timeout=5,
            })
        start(ebooks_directory_path)
        UIManager:show(InfoMessage:new{
                text = _("Collection 'All eBooks' is ready. This will take effect on next restart."),
                timeout=9,
            })        
        end,
        
       -- },  -- when sorting_hint is used this must be commented
       -- }   -- when sorting_hint is used this must be commented

    }
end

function AllMyeBooks:onAllMyeBooks()
    local popup = InfoMessage:new{
      text = _("Busy to create 'All eBooks' Collection...please wait till ready info appears."),
      timeout=5,
    }
    UIManager:show(popup)
    start(ebooks_directory_path)
    local popup = InfoMessage:new{
      text = _("Collection 'All eBooks' is ready. This will take effect on next restart."),
      timeout=9,
    }
    UIManager:show(popup)


end

return AllMyeBooks
