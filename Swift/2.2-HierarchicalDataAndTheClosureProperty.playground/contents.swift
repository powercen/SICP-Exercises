import Cocoa

// 2.2 Hierarchical Data and the Closure Property
// As we have seen, pairs provide a primitive "glue" that we can use to contruct compound data objects. We have already seen that cons can be used to combine not only numbers but pairs as well. As a consequence, pairs provide a universal building block from which we can construct all sorts of data structures.

// The ability to create pairs whose elements are pairs is the essence of list structure's importane as a representational tool. We refer to this ability as the closure property of cons. In general, an operation for combining data objects satisfies the closure property if the results of combining things with that operation can themselves be combined using the same operation. Closure is the key to power in any means of combination because it permits us to create hierarchical structures -- structures made up of parts, which themselves are made up of parts, and so on.



struct Pair<A,B> {
    let left: A
    let right: B
}

func cons<A,B>(left: A, _ right: B) -> Pair<A,B> {
    return Pair(left: left, right: right)
}
func car<A,B>(pair: Pair<A,B>) -> A {
    return pair.left
}
func cdr<A,B>(pair: Pair<A,B>) -> B {
    return pair.right
}

// One of the useful structures we can build with pairs is a sequence -- an ordered collection of data objects. There are many ways to represent sequences in terms of pairs. One particularly straightforward representation is illustrated below for the sequence 1 2 3 4.

let abcd = cons(1, cons(2, cons(3, cons(4,()))))

/*
let ab = cons(1, cons(2, ()))
let cd = cons(3, cons(4, ()))
let acdb = cons(ab, cd)

println("\(acdb)")

extension Array {
    var decompose : (head: T, tail: [T])? {
        return (count > 0) ? (self[0], Array(self[1..<count])) : nil
    }
}

func list<T,U>(values: [T]) -> U {
    if let (head, tail) = values.decompose {
        return cons(head, list(tail))
    }
}
*/
cons(1, cons(2, cons(3, cons(4, []))))

// Lisp systems conventionally print lists by printing the sequence of elements, enclosed in parentheses. In Swift a list literal looks like this [1, 2, 3, 4] but that isn't implemented via cons. I've had trouble writing a list function in Swift (I couldn't seem to make the generics work) so I'm switching to using an array as the base of the my lists. Thus I need car and cdr re-written to accept arrays.
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

// We can think of car as selecting the first item in the list, and of cdr as selecting the sublist consisting of all but the first item. Nested applications of car and cdr can be used to extract the second, third and subsequent items in the list.

let oneThroughFour = [1,2,3,4]
car(oneThroughFour)
cdr(oneThroughFour)

// cons(10, oneThroughFour)
// cons(5, oneThroughFour)


// List operations
// The use of pairs to represent sequences of elements as lists is accompanied by conventional programming techniques for manipulating lists by successively "cdring down" the lists. For example, the procedure list-ref takes as arguments a list and a number n and returns the nth item of the list. It is customary to number the elements of the list beginning with 0. The method for computing list-ref is the following:
// - For n == 0, list-ref should return the car of the list.
// - Otherwise, list-ref should return the (n-1)st item of the cdr of the list

func listRef<A>(items:[A], _ n: Int) -> A {
    if n == 0 {
        return car(items)
    } else {
        return listRef(cdr(items), n - 1)
    }
}
let squares = [1, 4, 9, 16, 25]
listRef(squares, 3)

// Often we cdr down the whole list. To aid in this, Swift includes a primitive predicate isEmpty, which tests whether its argument is the empty list. The procedure length, which returns the number of items in a list, illustrates this typical pattern of use:

func length<A>(items: [A]) -> Int {
    if items.isEmpty {
        return 0
    } else {
        return length(cdr(items)) + 1
    }
}
let odds = [1, 3, 5, 7]
length(odds)

// The length procedure implements a simple recursive plan. The reduction step is
// - The length of any list is 1 plus the length of the cdr of the list.
// This is applied successively until we reach the base case:
// - The length of the empty list is 0

