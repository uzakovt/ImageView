import Foundation
import XCTest

@testable import ImageView

final class ProfileViewControllerTests: XCTestCase {
    func testNotificationAndUpdateAvatarCall() {
        //given
        let vcSpy = ProfileControllerSpy()
        let presenter = ProfileControllerPresenter()
        presenter.view = vcSpy
        let exp = expectation(description: "updateAvatar called")
        vcSpy.exp = exp

        //when
        NotificationCenter.default.post(
            name: ProfileImageService.didChangeNotification, object: nil)

        //then
        wait(for: [exp], timeout: 3.0)
        XCTAssertTrue(vcSpy.updateAvatarCalled)
    }

    func testLogouAlertCallFromPresenter() {
        //given
        let vcSpy = ProfileControllerSpy()
        let presenter = ProfileControllerPresenter()
        presenter.view = vcSpy

        //when
        presenter.pressedLogout()

        //then
        XCTAssertTrue(vcSpy.showAlertCalled)
    }

    func testPresenterCallsWhenViewLoaded() {
        //given
        let vc = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        vc.presenter = presenter

        //when
        _ = vc.view

        //then
        XCTAssertTrue(presenter.updateAvatarCalled)
        XCTAssertTrue(presenter.updateProfileDataCalled)

    }
}
