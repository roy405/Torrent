@testable import Torrent
import XCTest
import CoreData

final class TorrentTests: XCTestCase {
    
    var feedbackViewModel: FeedbackViewModel!
    var recommendationViewModel: RecommendationViewModel!
    var cityViewModel: CityViewModel!
    
    var persistenceController: PersistenceController!
    var mockContainer: NSPersistentCloudKitContainer!

    override func setUp() {
        super.setUp()
        // Setup a mock container.
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle(for: type(of: self))])!
        mockContainer = NSPersistentCloudKitContainer(name: "Torrent", managedObjectModel: managedObjectModel)
        mockContainer.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        mockContainer.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Failed to load mock persistent store: \(error)")
            }
        }
        persistenceController = PersistenceController()
        persistenceController.container = mockContainer
    }

    override func setUpWithError() throws {
       try super.setUpWithError()
        feedbackViewModel = FeedbackViewModel()
        recommendationViewModel = RecommendationViewModel()
        cityViewModel = CityViewModel()
    }

    override func tearDownWithError() throws {
        feedbackViewModel = nil
        recommendationViewModel = nil
        cityViewModel = nil
        try super.tearDownWithError()
    }
    
    func testSaveCityToCoreData() {
        let city = CityData(id: 12345, cityname: "TestCity", country: "TestCountry", latitude: 12.345, longitude: 67.890)
        let result = persistenceController.saveCitiesToCoreData([city])
        switch result {
        case .success:
            XCTAssertTrue(true)
        case .failure(_):
            XCTFail("Failed to save city to Core Data")
        }
    }

    func testSaveOrUpdateCurrentWeather() {
        let weatherModel = CurrentWeatherModel(temperature: 25.5, conditionText: "Sunny", conditionIconURL: "http://image.jpg", location: "TestCity, TestCountry")
        let result = persistenceController.saveOrUpdateCurrentWeather(from: weatherModel)
        switch result {
        case .success:
            XCTAssertTrue(true)
        case .failure(_):
            XCTFail("Failed to save or update weather in Core Data")
        }
    }

    func testDeleteFeedback() {
        let feedback = FeedbackModel(id: UUID(), city: "TestCity", country: "TestCountry", reportedTemperature: 25.0, reportedCondition: "Rainy", actualTemperature: 24.5, actualCondition: "Cloudy")
        _ = persistenceController.saveFeedbackToCoreData(feedback: feedback)
        let result = persistenceController.deleteFeedback(feedback: feedback)
        switch result {
        case .success:
            XCTAssertTrue(true)
        case .failure(_):
            XCTFail("Failed to delete feedback from Core Data")
        }
    }

    func testFetchCities() {
        let city = CityData(id: 54321, cityname: "FetchCity", country: "FetchCountry", latitude: 12.345, longitude: 67.890)
        _ = persistenceController.saveCitiesToCoreData([city])
        let result = persistenceController.fetchCities()
        switch result {
        case .success(let cities):
            XCTAssert(cities.contains(where: { $0.cityname == "FetchCity" && $0.country == "FetchCountry" }))
        case .failure(_):
            XCTFail("Fetching cities failed.")
        }
    }

    func testFetchAllFeedbacks() {
        let feedback = FeedbackModel(id: UUID(), city: "FeedbackCity", country: "FeedbackCountry", reportedTemperature: 25.0, reportedCondition: "Rainy", actualTemperature: 24.5, actualCondition: "Cloudy")
        _ = persistenceController.saveFeedbackToCoreData(feedback: feedback)
        let result = persistenceController.fetchAllFeedbacks()
        switch result {
        case .success(let feedbacks):
            XCTAssert(feedbacks.contains(where: { $0.city == "FeedbackCity" && $0.country == "FeedbackCountry" }))
        case .failure(_):
            XCTFail("Fetching feedbacks failed.")
        }
    }

    func testLoadCitiesFromJSON() {
        cityViewModel.loadCitiesFromJSON()
        XCTAssertFalse(cityViewModel.cities.isEmpty)
    }

}
