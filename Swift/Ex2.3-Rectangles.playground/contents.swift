import Cocoa

// Exercise 2.3
// Implement a representation for rectangles in a plane. In terms of your constructors and selectors, create procedures that comput the perimeter and the area of a given rectangle.

// Now implement a different representation for rectangles.

// Can you design your system with suitable abstraction barriers so that the same perimeter and area procedures will work using either representation?


enum ConsPosition {
    case Left, Right
}

func cons<T>(a: T, _ b: T) -> (ConsPosition -> T) {
    func innerCons(i: ConsPosition) -> T {
        if i == .Left {
            return a;
        } else {
            return b;
        }
    }
    
    return innerCons;
}

func car<T>(innerCons: ConsPosition -> T) -> T {
    return innerCons(.Left);
}

func cdr<T>(innerCons: ConsPosition -> T) -> T {
    return innerCons(.Right);
}




typealias Point = (ConsPosition -> Double)

func makePoint(x: Double, _ y: Double) -> Point {
    return cons(x, y)
}
func xPoint(x: Point) -> Double {
    return car(x)
}
func yPoint(x: Point) -> Double {
    return cdr(x)
}
func printPoint(x: Point) {
    print("(\(xPoint(x)),\(yPoint(x)))")
}



typealias Segment = (ConsPosition -> Point)

func makeSegment(start: Point, _ end: Point) -> Segment {
    return cons(start, end)
}
func startSegment(x: Segment) -> Point {
    return car(x)
}
func endSegment(x: Segment) -> Point {
    return cdr(x)
}
func midpointSegment(x: Segment) -> Point {
    func average(a: Double, _ b: Double) -> Double {
        return (a + b) / 2
    }
    return makePoint(average(xPoint(startSegment(x)), xPoint(endSegment(x))), average(yPoint(startSegment(x)), yPoint(endSegment(x))))
}


typealias Size = (ConsPosition -> Double)
func makeSize(width: Double, _ height: Double) -> Size {
    return cons(width, height)
}
func width(x: Size) -> Double {
    return car(x)
}
func height(x: Size) -> Double {
    return cdr(x)
}

typealias Rect = (ConsPosition -> Point)
func makeRect(origin: Point, _ size: Size) -> Rect {
    return cons(origin, size)
}
func origin(x: Rect) -> Point {
    return car(x)
}
func size(x: Rect) -> Size {
    return cdr(x)
}

func perimeter(rect: Rect) -> Double {
    let theWidth = width(size(rect))
    let theHeight = height(size(rect))
    return 2 * (theWidth + theHeight)
}
func area(rect: Rect) -> Double {
    let theWidth = width(size(rect))
    let theHeight = height(size(rect))
    return theWidth * theHeight
}

let rect1 = makeRect(makePoint(0, 0), makeSize(4, 6))
perimeter(rect1)
area(rect1)

typealias Rect2 = (ConsPosition -> Point)
func makeRect2(origin: Point, _ diagonal: Point) -> Rect {
    return cons(origin, diagonal)
}
func origin2(x: Rect2) -> Point {
    return car(x)
}
func diagonal(x: Rect2) -> Point {
    return cdr(x)
}
func size2(x: Rect2) -> Size {
    return makeSize(abs(xPoint(origin2(x)) - xPoint(diagonal(x))), abs(yPoint(origin2(x)) - yPoint(diagonal(x))))
}

func perimeter2(rect: Rect2) -> Double {
    let theWidth = width(size2(rect))
    let theHeight = height(size2(rect))
    return 2 * (theWidth + theHeight)
}
func area2(rect: Rect2) -> Double {
    let theWidth = width(size2(rect))
    let theHeight = height(size2(rect))
    return theWidth * theHeight
}

let rect2 = makeRect2(makePoint(0, 0), makeSize(4, 6))
perimeter2(rect2)
area2(rect2)


