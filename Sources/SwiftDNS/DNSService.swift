//
//  DNSService.swift
//  SwiftDNS
//
//  Copyright (c) 2020 git <vh7157@gmail.com>
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

// https://developer.apple.com/documentation/network
@available(macOS 10.15, *)
@available(iOS 12, *)
public class DNSService: DNSQuerying {
    public func query(host: NWEndpoint.Host = "8.8.8.8", port: NWEndpoint.Port = 53, domain: String, type: DNSType = .A, queue: DispatchQueue, completion: @escaping (DNSRR?, Error?) -> Void) {
        let connection = NWConnection(host: host, port: port, using: .udp)
        
        connection.stateUpdateHandler = { newState in
            switch newState {
            case .ready:
                let q: DNSQuestion = DNSQuestion(Domain: domain, Typ: type.rawValue, Class: 0x1)
                let query: DNSRR = DNSRR(ID: 0xAAAA, RD: true, Questions: [q])
                connection.send(content: query.serialize(), completion: NWConnection.SendCompletion.contentProcessed { error in
					if let error = error {
						connection.stateUpdateHandler = nil
						connection.cancel()
						completion(nil, error)
					}
                })
                
                connection.receiveMessage { (data, context, isComplete, error) in
					guard error == nil else {
						connection.stateUpdateHandler = nil
						connection.cancel()
						completion(nil, error)
						return
					}

					guard isComplete else {
						connection.stateUpdateHandler = nil
						connection.cancel()
						// TODO: handle not complete response
						completion(nil, DNSServiceError.responseNotComplete)
						return
					}

                    let rr = DNSRR.deserialize(data: [UInt8](data!))
                    connection.stateUpdateHandler = nil
                    connection.cancel()
                    completion(rr, nil)
                }
			case .cancelled:
				connection.stateUpdateHandler = nil
				connection.cancel()
				completion(nil, DNSServiceError.connectionCancelled)
			case .failed(let error):
				connection.stateUpdateHandler = nil
				connection.cancel()
				completion(nil, error)
			default:
				break // Nothing to do
            }
        }
        connection.start(queue: queue)
    }

	@available(iOS 13, *)
	public func query(host: NWEndpoint.Host = "8.8.8.8", port: NWEndpoint.Port = 53, domain: String, type: DNSType = .A, queue: DispatchQueue) -> AnyPublisher<DNSRR, Error> {
		return Future<DNSRR, Error> { promise in
			self.query(host: host, port: port, domain: domain, type: type, queue: queue) { dnsrr, error in
				switch (dnsrr, error) {
				case (let dnsrr?, _):
					promise(.success(dnsrr))
				case (_, let error?):
					promise(.failure(error))
				default:
					promise(.failure(DNSServiceError.unknownError))
				}
			}
		}.eraseToAnyPublisher()
	}

	public init() {
		// Intentionally left blank
	}
}
