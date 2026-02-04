fx_version 'cerulean'
games { 'gta5' }
lua54 'yes'

author 'Test'
description 'TEST MINIMAL'
version '1.0.0'

-- RIEN EN SHARED - Test pur
client_scripts {
    'client/test_marker.lua'
}

server_scripts {
    'server/server_standalone.lua'
}
