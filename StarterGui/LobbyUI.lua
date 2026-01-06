-- @ScriptType: LocalScript
local zones = require(script:WaitForChild("Zones"))
local windows = require(script:WaitForChild("Windows"))
local createBase = require(script:WaitForChild("CreateBase"))
local joinBase = require(script:WaitForChild("JoinBase"))

zones.Initialize()
windows.Initialize()
createBase.Initialize()
joinBase.Initialize()