//
//  TestUITests.swift
//  TestUITests
//
//  Created by zhangnian on 16/9/18.
//  Copyright © 2016年 zhangnian. All rights reserved.
//

import XCTest

class TestUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    
//        XCTAssertEqual(app.navigationBars.element.identifier, "ttt")
        
        
        let app = XCUIApplication()
        let textView = app.otherElements.containing(.navigationBar, identifier:"MainViewController").children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .textView).element
        textView.tap()
        textView.typeText("456")
        //校验当前视图是否是MainVC
        XCTAssertEqual(app.navigationBars.element.identifier, "MainViewController")

        app.buttons["跳转"].tap()
        
        let textView2 = app.otherElements.containing(.navigationBar, identifier:"SubViewControllre").children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .textView).element
        textView2.tap()
        textView2.tap()
        //校验当前视图是否是subVC
        XCTAssertEqual(app.navigationBars.element.identifier, "SubViewControllre")

        app.buttons["跳回"].tap()
        textView.tap()
        //校验当前视图是否是MainVC
        XCTAssertEqual(app.navigationBars.element.identifier, "MainViewController")

    }
    
}
