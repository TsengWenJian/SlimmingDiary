//
//  SQLiteConnect.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/5/26.
//  Copyright © 2017年 Nick. All rights reserved.
//

import Foundation

class SQLiteConnect {
    var db: OpaquePointer?
    let path: String = NSHomeDirectory() + "/Documents/sqlite3.sqlite"

    init?() {
        checkDBisExist()
        db = openDatabase(path)

        if db == nil {
            return nil
        }
    }

    func checkDBisExist() {
        let fileManager = FileManager()
        let originalPath = Bundle.main.path(forResource: "sqlite3", ofType: "sqlite")

        if !fileManager.fileExists(atPath: path) {
            do {
                try fileManager.copyItem(atPath: originalPath!, toPath: path)
            } catch {
                SHLog(message: "copy sqlite error")
            }
        }
    }

    // 連結資料庫 connect database
    func openDatabase(_ path: String) -> OpaquePointer? {
        var connectdb: OpaquePointer?

        if sqlite3_open(path, &connectdb) == SQLITE_OK {
            return connectdb!
        } else {
            return nil
        }
    }

    // 建立資料表 create table
    func createTable(_ tableName: String, columnsInfo: [String]) -> Bool {
        let sql = "create table if not exists \(tableName) "
            + "(\(columnsInfo.joined(separator: ",")))"

        if sqlite3_exec(db, sql.cString(using: String.Encoding.utf8), nil, nil, nil) == SQLITE_OK {
            return true
        }

        return false
    }

    // 新增資料
    func insert(_ tableName: String, rowInfo: [String: String]) -> Bool {
        var statement: OpaquePointer?
        let sql = "insert into \(tableName) "
            + "(\(rowInfo.keys.joined(separator: ","))) "
            + "values (\(rowInfo.values.joined(separator: ",")))"

        let utf8 = sql.cString(using: String.Encoding.utf8)

        if sqlite3_prepare_v2(db, utf8, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                return true
            }
        }
        sqlite3_finalize(statement)
        sqlite3_close(db)
        return false
    }

    // 讀取資料
    func fetch2(_ tableName: String, cond: String?, order: String?) -> [[String: Any?]] {
        var statement: OpaquePointer?
        var sql = "select * from \(tableName)"
        if let condition = cond {
            sql += " where \(condition)"
        }

        if let orderBy = order {
            sql += " order by \(orderBy)"
        }

        sqlite3_prepare_v2(db, sql.cString(using: String.Encoding.utf8), -1, &statement, nil)
        var data = [[String: Any?]]()

        while sqlite3_step(statement) == SQLITE_ROW {
            let count = sqlite3_column_count(statement)

            let data2: [String: Any?] = {
                var date3 = [String: Any?]()

                for i in 0 ..< count {
                    var value: Any?

                    switch sqlite3_column_type(statement, i) {
                    case SQLITE_INTEGER:

                        value = Int(sqlite3_column_int(statement, i))

                    case SQLITE_TEXT:
                        if let cValue = sqlite3_column_text(statement, i) {
                            value = String(cString: cValue)
                        }
                    case SQLITE_FLOAT:

                        value = sqlite3_column_double(statement, i)

                    default:

                        value = nil
                    }
                    guard let dataName = sqlite3_column_name(statement, i),
                          let key = String(validatingUTF8: dataName)
                    else {
                        break
                    }

                    date3[key] = value
                }
                return date3
            }()

            data.append(data2)
        }

        sqlite3_finalize(statement)
        sqlite3_close(db)

        return data
    }

    // 更新資料
    func update(_ tableName: String, cond: String?, rowInfo: [String: String]) -> Bool {
        var statement: OpaquePointer?
        var sql = "update \(tableName) set "

        // row info
        var info: [String] = []
        for (k, v) in rowInfo {
            info.append("\(k) = \(v)")
        }

        sql += info.joined(separator: ",")

        // condition
        if let condition = cond {
            sql += " where \(condition)"
        }

        if sqlite3_prepare_v2(db, sql.cString(using: String.Encoding.utf8), -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                return true
            }
            sqlite3_finalize(statement)
            sqlite3_close(db)
        }

        return false
    }

    // 刪除資料
    func delete(_ tableName: String, cond: String?) -> Bool {
        var statement: OpaquePointer?
        var sql = "delete from \(tableName)"

        // condition
        if let condition = cond {
            sql += " where \(condition)"
        }

        let utf8 = sql.cString(using: String.Encoding.utf8)
        if sqlite3_prepare_v2(db, utf8, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                return true
            }
            sqlite3_finalize(statement)
            sqlite3_close(db)
        }

        return false
    }
}
