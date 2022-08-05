const std = @import("std");
const print = std.io.getStdOut().writer().print;

const Parser = @import("Parser.zig").Parser;

pub fn main() !void {
    const f = try std.fs.cwd().openFile("new.txt", .{ .mode = .read_only });
    const pos: usize = try f.getEndPos();
    defer f.close();

    //var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    var arena = std.heap.GeneralPurposeAllocator(.{}){};
    var cnt = try f.readToEndAlloc(arena.allocator(), pos);

    var newtok = try arena.allocator().create(Parser.Token);
    //var newtok : *Token = ;
    var Lis = try Parser.Tokenize(newtok, cnt, pos);
    //var is: usize = 0;

    //    while (is < Lis.len) {
    //        try print("[Token] = {}", .{Lis.List[is].Type});
    //        try print(":\t [Intval] = {}\n", .{Lis.List[is].IntVal});
    //        is += 1;
    //    }
    try Lis.printer();

    try print("{}\n", .{pos});
    try print("{s}\n", .{cnt});

    try print("size of token  = {}\n", .{@sizeOf(Parser.Tree)});
    arena.allocator().destroy(cnt.ptr);
    arena.allocator().destroy(newtok);
    try print("is Leak = {}\n", .{arena.detectLeaks()});
}
