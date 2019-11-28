//
//  MessageBroker.swift
//  gps4camera
//
//  Created by Astro on 11/23/19.
//  Copyright © 2019 RSB. All rights reserved.
//

import UIKit

// Pub/Sub pattern using a singleton
// From: http://everythingel.se/blog/publish-subscribe-in-swift/

private let _messageBroker = MessageBroker()
typealias MessageKey = String

// Protocols

protocol Message { func messageKey() -> MessageKey }
protocol Subscriber { func receive(_ message: Message) }

class MessageBroker: NSObject {

	class var sharedMessageBroker: MessageBroker {
		return _messageBroker
	}
	
	fileprivate var subscribers = Dictionary<MessageKey, Array<Weak<AnyObject>>>()
	
	func unsubscribe(_ subscriber: Subscriber, messageKey: MessageKey) {
		guard var messageSubscribers = subscribers[messageKey] else {
			return
		}
		
		let item = subscriber as AnyObject
        if let index = messageSubscribers.firstIndex(where: { $0.value === item }) {
			messageSubscribers.remove(at: index)
		}
	}
	
	func subscribe(_ subscriber: Subscriber, messageKey: MessageKey) {
		if subscribers[messageKey] == nil {
			subscribers[messageKey] = []
		}
		
		subscribers[messageKey]!.append(Weak(value: subscriber as AnyObject))
	}
	
	func publish(_ message: Message) {
		if let subscribers = subscribers[message.messageKey()] {
			for subscriber in subscribers {
				if subscriber.value != nil {
					(subscriber.value as! Subscriber).receive(message)
				}
			}
		}
		
		
	}
}

// from: http://stackoverflow.com/questions/24127587/how-do-i-declare-an-array-of-weak-references-in-swift
class Weak<T: AnyObject> {
	weak var value : T?
	init (value: T) {
		self.value = value
	}
}
