-- BH OP FINDER - RECENT LOGS UI + WORKING JOIN BUTTONS (NO POPUP)

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

--------------------------------------------------
-- SOUND
--------------------------------------------------
local ping = Instance.new("Sound", workspace)
ping.SoundId = "rbxassetid://9118823101"
ping.Volume = 2
ping.Looped = false
local function playPing()
    ping:Play()
    task.delay(1.5, function() ping:Stop() end)
end

--------------------------------------------------
-- GUI
--------------------------------------------------
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "BH_OP_MainGUI"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.fromOffset(300,260)
main.Position = UDim2.fromScale(0.35,0.25)
main.BackgroundColor3 = Color3.fromRGB(20,20,20)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main)

local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.new(1,1,1)
stroke.Thickness = 1

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,34)
title.BackgroundTransparency = 1
title.Text = "RECENT LOGS"
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextColor3 = Color3.new(1,1,1)

local list = Instance.new("ScrollingFrame", main)
list.Position = UDim2.new(0,6,0,38)
list.Size = UDim2.new(1,-12,1,-44)
list.ScrollBarThickness = 4
list.BackgroundTransparency = 1
list.ClipsDescendants = false
list.CanvasSize = UDim2.new(0,0,0,0)

local layout = Instance.new("UIListLayout", list)
layout.Padding = UDim.new(0,6)
layout.SortOrder = Enum.SortOrder.LayoutOrder

--------------------------------------------------
-- TOGGLE MAIN UI
--------------------------------------------------
local toggleGui = Instance.new("ScreenGui", player.PlayerGui)
toggleGui.Name = "BH_OP_ToggleGUI"

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
-- FUNCTION: TRY JOIN
--------------------------------------------------
local function tryJoin(jobId)
    task.spawn(function()
        for i = 1, MAX_JOIN_RETRIES do
            local success = pcall(function()
                TeleportService:TeleportToPlaceInstance(PLACE_ID, jobId, player)
            end)
            if success then break end
            task.wait(0.5)
        end
    end)
end

--------------------------------------------------
-- FUNCTION: SHOW ALERT (just sound, no popup)
--------------------------------------------------
local function showNotification()
    playPing() -- sound only
end

--------------------------------------------------
-- FUNCTION: ADD ROW
--------------------------------------------------
local function addRow(name, ms, jobId)
    if seenServers[jobId] then return end
    seenServers[jobId] = true

    showNotification() -- sound only

    local row = Instance.new("Frame")
    row.Size = UDim2.fromOffset(288,52)
    row.BackgroundColor3 = Color3.fromRGB(30,30,30)
    row.Parent = list
    Instance.new("UICorner", row)

    -- Name label
    local nameLbl = Instance.new("TextLabel", row)
    nameLbl.Position = UDim2.fromOffset(10,6)
    nameLbl.Size = UDim2.fromOffset(180,20)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = name
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextSize = 13
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.TextColor3 = Color3.new(1,1,1)

    -- MS label
    local msLbl = Instance.new("TextLabel", row)
    msLbl.Position = UDim2.fromOffset(10,28)
    msLbl.Size = UDim2.fromOffset(180,18)
    msLbl.BackgroundTransparency = 1
    msLbl.Text = ms
    msLbl.Font = Enum.Font.Gotham
    msLbl.TextSize = 12
    msLbl.TextXAlignment = Enum.TextXAlignment.Left
    msLbl.TextColor3 = Color3.fromRGB(0,255,0)

    -- JOIN BUTTON
    local joinBtn = Instance.new("TextButton", row)
    joinBtn.Size = UDim2.fromOffset(80,28)
    joinBtn.Position = UDim2.fromOffset(200,12)
    joinBtn.Text = "JOIN"
    joinBtn.Font = Enum.Font.GothamBold
    joinBtn.TextSize = 14
    joinBtn.TextColor3 = Color3.new(1,1,1)
    joinBtn.BackgroundColor3 = Color3.fromRGB(0,140,255)
    joinBtn.AutoButtonColor = true
    joinBtn.Visible = true
    joinBtn.Active = true
    joinBtn.Selectable = true
    Instance.new("UICorner", joinBtn)

    joinBtn.MouseButton1Click:Connect(function()
        tryJoin(jobId)
    end)

    if AutoJoin then
        tryJoin(jobId)
    end

    task.wait()
    list.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 6)
end

--------------------------------------------------
-- FETCH LOOP
--------------------------------------------------
local firstFetchDone = false
task.spawn(function()
    while true do
        local ok,res = pcall(function()
            local req = syn and syn.request or http_request or request
            if req then
                return req({Url=LISTENER_URL, Method="GET"}).Body
            else
                return HttpService:GetAsync(LISTENER_URL)
            end
        end)

        if ok and res then
            local data = HttpService:JSONDecode(res)
            if data.embeds then
                for _, embed in ipairs(data.embeds) do
                    local desc = embed.description or ""
                    desc = desc:gsub("```",""):gsub("\n","")
                    local name, ms = desc:match("^(.-) : (.-)$")
                    local jobId = embed.fields[2].value:match("gameInstanceId=([%w%-]+)")

                    if name and ms and jobId then
                        if not firstFetchDone then
                            firstFetchDone = true
                            seenServers[jobId] = true
                        else
                            addRow(name, ms, jobId)
                        end
                    end
                end
            end
        end
        task.wait(REFRESH_TIME)
    end
end)

print("✅ BH OP Finder - RECENT LOGS UI + WORKING JOIN BUTTONS LOADED (NO POPUP)")
