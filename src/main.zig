const std = @import("std");
const SystemConfig = @import("sys.zig");
const utils = @import("utils.zig");

pub fn main() !void {
    const alloc = std.heap.page_allocator;

    const sysconfig = try SystemConfig.fromFile(alloc, "/data/config/system.json");
    defer sysconfig.deinit();

    try std.fs.makeDirAbsolute("/var/lib/expidus-config");

    try utils.writeFile("/proc/sys/kernel/hostname", sysconfig.hostname);
    try utils.writeFile("/var/lib/expidus-config/hostname", sysconfig.hostname);

    const hosts = try utils.genHosts(alloc, sysconfig.hostname);
    defer alloc.free(hosts);
    try utils.writeFile("/var/lib/expidus-config/hosts", hosts);
}
