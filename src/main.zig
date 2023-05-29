const std = @import("std");
const sqlite = @import("sqlite");

pub fn main() !void {
    // create connection (WORKING)
    var db = try sqlite.Db.init(sqlite.InitOptions{
        .mode = sqlite.Db.Mode{ .File = "db.sqlite" },
        .open_flags = .{
            .write = true,
            .create = true,
        },
        .threading_mode = sqlite.ThreadingMode.MultiThread,
    });

    // create table structure (WORKING)
    const emp_query =
        \\ CREATE TABLE IF NOT EXISTS `employees` (
        \\ `id` TEXT(36) NOT NULL,
        \\ `name` TEXT(20),
        \\ `dep` TEXT(20),
        \\ `last_seen` INT NOT NULL,
        \\ PRIMARY KEY (`id`)
        \\ );
    ;
    db.exec(emp_query, .{}, .{}) catch |err| {
        std.debug.print("sql error while creating emp table", .{});
        return err;
    };

    // insert a new employee (WORKING but FAILING before)
    const insert_query = "INSERT INTO employees (id, name, dep, last_seen) VALUES (?, ?, ?, ?)";
    // with diagnostics
    var diags = sqlite.Diagnostics{};
    var stmt = db.prepareWithDiags(insert_query, .{ .diags = &diags }) catch |err| {
        std.log.err("unable to prepare statement, got error {}. diagnostics: {s}", .{ err, diags });
        return err;
    };
    defer stmt.deinit();

    // execute the statement (UKNOWN?)
    try stmt.exec(sqlite.QueryOptions{ .diags = &diags }, .{ .id = "0", .name = "Tom", .dep = "IT", .last_seen = 0 });
}
