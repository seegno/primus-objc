platform :osx, '10.9'
inhibit_all_warnings!

pod 'Emitter'
pod 'BlocksKit/DynamicDelegate'
pod 'NSTimer-Blocks'

pod 'socket.IO', :podspec => 'https://raw.github.com/nunofgs/cocoapods-specs/master/socket.IO/0.4.1/socket.IO.podspec'
pod 'SocketRocket'

target :PrimusTests do
    link_with 'Primus', 'PrimusTests'

    pod 'Specta'
    pod 'Expecta'
    pod 'OCMockito'
end
