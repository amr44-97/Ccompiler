const std = @import("std");
const print = std.io.getStdOut().writer().print;

pub const Parser = struct {
    const Self = @This();
    pub const TokenType = enum {
        Tok_plus,
        Tok_minus,
        Tok_star,
        Tok_int,
        Tok_slash,
        Tok_Eof,
    };

    // pub const TokenValue = struct {
    //     IntVal: ?u64 = null,
    //     Repres: ?[]u8,
    // };

    pub const Token = struct {
        Type: TokenType,
        IntVal: ?u64 = null,
        Line: usize,
    };

    const CharPos = struct {
        char: u8,
        pos: usize,
    };

    //pub fn IgnoreSpace(buffer : []u8) anyerror!u8 {
    //    var c: u8 = try File.reader().readByte();
    //    while (c == ' ' or c == '\t' or c == '\n' or c == '\r') {
    //        c = try File.reader().readByte();
    //    }
    //    return c;
    //}

    pub fn Next(File: std.fs.File, cops: CharPos) !CharPos {
        var c = try File.reader().readByte();
        return CharPos{
            .char = c,
            .pos = cops.pos + 1,
        };
    }

    pub fn ReadInt(buffer: []u8, buffer_indx: *u32) anyerror!u64 {
        var k: u64 = 0;
        while (std.ascii.isDigit(buffer[buffer_indx.*])) {
            k = k * 10 + try std.fmt.charToDigit(buffer[buffer_indx.*], 10);
            buffer_indx.* += 1;
            try print("hello\n", .{});
            if (!std.ascii.isDigit(buffer[buffer_indx.*])) {
                break;
            }
        }
        return k;
    }

    //const List = struct {
    //    len: usize,
    //    List: []Token,
    //};

    pub const List = struct {
        const Self_s = @This();
        len: usize = 0,
        List: []Token,
        var s: usize = 0;
        pub fn printer(self: Self_s) !void {
            var i: usize = 0;
            while (i < self.len) {
                try print("[Token] = {}", .{self.List[i].Type});
                if (self.List[i].IntVal == null) {
                    try print(":\t [Operator] \n", .{});
                } else {
                    try print(":\t [Intval] = {}\n", .{self.List[i].IntVal});
                }
                i += 1;
            }
        }
    };

    pub fn Tokenize(Tok: *Token, buffer: []u8, poss: usize) !List {
        //var c : u8 = try IgnoreSpace(File);
        var i: u32 = 0;
        var TokList: [10000]Token = undefined;

        var slice = List{
            .len = 0,
            .List = TokList[0..poss],
        };
        var Line: usize = 1;
        //var slice = TokList[0..poss];
        var tindx: usize = 0;
        while (i < buffer.len) {
            switch (buffer[i]) {
                ' ', '\t', '\r' => {
                    i += 1;
                    continue;
                },
                '\n' => {
                    i += 1;
                    Line += 1;
                    continue;
                },
                '+' => {
                    Tok.*.Type = TokenType.Tok_plus;
                    Tok.*.IntVal = null;
                },
                '-' => {
                    Tok.*.Type = TokenType.Tok_minus;
                    Tok.*.IntVal = null;
                },
                '*' => {
                    Tok.*.Type = TokenType.Tok_star;
                    Tok.*.IntVal = null;
                },
                '/' => {
                    Tok.*.Type = TokenType.Tok_slash;
                    Tok.*.IntVal = null;
                },
                else => {
                    //TODO try ReadInt()
                    var k: u64 = 0;
                    while (std.ascii.isDigit(buffer[i])) {
                        k = k * 10 + try std.fmt.charToDigit(buffer[i], 10);
                        i += 1;
                    }
                    Tok.*.Type = TokenType.Tok_int;
                    Tok.*.IntVal = k;
                },
            }
            slice.List[tindx] = Tok.*;
            slice.len += 1;
            tindx += 1;
            i += 1;
        }
        Tok.*.Type = TokenType.Tok_Eof;
        Tok.*.IntVal = null;
        slice.List[tindx] = Tok.*;
        slice.len += 1;
        return slice;
    }

    pub const Tree = struct {
        Intvalue: u64,
        Operation: u64,
        LeftNode: *Tree,
        RightNode: *Tree,
    };

    const ASTNodeTypes = enum { A_ADD, A_SUBTRACT, A_MULTIPLY, A_DIVIDE, A_INTLIT };

    pub fn MakeAstNode(val: u64, Operation: u64, LeftNode: *Tree, RightNode: *Tree) !*Tree {
        var n: *Tree = try std.heap.c_allocator.create(Tree);
        n.LeftNode = LeftNode;
        n.RightNode = RightNode;
        n.Operation = Operation;
        n.Intvalue = val;
        return n;
    }

    pub fn MakeAstLeaf(Operation: u64, Value: u64) !*Tree {
        return (try MakeAstNode(Value, Operation, null, null));
    }

    pub fn MakeAstUnary(Operation: u64, Value: u64, LeftNode: *Tree) !*Tree {
        return (try MakeAstNode(Value, Operation, LeftNode, null));
    }

    pub fn TokToAST(tok: u64) !u64 {
        switch (tok) {
            TokenType.Tok_plus => return ASTNodeTypes.A_ADD,
            TokenType.Tok_minus => return ASTNodeTypes.A_SUBTRACT,
            TokenType.Tok_star => return ASTNodeTypes.A_MULTIPLY,
            TokenType.Tok_slash => return ASTNodeTypes.A_DIVIDE,
            else => {
                try print("UnKnown Token on TokToAST() \n", .{});
            },
        }
    }

    pub fn primary(Tok: Token) !*Tree {
        var Node: *Tree = null;
        switch (Tok.Type) {
            TokenType.Tok_int => {
                Node = MakeAstLeaf(ASTNodeTypes.A_INTLIT, Tok.IntVal);
            },
        }
    }
};
