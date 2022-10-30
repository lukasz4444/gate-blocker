os = require("os")
c = require("component")
address = {"Auriga", "Cetus", "Centaurus", "Cancer", "Scutum", "Eridanus", "Point of Origin"}
event = require("event")
if not c.isAvailable("stargate") then
    io.stderr:write("StarGate not connected.")
    os.exit(1)
elseif c.isAvailable("stargate") then
    sg = c.stargate
end
counting = 0
term = require("term")
term.clear()
for i,v in ipairs(address) do print(i,v) end
loop = true

function dialNext(dialed)
    glyph = address[dialed + 1]
    print("Engaging " ..glyph.. "... ")
    sg.engageSymbol(glyph)
end

function cancelEvents()
    event.cancel(eventEngaged)
    event.cancel(openEvent)
    event.cancel(failEvent)
    loop = false
end

spammer = event.listen("stargate_wormhole_closed_fully", function(_, _, caller, isInitiating)
    dialNext(0)
    term.clear()
end)

eventEngaged = event.listen("stargate_spin_chevron_engaged", function(evname, address, caller, num, lock, glyph)
    os.sleep(0.5)
    if lock then
        print("Opening...")
        sg.engageGate()
    else
        dialNext(num)
    end
end)

dialNext(0)

openEvent = event.listen("stargate_open", function()
    print("Stargate opened successfully")
    counting = counting + 1
end)

failEvent = event.listen("stargate_failed", function()
    if counting == 0 then
        print("Unable to open stargate.")
    else
        print("Stargate failed to open after " .. counting .. " successfull dials")
    end
    cancelEvents()
end)

while loop do os.sleep(0.1) end