import XCTest
import PerfectHTTP
import PerfectNet
@testable import PerfectMustache

class ShimHTTPRequest: HTTPRequest {
	var method = HTTPMethod.get
	var path = "/"
	var queryParams = [(String, String)]()
	var protocolVersion = (1, 1)
	var remoteAddress = (host: "127.0.0.1", port: 8000 as UInt16)
	var serverAddress = (host: "127.0.0.1", port: 8282 as UInt16)
	var serverName = "my_server"
	var documentRoot = "./webroot"
	var connection = NetTCP()
	var urlVariables = [String:String]()
	func header(_ named: HTTPRequestHeader.Name) -> String? { return nil }
	func addHeader(_ named: HTTPRequestHeader.Name, value: String) {}
	func setHeader(_ named: HTTPRequestHeader.Name, value: String) {}
	var headers = AnyIterator<(HTTPRequestHeader.Name, String)> { return nil }
	var postParams = [(String, String)]()
	var postBodyBytes: [UInt8]? = nil
	var postBodyString: String? = nil
	var postFileUploads: [MimeReader.BodySpec]? = nil
}

class ShimHTTPResponse: HTTPResponse {
	var request: HTTPRequest = ShimHTTPRequest()
	var status: HTTPResponseStatus = .ok
	var isStreaming = false
	var bodyBytes = [UInt8]()
	func header(_ named: HTTPResponseHeader.Name) -> String? { return nil }
	func addHeader(_ named: HTTPResponseHeader.Name, value: String) {}
	func setHeader(_ named: HTTPResponseHeader.Name, value: String) {}
	var headers = AnyIterator<(HTTPResponseHeader.Name, String)> { return nil }
	func addCookie(_: PerfectHTTP.HTTPCookie) {}
	func appendBody(bytes: [UInt8]) {}
	func appendBody(string: String) {}
	func setBody(json: [String:Any]) throws {}
	func push(callback: (Bool) -> ()) {}
	func completed() {}
}

class PerfectMustacheTests: XCTestCase {
	
	func testMustacheParser1() {
		let usingTemplate = "TOP {\n{{#name}}\n{{name}}{{/name}}\n}\nBOTTOM"
		do {
			let template = try MustacheParser().parse(string: usingTemplate)
			let d = ["name":"The name"] as [String:Any]
			
			let response = ShimHTTPResponse()
			
			let context = MustacheWebEvaluationContext(webResponse: response, map: d)
			let collector = MustacheEvaluationOutputCollector()
			template.evaluate(context: context, collector: collector)
			
			XCTAssertEqual(collector.asString(), "TOP {\n\nThe name\n}\nBOTTOM")
		} catch {
			XCTAssert(false)
		}
	}
	
	func testMustacheLambda1() {
		let usingTemplate = "TOP {\n{{#name}}\n{{name}}{{/name}}\n}\nBOTTOM"
		do {
			let nameVal = "Me!"
			let template = try MustacheParser().parse(string: usingTemplate)
			let d = ["name":{ (tag:String, context:MustacheEvaluationContext) -> String in return nameVal }] as [String:Any]
			
			let response = ShimHTTPResponse()
			
			let context = MustacheWebEvaluationContext(webResponse: response, map: d)
			let collector = MustacheEvaluationOutputCollector()
			template.evaluate(context: context, collector: collector)
			
			let result = collector.asString()
			XCTAssertEqual(result, "TOP {\n\n\(nameVal)\n}\nBOTTOM")
		} catch {
			XCTAssert(false)
		}
	}
	
	func testMustacheParser2() {
		let usingTemplate = "TOP {\n{{#name}}\n{{name}}{{/name}}\n}\nBOTTOM"
		do {
			let template = try MustacheParser().parse(string: usingTemplate)
			let d = ["name":"The name"] as [String:Any]
			
			let context = MustacheEvaluationContext(map: d)
			let collector = MustacheEvaluationOutputCollector()
			template.evaluate(context: context, collector: collector)
			
			XCTAssertEqual(collector.asString(), "TOP {\n\nThe name\n}\nBOTTOM")
		} catch {
			XCTAssert(false)
		}
	}
	
	func testMustacheLambda2() {
		let usingTemplate = "TOP {\n{{#name}}\n{{name}}{{/name}}\n}\nBOTTOM"
		do {
			let nameVal = "Me!"
			let template = try MustacheParser().parse(string: usingTemplate)
			let d = ["name":{ (tag:String, context:MustacheEvaluationContext) -> String in return nameVal }] as [String:Any]
			
			let context = MustacheEvaluationContext(map: d)
			let collector = MustacheEvaluationOutputCollector()
			template.evaluate(context: context, collector: collector)
			
			let result = collector.asString()
			XCTAssertEqual(result, "TOP {\n\n\(nameVal)\n}\nBOTTOM")
		} catch {
			XCTAssert(false)
		}
	}

    static var allTests : [(String, (PerfectMustacheTests) -> () throws -> Void)] {
		return [
			("testMustacheParser1", testMustacheParser1),
			("testMustacheLambda1", testMustacheLambda1),
			("testMustacheParser2", testMustacheParser2),
			("testMustacheLambda2", testMustacheLambda2)
        ]
    }
}
