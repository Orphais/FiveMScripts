fx_version 'cerulean'
games { 'gta5' }
lua54 'yes'

author 'SurgeryEsthetic'
description 'Plastic Surgery System - STANDALONE (No QB-Core required)'
version '1.0.0-standalone'

shared_scripts {
    '@ox_lib/init.lua',
    'config_standalone.lua',
    'shared/pedModels.lua'
}

client_scripts {
    'client/client_standalone.lua'
}

server_scripts {
    'server/server_standalone.lua'
}

dependencies {
    'ox_lib'
}
