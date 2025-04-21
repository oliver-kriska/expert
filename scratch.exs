text = File.read!("code.txt")
d = doc(:expert, text)
p = pos(d, 4, 12)
Lexical.Ast.path_at(d, p)
