fx_version 'cerulean'
game 'gta5'

name '777-starterbox'
description 'Premium Starter Box System'
author '777 Development'
version '2.2.0'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}