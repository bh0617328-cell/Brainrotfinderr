BH OP FINDER (RECENT LOGS UI + AUTO JOIN + TOP NOTIFY)

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

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
-- AUTO JOIN FUNCTION
--------------------------------------------------
local function tryJoin(jobId)
    task.spawn(function()
        for i = 1, MAX_JOIN_RETRIES do
            pcall(function()
                TeleportService:TeleportToPlaceInstance(PLACE_ID, jobId, player)
            end)
            task.wait(0.1)
        end
    end)
end

--------------------------------------------------
-- TOP NOTIFICATION
--------------------------------------------------
local notifGui = Instance.new("ScreenGui", player.PlayerGui)

local function showNotify(name, ms)
    local frame = Instance.new("Frame", notifGui)
    frame.Size = UDim2.fromOffset(260,50)
    frame.Position = UDim2.new(0.5,-130,-0.2,0)
    frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
    frame.AnchorPoint = Vector2.new(0.5,0)
    frame.BackgroundTransparency = 0.1
    Instance.new("UICorner", frame)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(0,200,255)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1,0,0.5,0)
    title.BackgroundTransparency = 1
    title.Text = "BRAINROT DETECTED"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextColor3 = Color3.fromRGB(0,200,255)
    title.Parent = frame

    local info = Instance.new("TextLabel", frame)
    info.Position = UDim2.new(0,0,0.5,0)
    info.Size = UDim2.new(1,0,0.5,0)
    info.BackgroundTransparency = 1
    info.Text = name.." | "..ms
    info.Font = Enum.Font.Gotham
    info.TextSize = 12
    info.TextColor3 = Color3.new(1,1,1)
    info.Parent = frame

    local down = TweenService:Create(frame,TweenInfo.new(0.4),{
        Position = UDim2.new(0.5,-130,0.03,0)
    })
    local up = TweenService:Create(frame,TweenInfo.new(0.4),{
        Position = UDim2.new(0.5,-130,-0.2,0)
    })

    down:Play()
    task.delay(1.5,function()
        up:Play()
        task.delay(0.4,function()
            frame:Destroy()
        end)
    end)
end

--------------------------------------------------
-- GUI
--------------------------------------------------
local gui = Instance.new("ScreenGui", player.PlayerGui)

local main = Instance.new("Frame", gui)
main.Size = UDim2.fromOffset(300,260)
main.Position = UDim2.fromScale(0.35,0.25)
main.BackgroundColor3 = Color3.fromRGB(20,20,20)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main)

local stroke = Instance.new("UIStroke", main)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,34)
title.Text = "RECENT LOGS"
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextColor3 = Color3.new(1,1,1)

-- AUTO JOIN TOGGLE
local autoBtn = Instance.new("TextButton", main)
autoBtn.Size = UDim2.fromOffset(80,24)
autoBtn.Position = UDim2.fromOffset(210,5)
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

-- LIST
local list = Instance.new("ScrollingFrame", main)
list.Position = UDim2.new(0,6,0,38)
list.Size = UDim2.new(1,-12,1,-44)
list.ScrollBarThickness = 4
list.BackgroundTransparency = 1
list.CanvasSize = UDim2.new(0,0,0,0)

local layout = Instance.new("UIListLayout", list)
layout.Padding = UDim.new(0,6)

--------------------------------------------------
-- ADD CARD
--------------------------------------------------
local function addCard(name, ms, jobId)

    if seenServers[jobId] then return end
    seenServers[jobId] = true

    showNotify(name, ms)

    local card = Instance.new("Frame", list)
    card.Size = UDim2.new(1,0,0,52)
    card.BackgroundColor3 = Color3.fromRGB(30,30,30)
    Instance.new("UICorner", card)

    local nameLbl = Instance.new("TextLabel", card)
    nameLbl.Position = UDim2.new(0,10,0,6)
    nameLbl.Size = UDim2.new(0.6,0,0.45,0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = name
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextSize = 13
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.TextColor3 = Color3.new(1,1,1)

    local msLbl = Instance.new("TextLabel", card)
    msLbl.Position = UDim2.new(0,10,0.52,0)
    msLbl.Size = UDim2.new(0.6,0,0.4,0)
    msLbl.BackgroundTransparency = 1
    msLbl.Text = ms
    msLbl.Font = Enum.Font.Gotham
    msLbl.TextSize = 12
    msLbl.TextXAlignment = Enum.TextXAlignment.Left
    msLbl.TextColor3 = Color3.fromRGB(0,255,0)

    local joinBtn = Instance.new("TextButton", card)
    joinBtn.Size = UDim2.new(0.32,0,0.7,0)
    joinBtn.Position = UDim2.new(0.66,0,0.15,0)
    joinBtn.Text = "JOIN"
    joinBtn.Font = Enum.Font.GothamBold
    joinBtn.TextSize = 14
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
-- FETCH LOOP
--------------------------------------------------
task.spawn(function()
    while true do
        local ok,res = pcall(function()
            return HttpService:GetAsync(LISTENER_URL)
        end)

        if ok and res then
            local data = HttpService:JSONDecode(res)

            if data.embeds and data.embeds[1] then
                local embed = data.embeds[1]
                local desc = embed.description:gsub("```",""):gsub("\n","")
                local name, ms = desc:match("^(.-) : (.-)$")
                local jobId = embed.fields[2].value:match("gameInstanceId=([%w%-]+)")

                if name and ms and jobId then
                    addCard(name, ms, jobId)
                end
            end
        end

        task.wait(REFRESH_TIME)
    end
end)

print("BH OP Finder Loaded")