// We could also compute length in an iterative style

func length2<A>(items: [A]) -> Int {
    var lengthIter: ([A], Int) -> Int = { _, _ in return 0 }
    lengthIter = { a, count in
        if a.isEmpty {
            return count
        } else {
            return lengthIter(cdr(a), count + 1)
        }
    }
    return lengthIter(items, 0)
}
length2(odds)

// Another conventional programming technique is to "cons up" an answer list while cdring down a list, as in the procedure append, which takes two lists as arguments and combines their elements to make a new list:

// Append is also implemented using a recursive plan. To append lists list1 and list2, do the following
// - If list1 is the empty list, then the result is just list2
// - Otherwise, append the cdr of list1 and list2, and cons the car of list1 onto the result

func append<A>(list1: [A], _ list2: [A]) -> [A] {
    if list1.isEmpty {
        return list2
    } else {
        return cons(car(list1), append(cdr(list1), list2))
    }
}

append(squares, odds)
append(odds, squares)


// Mapping over lists
// One extremely useful operation is to apply some transformation to each element in a list and generate the list of results. For instance, the following procedure scales each number in a list by a given factor:

func scaleList(items: [Double], _ factor: Double) -> [Double] {
    if items.isEmpty {
        return []
    } else {
        return cons(car(items) * factor, scaleList(cdr(items), factor))
    }
}
scaleList([1, 2, 3, 4, 5], 10)

// We can abstract this general idea and capture it as a common pattern expressed as a higher-order procedure, just as in section 1.3. The higher-order procedure here is called map. Map takes as arguments a procedure of one argument and a list, and returns a list of the results produced by applying the procedure to each element in the list:

func map<T, U>(proc:(T) -> U, _ items: [T]) -> [U] {
    if items.isEmpty {
        return []
    } else {
        return cons(proc(car(items)), map(proc, cdr(items)))
    }
}

map(abs, [-10, 2.5, -11.6, 17])
map({ x in x * x }, [1, 2, 3, 4])
// Now we can give a new definition of scaleList in terms of map:
func scaleList2(items: [Double], _ factor: Double) -> [Double] {
    return map({ x in x * factor }, items)
}
scaleList2([1, 2, 3, 4, 5], 10)

// Map is an important construct not only because it captures a common pattern, but because it establishes a higher level of abstraction in dealing with lists. In the original definition of scaleList, the recursive structure of the program draws attention to the element-by-element processing of the list. Defining scaleList in terms of map suppresses that level of detail and emphasizes that scaling transforms a list of elements to a list of results. The difference between the two definitions is not that the computer is performing a different process (it isn't) but that we think about the process differently. In effect, map helps establish an abstraction barrier that isolates the implementation of procedures that trahsform lists from the details of how the elements of the list are extracted and combined. Like the barriers shown in figure 2.1, this abstraction gives us the flexibility to change the low-level details of how sequences are implemented, while preserving the conceptual framework of operations that transform sequences to sequences.


// 2.2.2 Hierarchical Structures
// The representation of sequences in terms of lists generalizes naturally to represent sequences whose elements may themselves be sequences. For example, we can regard the object ((1 2) 3 4) constructed by

cons([1, 2], [3, 4])

// as a list of three items, the first of which is itself a list, (1 2). Indeed, this is suggested by the form in which the result is printed by the interpreter.

// Another way to think of sequences whose elements are sequences is as trees. The elements of the sequence are the branches of the tree, and elements that are themselves sequences are subtrees.

// Recursion is a natural tool for dealing with tree structures, since we can often reduce operations on trees to operations on their branches, which reduce in turn to operations on the branches of the branches, and so on, until we reach the leaves of the tree. As an example, compare the length procedure of section 2.2.1 with the count-leaves procedure, which returns the total number of leaves of a tree.

// To implement count-leaves, recall the recursive plan for computing length:
// - Length of a list x is 1 plus length of the cdr of x
// - Length of the empty list is 0

