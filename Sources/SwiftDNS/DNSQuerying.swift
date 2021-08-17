//
//  DNSQuerying.swift
//  SwiftDNS
//
//  Copyright © 2021 Charles Augustine.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Combine
import Foundation
import Network

public protocol DNSQuerying {
	func query(host: NWEndpoint.Host, port: NWEndpoint.Port, domain: String, type: DNSType, queue: DispatchQueue, completion: @escaping (DNSRR?, Error?) -> Void)
	func query(host: NWEndpoint.Host, port: NWEndpoint.Port, domain: String, type: DNSType, queue: DispatchQueue) -> AnyPublisher<DNSRR, Error>
}

extension DNSQuerying {
	public func query(domain: String, queue: DispatchQueue, completion: @escaping (DNSRR?, Error?) -> Void) {
		query(host: "8.8.8.8", port: 53, domain: domain, type: .A, queue: queue, completion: completion)
	}

	public func query(host: NWEndpoint.Host, domain: String, queue: DispatchQueue, completion: @escaping (DNSRR?, Error?) -> Void) {
		query(host: host, port: 53, domain: domain, type: .A, queue: queue, completion: completion)
	}

	public func query(port: NWEndpoint.Port, domain: String, queue: DispatchQueue, completion: @escaping (DNSRR?, Error?) -> Void) {
		query(host: "8.8.8.8", port: port, domain: domain, type: .A, queue: queue, completion: completion)
	}

	func query(domain: String, type: DNSType, queue: DispatchQueue, completion: @escaping (DNSRR?, Error?) -> Void) {
		query(host: "8.8.8.8", port: 53, domain: domain, type: type, queue: queue, completion: completion)
	}

	func query(host: NWEndpoint.Host, port: NWEndpoint.Port, domain: String, queue: DispatchQueue, completion: @escaping (DNSRR?, Error?) -> Void) {
		query(host: host, port: port, domain: domain, type: .A, queue: queue, completion: completion)
	}

	func query(host: NWEndpoint.Host, domain: String, type: DNSType, queue: DispatchQueue, completion: @escaping (DNSRR?, Error?) -> Void) {
		query(host: host, port: 53, domain: domain, type: type, queue: queue, completion: completion)
	}

	func query(port: NWEndpoint.Port, domain: String, type: DNSType, queue: DispatchQueue, completion: @escaping (DNSRR?, Error?) -> Void) {
		query(host: "8.8.8.8", port: port, domain: domain, type: type, queue: queue, completion: completion)
	}

	public func query(domain: String, queue: DispatchQueue) -> AnyPublisher<DNSRR, Error> {
		query(host: "8.8.8.8", port: 53, domain: domain, type: .A, queue: queue)
	}

	public func query(host: NWEndpoint.Host, domain: String, queue: DispatchQueue) -> AnyPublisher<DNSRR, Error> {
		query(host: host, port: 53, domain: domain, type: .A, queue: queue)
	}

	public func query(port: NWEndpoint.Port, domain: String, queue: DispatchQueue) -> AnyPublisher<DNSRR, Error> {
		query(host: "8.8.8.8", port: port, domain: domain, type: .A, queue: queue)
	}

	func query(domain: String, type: DNSType, queue: DispatchQueue) -> AnyPublisher<DNSRR, Error> {
		query(host: "8.8.8.8", port: 53, domain: domain, type: type, queue: queue)
	}

	func query(host: NWEndpoint.Host, port: NWEndpoint.Port, domain: String, queue: DispatchQueue) -> AnyPublisher<DNSRR, Error> {
		query(host: host, port: port, domain: domain, type: .A, queue: queue)
	}

	func query(host: NWEndpoint.Host, domain: String, type: DNSType, queue: DispatchQueue) -> AnyPublisher<DNSRR, Error> {
		query(host: host, port: 53, domain: domain, type: type, queue: queue)
	}

	func query(port: NWEndpoint.Port, domain: String, type: DNSType, queue: DispatchQueue) -> AnyPublisher<DNSRR, Error> {
		query(host: "8.8.8.8", port: port, domain: domain, type: type, queue: queue)
	}
}
