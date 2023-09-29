const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const stepTest = b.step("test", "Run tests");

    const main = b.addExecutable(.{
        .name = "expidus-config",
        .root_source_file = .{
            .path = "src/main.zig",
        },
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(main);

    const mainTest = b.addTest(.{
        .root_source_file = .{
            .path = "src/lib.zig",
        },
        .target = target,
        .optimize = optimize,
    });
    const mainTestExec = b.addRunArtifact(mainTest);
    stepTest.dependOn(&mainTestExec.step);
}