// Count-leaves is similar. The value for the empty list is the same:
// - Count-leaves of the empty list is 0
// But in the reduction step, where we strip off the car of the list, we must take into account that the car may itself be a tree whose leaves we need to count. Thus, the appropriate reduction step is
// - Count-leaves of a tree x is count-leaves of the car of x plus count-leaves of the cdr of x

// Finally, by taking cars we reach actual leaves, so we need another base case:
// - Count-leaves of a leaf is 1.

// To aid in writing recursive procedures on trees, Scheme provides the primitive predicate pair?, which tests whether its argument is a pair. Here is the complete procedure

func countLeaves(x: Int) -> Int {
    return 1
}

func countLeaves(x: [Int]) -> Int {
    switch true {
    case x.isEmpty:
        return 0
    default:
        return countLeaves(car(x)) + countLeaves(cdr(x))
    }
}

func countLeaves(x: Pair<[Int],[Int]>) -> Int {
    return countLeaves(car(x)) + countLeaves(cdr(x))
}

let x = cons([1,2],[3,4])
countLeaves(x)


// Mapping over trees
// Just as map is a powerful abstraction for dealing with sequences, map together with recursion is a powerful abstraction for dealing with trees. For instance, the scale-tree procedure, analogous to scale-list of section 2.2.1 takes as arguments a numeric factor and a tree whose leaves are numbers. It returns a tree of the same shape, where each number is multiplied by the factor. The recursive plan for scale-tree is similar to the one for count-leaves:

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
            let strings = values.map { $0.unbox.stringRepresentation }
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

//let xx = Tree.Node(Box([Tree.Node(Box([Tree.Leaf(Box(1)),Tree.Leaf(Box(2))]),Tree.Leaf(Box(3)), Tree.Leaf(Box(4)))]))

let a = Tree.Node([Box(.Leaf(Box(3))), Box(.Leaf(Box(4)))])
a.stringRepresentation


let b = Tree.node(Tree.leaf(1), Tree.node(Tree.leaf(2), Tree.list(3,4), Tree.leaf(5), Tree.list(6,7)))
print("\(b.stringRepresentation)")

protocol Multipliable: Equatable {
    func *(lhs: Self, rhs: Self) -> Self
}
extension Int: Multipliable {}
extension Double: Multipliable {}

func scaleTree<T: Multipliable>(tree: Tree<T>, _ factor: T) -> Tree<T> {
    switch tree {
    case let .Leaf(value):
        return Tree.leaf(value.unbox * factor)
    case let .Node(values):
        let newValues = values.map { Box(scaleTree($0.unbox, factor)) }
        return Tree.Node(newValues)
    }
}

let c = scaleTree(b, 10)
c.stringRepresentation


// 2.2.3 Sequences as Conventional Interfaces

// In working with compound data, we've stressed how data abstraction permits us to design programs without becoming enmeshed in the details of data representations, and how abstraction preserves for us the flexibility to experiment with alternative representations. In this section we introduce another powerful design principle for working with data structures - the use of conventional interfaces.
// In Section 1.3 we say how program abstractions, implemented as higher-order procedures, can capture common patterns in programs that deal with numerical data. Our ability to formulate analogous operations for working with compound data depends crucially on the style in which we manipulate our data structures. Consider, for example, the following procedure, analogous to the count-leaves procedure of section 2.2.2, which takes a tree as argument and computes the sum of the squares of the leaves that are odd:

func isEven(x: Int) -> Bool {
    return x % 2 == 0
}
func isOdd(x: Int) -> Bool {
    return x % 2 != 0
}

isOdd(1)
isOdd(2)
isOdd(3)

func square(x: Int) -> Int { return x * x }

func sumOddSquares(tree: Tree<Int>) -> Int {
    switch tree {
    case .Leaf(let value):
        return isOdd(value.unbox) ? square(value.unbox) : 0
    case .Node(let values):
        return values.reduce(0) { $0 + sumOddSquares($1.unbox) }
    }
}

1 + (3*3) + (5*5) + (7*7)
sumOddSquares(b)

//On the surface, this procedure is very different from the following one, which constructs a list of all the even Fibonacci numbers Fib(k), where k is less than or equal to a given integer n:

