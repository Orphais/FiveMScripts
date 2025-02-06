fx_version 'cerulean'
games { 'gta5' };
lua54 'yes'

client_scripts {
    "client/*.lua",

    -- RageUI
    'src/RageUI.lua',
    'src/Menu.lua',
    'src/MenuController.lua',
    'src/components/*.lua',
    'src/elements/*.lua',
    'src/items/*.lua',
}

server_scripts {
    "server/*.lua"
}