//
//  HomeWorker.swift
//  iOSBase-SwiftUI
//
//  Created by NamNH on 15/02/2022.
//

import UIKit
import Combine
import Common

protocol IHomeWorker {
	var remoteStore: IHomeRemoteStore { get }
	var inMemoryStore: IHomeInMemoryStore { get }
	
	func getSamples(samples: LoadableSubject<[ISampleModel]>)
}

struct HomeWorker {
	let remoteStore: IHomeRemoteStore
	let inMemoryStore: IHomeInMemoryStore
	
	init(remoteStore: IHomeRemoteStore, inMemoryStore: IHomeInMemoryStore) {
		self.remoteStore = remoteStore
		self.inMemoryStore = inMemoryStore
	}
}

extension HomeWorker: IHomeWorker {
	func getSamples(samples: LoadableSubject<[ISampleModel]>) {
		let cancelBag = CancelBag()
		samples.wrappedValue.setIsLoading(cancelBag: cancelBag)
		
		Just<Void>
			.withErrorType(Error.self)
			.flatMap {
				return Deferred {
					Future<[ISampleModel], Error> { promise in
						self.remoteStore.getSamples(completion: { result in
							switch result {
							case .success(let sampleDatas):
								promise(.success(sampleDatas))
							case .failure(let error):
								promise(.failure(error))
							}
						})
					}
				}
				.eraseToAnyPublisher()
			}
			.sinkToLoadable { samples.wrappedValue = $0 }
			.store(in: cancelBag)
	}
}

extension Just where Output == Void {
	static func withErrorType<E>(_ errorType: E.Type) -> AnyPublisher<Void, E> {
		return withErrorType((), E.self)
	}
}

extension Just {
	static func withErrorType<E>(_ value: Output, _ errorType: E.Type
	) -> AnyPublisher<Output, E> {
		return Just(value)
			.setFailureType(to: E.self)
			.eraseToAnyPublisher()
	}
}

extension Publisher {
	func sinkToResult(_ result: @escaping (Result<Output, Failure>) -> Void) -> AnyCancellable {
		return sink(receiveCompletion: { completion in
			switch completion {
			case let .failure(error):
				result(.failure(error))
			default: break
			}
		}, receiveValue: { value in
			result(.success(value))
		})
	}
	
	func sinkToLoadable(_ completion: @escaping (Loadable<Output>) -> Void) -> AnyCancellable {
		return sink(receiveCompletion: { subscriptionCompletion in
			if let error = subscriptionCompletion.error {
				completion(.failed(error))
			}
		}, receiveValue: { value in
			completion(.loaded(value))
		})
	}
	
	func extractUnderlyingError() -> Publishers.MapError<Self, Failure> {
		mapError {
			($0.underlyingError as? Failure) ?? $0
		}
	}
	
	/// Holds the downstream delivery of output until the specified time interval passed after the subscription
	/// Does not hold the output if it arrives later than the time threshold
	///
	/// - Parameters:
	///   - interval: The minimum time interval that should elapse after the subscription.
	/// - Returns: A publisher that optionally delays delivery of elements to the downstream receiver.
	
	func ensureTimeSpan(_ interval: TimeInterval) -> AnyPublisher<Output, Failure> {
		let timer = Just<Void>(())
			.delay(for: .seconds(interval), scheduler: RunLoop.main)
			.setFailureType(to: Failure.self)
		return zip(timer)
			.map { $0.0 }
			.eraseToAnyPublisher()
	}
}

private extension Error {
	var underlyingError: Error? {
		let nsError = self as NSError
		if nsError.domain == NSURLErrorDomain && nsError.code == -1009 {
			// "The Internet connection appears to be offline."
			return self
		}
		return nsError.userInfo[NSUnderlyingErrorKey] as? Error
	}
}

extension Subscribers.Completion {
	var error: Failure? {
		switch self {
		case let .failure(error): return error
		default: return nil
		}
	}
}
