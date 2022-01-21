local cartridge = require('cartridge')
local crud = require('crud')


local function init(opts)
    if opts.is_master then
        local users = box.schema.space.create('users', {if_not_exists = true})


        users:format({
            {name='bucket_id', type='unsigned'},
            {name='user_id', type='uuid'},
            {name='fullname', type='string'},
        })

        users:create_index('pk', {parts= {{field = 'user_id'}}, if_not_exists = true})
        users:create_index('bucket_id', {parts= {{field = 'bucket_id'}}, unique=false, if_not_exists = true})

    end
    return true
end

return {
    role_name = 'app.roles.storage',
    init = init,
    dependencies = {'cartridge.roles.crud-storage'}
}