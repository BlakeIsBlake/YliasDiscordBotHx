package model.entity;

import model.Entity.EntityProperties;
import utils.Logger;
import translations.L;

class Permission extends Entity {
    public static var properties: EntityProperties = {
        tableName: 'permission',
        tableColumns: [
            {
                name: 'id_user',
                mappedBy: 'idUser',
                primary: true
            },
            {
                name: 'id_server',
                mappedBy: 'idServer',
                primary: true
            },
            {
                name: 'command',
                mappedBy: 'command',
                primary: true
            },
            {
                name: 'granted',
                mappedBy: 'granted',
                primary: false
            }
        ]
    };

    public var idUser: String;
    public var idServer: String;
    public var command: String;
    public var granted: Bool;

    public static function register(idUser: String, idServer: String, command: String, granted: Bool, callback: String->Void): Void {
        if (idUser.length > 0 && idServer.length > 0 && command.length > 0) {
            Db.instance.query('SELECT COUNT(*) AS nb FROM ' + properties.tableName + ' WHERE id_user = ? AND id_server = ? AND command = ?', [idUser, idServer, command], function (err: Dynamic, results: Array<Dynamic>) {
                if (err != null) {
                    Logger.exception(err);
                    callback(L.a.n.g('model.entity.permission.register.error_sql_server_retrieval'));
                } else {
                    var query: String;
                    var values = new Array<String>();
                    var result = results[0];
                    var grantedValue: Int;

                    if (granted) {
                        grantedValue = 1;
                    } else {
                        grantedValue = 0;
                    }

                    if (Std.parseInt(result.nb) > 0) {
                        query = 'UPDATE ' + properties.tableName + ' SET granted = ? WHERE id_user = ? AND id_server = ? AND command = ?';
                        values = [cast grantedValue, idUser, idServer, command];
                    } else {
                        query = 'INSERT INTO permission VALUES(?, ?, ?, ?)';
                        values = [idUser, idServer, command, cast grantedValue];
                    }

                    Db.instance.execute(query, values, cast function (err: Dynamic) {
                        if (err != null) {
                            Logger.exception(err);
                            callback(L.a.n.g('model.entity.permission.register.error_sql_server_saving'));
                        } else {
                            callback(null);
                        }
                    });
                }
            });
        } else {
            callback(L.a.n.g('model.entity.permission.register.error_data_format'));
        }
    }

    public static function unregister(idUser: String, idServer: String, command: String, callback: String->Void): Void {
        if (idUser.length > 0 && idServer.length > 0 && command.length > 0) {
            Db.instance.query('SELECT COUNT(*) AS nb FROM ' + properties.tableName + ' WHERE id_user = ? AND id_server = ? AND command = ?', [idUser, idServer, command], cast function (err: Dynamic, results: Array<Dynamic>) {
                if (err != null) {
                    Logger.exception(err);
                    callback(L.a.n.g('model.entity.permission.unregister.error_sql_server_retrieval'));
                } else {
                    var query: String;
                    var values = new Array<String>();
                    var result = results[0];

                    if (Std.parseInt(result.nb) > 0) {
                        query = 'DELETE FROM permission WHERE id_user = ? AND id_server = ? AND command = ?';
                        values = [idUser, idServer, command];

                        Db.instance.execute(query, values, cast function (err: Dynamic) {
                            if (err != null) {
                                Logger.exception(err);
                                callback(L.a.n.g('model.entity.permission.ununregister.error_sql_server_deleting'));
                            } else {
                                callback(null);
                            }
                        });
                    } else {
                        callback(L.a.n.g('model.entity.permission.unregister.error_404'));
                    }
                }
            });
        } else {
            callback(L.a.n.g('model.entity.permission.unregister.error_data_format'));
        }
    }

    public static function check(idUser: String, idServer: String, command: String, callback: Bool->Void): Void {
        Db.instance.get(
            'SELECT IF(' +
            '    (SELECT COUNT(*) FROM permission WHERE id_user = "' + idUser + '" AND id_server = "' + idServer + '" AND command = "' + command + '"),' +
            '    (SELECT granted FROM permission WHERE id_user = "' + idUser + '" AND id_server = "' + idServer + '" AND command = "' + command + '"),' +
            '    IF(' +
            '        (SELECT COUNT(*) FROM permission WHERE id_user = "' + idUser + '" AND id_server = "0" AND command = "' + command + '"),' +
            '        (SELECT granted FROM permission WHERE id_user = "' + idUser + '" AND id_server = "0" AND command = "' + command + '"),' +
            '        IF(' +
            '            (SELECT COUNT(*) FROM permission WHERE id_user = "0" AND id_server = "' + idServer + '" AND command = "' + command + '"),' +
            '            (SELECT granted FROM permission WHERE id_user = "0" AND id_server = "' + idServer + '" AND command = "' + command + '"),' +
            '            IF(' +
            '                (SELECT COUNT(*) FROM permission WHERE id_user = "0" AND id_server = "0" AND command = "' + command + '"),' +
            '                (SELECT granted FROM permission WHERE id_user = "0" AND id_server = "0" AND command = "' + command + '"),' +
            '                1' +
            '            )' +
            '        )' +
            '    )' +
            ') AS granted',
            function (err: Dynamic, result: Dynamic) {
                if (err) {
                    Logger.exception(err);
                    callback(false);
                } else {
                    callback(result.granted);
                }
            }
        );
    }

    public static function getDeniedCommandList(idUser: String, idServer, callback: Dynamic->Array<String>->Void): Void {
        Db.instance.getAll(
            'SELECT DISTINCT command AS cmd, (' +
            '    SELECT IF(' +
            '        (SELECT COUNT(*) FROM permission WHERE id_user = "' + idUser + '" AND id_server = "' + idServer + '" AND command = cmd),' +
            '        (SELECT granted FROM permission WHERE id_user = "' + idUser + '" AND id_server = "' + idServer + '" AND command = cmd),' +
            '        IF(' +
            '            (SELECT COUNT(*) FROM permission WHERE id_user = "' + idUser + '" AND id_server = "0" AND command = cmd),' +
            '            (SELECT granted FROM permission WHERE id_user = "' + idUser + '" AND id_server = "0" AND command = cmd),' +
            '            IF(' +
            '                (SELECT COUNT(*) FROM permission WHERE id_user = "0" AND id_server = "' + idServer + '" AND command = cmd),' +
            '                (SELECT granted FROM permission WHERE id_user = "0" AND id_server = "' + idServer + '" AND command = cmd),' +
            '                IF(' +
            '                    (SELECT COUNT(*) FROM permission WHERE id_user = "0" AND id_server = "0" AND command = cmd),' +
            '                    (SELECT granted FROM permission WHERE id_user = "0" AND id_server = "0" AND command = cmd),' +
            '                    1' +
            '                )' +
            '            )' +
            '        )' +
            '    )' +
            ') AS authorized ' +
            'FROM permission ' +
            'HAVING authorized = 0',
            [],
            function (err: Dynamic, results: Array<Dynamic>) {
                if (err) {
                    Logger.exception(err);
                    callback(err, null);
                } else {
                    var parsedResults = new Array<String>();

                    for (i in 0...results.length) {
                        parsedResults.push(results[i].cmd);
                    }

                    callback(err, parsedResults);
                }
            }
        );
    }
}