func fib(n: Int) -> Int {
    switch true {
    case n == 0:
        return 0
    case n == 1:
        return 1
    default:
        return fib(n - 1) + fib(n - 2)
    }
}

func evenFibs(fromFirstNFibs n: Int) -> [Int] {
    var next: (Int) -> [Int] = { _ in return [] }
    next = { (k: Int) in
        if k > n {
            return []
        } else {
            let f = fib(k)
            if isEven(f) {
                return cons(f, next(k + 1))
            } else {
                return next(k + 1)
            }
        }
    }
    return next(0)
}

evenFibs(fromFirstNFibs: 10)

// Despite the fact that these two procedures are structurally very different, a more abstract description of the two computations reveals a great deal of similarity. The first program
// - Enumerates the leaves of a tree
// - filters them, selecting the odd ones
// - squares each of the selected ones, and
// - accumulates the results using +, starting with 0

// The second program
// - Enumerates the integers from 0 to n
// - computes the Fibonacci number for each integer
// - filters them, selecting the even ones, and
// - accumulates the results using cons, starting with an empty list

// A signal processing engineer would find it natural to conceptualize these processes in terms of signals flowing through a cascade of stages, each of which implements part of the program plan. In sum-odd-squares, we begin with an enumerator, which generates a signal consisting of the leaves of a given tree. This signal is passed through a filter, which eliminates all but the odd elements. The resulting signal is in turn passed through a map, which is a transducer that applies the square procedure to each element. The output of the map is then fed to an accumulator, which combines the elements using +, starting from an initial 0. The plan for even-fibs is analogous.
// Unfortunately, the two procedure definitions above fail to exhibit this signal-flow structure. For instance, if we examine the sum-odd-squares procedure, we find that the enumeration is implemented partly by the null? and pair? tests and partly bu the tree-recursive structure of the procedure. Similarly, the accumulation is found partly in the tests and partly in the addition used in the recursion In general, there are no distinct parts of either procedure that correspond to the elements in the signal-flow description. Our two procedures decompose the computations in a different way, spreading the enumeration over the program mingling it with the map, the filter and the accumulation. If we could organize our programs to make the signal-flow structure manifest in the procedures we write, this would increase the conceptual clarity of the resulting code.


// Sequence Operations
// The key to organising programs so as to more clearly reflect the signal-flow structure is to concentrate on the "signals" that flow from one stage in the process to the next. If we represent these signals as lists, then we can use list operations to implement the processing at each of the stages. For instance, we can implement the mapping stages of the signal-flow diagrams using the map procedure from section 2.2.1

[1,2,3,4,5].map(square)

//Filtering a sequence to select only those elements that satisfy a given predicate is accomplished by

func filterDRP(predicate: (Int) -> Bool, _ sequence: [Int]) -> [Int] {
    switch true {
    case sequence.isEmpty:
        return []
    case predicate(car(sequence)):
        return cons(car(sequence), filterDRP(predicate, cdr(sequence)))
    default:
        return filterDRP(predicate, cdr(sequence))
    }
}

filterDRP(isOdd, [1,2,3,4,5])
[1,2,3,4,5].filter(isOdd)

// Accumulations can be implemented by
func accumulate(op: (Int, Int) -> Int, _ initial: Int, _ sequence: [Int]) -> Int {
    if sequence.isEmpty {
        return initial
    } else {
        return op(car(sequence), accumulate(op, initial, cdr(sequence)))
    }
}

accumulate(+, 0, [1,2,3,4,5])
accumulate(*, 1, [1,2,3,4,5])
// accumulate(cons, [], [1,2,3,4,5]) // Needs a generic version of accumulate.

[1,2,3,4,5].reduce(0, combine: +)
[1,2,3,4,5].reduce(1, combine: *)

// All that remains to implement signal-flow diagrams is to enumerate the sequence of elements to be processed. For even-fibs, we need to generate the sequence of integers in a given range, which we can do as follows

