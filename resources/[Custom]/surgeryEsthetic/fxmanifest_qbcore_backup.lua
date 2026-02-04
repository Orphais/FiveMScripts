fx_version 'cerulean'
games { 'gta5' }
lua54 'yes'

author 'SurgeryEsthetic'
description 'Plastic Surgery System for FiveM RP'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'shared/pedModels.lua'
}

client_scripts {
    'client/utils.lua',
    'client/client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/callbacks.lua',
    'server/server.lua'
}

dependencies {
    'qb-core',
    'ox_lib',
    'oxmysql'
}