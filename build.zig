const std = @import("std");
const deps = @import("deps.zig");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "zig-prometheus",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(lib);
    const main_tests = b.addTest(.{
        .name = "main",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    const examples = &[_][]const u8{
        "apple_pie",
        "basic",
    };

    inline for (examples) |name| {
        var exe = b.addExecutable(.{
            .name = "example-" ++ name,
            .root_source_file = .{ .path = "examples/" ++ name ++ "/main.zig" },
            .target = target,
            .optimize = optimize,
        });
        deps.addAllTo(exe);
        b.installArtifact(exe);

        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(b.getInstallStep());

        const run_step = b.step("run-example-" ++ name, "Run the example " ++ name);
        run_step.dependOn(&run_cmd.step);
    }

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);
}
