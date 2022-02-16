local comp = require('component')
local sides = require('sides')
local event = require('event')
local sg = comp.stargate
local rs = comp.redstone
local serialization = require('serialization')

gateAddress = {}

loop = true
timesDialed = 0

eventStargateOpen = event.listen('stargate_open', function (nam, add, call, me)
    loop = false
    if me then
        gateAddress = serialization.unserialize(sg.dialedAddress:gsub(", ", "\",\""):gsub("%[", "{\""):gsub("%]", "\"}"))
    end
    timesDialed = timesDialed + 1
end)

while loop do os.sleep(0.1) end
print()
failed = false
event.cancel(eventStargateOpen)
while rs.getInput(sides.left) > 0 and not failed do
    event.pull('stargate_wormhole_closed_fully')
    print("Dialing")
    for i, v in ipairs(gateAddress) do print(i, v) end
    print()
    loop = true
    function dialNext(dialed)
        glyph = gateAddress[dialed + 1]
        sg.engageSymbol(glyph)
    end
    function cancelEvents()
        event.cancel(eventEngaged)
        event.cancel(openEvent)
        event.cancel(failEvent)
        loop = false
    end
    eventEngaged = event.listen("stargate_spin_chevron_engaged", function(evname, address, caller, num, lock, glyph)
        os.sleep(0.5)
        if lock then
            print("Engaging...")
            sg.engageGate()
        else
            dialNext(num)
        end
    end)
    dialNext(0)
    openEvent = event.listen("stargate_open", function()
        print("Stargate opened successfully")
        timesDialed = timesDialed + 1
        cancelEvents()
    end)
    failEvent = event.listen("stargate_failed", function()
        print("Stargate failed to open after" .. timesDialed .. "successfull dials")
        failed = true
        cancelEvents()
    end)
    while loop do os.sleep(0.1) end
end