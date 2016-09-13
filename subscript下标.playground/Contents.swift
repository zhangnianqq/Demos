//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"
//使用下标读取数据 使用subscript  （可以是类也可以是结构体）
class Vector3 {
    var x:Double = 0.0
    var y:Double = 0.0
    var z:Double = 0.0
    init(x:Double,y:Double,z:Double) {
        self.x = x
        self.y = y
        self.z = z
    }
    //新关键子subscript 返回类型根据环境变换
    /*使用下标读取对应的数据*/
    subscript(index:Int) -> Double?{
        get { //获取
            switch index {
            case 0:return x
            case 1:return y
            case 2:return z
            default: return nil
            }
        }
        set {//设置
            guard let newValue = newValue else {return}
            switch index {
            case 0: x = newValue
            case 1: y = newValue
            case 2: z = newValue
            default: return
            }
            print("\(newValue)")
        }
    }
    //传入字符串
    subscript(axis:String) -> Double?{
        switch axis {
        case "x","X":return x
        case "y","Y":return y
        case "z","Z":return z
        default: return nil
        }
    }
}
var v = Vector3(x: 1.0, y: 2.0, z: 3.0)
v.x
v[0]
v[100]
v["x"]
v["Z"]
v["hello"]

v[0] = 111
v[0]



//多维下标
struct Matrix{
    var data:[[Double]]
    let r:Int
    let c:Int
    init(row:Int,col:Int) {
        self.r = row
        self.c = col
        data = [[Double]]()
        for _ in 0..<r {
            let aRow = Array(count: col, repeatedValue: 0.0)
            data.append(aRow)
        }
    }
    //此处同样可以写set和get 默认是get  此处调用方法为 m[1,1]
    subscript(x:Int,y:Int) ->Double {
        get{
            assert(x>=0 && x<r && y>=0 && y<c, "数组越界")
            return data[x][y]
        }
        set {
            assert(x>=0 && x<r && y>=0 && y<c, "数组越界")
            data[x][y] = newValue
        }
    }
    
    //此处使用m[1][1] 调用   m[1] 是这个方法返回数组 [1]数组自带下标
    subscript(row:Int) -> [Double]{
        get{
            assert(row>=0 && row<r, "数组越界")
            return data[row]
        }
        //vector 向量
        set(vector){
            assert(vector.count == c, "列数错误")
            data[row] = vector
        }
    }
}
var m = Matrix(row: 2, col: 2)
m[1,1]  //此种写法才是多维下标调用 错误实例：m[1][1] 这是表示二位数组 这是调用了两个下标
m[1,1] = 100
m[1,1]

//此处使用m[1][1] 调用   m[1] 是这个方法返回数组 [1]数组自带下标
m[1][1]
m[1] = [1.3,2.4]
m[1][1]
