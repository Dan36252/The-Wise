-- @ScriptType: Script
local sss = game:GetService("ServerScriptService")
local rs = game:GetService("ReplicatedStorage")
local ps = game:GetService("Players")

-- Set up callback for telling clients whether the server is ready or not
local ready = false
local serverReadyFunc = rs:WaitForChild("RemoteFunctions"):WaitForChild("ServerReady")
serverReadyFunc.OnServerInvoke = function() return ready end

-- Initialize Create Base Manager
local createBaseM = require(sss:WaitForChild("CreateBaseManager"))
createBaseM.Initialize()

-- Initialize Join Base Manager
local joineBaseM = require(sss:WaitForChild("JoinBaseManager"))
joineBaseM.Initialize()

-- Initialize Tutorial Manager
local tutorialM = require(sss:WaitForChild("TutorialManager"))
tutorialM.Initialize()

-- Initialize DataStore module to stop game from closing until it is ready
local dataStoreM = require(sss:WaitForChild("DataStore"))
dataStoreM.Initialize()


ready = true