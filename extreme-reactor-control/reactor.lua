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

-- Variables
autoOnPerc = 100
autoOffPerc = 100
------------ ENERGY STAT FUNCTION -------------

-- TODO

-----------------------------------------------

-- Setting the main monitor scale, didn't figure out how to do this within Basalt
local mon
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
  :addItem("Efficiency",colors.blue,colors.white)
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
  :setForeground(colors.lightYellow)
local powerStatusLabel = sub[2]:addLabel()
  :setText("OFFLINE")
  :setFontSize(1)
  :setPosition(9, 2)
  :setForeground(colors.red)

---- Adding Radio Buttons
-- Function for changing frames
local function powerOptions(id)
    check = id --bMenubar:getItem(id).text
    if check == "3" then
        powerStatusLabel:setForeground(colors.red)
        powerStatusLabel:setText("OFFLINE")
    end
    if check == "1" then
        powerStatusLabel:setForeground(colors.green)
        powerStatusLabel:setText("ONLINE")
    end
    if check == "2" then
        powerStatusLabel:setForeground(colors.green)
        powerStatusLabel:setText("ONLINE AUTO")
    end
end

-- Setting Top Menu Bar
bMenubar = sub[2]:addMenubar()
  :addItem("OFF",colors.blue,colors.white) -- id3
  :addItem("ON",colors.blue,colors.white) -- id1
  :addItem("AUTO",colors.blue,colors.white) -- id2
  :setPosition(21,2)
  :setSize(15,1)
  :setBackground(colors.black)
  :onChange(function(self, val)
    powerOptions(tostring(self:getItemIndex()))
  end)

---- FUEL STATUS
local fuelLabel = sub[2]:addLabel()
  :setText("Fuel Level: ")
  :setFontSize(1)
  :setPosition(2, 4)
  :setSize(14,1)
  :setForeground(colors.lightYellow)
local progressBarFuel = sub[2]:addProgressbar()
  :setDirection(0)
  :setProgress(10)
  :setPosition(2, 5)
  :setSize("{parent.w * 0.6 - 2}",1)
  :setProgressBar(colors.lime, " ", colors.white)

---- FUEL TEMP
local fuelTempLabel = sub[2]:addLabel()
  :setText("Fuel Temp: ")
  :setFontSize(1)
  :setPosition(2, 7)
  :setSize(14,1)
  :setForeground(colors.lightYellow)
local progressBarFuelTemp = sub[2]:addProgressbar()
  :setDirection(0)
  :setProgress(10)
  :setPosition(2, 8)
  :setSize("{parent.w * 0.6 - 2}",1)
  :setProgressBar(colors.lime, " ", colors.white)

---- CASING TEMP
local casingLabel = sub[2]:addLabel()
  :setText("Casing Temp: ")
  :setFontSize(1)
  :setPosition(2, 10)
  :setSize(14,1)
  :setForeground(colors.lightYellow)
local progressBarCasing = sub[2]:addProgressbar()
  :setDirection(0)
  :setProgress(10)
  :setPosition(2, 11)
  :setSize("{parent.w * 0.6 - 2}",1)
  :setProgressBar(colors.lime, " ", colors.white)

---- ENERGY CAP 
local energyLabel = sub[2]:addLabel()
  :setText("Energy Cap: ")
  :setFontSize(1)
  :setPosition(2, 13)
  :setSize(14,1)
  :setForeground(colors.lightYellow)
local progressBarEnergy = sub[2]:addProgressbar()
  :setDirection(0)
  :setProgress(10)
  :setPosition(2, 14)
  :setSize("{parent.w * 0.6 - 2}",1)
  :setProgressBar(colors.lime, " ", colors.white)

---- CONTROL ROD  
local rodLabel = sub[2]:addLabel()
  :setText("Control Rods: ")
  :setFontSize(1)
  :setPosition(2, 16)
  :setSize(14,1)
  :setForeground(colors.lightYellow)
local progressBarRods = sub[2]:addProgressbar()
  :setDirection(0)
  :setProgress(10)
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
  :setText("x FE/t")
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
  :setText("x FE/t")
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
  :setText("x B/t")
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
  :setText("x FE/B")
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
  :setText("x mB")
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
  :setText("x FE")
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
  :setText("<")
  :setPosition(20,19)
  :setSize(1,1)
autoOnLButton:onClick(function(self,event,button,x,y)
  if(event=="mouse_click")and(button==1)then
    if autoOnPerc > 0 then
        autoOnPerc = autoOnPerc - 1
        autoOnInput:setText(autoOnPerc.."%")
    end
  end
end)
local autoOnRButton = sub[2]:addButton()
  :setText(">")
  :setPosition(22,19)
  :setSize(1,1)
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
  :setText("<")
  :setPosition(20,21)
  :setSize(1,1)
autoOffLButton:onClick(function(self,event,button,x,y)
  if(event=="mouse_click")and(button==1)then
    if autoOffPerc > 0 then
        autoOffPerc = autoOffPerc - 1
        autoOffInput:setText(autoOffPerc.."%")
    end
  end
end)
local autoOffRButton = sub[2]:addButton()
  :setText(">")
  :setPosition(22,21)
  :setSize(1,1)
autoOffRButton:onClick(function(self,event,button,x,y)
  if(event=="mouse_click")and(button==1)then
    if autoOffPerc < 100 then
        autoOffPerc = autoOffPerc + 1
        autoOffInput:setText(autoOffPerc.."%")
    end
  end
end)

---------- Testing out Graph Section -----------
local graphPanel = sub[2]:addPane()
  :setBackground(colors.lightGray)
  :setSize("{parent.w - 4}","{parent.h - 17 - 7}")
  :setPosition(2, 23)
local graphLabel = sub[2]:addLabel()
  :setText(" Capacity Over Time: ")
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
  :addDataPoint(80)
  :addDataPoint(75)
  :addDataPoint(70)
  :addDataPoint(60)
  :addDataPoint(50)
  :addDataPoint(30)
  :addDataPoint(10)
  :addDataPoint(0)
   
openSubFrame(2)

basalt.autoUpdate()