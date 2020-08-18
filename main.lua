-- ------------------------------------------------------
-- Fibaro device exporter quick app
-- Author: Irek Kubicki <irek@ixdude.com>
-- v.0.1.0
-- GIT: https://github.com/ikubicki/fibaro-exporter
-- ------------------------------------------------------


function QuickApp:onInit()
    
    self.http = net.HTTPClient({timeout=3000})
    self.remoteUrl = self:getVariable("URL")
    self:trace("Exporter initialized")
    self:debug("URL: " .. self.remoteUrl)
    self.interval = 5

    self:updateView("label1", "text", "Updates will be send every " .. self.interval .. " minutes.")
    self:updateView("button1", "text", "Send data")
    self:updateView("slider1", "value", tostring(self.interval))
    if (string.sub(self.remoteUrl, 0, 4) ~= 'http') then
        self:updateView("label1", "text", "Invalid configuration!")
    else
        self:loop()
    end
end

function QuickApp:loop()
    self:exportDevices()
    if (self.interval > 0) then
        fibaro.setTimeout(self.interval * 1000 * 60, function() 
            self:loop()
        end)
    end
end

function QuickApp:slider1Event(event)
    self.interval = event['values'][1]
    self:updateView("label1", "text", "Updates will be send every " .. self.interval .. " minutes.")
end

function QuickApp:button1Event()
    self:exportDevices()
end

function QuickApp:exportDevices()
    if (string.sub(self.remoteUrl, 0, 4) ~= 'http') then
        return
    end
    self:updateView("label1", "text", "Please wait...")
    self:updateView("button1", "text", "Sending data")

    local devices = api.get('/devices')
    local devicesPayload = {}
    for _, device in pairs(devices) do
        if (self.id == device.id) then
            goto continue
        end
        if (not device.enabled) then
            goto continue
        end
        if (not device.visible) then
            goto continue
        end
        if (string.sub(device.type, 1, 11) ~= "com.fibaro.") then
            goto continue
        end
        if (device.dead or device.properties.dead) then
            goto continue
        end
        local devicePayload = {
            id = device.id,
            name = device.name,
            type = device.type,
            basetype = device.baseType,
            properties = {
                userDescription = device.properties.userDescription,
                quickAppVariables = device.properties.quickAppVariables,
                value = device.properties.value,
                manufacturer = device.properties.manufacturer,
                model = device.properties.model,
                categories = device.properties.categories,
                zwaveInfo = device.properties.zwaveInfo,
                dead = device.properties.dead,
                unit = device.properties.unit
            },
            dead = device.dead
        }
        devicesPayload[#devicesPayload + 1] = devicePayload
        ::continue::
    end
    self.http:request(self.remoteUrl, {
        options = {
            checkCertificate = false,
            method = 'POST',
            data = json.encode(devicesPayload)
        },
        success = function(response)
            if (response.status >= 300) then
                self:updateView("button1", "text", "Send data")
                self:updateView('label1', 'text', 'Unable to export data')
            else
                self:updateView("button1", "text", "Send data")
                self:updateView('label1', 'text', 'Updated ' .. tostring(#devicesPayload) .. ' devices at ' .. os.date("%Y-%m-%d %H:%M:%S"))
            end
        end,
        error = function(error)
            self:error('HTTP Error', json.encode(error))
            self:updateView('label1', 'text', 'ERROR: ' .. json.encode(error))
            self:updateView("button1", "text", "Send data")
        end
    }) 
end
