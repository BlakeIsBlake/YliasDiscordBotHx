package external.discord.permission;

import external.discord.Object;
import external.discord.permission.Role.Permission;

extern class PermissionOverwrite implements Object {
    public var id: String;
    public var type: PermissionOverwriteType;
    public var allowed: Array<Permission>;
    public var denied: Array<Permission>;
}

@:enum
abstract PermissionOverwriteType(String) {
    var MEMBER = 'member';
    var ROLE = 'role';
}

class OverwritePermissionsOptions {
    public var sendMessages: Bool;
    public var attachFiles: Bool;
}