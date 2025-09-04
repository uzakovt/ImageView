import XCTest

final class ImageViewUITests: XCTestCase {

    private let app = XCUIApplication()  // переменная приложения

    override func setUpWithError() throws {
        continueAfterFailure = false  // настройка выполнения тестов, которая прекратит выполнения тестов, если в тесте что-то пошло не так

        app.launch()  // запускаем приложение перед каждым тестом
    }

    func testAuth() throws {
        // Нажать кнопку авторизации
        app.buttons["Authenticate"].tap()
        
        // Подождать, пока экран авторизации открывается и загружается
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        // Ввести данные в форму
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 3))
        loginTextField.tap()
        loginTextField.typeText("t@uzakovv.ru")
        loginTextField.swipeUp()

        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 3))
        passwordTextField.tap()
        passwordTextField.typeText("Adadad2002ad")
        webView.swipeUp()

        // Нажать кнопку логина
        webView.buttons["Login"].tap()

        // Подождать, пока открывается экран ленты
        let tableQuery = app.tables
        let cell = tableQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }

    func testFeed() throws {
        // Подождать, пока открывается и загружается экран ленты
        sleep(5)
        let tableQuery = app.tables
        let cell = tableQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
        // Сделать жест «смахивания» вверх по экрану для его скролла
        cell.swipeUp()
        // Поставить лайк в ячейке верхней картинки
        let nextCell = tableQuery.children(matching: .cell).element(boundBy: 1)
        nextCell.buttons["Like button"].tap()
        sleep(3)
        // Отменить лайк в ячейке верхней картинки
        nextCell.buttons["Like button"].tap()
        sleep(3)
        // Нажать на верхнюю ячейку
        nextCell.tap()
        sleep(3)
        // Подождать, пока картинка открывается на весь экран
        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 3))
        // Увеличить картинку
        image.pinch(withScale: 3.0, velocity: 1)
        // Уменьшить картинку
        image.pinch(withScale: 0.5, velocity: -1)
        // Вернуться на экран ленты
        app.buttons["backward"].tap()
    }

    func testProfile() throws {
        // Подождать, пока открывается и загружается экран ленты
        sleep(3)
        let tableQuery = app.tables
        let cell = tableQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
        
        //Перейти на страницу профилья
        app.tabBars.buttons.element(boundBy: 1).tap()
        XCTAssertTrue(app.staticTexts["@username"].exists)
        
        //Нажать на кнопку выйти
        app.buttons["logout"].tap()
        
        //Нажать на кнопку алерта
        app.alerts["Bye bye!"].scrollViews.otherElements.buttons["yes"].tap()
    }
}
