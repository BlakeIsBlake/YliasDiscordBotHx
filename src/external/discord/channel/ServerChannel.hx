package external.discord.channel;

import external.discord.user.User;
import external.discord.permission.ChannelPermissions;
import external.discord.permission.PermissionOverwrite;

extern class ServerChannel extends Channel {
    public var name: String;
    public var type: ServerChannelType;
    public var position: Int;
    public var permissionOverwrites: Cache<PermissionOverwrite>;
    public var server: Server;

    public function permissionsOf(user: User): ChannelPermissions;
    public function permsOf(user: User): ChannelPermissions;
    public function mention(): String;
}

@:enum
abstract ServerChannelType(String) {
    var VOICE = 'voice';
    var TEXT = 'text';
}