func enumerateInterval(low: Int, _ high:Int) -> [Int] {
    if low > high {
        return []
    } else  {
        return cons(low, enumerateInterval(low + 1, high))
    }
}

enumerateInterval(3, 10)

// or in Swift
Array(3...10)

// TO enumerate the leaves of a tree we can use
func enumerateTree(tree: Tree<Int>) -> [Int] {
    switch tree {
    case .Leaf(let value):
        return [value.unbox]
    case .Node(let values):
        return values.reduce([]) { $0 + enumerateTree($1.unbox) }
    }
}

enumerateTree(b)
enumerateTree(c)

// Now we can reformulate sum-odd-squares and even-fibs as in the signal-flow diagrams. For sum-odd-squares, we enumerate the sequence of leaves of the tree, filter this to keep only the odd numbers in the sequence, square each element, and sum the results

func sumOddSquares2(tree: Tree<Int>) -> Int {
    return accumulate(+, 0, filterDRP(isOdd, enumerateTree(b)).map(square))
}
sumOddSquares2(b)

func sumOddSquares3(tree: Tree<Int>) -> Int {
    return enumerateTree(b).filter(isOdd).map(square).reduce(0, combine: +)
}
sumOddSquares3(b)

// For even-fibs, we enumerate the integers from 0 to n, generate the fibonacci number for each of these integers, filter the resulting sequence to keep only the even elements, and accumulate the results into a list

func evenFibs2(n: Int) -> [Int] {
    return Array(0...n).map(fib).filter(isEven).reduce([]) { $0 + [$1] }
}
evenFibs2(10)

// The value of expressing programs as sequence operations is that this helps us make program designs that are modular, that is, designs that are constructed by combining relatively independent pieces. We can encourage modular design by providing a library of standard componsnts together with a conventional intergace for connecting the components in flexible ways.
// Modular construction is a powerful strategy for controlling complexity in engineering design. In real signal-processing applications, for example, designers regularly build systems by cascading elements selected from standardized families of filters and transducers. Similarly, sequence operations provide a library of standard program elements that we can mix and match. For instance, we can reuse pieces from the sum-odd-squares and even-fibs procedures in a program that constructs a list of the squares of the first n + 1 Fibonaccy numbers:

func listFibSquares(n: Int) -> [Int] {
    return Array(0...n).map(fib).map(square)
}
listFibSquares(10)

// We can rearrange the pieces and use them in computing the product of the squares of the odd integers in a sequence:
func productOfSquaresOfOddElements(sequence: [Int]) -> Int {
    return sequence.filter(isOdd).map(square).reduce(1, combine: *)
}
productOfSquaresOfOddElements(Array(1...5))

// We can also formulate conventional data-processing applications in terms of sequence operations. Suppose we have a sequence of personnel records and we want to find the salary of the highest-paid programmer. Assume that we have a selector salary that returns the salary of a record, and a predicate programmer? that tests if a record is for a programmer. Then we can write
struct Employee {
    let job: String
    let salary: Int
}

func salaryOfHighestPaidProgrammer(records: [Employee]) -> Int {
    let salariesOfHighestPaidProgrammers = records.filter{ $0.job == "Programmer" }
    return salariesOfHighestPaidProgrammers.reduce(0) { max($0, $1.salary) }
}

let employees = [Employee(job: "Programmer", salary: 90000),Employee(job: "Programmer", salary: 70000), Employee(job: "Programmer", salary: 90010), Employee(job: "Gamer", salary: 900000)]
salaryOfHighestPaidProgrammer(employees)

// These examples give just a hint of the vast range of operations that can be expressed as sequence operations.
// Sequences, implemented here as lists, serve as a conventional intergace that permits us to combine processing modules. Additionally, when we uniformly represent structures as sequences, we have localized the data-structure dependencies in our programs to a small number of sequence operations. By changing these we can experiment with alternative representations of sequences, while leaving the overall design of our programs intact. We will exploit this capability in Section 3.5, when we generalize the sequence-processing paradigm to admit infinite sequences.



