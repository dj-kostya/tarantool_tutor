local cartridge = require('cartridge')
local crud = require('crud')
local log = require('log')
local fun = require('fun')
local uuid = require('uuid')
local json = require('json')


local function get_users(request)
    local users, err = crud.select('users')
    if err ~= nil then
        log.error(err)
        return {status = 500}
    end
    users = crud.unflatten_rows(users.rows, users.metadata)
    users = fun.iter(users):map(function (x) return {
        user_id = x.user_id,
        fullname = x.fullname
    }
    end):totable()

    return request:render({json=users})
end

local function post_user(req)
    local fullname = req:post_param("fullname")

    local u, err = crud.insert_object('users', {
        user_id = uuid.new(),
        fullname = fullname
    })
    -- u = crud.unflatten_rows(u.rows, u.metadata)
    if err ~= nil then
        log.error(err)
        return {status = 500}
    end
    return { body = json.encode({status = "Success!", result = u}), status = 200 }
end

local function init()
    local httpd = assert(cartridge.service_get('httpd'), "Failed to get httpd")
    httpd:route({method = 'GET', path = '/users'}, get_users)
    httpd:route({method = 'POST', path = '/users'}, post_user)

    return true
end


return {
    role_name = 'app.roles.api',
    init = init,
    dependencies = {'cartridge.roles.crud-router'},
}