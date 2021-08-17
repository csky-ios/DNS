//
//  DNS.swift
//  SwiftDNS
//
//  Created by Vincent Huang on 2020/6/20.
//  Copyright © 2020 Vincent Huang. All rights reserved.
//

import Combine
import Foundation
import Network

enum DNSServiceError: Error {
    case connectionNotReady
    case responseNotComplete
	case unknownError
}

// https://developer.apple.com/documentation/network
@available(macOS 10.15, *)
@available(iOS 12, *)
public class DNSService {
    public static func query(host: NWEndpoint.Host = "8.8.8.8", port: NWEndpoint.Port = 53, domain: String, type: DNSType = .A, queue: DispatchQueue, completion: @escaping (DNSRR?, Error?) -> Void) {
        let connection = NWConnection(host: host, port: port, using: .udp)
        
        connection.stateUpdateHandler = { newState in
            switch newState {
            case .ready:
                let q: DNSQuestion = DNSQuestion(Domain: domain, Typ: type.rawValue, Class: 0x1)
                let query: DNSRR = DNSRR(ID: 0xAAAA, RD: true, Questions: [q])
                connection.send(content: query.serialize(), completion: NWConnection.SendCompletion.contentProcessed { error in
                    if error != nil {
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
                print("cancelled")
            case .setup:
                print("setup")
            case .preparing:
                print("preparing")
            default:
                print("waiting")
            }
        }
        
        connection.start(queue: queue)
    }

	@available(iOS 13, *)
	public static func query(host: NWEndpoint.Host = "8.8.8.8", port: NWEndpoint.Port = 53, domain: String, type: DNSType = .A, queue: DispatchQueue) -> AnyPublisher<DNSRR, Error> {
		return Future<DNSRR, Error> { promise in
			query(host: host, port: port, domain: domain, type: type, queue: queue) { dnsrr, error in
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
}