// Nested Mappings
// We can extend the sequence paradigm to include many computations that are commonly expressed using nested loops. Consider this problem: Given a positive integer n, find all ordered pairs of distinct positive integers i and j, where 1 <= j <= i <= n, such that i + j is prime. For example if n = 6, then the pairs are the following

//   i   | 2 3 4 4 5 6 6
//   j   | 1 2 1 3 2 1 5
// ----------------------
// i + j | 3 5 5 7 7 7 11

// A natural way to organise this computaton is to generate the sequence of all ordered pairs of positive integers less than or equal to n, filter to select those whose sum is prime, and then, for each pair (i, j) that passes through the filter, produce the triple (i, j, i + j).

// Here is a way to generate the sequence of pairs: For each integer i <= n, enumerate the integers j < i, and for each such i and j generate the pair (i, j). In terms of sequence operations, we map along the sequence (enumerate-interval 1 n). For each i in this sequence, we map along the sequence (enumerate-interval 1 (- i 1)). For each j in this latter sequence, we generate the pair (list i j). This gives us a sequence of pairs for each i. Combining all the sequences for all the i (by accumulating with append) produces the required sequence of pairs:

let n = 6
let lists = map({ i in map({ j in return [i,j] }, enumerateInterval(1, i - 1)) }, enumerateInterval(1, n))
print("\(lists)")

//let flattened: [[Int]] = accumulate(append, [[1]], lists)

// The combination of mapping and accumulating with append is so common in this sort of program that we will isolate it as a separate procedure:
/*
func flatMap(proc: (Int) -> Int, seq: [Int]) -> [Int] {
    return accumulate(append, [], seq)
}
*/

// Now filter this sequence of pairs to find those whose sum is prime. The filter predicate is called for each element of the sequence; its argument is a pair and it must extract the integers from the pair. Thus, the predicate to apply to each element in the sequence is

func dividesWithNoRemainder(a: Int, _ b: Int) -> Bool {
    return  a % b == 0
}
dividesWithNoRemainder(10, 2)

func findDivisor(n: Int, _ testDivisor: Int) -> Int {
    switch true {
    case square(testDivisor) > n:
        return n
    case dividesWithNoRemainder(n, testDivisor):
        return testDivisor
    default:
        return findDivisor(n, testDivisor + 1)
    }
}

func smallestDivisor(n: Int) -> Int {
    return findDivisor(n, 2)
}

func isPrime(n:Int) -> Bool {
    return n == smallestDivisor(n)
}

func isPrimeSum(pair: [Int]) -> Bool {
    return isPrime(pair[0] + pair[1]) // ??? No Type Checking
}

// Finally, generate the sequence of results by mapping over the filtered pairs using the following procedure, which constructs a triple consisting of the two elements of the pair along with their sum:

func makePairSum(pair: [Int]) -> [Int] {
    return [pair[0], pair[1], pair[0] + pair[1]]
}

// Combining all these steps yields the complete procdure

func primeSumPairs(n: Int) -> [[Int]] {
    let possibles = enumerateInterval(1, n).flatMap() { i in
        return enumerateInterval(1, i - 1).map() { j in
            return [i,j]
        }
    }
    return possibles.filter(isPrimeSum).map(makePairSum)
}

primeSumPairs(6)


// Can I do better using tuples? This was you can't pass in an array of the wrong length at any stage.

func isPrimeSum(pair: (Int,Int)) -> Bool {
    return isPrime(pair.0 + pair.1)
}

func makePairSum(pair: (Int,Int)) -> (Int,Int,Int) {
    return (pair.0, pair.1, pair.0 + pair.1)
}

func primeSumPairs2(n: Int) -> [(Int,Int,Int)] {
    let possibles = enumerateInterval(1, n).flatMap() { i in
        enumerateInterval(1, i - 1).map() { j in (i,j) }}
    
    return possibles.filter(isPrimeSum).map(makePairSum)
}
print("\(primeSumPairs2(6))")

