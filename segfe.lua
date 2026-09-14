local WORKER_API = "https://xziler-api.xzpmkill681.workers.dev"
local WORKER_GENERATOR = "https://getxziler.xzpmkill681.workers.dev" 
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 1. ดึง HWID
local function getHWID()
    if syn and syn.get_hwid then return syn.get_hwid()
    elseif gethwid then return gethwid()
    elseif identifyexecutor then return identifyexecutor() .. "_" .. tostring(LocalPlayer.UserId)
    end
    return "UNKNOWN_" .. tostring(LocalPlayer.UserId)
end

local hwid = getHWID()

-- 2. ดึงคีย์จาก getxziler (หมายเหตุ: Worker getxziler ต้องมี Endpoint ที่ return JSON เช่น {"key": "XYZ-123"} กลับมา)
-- ถ้าเว็บ getxziler เป็น HTML ล้วนๆ การดึงคีย์จะทำได้ยากและไม่เสถียร
local success, response = pcall(function()
    return game:HttpGet(WORKER_GENERATOR .. "/api/generate?hwid=" .. HttpService:UrlEncode(hwid))
end)

if not success then
    LocalPlayer:Kick("[XZILER HUB]: Cannot fetch key from generator!")
    return
end

local decodeSuccess, data = pcall(function() return HttpService:JSONDecode(response) end)
local userKey = data and data.key -- ปรับตามโครงสร้าง JSON ที่ getxziler ส่งกลับมาจริงๆ

if not userKey then
    LocalPlayer:Kick("[XZILER HUB]: Failed to get a valid key from generator!")
    return
end

print("[XZILER DEBUG] Fetched Key:", userKey)

-- 3. เอาคีย์ที่ได้ไป Verify ที่ xziler-api
local verifyUrl = string.format("%s/verify?key=%s&hwid=%s", WORKER_API, HttpService:UrlEncode(tostring(userKey)), HttpService:UrlEncode(hwid))
local vSuccess, vResponse = pcall(function() return game:HttpGet(verifyUrl) end)

if not vSuccess then
    LocalPlayer:Kick("[XZILER HUB]: Connection error to verification server!")
    return
end

local vDecodeSuccess, vData = pcall(function() return HttpService:JSONDecode(vResponse) end)

if not vDecodeSuccess or type(vData) ~= "table" or not vData.success then
    local errReason = (vData and vData.msg) or "Invalid key or connection failed"
    LocalPlayer:Kick("[XZILER HUB] Access Denied: " .. tostring(errReason))
    return
end

print("[XZILER HUB] Access Granted! Loading Dumper...")
loadstring(game:HttpGet("https://raw.githubusercontent.com/CaxQler/Dum/refs/heads/main/Dum-main.lua", true))()
