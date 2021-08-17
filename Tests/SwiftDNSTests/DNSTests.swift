//
//  DNSTests.swift
//  SwiftDNSTests
//
//  Created by Vincent Huang on 2020/6/20.
//  Copyright © 2020 Vincent Huang. All rights reserved.
//


import Combine
import SwiftDNS
import XCTest


class DNSTests: XCTestCase {
	private var cancellables = Set<AnyCancellable>()

	override func tearDown() {
		cancellables.removeAll()
	}

	func testDNSServiceQuery() {
		let exp = expectation(description: "query dns")

		DNSService.query(domain: "vincent178.site", queue: .global(), completion: { (rr, err) in

			XCTAssertNil(err)
			XCTAssertNotNil(rr)

			XCTAssertEqual(rr!.Questions[0].Domain, "vincent178.site")
			XCTAssertEqual(rr!.ANCount, 2)
			XCTAssertEqual(rr!.Answers.map { $0.RData }.sorted(), ["104.21.3.164", "172.67.130.241"].sorted())

			exp.fulfill()
		})

		waitForExpectations(timeout: 3, handler: { error in
			if error != nil {
				XCTFail("waitForExpectations error \(error.debugDescription)")
			}
		})
	}

	func testDNSServiceQueryCombine() {
		let finishedExpectation = expectation(description: "query dns finished")

		DNSService.query(domain: "vincent178.site", queue: .global()).sink { completion in
			if case .finished = completion {
				finishedExpectation.fulfill()
			}
		} receiveValue: { rr in
			XCTAssertEqual(rr.Questions[0].Domain, "vincent178.site")
			XCTAssertEqual(rr.ANCount, 2)
			XCTAssertEqual(rr.Answers.map { $0.RData }.sorted(), ["104.21.3.164", "172.67.130.241"].sorted())
		}.store(in: &cancellables)

		waitForExpectations(timeout: 3, handler: { error in
			if error != nil {
				XCTFail("waitForExpectations error \(error.debugDescription)")
			}
		})
	}

	func testDNSServiceQueryWithType() {
		let exp = expectation(description: "query dns")

		DNSService.query(domain: "goat.disco.goateng.com", type: .TXT, queue: .global(), completion: { (rr, err) in

			XCTAssertNil(err)
			XCTAssertNotNil(rr)

			XCTAssertEqual(rr!.Questions[0].Domain, "goat.disco.goateng.com")
			XCTAssertEqual(rr!.ANCount, 1)
			XCTAssertEqual(rr!.Answers[0].RData, "api=www.goat.com images=image.goat.com cms=cmd-cdn.goat.com")

			exp.fulfill()
		})

		waitForExpectations(timeout: 3, handler: { error in
			if error != nil {
				XCTFail("waitForExpectations error \(error.debugDescription)")
			}
		})
	}

	func testDNSServiceQueryWithTypeCombine() {
		let finishedExpectation = expectation(description: "query dns finished")

		DNSService.query(domain: "goat.disco.goateng.com", type: .TXT, queue: .global()).sink { completion in
			if case .finished = completion {
				finishedExpectation.fulfill()
			}
		} receiveValue: { rr in
			XCTAssertEqual(rr.Questions[0].Domain, "goat.disco.goateng.com")
			XCTAssertEqual(rr.ANCount, 1)
			XCTAssertEqual(rr.Answers[0].RData, "api=www.goat.com images=image.goat.com cms=cmd-cdn.goat.com")
		}.store(in: &cancellables)

		waitForExpectations(timeout: 3, handler: { error in
			if error != nil {
				XCTFail("waitForExpectations error \(error.debugDescription)")
			}
		})
	}

	func testCustomNameServer() {
		let exp = expectation(description: "query dns")

		DNSService.query(host: "ns-926.awsdns-51.net", domain: "api.disco.goateng.com", queue: .global(), completion: { (rr, err) in
			XCTAssertNil(err)
			XCTAssertNotNil(rr)

			XCTAssertEqual(rr!.Questions[0].Domain, "api.disco.goateng.com")
			XCTAssertEqual(rr!.ANCount, 1)
			XCTAssertTrue(["www.goat.com", "www.goatchina.cn"].contains(rr!.Answers[0].RData))

			exp.fulfill()
		})

		waitForExpectations(timeout: 3, handler: { error in
			if error != nil {
				XCTFail("waitForExpectations error \(error.debugDescription)")
			}
		})
	}

	func testCustomNameServerCombine() {
		let finishedExpectation = expectation(description: "query dns finished")

		DNSService.query(host: "ns-926.awsdns-51.net", domain: "api.disco.goateng.com", queue: .global()).sink { completion in
			if case .finished = completion {
				finishedExpectation.fulfill()
			}
		} receiveValue: { rr in
			XCTAssertEqual(rr.Questions[0].Domain, "api.disco.goateng.com")
			XCTAssertEqual(rr.ANCount, 1)
			XCTAssertTrue(["www.goat.com", "www.goatchina.cn"].contains(rr.Answers[0].RData))
		}.store(in: &cancellables)

		waitForExpectations(timeout: 3, handler: { error in
			if error != nil {
				XCTFail("waitForExpectations error \(error.debugDescription)")
			}
		})
	}

	func testMutipleQuery() {
		let exp = expectation(description: "query dns")

		DNSService.query(domain: "vincent178.site", queue: .global(), completion: { (rr, err) in
			XCTAssertNil(err)
			XCTAssertNotNil(rr)

			XCTAssertEqual(rr!.Questions[0].Domain, "vincent178.site")
			XCTAssertEqual(rr!.ANCount, 2)
			XCTAssertEqual(rr!.Answers.map { $0.RData }.sorted(), ["104.21.3.164", "172.67.130.241"].sorted())
		})

		DNSService.query(domain: "goat.com", queue: .global(), completion: { (rr, err) in
			XCTAssertNil(err)
			XCTAssertNotNil(rr)

			XCTAssertEqual(rr!.Questions[0].Domain, "goat.com")
			XCTAssertEqual(rr!.ANCount, 2)
			XCTAssertEqual(rr!.Answers.map { $0.RData }.sorted(), ["104.18.24.81", "104.18.25.81"].sorted())

			exp.fulfill()
		})

		waitForExpectations(timeout: 3, handler: { error in
			if error != nil {
				XCTFail("waitForExpectations error \(error.debugDescription)")
			}
		})
	}

	func testMutipleQueryCombine() {
		let finishedExpectation = expectation(description: "query dns finished")

		let queryOne = DNSService.query(domain: "vincent178.site", queue: .global())
		let queryTwo = DNSService.query(domain: "goat.com", queue: .global())
		queryOne.zip(queryTwo).sink { completion in
			if case .finished = completion {
				finishedExpectation.fulfill()
			}
		} receiveValue: { (queryOneValue, queryTwoValue) in
			XCTAssertEqual(queryOneValue.Questions[0].Domain, "vincent178.site")
			XCTAssertEqual(queryOneValue.ANCount, 2)
			XCTAssertEqual(queryOneValue.Answers.map { $0.RData }.sorted(), ["104.21.3.164", "172.67.130.241"].sorted())

			XCTAssertEqual(queryTwoValue.Questions[0].Domain, "goat.com")
			XCTAssertEqual(queryTwoValue.ANCount, 2)
			XCTAssertEqual(queryTwoValue.Answers.map { $0.RData }.sorted(), ["104.18.24.81", "104.18.25.81"].sorted())
		}.store(in: &cancellables)

		waitForExpectations(timeout: 3, handler: { error in
			if error != nil {
				XCTFail("waitForExpectations error \(error.debugDescription)")
			}
		})
	}
}
