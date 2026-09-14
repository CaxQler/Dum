local WORKER_URL = "https://xziler-api.xzpmkill681.workers.dev"
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local userKey = getgenv().license
if not userKey then
    LocalPlayer:Kick("[XZILER HUB]: No license provided!")
    return
end

local function getHWID()
    if syn and syn.get_hwid then
        return syn.get_hwid()
    elseif gethwid then
        return gethwid()
    elseif identifyexecutor then
        local name = identifyexecutor()
        return name .. "_" .. tostring(LocalPlayer.UserId)
    end
    return "UNKNOWN_" .. tostring(LocalPlayer.UserId)
end

local targetUrl = string.format("%s/verify?key=%s&hwid=%s", WORKER_URL, HttpService:UrlEncode(tostring(userKey)), HttpService:UrlEncode(getHWID()))

print("[XZILER DEBUG] กำลังเชื่อมต่อไปยัง:", targetUrl)

local success, response = pcall(function()
    return game:HttpGet(targetUrl)
end)

if not success then
    warn("[XZILER DEBUG] HttpGet Failed:", response)
    LocalPlayer:Kick("[XZILER HUB]: Connection error to verification server!")
    return
end

print("[XZILER DEBUG] ตอบกลับจาก Worker:", response)

local decodeSuccess, data = pcall(function()
    return HttpService:JSONDecode(response)
end)

if not decodeSuccess or type(data) ~= "table" or not data.success then
    local errReason = (data and data.msg) or "Invalid key or connection failed"
    LocalPlayer:Kick("[XZILER HUB] Access Denied: " .. tostring(errReason))
    return
end

print("[XZILER HUB] Access Granted! Loading Dumper...")

local runSuccess, runErr = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/CaxQler/Dum/refs/heads/main/Dumper-main.lua", true))()
end)

if not runSuccess then
    warn("[XZILER HUB] Failed to execute Dumper script: " .. tostring(runErr))
end