// Maybe it would be better if I gave (Int,Int) a name like IntPair???
// Or would it be best if the tuple components are named
let (left, right, sum) = makePairSum((2,3))
// This use of tuples to box up a collection of parameters is interesting. It allows for makePairSum and isPrimeSum to be used very concisely in the map and filter functions above (as opposed to having to use trailing closures so as to fill out multiple parameters). However that does mean that isPrimeSum, which by rights should take two parameters not mysteriously takes a single parameter which happens to contain two values. I can't tell if this is a win or not???
// There is something a little horrifying about the chained map, filter, reduce calls. They are extremely powerful, elegant and succinct but they are completely unintuitive. Thinking some more about them I can see why the .map syntax is popular. Feels a lot more like the pipe that it is. Still this method kind of feels like it is in reverse.

// Nested mappings are also useful for sequences other than those that enumerate intervals. Suppose we wish to generate all the permutations of a set s; that is, all the ways of ordering the items in the set. 
// Here is a plan for generating the permutations of S: For each item x in S, recursively generate the sequence of permutations of S - x, and adjoin x to the front of each one. This yields, for each x in S, the sequence of permutations of S that begin with x. Combining these sequences for all x gives all the permutations of S:

func remove(item: Int, _ sequence: [Int]) -> [Int] {
    return sequence.filter() { x in x != item }
}

func permutations(s:[Int]) -> [[Int]] {
    if s.isEmpty {
        return [[]]
    } else {
        return s.flatMap() { x in
            permutations(remove(x,s)).map { p in [x] + p }
        }
    }
}

permutations([1,2,3])

// Notice how this strategy reduces the problem of generating permutations of S to the problem of generating the permutations of sets with fewer elements than S. In the ternminal case, we work our way down to the empty list, which represents a set of no elements. For this, we generate [[]], which is a sequence with one item, namely the set with no elements. The remove procedure used in permutations returns all the items in a given sequence except for a given item.



// 2.2.4 Example: A Picture Language

// Levels of language for robust design
// The picture language exercises some of the critical ideas we've introduced about abstraction with procedures and data. The fundamental data abstractions, painters, are implemented using procedural representations, which enables the language to handle different basic drawing capabilities in a uniform way. The means of combination satisfy the closure protery, which permits us to easily build up complex designs. Finally, all the tools for abstracting proceures are available to us for abstracting means of combination for painters.
// We have also obtained a glimpse of another crucial idea about languages and program design. This is the approach of stratified design, the notion that a complex system should be structured as a sequence of levels that are described using a seguence of languages. Each level is constructed by combining parts that are regarded as primitive at that level, and the parts constructed at each level are used as primitives at the next level. The language used at each level of a stratified design has primitives, means of combination, and means of abstraction appropriate to that level of detail.
// Stratified design pervades the engineering of complex systems. For example, in computer engineering, resistors and transistors are combined (and described using a language of analog circuits) to produce parts such as and-gates and or-gates, which form the primitives of a language for digital-circuit design. These parts are combined to build processors, bus structures, and memory systems, which are in turn combined to form computers, using languages appropriate to computer architecture. Computers are combined to form distributed systems, using languages appropriate for describing network interconnections, and so on.
// As a tiny example of stratification, our picture language uses primitive elements (primitive painters) that are created using a language that specifies points and lines to provide the lists of line segments for segmentsToPainter, or the shading details for a painter like rogers. The bulk of our description of the picture language focused on combining these primitives, using geometric combiners such as beside and below. We also worked at a higher level, regarding beside and below as primitives to be manipulated in a language whose operations, such as squareOfFour, capture common patterns of combining geometric combiners.
// Stratified design helps make programs robust, that is it makes it likely that small changes in a specification will require correspondingly small changes in the program. For instance, suppose we wanted to change the image based on wave shown in Figure 2.9. We could work at the lowest level to change the detailed appearance of the wave element; we could work at the middle level to change the way cornerSplit replicates the wave; we could work at the highest level to change how squareLimit arranges the four copies of the corner. In genera, each level of a stratified design provides a different vocabulary for expressing the characteristics of the system, and a different kind of ability to change it.





