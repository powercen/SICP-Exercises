import Cocoa

// Exercise 2.36
// Redefine count-leaves from Section 2.2.2 as an accumulation

func cons<A>(value: A, _ list: [A]) -> [A] {
    var newList = list
    newList.insert(value, atIndex: 0)
    return newList
}
func car<A>(list:[A]) -> A {
    return list[0]
}
func cdr<A>(list:[A]) -> [A] {
    return Array(list[1..<list.count])
}
func accumulate<A>(op: (A, A) -> A, initial: A, seq sequence: [A]) -> A {
    if sequence.isEmpty {
        return initial
    } else {
        return op(car(sequence), accumulate(op, initial: initial, seq: cdr(sequence)))
    }
}

class Box<T>{
    let unbox: T
    init(_ value: T) {
        self.unbox = value
    }
}

enum Tree<T> {
    case Leaf(Box<T>)
    case Node([Box<Tree<T>>])
    
    var stringRepresentation: String {
        switch self {
        case let .Leaf(value):
            return " \(value.unbox)"
        case let .Node(values):
            let strings = values.map{ $0.unbox.stringRepresentation }
            return "\(strings)"
        }
    }
    
    static func leaf(value: T) -> Tree<T> {
        return Tree.Leaf(Box(value))
    }
    static func node(leaves: Tree<T>...) -> Tree<T> {
        let boxed = leaves.map { Box($0) }
        return Tree.Node(boxed)
    }
    static func list(values: T...) -> Tree<T> {
        let boxedValues = values.map { Box($0) }
        let leaves = boxedValues.map { Tree.Leaf($0) }
        let boxed = leaves.map { Box($0) }
        return Tree.Node(boxed)
    }
}

func enumerateTree(tree: Tree<Int>) -> [Int] {
    switch tree {
    case .Leaf(let value):
        return [value.unbox]
    case .Node(let values):
        return values.reduce([]) { $0 + enumerateTree($1.unbox) }
    }
}

func countLeaves(tree: Tree<Int>) -> Int {
    return accumulate({ $1 + 1 }, initial:0, seq:enumerateTree(tree))
}


let b = Tree.node(Tree.leaf(11), Tree.node(Tree.leaf(2), Tree.list(3,4), Tree.leaf(5), Tree.list(6,15)))

countLeaves(b)


func countLeaves2(tree: Tree<Int>) -> Int {
    return enumerateTree(tree).reduce(0) { (tally, _) in tally + 1 }
}
countLeaves2(b)







