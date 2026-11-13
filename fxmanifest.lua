fx_version 'cerulean'
version '1.1.0'
lua54 'yes'
game 'gta5'

description 'Bug a stranger enough and he calls the cops (Qbox, QBCore, ESX via community_bridge)'

shared_scripts {
    'shared/locale.lua',
    'locales/en.lua', -- change en to your language
    'config.lua',
}

client_scripts{
    'client/*.lua',
}

server_scripts{
    'server/*.lua',
}

dependencies {
    'community_bridge',
    'bl_dialog',
}
