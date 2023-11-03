-- Extreme Reactor Control for ATM9 modpack
-- Created by padraignix (https://github.com/padraignix)
-- 
-----------------------------------------------
-- Reactor Control - Version History
--
-- v0.1 - Initial UI layout using Basalt
--
--
-----------------------------------------------

-- Local variables
local version = 0.1
local basalt = require("basalt")

-- Peripherals
local reactor
local mon

---- Variables
-- Automation
autoOnPerc = 20
autoOffPerc = 100
autoPower = false
autoRods = false
-- ProgressBar Stats
fuelLevel = 0
fuelTemp = 0
casingTemp = 0
energyCap = 0
rodLevelControl = 0
-- General Stats
statsGen = 0
statsDrain = 0
statsBurn = 0
statsEff = 0
statsWaste = 0
statsStored = 0
storedLastTick = 0
storedThisTick = 0

-------------- Helper Functions ---------------
-----------------------------------------------

function format(num)
  if (num >= 1000000000) then
      return string.format("%.3f G", num / 1000000000)
  elseif (num >= 1000000) then
      return string.format("%.3f M", num / 1000000)
  elseif (num >= 1000) then
      return string.format("%.3f k", num / 1000)
  elseif (num >= 1) then
      return string.format("%.3f ", num)
  elseif (num >= .001) then
      return string.format("%.3f m", num * 1000)
  elseif (num >= .000001) then
      return string.format("%.3f u", num * 1000000)
  else
      return string.format("%.3f ", 0)
  end
end

---------------- GUI Elements -----------------
-----------------------------------------------

-- Setting the main monitor scale
mon = peripheral.wrap("back")
mon.setTextScale(0.5)

-- Setting up the main monitor details
local main = basalt.addMonitor()
main:setMonitor("back")
main:setForeground(colors.lightGray)
main:setBackground(colors.black)

-- Creating subframes for menu items
local sub = {
    main:addFrame():setPosition(1, 2):setSize("{parent.w}", "{parent.h - 3}"):setBackground(colors.black):setForeground(colors.lightGray),
    main:addFrame():setPosition(1, 2):setSize("{parent.w}", "{parent.h - 3}"):setBackground(colors.black):setForeground(colors.lightGray):hide(),
}

-- Function for changing frames
local function openSubFrame(id)
    if(sub[id]~=nil)then
        for k,v in pairs(sub)do
            v:hide()
        end
        sub[id]:show()
    end
end

-- Setting Top Menu Bar
local aMenubar = main:addMenubar()
  :addItem("Power Stats",colors.blue,colors.white)
  --:addItem("Efficiency",colors.blue,colors.white)
  :setSelectionColor(colors.lightGray,colors.black)
  :setPosition(1,1)
  :setBackground(colors.blue)
  :setSize("{parent.w}",1)
  :onChange(function(self, val)
    openSubFrame(self:getItemIndex())
  end)

-- Bottom Banner Label
local bannerLabel = main:addLabel()
  :setText("Reactor Control v"..version.." - padraignix")
  :setFontSize(1)
  :setPosition(1, "{parent.h - 1}")
  :setSize("{parent.w}",1)
  :setForeground(colors.white)
  :setBackground(colors.blue)
  :setTextAlign("center")

------ SETTING UP GUI ELEMENTS -----------
--  Setting up GUI placement which can
--  be referenced later on dynamically
------------------------------------------

---- POWER STATUS
-- Power Status Label
local powerLabel = sub[2]:addLabel()
  :setText("Power: ")
  :setFontSize(1)
  :setPosition(2, 2)
  :setSize(7,1)
local powerStatusLabel = sub[2]:addLabel()
  :setText("OFFLINE")
  :setFontSize(1)
  :setPosition(9, 2)
  :setForeground(colors.red)

---- Adding Radio Buttons
-- Function for changing frames
local function powerOptions(id)
    check = id --bMenubar:getItem(id).number
    if check == "ON" then
        powerStatusLabel:setForeground(colors.red)
        powerStatusLabel:setText("OFFLINE")
        reactor.setActive(false)
    end
    if check == "OFF" then
        powerStatusLabel:setForeground(colors.green)
        powerStatusLabel:setText("ONLINE")
        reactor.setActive(true)
    end
end

-- Setting Top Power Bar
local power2Label = sub[2]:addLabel()
  :setText("Power: ")
  :setFontSize(1)
  :setPosition(19,2)
  :setSize(7,1)
bMenubar = sub[2]:addMenubar()
  :addItem("OFF",colors.blue,colors.white)
  :addItem("ON",colors.blue,colors.white)
  :setPosition(25,2)
  :setSize(9,1)
  :setBackground(colors.black)
  :setSelectionColor(colors.lightGray,colors.black)
  :onChange(function(self, val)
    powerOptions(self:getItem(self:getItemIndex()).text)
  end)

-- Setting Top Power Bar
local function powerAutoOptions(id)
  if id == 1 then
    autoPower = true
  end
  if id == 2 then
    autoPower = false
  end
end
local powerAutoLabel = sub[2]:addLabel()
  :setText("Auto: ")
  :setFontSize(1)
  :setPosition(19,3)
  :setSize(6,1)
  :setForeground(colors.lightYellow)
dMenubar = sub[2]:addMenubar()
  :addItem("OFF",colors.blue,colors.white)
  :addItem("ON",colors.blue,colors.white)
  :setPosition(25,3)
  :setSize(9,1)
  :setBackground(colors.black)
  :setSelectionColor(colors.lightGray,colors.black)
  :onChange(function(self, val)
    powerAutoOptions(self:getItemIndex())
  end)

---- FUEL STATUS
local fuelLabel = sub[2]:addLabel()
  :setText("Fuel Level:  "..fuelLevel.."%")
  :setFontSize(1)
  :setPosition(2, 4)
  --:setSize(14,1)
  :setForeground(colors.lightYellow)
local progressBarFuel = sub[2]:addProgressbar()
  :setDirection(0)
  :setProgress(fuelLevel)
  :setPosition(2, 5)
  :setSize("{parent.w * 0.6 - 2}",1)
  :setProgressBar(colors.lime, " ", colors.white)

---- FUEL TEMP
local fuelTempLabel = sub[2]:addLabel()
  :setText("Fuel Temp:   "..fuelTemp.." / 2000")
  :setFontSize(1)
  :setPosition(2, 7)
  --:setSize(14,1)
  :setForeground(colors.lightYellow)
local progressBarFuelTemp = sub[2]:addProgressbar()
  :setDirection(0)
  :setProgress(fuelTemp/2000)
  :setPosition(2, 8)
  :setSize("{parent.w * 0.6 - 2}",1)
  :setProgressBar(colors.lime, " ", colors.white)

---- CASING TEMP
local casingLabel = sub[2]:addLabel()
  :setText("Casing Temp: "..casingTemp.." / 2000")
  :setFontSize(1)
  :setPosition(2, 10)
  --:setSize(14,1)
  :setForeground(colors.lightYellow)
local progressBarCasing = sub[2]:addProgressbar()
  :setDirection(0)
  :setProgress(casingTemp/2000)
  :setPosition(2, 11)
  :setSize("{parent.w * 0.6 - 2}",1)
  :setProgressBar(colors.lime, " ", colors.white)

---- ENERGY CAP 
local energyLabel = sub[2]:addLabel()
  :setText("Energy Cap:  "..energyCap.."%")
  :setFontSize(1)
  :setPosition(2, 13)
  --:setSize(14,1)
  :setForeground(colors.lightYellow)
local progressBarEnergy = sub[2]:addProgressbar()
  :setDirection(0)
  :setProgress(energyCap)
  :setPosition(2, 14)
  :setSize("{parent.w * 0.6 - 2}",1)
  :setProgressBar(colors.lime, " ", colors.white)

---- CONTROL ROD  
rodLabel = sub[2]:addLabel()
  :setText("Rods Levels: "..tostring(rodLevelControl).."%")
  :setFontSize(1)
  :setPosition(2, 16)
  :setSize(20,1)
  :setForeground(colors.lightYellow)
local progressBarRods = sub[2]:addProgressbar()
  :setDirection(0)
  :setProgress(rodLevelControl)
  :setPosition(2, 17)
  :setSize("{parent.w * 0.6 - 2}",1)
  :setProgressBar(colors.lime, " ", colors.white)

---- METRICS PANE
local metricsPane1 = sub[2]:addPane()
  :setBackground(colors.lightGray)
  :setSize("{parent.w * 0.3 + 2}",16)
  :setPosition("{parent.w * 0.7 - 4}", 2)
local metricsPane2 = sub[2]:addPane()
  :setBackground(colors.black)
  :setSize("{parent.w * 0.3}",14)
  :setPosition("{parent.w * 0.7 - 3}", 3)
local metricsLabel = sub[2]:addLabel()
  :setText(" Stats: ")
  :setFontSize(1)
  :setPosition("{parent.w * 0.7 - 2}", 2)
  :setSize(7,1)
  :setForeground(colors.white)
  :setBackground(colors.black)
local genLabel1 = sub[2]:addLabel()
  :setText("Generating: ")
  :setFontSize(1)
  :setPosition("{parent.w * 0.7 - 1}", 4)
  :setForeground(colors.green)
  :setBackground(colors.black)
local genLabel2 = sub[2]:addLabel()
  :setText(format(statsGen).."FE/t")
  :setFontSize(1)
  :setPosition("{parent.w * 0.7}", 5)
  :setForeground(colors.white)
  :setBackground(colors.black)
local drainLabel1 = sub[2]:addLabel()
  :setText("Drain: ")
  :setFontSize(1)
  :setPosition("{parent.w * 0.7 - 1}", 6)
  :setForeground(colors.green)
  :setBackground(colors.black)
local drainLabel2 = sub[2]:addLabel()
  :setText(format(statsDrain).."FE/t")
  :setFontSize(1)
  :setPosition("{parent.w * 0.7}", 7)
  :setForeground(colors.white)
  :setBackground(colors.black)
local burnLabel1 = sub[2]:addLabel()
  :setText("Burn Rate: ")
  :setFontSize(1)
  :setPosition("{parent.w * 0.7 - 1}", 8)
  :setForeground(colors.green)
  :setBackground(colors.black)
local burnLabel2 = sub[2]:addLabel()
  :setText(format(statsBurn).."B/t")
  :setFontSize(1)
  :setPosition("{parent.w * 0.7}", 9)
  :setForeground(colors.white)
  :setBackground(colors.black)
local effLabel1 = sub[2]:addLabel()
  :setText("Efficiency: ")
  :setFontSize(1)
  :setPosition("{parent.w * 0.7 - 1}", 10)
  :setForeground(colors.green)
  :setBackground(colors.black)
local effLabel2 = sub[2]:addLabel()
  :setText(format(statsEff).."FE/B")
  :setFontSize(1)
  :setPosition("{parent.w * 0.7}", 11)
  :setForeground(colors.white)
  :setBackground(colors.black)
local wasteLabel1 = sub[2]:addLabel()
  :setText("Waste: ")
  :setFontSize(1)
  :setPosition("{parent.w * 0.7 - 1}", 12)
  :setForeground(colors.green)
  :setBackground(colors.black)
local wasteLabel2 = sub[2]:addLabel()
  :setText(format(statsWaste).."mB")
  :setFontSize(1)
  :setPosition("{parent.w * 0.7}", 13)
  :setForeground(colors.white)
  :setBackground(colors.black)
local storedLabel1 = sub[2]:addLabel()
  :setText("Stored: ")
  :setFontSize(1)
  :setPosition("{parent.w * 0.7 - 1}", 14)
  :setForeground(colors.green)
  :setBackground(colors.black)
local storedLabel2 = sub[2]:addLabel()
  :setText(format(statsStored).."FE")
  :setFontSize(1)
  :setPosition("{parent.w * 0.7}", 15)
  :setForeground(colors.white)
  :setBackground(colors.black)

---- ROD / AUTO CONTROLS
local autoOnLabel = sub[2]:addLabel()
  :setText("Auto Starts: ")
  :setFontSize(1)
  :setPosition(2,19)
  :setForeground(colors.white)
  :setBackground(colors.black)
autoOnInput = sub[2]:addLabel()
  :setText(autoOnPerc.."%")
  :setPosition(15,19)
  :setForeground(colors.white)
  :setBackground(colors.black)
local autoOnLButton = sub[2]:addButton()
  :setText(" < ")
  :setPosition(21,19)
  :setSize(3,1)
autoOnLButton:onClick(function(self,event,button,x,y)
  if(event=="mouse_click")and(button==1)then
    if autoOnPerc > 0 then
        autoOnPerc = autoOnPerc - 1
        autoOnInput:setText(autoOnPerc.."%")
    end
  end
end)
local autoOnRButton = sub[2]:addButton()
  :setText(" > ")
  :setPosition(25,19)
  :setSize(3,1)
autoOnRButton:onClick(function(self,event,button,x,y)
  if(event=="mouse_click")and(button==1)then
    if autoOnPerc < 100 then
        autoOnPerc = autoOnPerc + 1
        autoOnInput:setText(autoOnPerc.."%")
    end
  end
end)

local autoOffLabel = sub[2]:addLabel()
  :setText("Auto Stops : ")
  :setFontSize(1)
  :setPosition(2,21)
  :setForeground(colors.white)
  :setBackground(colors.black)
autoOffInput = sub[2]:addLabel()
  :setText(autoOffPerc.."%")
  :setPosition(15,21)
  :setForeground(colors.white)
  :setBackground(colors.black)
local autoOffLButton = sub[2]:addButton()
  :setText(" < ")
  :setPosition(21,21)
  :setSize(3,1)
autoOffLButton:onClick(function(self,event,button,x,y)
  if(event=="mouse_click")and(button==1)then
    if autoOffPerc > 0 then
        autoOffPerc = autoOffPerc - 1
        autoOffInput:setText(autoOffPerc.."%")
    end
  end
end)
local autoOffRButton = sub[2]:addButton()
  :setText(" > ")
  :setPosition(25,21)
  :setSize(3,1)
autoOffRButton:onClick(function(self,event,button,x,y)
  if(event=="mouse_click")and(button==1)then
    if autoOffPerc < 100 then
        autoOffPerc = autoOffPerc + 1
        autoOffInput:setText(autoOffPerc.."%")
    end
  end
end)


-- Manual Rod Control
local manRodLLButton = sub[2]:addButton()
  :setText(" << ")
  :setPosition(34,21)
  :setSize(4,1)
manRodLLButton:onClick(function(self,event,button,x,y)
  if(event=="mouse_click")and(button==1)then
    if rodLevelControl > 0 then
        rodLevelControl = rodLevelControl - 10
        rodLabel:setText("Rod Levels: "..tostring(rodLevelControl).."%")
        --progressBarRods:setProgress(rodLevelControl)
        reactor.setAllControlRodLevels(rodLevelControl)
    end
  end
end)
local manRodLButton = sub[2]:addButton()
  :setText(" < ")
  :setPosition(39,21)
  :setSize(3,1)
manRodLButton:onClick(function(self,event,button,x,y)
  if(event=="mouse_click")and(button==1)then
    if rodLevelControl > 0 then
        rodLevelControl = rodLevelControl - 1
        rodLabel:setText("Rod Levels: "..tostring(rodLevelControl).."%")
        --progressBarRods:setProgress(rodLevelControl)
        reactor.setAllControlRodLevels(rodLevelControl)
    end
  end
end)

--local manRodOnLabel = sub[2]:addLabel()
--  :setText("Adj")
--  :setFontSize(1)
--  :setPosition(43,21)
--  :setForeground(colors.white)
--  :setBackground(colors.black)

local manRodRButton = sub[2]:addButton()
  :setText(" > ")
  :setPosition(44,21)
  :setSize(3,1)
manRodRButton:onClick(function(self,event,button,x,y)
  if(event=="mouse_click")and(button==1)then
    if rodLevelControl < 100 then
        rodLevelControl = rodLevelControl + 1
        rodLabel:setText("Rod Levels: "..tostring(rodLevelControl).."%")
        --progressBarRods:setProgress(rodLevelControl)
        reactor.setAllControlRodLevels(rodLevelControl)
    end
  end
end)
local manRodRRButton = sub[2]:addButton()
  :setText(" >> ")
  :setPosition(48,21)
  :setSize(4,1)
manRodRRButton:onClick(function(self,event,button,x,y)
  if(event=="mouse_click")and(button==1)then
    if rodLevelControl < 100 then
        rodLevelControl = rodLevelControl + 10
        rodLabel:setText("Rod Levels: "..tostring(rodLevelControl).."%")
        --progressBarRods:setProgress(rodLevelControl)
        reactor.setAllControlRodLevels(rodLevelControl)
    end
  end
end)

-------- Control Rod Automation Area ---------
local function controlRodOptions(id)
  check = id
  ---- TODO commenting out autorod until functionality is created
  --if check == "1" then
  --    autoRods = true
  --    manRodLLButton:hide()
  --    manRodLButton:hide()
  --    manRodRButton:hide()
  --    manRodRRButton:hide()
  --end
  if check == "2" then
      autoRods = false
      manRodLLButton:show()
      manRodLButton:show()
      manRodRButton:show()
      manRodRRButton:show()
  end
end

local autoRodOnLabel = sub[2]:addLabel()
:setText("Auto Rods: ")
:setFontSize(1)
:setPosition(32,19)
:setForeground(colors.white)
:setBackground(colors.black)
cMenubar = sub[2]:addMenubar()
:addItem("OFF",colors.blue,colors.white) -- id1
:addItem("ON",colors.blue,colors.white) -- id2
:setPosition(45,19)
:setSize(9,1)
:setSelectionColor(colors.lightGray,colors.black)
:onChange(function(self, val)
  controlRodOptions(tostring(self:getItemIndex()))
end)

------------ ENERGY STAT FUNCTION -------------
-----------------------------------------------
function reactorStats()
  bat = reactor.getEnergyStats()
  fuel = reactor.getFuelStats()

  storedLastTick = storedThisTick
  storedThisTick = bat.energyStored
  lastRFT = bat.energyProducedLastTick
  energyStored = bat.energyStored
  energyCapacity = bat.energyCapacity
  rod = reactor.getControlRodLevel(0)
  fuelUsage = fuel.fuelConsumedLastTick / 1000
  waste = reactor.getWasteAmount()
  fuelTemp = reactor.getFuelTemperature()
  caseTemp = reactor.getCasingTemperature()

end
------------------------------------------------
------- Updating Reactor Stats Function --------
function updateReactorStats()

  ------------ Progress Bars -------------------
  fuelLevel = math.floor((fuel.fuelAmount/fuel.fuelCapacity)*100)
  fuelLabel:setText("Fuel Level:  "..fuelLevel.."%")
  progressBarFuel:setProgress(fuelLevel)
  ----
  fuelTempLabel:setText("Fuel Temp:   "..math.floor(fuelTemp).." / 2000")
  local fuelTempPerc = math.floor((fuelTemp/2000)*100)
  if fuelTempPerc <= 25 then
    progressBarFuelTemp:setProgress(fuelTempPerc)
    progressBarFuelTemp:setProgressBar(colors.lime, " ", colors.white)
  end
  if fuelTempPerc > 25 and fuelTempPerc <= 50 then
    progressBarFuelTemp:setProgress(fuelTempPerc)
    progressBarFuelTemp:setProgressBar(colors.yellow, " ", colors.white)
  end
  if fuelTempPerc > 50 and fuelTempPerc <= 75 then
    progressBarFuelTemp:setProgress(fuelTempPerc)
    progressBarFuelTemp:setProgressBar(colors.orange, " ", colors.white)
  end
  if fuelTempPerc > 75 and fuelTempPerc <= 100 then
    progressBarFuelTemp:setProgress(fuelTempPerc)
    progressBarFuelTemp:setProgressBar(colors.red, " ", colors.white)
  end
  if fuelTempPerc > 100 then
    progressBarFuelTemp:setProgress(100)
    progressBarFuelTemp:setProgressBar(colors.red, " ", colors.white)
  end
  ----
  casingLabel:setText("Casing Temp: "..math.floor(caseTemp).." / 2000")
  local casingTempPerc = math.floor((caseTemp/2000)*100)
  if casingTempPerc <= 25 then
    progressBarCasing:setProgress(casingTempPerc)
    progressBarCasing:setProgressBar(colors.lime, " ", colors.white)
  end
  if casingTempPerc > 25 and casingTempPerc <= 50 then
    progressBarCasing:setProgress(casingTempPerc)
    progressBarCasing:setProgressBar(colors.yellow, " ", colors.white)
  end
  if casingTempPerc > 50 and casingTempPerc <= 75 then
    progressBarCasing:setProgress(casingTempPerc)
    progressBarCasing:setProgressBar(colors.orange, " ", colors.white)
  end
  if casingTempPerc > 75 and casingTempPerc <= 100 then
    progressBarCasing:setProgress(casingTempPerc)
    progressBarCasing:setProgressBar(colors.red, " ", colors.white)
  end
  if casingTempPerc > 100 then
    progressBarCasing:setProgress(100)
    progressBarCasing:setProgressBar(colors.red, " ", colors.white)
  end
  ----
  energyCap = math.floor((energyStored/energyCapacity)*100)
  energyLabel:setText("Energy Cap:  "..energyCap.."%")
  if energyCap <= 10 then
    progressBarEnergy:setProgress(energyCap)
    progressBarEnergy:setProgressBar(colors.red, " ", colors.white)
  end
  if energyCap > 10 and energyCap <= 25 then
    progressBarEnergy:setProgress(energyCap)
    progressBarEnergy:setProgressBar(colors.orange, " ", colors.white)
  end
  if energyCap > 25 and energyCap <= 50 then
    progressBarEnergy:setProgress(energyCap)
    progressBarEnergy:setProgressBar(colors.yellow, " ", colors.white)
  end
  if energyCap > 50 and energyCap <= 100 then
    progressBarEnergy:setProgress(energyCap)
    progressBarEnergy:setProgressBar(colors.lime, " ", colors.white)
  end
  ----
  rodLevelControl = rod
  rodLabel:setText("Rod Levels: "..tostring(rodLevelControl).."%")
  progressBarRods:setProgress(rodLevelControl)

  ----------- Stats Section -------------------

  statsGen = lastRFT
  genLabel2:setText(format(statsGen).."FE/t")

  rfLost = lastRFT + storedLastTick - storedThisTick
  statsDrain = rfLost
  drainLabel2:setText(format(statsDrain).."FE/t")

  statsBurn = fuelUsage
  burnLabel2:setText(format(statsBurn).."B/t")

  statsEff = lastRFT / fuelUsage
  effLabel2:setText(format(statsEff).."FE/B")

  statsWaste = waste
  wasteLabel2:setText(format(statsWaste).."mB")

  statsStored = energyStored
  storedLabel2:setText(format(statsStored).."FE")

end
------------------------------------------------ 
----------------- Auto Control -----------------
--
--  Checks if Capacity is at configured levels,
--  and if so, turns on/off the reactor
--
function autoCheck()

  -- Check whether to turn off reactor
  if reactor.getActive() and autoPower then
    if energyCap >= autoOffPerc then
      reactor.setActive(false)
    end
  end
  --check whether to turn on reactor
  if not reactor.getActive() and autoPower then
    if energyCap <= autoOnPerc then
      reactor.setActive(true)
    end
  end

end
------------------------------------------------
---------- Testing out Graph Section -----------
local graphPanel = sub[2]:addPane()
  :setBackground(colors.lightGray)
  :setSize("{parent.w - 4}","{parent.h - 17 - 7}")
  :setPosition(2, 23)
local graphLabel = sub[2]:addLabel()
  :setText(" Efficiency Over Time: ")
  :setFontSize(1)
  :setPosition(4, 23)
  :setForeground(colors.white)
  :setBackground(colors.black)
local aGraph = sub[2]:addGraph()
  :setGraphType("line")
  :setSize("{parent.w - 6}","{parent.h - 17 - 9}")
  :setPosition(3, 24)    
  :setGraphSymbol(" ")
  :setGraphColor(colors.lime)
  :setBackground(colors.black)
   

------------------------------------------------

openSubFrame(2)

local function getReactorStats()
  while true do
      reactor = peripheral.find("BigReactors-Reactor")
          if(reactor~=nil)then
            reactorStats()
            updateReactorStats()
            autoCheck()
          else
            basalt.debug("Reactor not found")
          end
            os.sleep(1)
   end
end
main:addThread():start(getReactorStats)

basalt.autoUpdate()