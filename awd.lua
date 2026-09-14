local WORKER_URL = "https://getxziler.xzpmkill681.workers.dev"
local HttpService = game:GetService("HttpService")

local userKey = getgenv().license or "TEST_KEY"
local testUrl = string.format("%s/verify?key=%s&hwid=TEST_HWID_123", WORKER_URL, HttpService:UrlEncode(tostring(userKey)))

print("[DEBUG] กำลังส่ง Request ไปที่:", testUrl)

local success, response = pcall(function()
    return game:HttpGet(testUrl)
end)

if success then
    print("[DEBUG] เชื่อมต่อสำเร็จ! ผลลัพธ์จาก Worker:", response)
else
    warn("[DEBUG] เชื่อมต่อไม่สำเร็จ (Connection Failed):", response)
end
