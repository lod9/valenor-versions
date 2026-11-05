-- Valenor Studio · version checker
-- Added to every Valenor release by Valenor Portal. Compares this resource's version with the public
-- feed at https://github.com/lod9/valenor-versions and prints an official notice in the server
-- console when a newer version is out: at start, then every hour until the resource is updated.
if not IsDuplicityVersion() then return end

local PRODUCT = '__VALENOR_PRODUCT__'
local FEED = 'https://raw.githubusercontent.com/lod9/valenor-versions/main/versions.json'
local PORTAL = 'https://portal.cfx.re/assets/granted-assets'
local REPEAT_MS = 60 * 60 * 1000

local resource = GetCurrentResourceName()
local installed = GetResourceMetadata(resource, 'version', 0) or '0.0.0'

local function numbers(version)
    local out = {}
    for n in (tostring(version):gsub('^[vV]', '')):gmatch('%d+') do out[#out + 1] = tonumber(n) end
    return out
end

local function isOlder(a, b)
    local pa, pb = numbers(a), numbers(b)
    for i = 1, math.max(#pa, #pb) do
        local x, y = pa[i] or 0, pb[i] or 0
        if x ~= y then return x < y end
    end
    return false
end

local function outdatedNotice(latest)
    local bar = '^1==============================================================^0'
    local lines = {
        '',
        bar,
        ('^1  VALENOR STUDIO^0  |  ^3%s is outdated^0'):format(PRODUCT),
        ('  Installed: ^1%s^0    Latest: ^2%s^0'):format(installed, tostring(latest.version)),
    }
    if type(latest.changes) == 'table' and #latest.changes > 0 then
        lines[#lines + 1] = '  What is new:'
        for i = 1, math.min(#latest.changes, 6) do
            lines[#lines + 1] = ('    - %s'):format(tostring(latest.changes[i]))
        end
    end
    lines[#lines + 1] = ('  Please download the update from the Cfx.re Portal: ^5%s^0'):format(
        type(latest.download) == 'string' and latest.download or PORTAL)
    lines[#lines + 1] = bar
    lines[#lines + 1] = ''
    print(table.concat(lines, '\n'))
end

local failedOnce = false

local function check(first)
    PerformHttpRequest(FEED, function(status, body)
        if status ~= 200 or type(body) ~= 'string' then
            if not failedOnce then
                failedOnce = true
                print(('^3[%s] Version check unavailable right now (HTTP %s).^0'):format(resource, tostring(status)))
            end
            return
        end
        local ok, data = pcall(json.decode, body)
        local latest = ok and type(data) == 'table' and type(data.resources) == 'table' and data.resources[PRODUCT]
        if type(latest) ~= 'table' or not latest.version then return end
        if isOlder(installed, latest.version) then
            outdatedNotice(latest)
        elseif first then
            print(('^2[%s] Up to date (%s) | Valenor Studio^0'):format(resource, installed))
        end
    end, 'GET', '', { ['User-Agent'] = 'Valenor-VersionChecker' })
end

Citizen.CreateThread(function()
    Citizen.Wait(4000) -- after the resource's own start output
    check(true)
    while true do
        Citizen.Wait(REPEAT_MS)
        check(false)
    end
end)
