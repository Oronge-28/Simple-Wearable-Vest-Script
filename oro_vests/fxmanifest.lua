fx_version 'cerulean'
game 'gta5'

author 'Oronge_28'
description 'Wearable Bulletproof Vests with animations and models for ESX , Qbox & QBCore'
version '1.0'

dependencies {
    'ox_lib'
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}
