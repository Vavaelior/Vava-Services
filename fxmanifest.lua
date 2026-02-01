fx_version 'cerulean'
game 'gta5'

author 'Vavaelior'
description 'Système de Radar automatique avec amendes'
version '1.0.0'

shared_scripts {
    '@es_extended/imports.lua',  -- Si vous utilisez ESX
    'sh_main.lua',
    'config.lua'
}

client_scripts {
    'VavaRadarSystem.lua'
}

server_scripts {
    'VavaRadarSystem_server.lua'
}

dependencies {
    'es_extended'  -- Si vous utilisez ESX
}