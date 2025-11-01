local Player = game:GetService("Players").LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

local Skeletons = Instance.new("ScreenGui")
Skeletons.Name = "Skeletons"
Skeletons.ResetOnSpawn = false
Skeletons.Parent = game:GetService("CoreGui") -- or gethui()

local mastertoggle = { value = true }
local ESPs = {}

--// function to make line using Frame
local function MakeLine()
	local line = Instance.new("Frame")
	line.AnchorPoint = Vector2.new(0.5, 0.5)
	line.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	line.BorderSizePixel = 0
	line.Size = UDim2.new(0, 1, 0, 1)
	line.Visible = false
	line.Parent = Skeletons
	return line
end

--// function to connect two 2D points with a GUI line
local function ConnectLine(line, from, to)
	local dist = (to - from).Magnitude
	local midpoint = (from + to) / 2
	line.Size = UDim2.new(dist, 2) -- Use actual distance for size
	line.Position = UDim2.fromOffset(midpoint.X, midpoint.Y)
	line.Rotation = math.deg(math.atan2(to.Y - from.Y, to.X - from.X))
end

--// function to build ESP for a player
local function DrawESP(plr)
    repeat task.wait() until plr.Character and plr.Character:FindFirstChild("Humanoid")

    local limbs = {}
    local rigType = plr.Character.Humanoid.RigType
    local isR15 = (rigType == Enum.HumanoidRigType.R15)

    if isR15 then
        limbs = {
            Head_UpperTorso = MakeLine(),
            UpperTorso_LowerTorso = MakeLine(),
            UpperTorso_LeftUpperArm = MakeLine(),
            LeftUpperArm_LeftLowerArm = MakeLine(),
            LeftLowerArm_LeftHand = MakeLine(),
            UpperTorso_RightUpperArm = MakeLine(),
            RightUpperArm_RightLowerArm = MakeLine(),
            RightLowerArm_RightHand = MakeLine(),
            LowerTorso_LeftUpperLeg = MakeLine(),
            LeftUpperLeg_LeftLowerLeg = MakeLine(),
            LeftLowerLeg_LeftFoot = MakeLine(),
            LowerTorso_RightUpperLeg = MakeLine(),
            RightUpperLeg_RightLowerLeg = MakeLine(),
            RightLowerLeg_RightFoot = MakeLine()
        }
    else
        limbs = {
            Head_Spine = MakeLine(),
            Spine = MakeLine(),
            LeftArm = MakeLine(),
            LeftArm_UpperTorso = MakeLine(),
            RightArm = MakeLine(),
            RightArm_UpperTorso = MakeLine(),
            LeftLeg = MakeLine(),
            LeftLeg_LowerTorso = MakeLine(),
            RightLeg = MakeLine(),
            RightLeg_LowerTorso = MakeLine()
        }
    end

    local function SetVisible(state)
        for _, v in pairs(limbs) do
            v.Visible = state
        end
    end

    local function SetColor(color)
        for _, v in pairs(limbs) do
            v.BackgroundColor3 = color
        end
    end


--// helper projection with vertical correction
local function project(part)
	if not part then return Vector3.zero end
	local pos, onScreen = Camera:WorldToViewportPoint(part.Position)

	if not onScreen then return Vector2.new(-1,-1) end -- Return invalid coordinates if offscreen

    -- Correct the Y coordinate based on distance and camera's field of view (FOV).
    local distance = (Camera.CFrame.Position - part.Position).Magnitude
    local fov = Camera.FieldOfView * math.rad(0.5) -- Half of the FOV in radians

	-- Calculate the vertical offset based on perspective projection
	local verticalOffset = (distance * math.tan(fov) * 0.5) / distance  -- Adjust multiplier as needed

    pos = Vector2.new(pos.X, pos.Y - verticalOffset) -- Apply the vertical offset

	return pos
end


    -- Updater
    local conn
    conn = game:GetService("RunService").RenderStepped:Connect(function()
        local char = plr.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if not (char and hum and hum.Health > 0) then
            SetVisible(false)
            if not game.Players:FindFirstChild(plr.Name) then
                for _, v in pairs(limbs) do v:Destroy() end
                conn:Disconnect()
            end
            return
        end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local _, visible = Camera:WorldToViewportPoint(hrp.Position)
        if not visible then SetVisible(false) return end

        if isR15 then
            local H = project(char.Head)
            local UT = project(char.UpperTorso)
            local LT = project(char.LowerTorso)

            local LUA = project(char.LeftUpperArm)
            local LLA = project(char.LeftLowerArm)
            local LH = project(char.LeftHand)

            local RUA = project(char.RightUpperArm)
            local RLA = project(char.RightLowerArm)
            local RH = project(char.RightHand)

            local LUL = project(char.LeftUpperLeg)
            local LLL = project(char.LeftLowerLeg)
            local LF = project(char.LeftFoot)

            local RUL = project(char.RightUpperLeg)
            local RLL = project(char.RightLowerLeg)
            local RF = project(char.RightFoot)

            -- connect bones
            ConnectLine(limbs.Head_UpperTorso, Vector2.new(H.X,H.Y), Vector2.new(UT.X,UT.Y))
            ConnectLine(limbs.UpperTorso_LowerTorso, Vector2.new(UT.X,UT.Y), Vector2.new(LT.X,LT.Y))
            ConnectLine(limbs.UpperTorso_LeftUpperArm, Vector2.new(UT.X,UT.Y), Vector2.new(LUA.X,LUA.Y))
            ConnectLine(limbs.LeftUpperArm_LeftLowerArm, Vector2.new(LUA.X,LUA.Y), Vector2.new(LLA.X,LLA.Y))
            ConnectLine(limbs.LeftLowerArm_LeftHand, Vector2.new(LLA.X,LLA.Y), Vector2.new(LH.X,LH.Y))
            ConnectLine(limbs.UpperTorso_RightUpperArm, Vector2.new(UT.X,UT.Y), Vector2.new(RUA.X,RUA.Y))
            ConnectLine(limbs.RightUpperArm_RightLowerArm, Vector2.new(RUA.X,RUA.Y), Vector2.new(RLA.X,RLA.Y))
            ConnectLine(limbs.RightLowerArm_RightHand, Vector2.new(RLA.X,RLA.Y), Vector2.new(RH.X,RH.Y))
            ConnectLine(limbs.LowerTorso_LeftUpperLeg, Vector2.new(LT.X,LT.Y), Vector2.new(LUL.X,LUL.Y))
            ConnectLine(limbs.LeftUpperLeg_LeftLowerLeg, Vector2.new(LUL.X,LUL.Y), Vector2.new(LLL.X,LLL.Y))
            ConnectLine(limbs.LeftLowerLeg_LeftFoot, Vector2.new(LLL.X,LLL.Y), Vector2.new(LF.X,LF.Y))
            ConnectLine(limbs.LowerTorso_RightUpperLeg, Vector2.new(LT.X,LT.Y), Vector2.new(RUL.X,RUL.Y))
            ConnectLine(limbs.RightUpperLeg_RightLowerLeg, Vector2.new(RUL.X,RUL.Y), Vector2.new(RLL.X,RLL.Y))
            ConnectLine(limbs.RightLowerLeg_RightFoot, Vector2.new(RLL.X,RLL.Y), Vector2.new(RF.X,RF.Y))
        end

        SetVisible(mastertoggle.value)
    end)

    return { Visible = SetVisible, Color = SetColor }
end
