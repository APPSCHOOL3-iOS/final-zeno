//
//  CommRepository.swift
//  Zeno
//
//  Created by gnksbm on 2023/10/11.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import Foundation

class CommRepository {
    static let shared = CommRepository()
    private let semaphore = DispatchSemaphore(value: 1)
    
    private var currentUser: User?
    private var allComm: [Community] = []
    private var joinedComm: [Community] = []
    
    enum Action {
        case set(communities: [Community])
        case getAll
        case getjoined
    }
    
    private init() { }
    
    @discardableResult
    func reduce(action: Action) -> [Community]? {
        var result: [Community]?
        semaphore.wait()
        switch action {
        case let .set(allComms):
            setAllComm(allComm)
        case .getAll:
            result = getAllComm()
        case .getjoined:
            result = getJoinedComm()
        }
        semaphore.signal()
        return result
    }
    
    private func setUser(_ object: User?) {
        semaphore.wait()
        currentUser = object
        semaphore.signal()
    }
    
    private func setAllComm(_ objects: [Community]) {
        allComm = objects
        joinedComm = allComm.filter { comm in
            guard let currentUser else { return false }
            return currentUser.commInfoList.contains(where: { $0.id == comm.id })
        }
    }
    
    private func getAllComm() -> [Community] {
        return allComm
    }
    
    private func getJoinedComm() -> [Community] {
        return joinedComm
    }
}
