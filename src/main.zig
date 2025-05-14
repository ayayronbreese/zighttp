const std = @import("std");
const net = std.net;
const posix = std.posix;

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var listener = try net.StreamServer.init(.{}, allocator);
    defer listener.deinit();

    try listener.listen(.{
        .address = try net.Address.parseIp("127.0.0.1", 8080),
        .reuse_address = true,
    });

    std.debug.print("Listening on 127.0.0.1:8080...\n", .{});

    while (true) {
        const conn = try listener.accept();
        std.debug.print("Client connected\n", .{});
        try handleConnection(conn);
    }
}

fn handleConnection(conn: net.StreamServer.Connection) !void {
    const allocator = std.heap.page_allocator;
    defer conn.stream.close();

    var buf: [1024]u8 = undefined;
    const len = try conn.stream.read(&buf);
    const req = buf[0..len];

    if (std.mem.indexOf(u8, req, "GET / ") != null) {
        try conn.stream.writeAll(
            "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\nHello from Zig!\n"
        );
    } else {
        try conn.stream.writeAll(
            "HTTP/1.1 404 Not Found\r\nContent-Type: text/plain\r\n\r\nNot found\n"
        );
    }
}

