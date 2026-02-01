  -- BH OP FINDER - FINAL MERGED (DELTA SAFE, NO OLD LOGS)

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local PLACE_ID = game.PlaceId

--------------------------------------------------
-- CONFIG
--------------------------------------------------
local LISTENER_URL = "https://deeznutz.pythonanywhere.com/latest"
local REFRESH_TIME = 2
local MAX_JOIN_RETRIES = 30

local AutoJoin = false
local seenServers = {}
local firstFetch = true -- ignore old logs

--------------------------------------------------
-- GUI
--------------------------------------------------
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.fromOffset(300,260)
main.Position = UDim2.fromScale(0.35,0.25)
main.BackgroundColor3 = Color3.fromRGB(20,20,20)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main)

local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.new(255,255,255)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,34)
title.BackgroundTransparency = 1
title.Text = "RECENT LOGS"
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextColor3 = Color3.new(1,1,1)

--------------------------------------------------
-- AUTO JOIN BUTTON
--------------------------------------------------
local autoBtn = Instance.new("TextButton", main)
autoBtn.Size = UDim2.fromOffset(90,26)
autoBtn.Position = UDim2.fromOffset(200,4)
autoBtn.Text = "AUTO: OFF"
autoBtn.Font = Enum.Font.GothamBold
autoBtn.TextSize = 12
autoBtn.TextColor3 = Color3.new(1,1,1)
autoBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
Instance.new("UICorner", autoBtn)

autoBtn.MouseButton1Click:Connect(function()
    AutoJoin = not AutoJoin
    autoBtn.Text = AutoJoin and "AUTO: ON" or "AUTO: OFF"
    autoBtn.BackgroundColor3 = AutoJoin and Color3.fromRGB(0,180,120) or Color3.fromRGB(40,40,40)
end)

--------------------------------------------------
-- LIST
--------------------------------------------------
local list = Instance.new("ScrollingFrame", main)
list.Position = UDim2.new(0,6,0,38)
list.Size = UDim2.new(1,-12,1,-44)
list.ScrollBarThickness = 4
list.BackgroundTransparency = 1
list.CanvasSize = UDim2.new(0,0,0,0)

local layout = Instance.new("UIListLayout", list)
layout.Padding = UDim.new(0,6)

--------------------------------------------------
-- TOGGLE UI
--------------------------------------------------
local toggleGui = Instance.new("ScreenGui", player.PlayerGui)

local toggleBtn = Instance.new("TextButton", toggleGui)
toggleBtn.Size = UDim2.fromOffset(90,32)
toggleBtn.Position = UDim2.fromOffset(25,25)
toggleBtn.Text = "OPEN"
toggleBtn.BackgroundColor3 = Color3.fromRGB(0,120,255)
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 13
Instance.new("UICorner", toggleBtn)
toggleBtn.Active = true
toggleBtn.Draggable = true

toggleBtn.MouseButton1Click:Connect(function()
    main.Visible = not main.Visible
end)

--------------------------------------------------
-- JOIN FUNCTION
--------------------------------------------------
local function tryJoin(jobId)
    task.spawn(function()
        for i=1,MAX_JOIN_RETRIES do
            pcall(function()
                TeleportService:TeleportToPlaceInstance(PLACE_ID, jobId, player)
            end)
            task.wait(0.2)
        end
    end)
end

--------------------------------------------------
-- ADD ROW
--------------------------------------------------
local function addRow(name, ms, jobId)
    if seenServers[jobId] then return end
    seenServers[jobId] = true

    -- SOUND
    local ping = Instance.new("Sound", workspace)
    ping.SoundId = "rbxassetid://9118823101"
    ping.Volume = 2
    ping.Looped = false
    ping:Play()
    task.delay(1.5,function() ping:Stop() end)

    local row = Instance.new("Frame")
    row.Size = UDim2.fromOffset(270,50)
    row.BackgroundColor3 = Color3.fromRGB(30,30,30)
    row.Parent = list
    Instance.new("UICorner", row)

    local nameLbl = Instance.new("TextLabel", row)
    nameLbl.Position = UDim2.fromOffset(8,4)
    nameLbl.Size = UDim2.new(0.6,0,0.5,0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = name
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextSize = 14
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.TextColor3 = Color3.new(1,1,1)

    local msLbl = Instance.new("TextLabel", row)
    msLbl.Position = UDim2.fromOffset(8,28)
    msLbl.Size = UDim2.new(0.6,0,0.4,0)
    msLbl.BackgroundTransparency = 1
    msLbl.Text = ms
    msLbl.Font = Enum.Font.Gotham
    msLbl.TextSize = 12
    msLbl.TextXAlignment = Enum.TextXAlignment.Left
    msLbl.TextColor3 = Color3.fromRGB(0,255,0)

    local joinBtn = Instance.new("TextButton")
    joinBtn.Parent = row
    joinBtn.Size = UDim2.fromOffset(60,28)
    joinBtn.Position = UDim2.fromOffset(200,11)
    joinBtn.Text = "JOIN"
    joinBtn.Font = Enum.Font.GothamBold
    joinBtn.TextSize = 12
    joinBtn.TextColor3 = Color3.new(1,1,1)
    joinBtn.BackgroundColor3 = Color3.fromRGB(0,140,255)
    Instance.new("UICorner", joinBtn)

    joinBtn.MouseButton1Click:Connect(function()
        tryJoin(jobId)
    end)

    if AutoJoin then
        tryJoin(jobId)
    end

    list.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 6)
end

--------------------------------------------------
-- FETCH LOOP (DELTA SAFE)
--------------------------------------------------
task.spawn(function()
    while true do
        local ok,res = pcall(function()
            local req = syn and syn.request or http_request or request
            return req({Url=LISTENER_URL,Method="GET"}).Body
        end)

        if ok and res then
            local data = HttpService:JSONDecode(res)

            if data.embeds then
                for _, embed in ipairs(data.embeds) do
                    local desc = embed.description:gsub("```",""):gsub("\n","")
                    local name, ms = desc:match("^(.-) : (.-)$")
                    local jobId = embed.fields[2].value:match("gameInstanceId=([%w%-]+)")

                    if name and ms and jobId then
                        if firstFetch then
                            seenServers[jobId] = true -- mark old logs
                        else
                            addRow(name, ms, jobId)
                        end
                    end
                end
            end
        end

        firstFetch = false
        task.wait(REFRESH_TIME)
    end
end)

print("✅ BH OP Finder Loaded - No Old Logs, Join Buttons + AutoJoin Ready")
